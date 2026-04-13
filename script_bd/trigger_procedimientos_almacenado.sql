-----------------------------------------------------------
-------------------------------------------------------------------------------------------------------
------------PROCEDIMIENTOS ALMACENADOS  DE INSERTAR, CONSULTAR, ACTUALIZAR, BORRAR Y LISTAR DE LA TABLA PROGRAMA ----------------------------
--------------------------------------------------------------------------
---------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_insertar_programa_completo
    -- Parámetros del Maestro (Programa)
    @p_nombre NVARCHAR(60),
    @p_tipo NVARCHAR(45),
    @p_nivel NVARCHAR(45),
    @p_fecha_creacion NVARCHAR(45),
    @p_fecha_cierre NVARCHAR(45) = NULL,
    @p_numero_cohortes NVARCHAR(45),
    @p_cant_graduados NVARCHAR(45),
    @p_fecha_actualizacion NVARCHAR(45),
    @p_ciudad NVARCHAR(45),
    @p_facultad INT,
    
    -- Parámetros de los Detalles (JSON Strings)
    @p_premios NVARCHAR(MAX) = NULL,   
    @p_pasantias NVARCHAR(MAX) = NULL, 
    
    -- Parámetro de Salida para que la API lo lea
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        -- Iniciamos una Transacción: Si algo falla, se cancela TODO (no quedan datos a medias)
        BEGIN TRANSACTION;

        -- 1. Calcular el nuevo ID para el Programa (ya que no es IDENTITY)
        DECLARE @nuevo_id_programa INT;
        SELECT @nuevo_id_programa = ISNULL(MAX(id), 0) + 1 FROM programa;

        -- 2. Insertar el Programa (El Maestro)
        INSERT INTO programa (id, nombre, tipo, nivel, fecha_creacion, fecha_cierre, numero_cohortes, cant_graduados, fecha_actualizacion, ciudad, facultad)
        VALUES (@nuevo_id_programa, @p_nombre, @p_tipo, @p_nivel, @p_fecha_creacion, @p_fecha_cierre, @p_numero_cohortes, @p_cant_graduados, @p_fecha_actualizacion, @p_ciudad, @p_facultad);

        -- 3. Insertar Premios (Detalle 1) leyendo el JSON
        IF @p_premios IS NOT NULL AND ISJSON(@p_premios) > 0
        BEGIN
            DECLARE @max_id_premio INT;
            SELECT @max_id_premio = ISNULL(MAX(id), 0) FROM premio;

            INSERT INTO premio (id, nombre, descripcion, fecha, entidad_otorgante, pais, programa)
            SELECT 
                -- Calculamos un ID secuencial para cada premio que venga en el JSON
                @max_id_premio + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),
                nombre, 
                descripcion, 
                fecha, 
                entidad_otorgante, 
                pais, 
                @nuevo_id_programa -- Le amarramos el ID del programa recién creado
            FROM OPENJSON(@p_premios)
            WITH (
                nombre NVARCHAR(45) '$.nombre',
                descripcion NVARCHAR(45) '$.descripcion',
                fecha DATE '$.fecha',
                entidad_otorgante NVARCHAR(45) '$.entidad_otorgante',
                pais NVARCHAR(45) '$.pais'
            );
        END

        -- 4. Insertar Pasantías (Detalle 2) leyendo el JSON
        IF @p_pasantias IS NOT NULL AND ISJSON(@p_pasantias) > 0
        BEGIN
            DECLARE @max_id_pasantia INT;
            SELECT @max_id_pasantia = ISNULL(MAX(id), 0) FROM pasantia;

            INSERT INTO pasantia (id, nombre, pais, empresa, descripcion, programa)
            SELECT 
                @max_id_pasantia + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),
                nombre, 
                pais, 
                empresa, 
                descripcion, 
                @nuevo_id_programa -- Le amarramos el ID del programa recién creado
            FROM OPENJSON(@p_pasantias)
            WITH (
                nombre NVARCHAR(45) '$.nombre',
                pais NVARCHAR(45) '$.pais',
                empresa NVARCHAR(45) '$.empresa',
                descripcion NVARCHAR(45) '$.descripcion'
            );
        END

        -- Si todo salió bien, confirmamos la transacción
        COMMIT TRANSACTION;

        -- 5. Armamos un JSON de respuesta para enviárselo a Blazor
        SET @p_resultado = (
            SELECT 
                mensaje = 'Programa creado exitosamente con todos sus detalles',
                programa_id = @nuevo_id_programa
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

    END TRY
    BEGIN CATCH
        -- Si hay algún error (ej. se cayó el internet o falta un dato), se deshace TODO
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Le devolvemos el error a C# para que lo muestre en pantalla
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO


---------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_consultar_programa_completo
    @p_numero INT, -- Recibe el ID del programa a buscar
    @p_resultado NVARCHAR(MAX) OUTPUT -- Devuelve el JSON armado
AS
BEGIN
    BEGIN TRY
        -- 1. Validar que el programa exista
        IF NOT EXISTS (SELECT 1 FROM programa WHERE id = @p_numero)
        BEGIN
            RAISERROR('El programa especificado no existe.', 16, 1);
            RETURN;
        END

        -- 2. Armar el JSON anidado (Maestro + Detalles)
        -- Usamos FOR JSON PATH para que SQL Server convierta las tablas a texto JSON automáticamente
        SET @p_resultado = (
            SELECT 
                -- Maestro (Como es un solo registro, le quitamos los corchetes de arreglo)
                programa = JSON_QUERY((
                    SELECT id, nombre, tipo, nivel, fecha_creacion, fecha_cierre, 
                           numero_cohortes, cant_graduados, fecha_actualizacion, ciudad, facultad 
                    FROM programa 
                    WHERE id = @p_numero 
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                )),
                
                -- Detalle 1: Premios (Devuelve un arreglo JSON)
                premios = ISNULL(JSON_QUERY((
                    SELECT id, nombre, descripcion, fecha, entidad_otorgante, pais 
                    FROM premio 
                    WHERE programa = @p_numero 
                    FOR JSON PATH
                )), '[]'), -- Si no hay premios, devuelve un arreglo vacío '[]'
                
                -- Detalle 2: Pasantías (Devuelve un arreglo JSON)
                pasantias = ISNULL(JSON_QUERY((
                    SELECT id, nombre, pais, empresa, descripcion 
                    FROM pasantia 
                    WHERE programa = @p_numero 
                    FOR JSON PATH
                )), '[]') -- Si no hay pasantías, devuelve un arreglo vacío '[]'
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-----------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_actualizar_programa_completo
    @p_numero INT, -- El ID del programa a editar
    @p_nombre NVARCHAR(60),
    @p_tipo NVARCHAR(45),
    @p_nivel NVARCHAR(45),
    @p_fecha_creacion NVARCHAR(45),
    @p_fecha_cierre NVARCHAR(45) = NULL,
    @p_numero_cohortes NVARCHAR(45),
    @p_cant_graduados NVARCHAR(45),
    @p_fecha_actualizacion NVARCHAR(45),
    @p_ciudad NVARCHAR(45),
    @p_facultad INT,
    @p_premios NVARCHAR(MAX) = NULL,
    @p_pasantias NVARCHAR(MAX) = NULL,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM programa WHERE id = @p_numero)
        BEGIN
            RAISERROR('El programa a actualizar no existe.', 16, 1);
            RETURN;
        END

        -- 1. Actualizar datos del Maestro (Programa)
        UPDATE programa
        SET nombre = @p_nombre, tipo = @p_tipo, nivel = @p_nivel, fecha_creacion = @p_fecha_creacion, 
            fecha_cierre = @p_fecha_cierre, numero_cohortes = @p_numero_cohortes, cant_graduados = @p_cant_graduados, 
            fecha_actualizacion = @p_fecha_actualizacion, ciudad = @p_ciudad, facultad = @p_facultad
        WHERE id = @p_numero;

        -- 2. Limpiar detalles antiguos
        DELETE FROM premio WHERE programa = @p_numero;
        DELETE FROM pasantia WHERE programa = @p_numero;

        -- 3. Insertar los nuevos Premios
        IF @p_premios IS NOT NULL AND ISJSON(@p_premios) > 0
        BEGIN
            DECLARE @max_id_premio INT;
            SELECT @max_id_premio = ISNULL(MAX(id), 0) FROM premio;

            INSERT INTO premio (id, nombre, descripcion, fecha, entidad_otorgante, pais, programa)
            SELECT 
                @max_id_premio + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),
                nombre, descripcion, fecha, entidad_otorgante, pais, @p_numero
            FROM OPENJSON(@p_premios)
            WITH (nombre NVARCHAR(45) '$.nombre', descripcion NVARCHAR(45) '$.descripcion', fecha DATE '$.fecha', entidad_otorgante NVARCHAR(45) '$.entidad_otorgante', pais NVARCHAR(45) '$.pais');
        END

        -- 4. Insertar las nuevas Pasantías
        IF @p_pasantias IS NOT NULL AND ISJSON(@p_pasantias) > 0
        BEGIN
            DECLARE @max_id_pasantia INT;
            SELECT @max_id_pasantia = ISNULL(MAX(id), 0) FROM pasantia;

            INSERT INTO pasantia (id, nombre, pais, empresa, descripcion, programa)
            SELECT 
                @max_id_pasantia + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),
                nombre, pais, empresa, descripcion, @p_numero
            FROM OPENJSON(@p_pasantias)
            WITH (nombre NVARCHAR(45) '$.nombre', pais NVARCHAR(45) '$.pais', empresa NVARCHAR(45) '$.empresa', descripcion NVARCHAR(45) '$.descripcion');
        END

        COMMIT TRANSACTION;

        SET @p_resultado = (SELECT mensaje = 'Programa actualizado exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_borrar_programa_completo
    @p_numero INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM programa WHERE id = @p_numero)
        BEGIN
            RAISERROR('El programa no existe.', 16, 1);
            RETURN;
        END

        -- Borrar primero a los hijos para evitar errores de Foreign Key
        DELETE FROM premio WHERE programa = @p_numero;
        DELETE FROM pasantia WHERE programa = @p_numero;
        
        -- Ahora sí podemos borrar al padre
        DELETE FROM programa WHERE id = @p_numero;

        COMMIT TRANSACTION;

        SET @p_resultado = (SELECT mensaje = 'Programa y sus detalles eliminados exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
----------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_listar_programas_completos
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        SET @p_resultado = (
            SELECT 
                id, nombre, tipo, nivel, fecha_creacion, fecha_cierre, 
                numero_cohortes, cant_graduados, fecha_actualizacion, ciudad, facultad,
                
                -- Anidamos los premios (usamos JSON_QUERY para que no lo devuelva como texto escapado)
                premios = JSON_QUERY(ISNULL((
                    SELECT id, nombre, descripcion, fecha, entidad_otorgante, pais 
                    FROM premio 
                    WHERE programa = p.id 
                    FOR JSON PATH
                ), '[]')),
                
                -- Anidamos las pasantías
                pasantias = JSON_QUERY(ISNULL((
                    SELECT id, nombre, pais, empresa, descripcion 
                    FROM pasantia 
                    WHERE programa = p.id 
                    FOR JSON PATH
                ), '[]'))
            FROM programa p
            FOR JSON PATH
        );
        
        -- Si la tabla está vacía, evitamos devolver un NULL y mandamos un arreglo vacío
        IF @p_resultado IS NULL
            SET @p_resultado = '[]';

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
------------------------
------------------------ALIANZA INSERTAR, ACTUALIZAR , BORRAR  --------------
-- 1. INSERTAR ALIANZA
CREATE OR ALTER PROCEDURE sp_insertar_alianza
    @p_aliado BIGINT,
    @p_departamento INT,
    @p_fecha_inicio DATE,
    @p_fecha_fin DATE = NULL,
    @p_docente INT = NULL,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        INSERT INTO alianza (aliado, departamento, fecha_inicio, fecha_fin, docente)
        VALUES (@p_aliado, @p_departamento, @p_fecha_inicio, @p_fecha_fin, @p_docente);
        
        SET @p_resultado = (SELECT mensaje = 'Alianza creada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- 2. ACTUALIZAR ALIANZA
CREATE OR ALTER PROCEDURE sp_actualizar_alianza
    @p_aliado BIGINT,
    @p_departamento INT,
    @p_fecha_inicio DATE,
    @p_fecha_fin DATE = NULL,
    @p_docente INT = NULL,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        UPDATE alianza
        SET fecha_inicio = @p_fecha_inicio, 
            fecha_fin = @p_fecha_fin, 
            docente = @p_docente
        WHERE aliado = @p_aliado AND departamento = @p_departamento;

        SET @p_resultado = (SELECT mensaje = 'Alianza actualizada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- 3. BORRAR ALIANZA
CREATE OR ALTER PROCEDURE sp_borrar_alianza
    @p_aliado BIGINT,
    @p_departamento INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        DELETE FROM alianza 
        WHERE aliado = @p_aliado AND departamento = @p_departamento;

        SET @p_resultado = (SELECT mensaje = 'Alianza eliminada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO