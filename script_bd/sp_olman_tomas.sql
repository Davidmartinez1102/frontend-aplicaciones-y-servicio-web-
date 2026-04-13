-- ============================================================
-- STORED PROCEDURES: OLMAN + TOMÁS
-- Módulo: Núcleo Académico + Configuración Programa
-- ============================================================

-- ============================================================
-- OLMAN - TABLA: enfoque_rc (PK compuesta, solo INSERT/DELETE)
-- ============================================================

CREATE OR ALTER PROCEDURE sp_borrar_enfoque_rc
    @p_enfoque INT,
    @p_registro_calificado INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        DELETE FROM enfoque_rc
        WHERE enfoque = @p_enfoque AND registro_calificado = @p_registro_calificado;

        SET @p_resultado = (SELECT mensaje = 'Relación Enfoque-RC eliminada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- ============================================================
-- OLMAN - TABLA: aa_rc (PK compuesta + campos componente/semestre)
-- INSERT, UPDATE, DELETE
-- ============================================================

CREATE OR ALTER PROCEDURE sp_insertar_aa_rc
    @p_activ INT,
    @p_rc INT,
    @p_componente NVARCHAR(45),
    @p_semestre NVARCHAR(45),
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        INSERT INTO aa_rc (activ_academicas_idcurso, registro_calificado_codigo, componente, semestre)
        VALUES (@p_activ, @p_rc, @p_componente, @p_semestre);

        SET @p_resultado = (SELECT mensaje = 'Relación AA-RC creada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_actualizar_aa_rc
    @p_activ INT,
    @p_rc INT,
    @p_componente NVARCHAR(45),
    @p_semestre NVARCHAR(45),
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        UPDATE aa_rc
        SET componente = @p_componente,
            semestre = @p_semestre
        WHERE activ_academicas_idcurso = @p_activ AND registro_calificado_codigo = @p_rc;

        SET @p_resultado = (SELECT mensaje = 'Relación AA-RC actualizada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_borrar_aa_rc
    @p_activ INT,
    @p_rc INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        DELETE FROM aa_rc
        WHERE activ_academicas_idcurso = @p_activ AND registro_calificado_codigo = @p_rc;

        SET @p_resultado = (SELECT mensaje = 'Relación AA-RC eliminada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- ============================================================
-- TOMÁS - TABLA: programa_ci (PK compuesta, solo INSERT/DELETE)
-- ============================================================

CREATE OR ALTER PROCEDURE sp_borrar_programa_ci
    @p_programa INT,
    @p_car_innovacion INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        DELETE FROM programa_ci
        WHERE programa = @p_programa AND car_innovacion = @p_car_innovacion;

        SET @p_resultado = (SELECT mensaje = 'Relación Programa-CI eliminada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- ============================================================
-- TOMÁS - TABLA: programa_pe (PK compuesta, solo INSERT/DELETE)
-- ============================================================

CREATE OR ALTER PROCEDURE sp_borrar_programa_pe
    @p_programa INT,
    @p_practica_estrategia INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        DELETE FROM programa_pe
        WHERE programa = @p_programa AND practica_estrategia = @p_practica_estrategia;

        SET @p_resultado = (SELECT mensaje = 'Relación Programa-PE eliminada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- ============================================================
-- TOMÁS - TABLA: an_programa (PK compuesta, solo INSERT/DELETE)
-- ============================================================

CREATE OR ALTER PROCEDURE sp_borrar_an_programa
    @p_aspecto_normativo INT,
    @p_programa INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        DELETE FROM an_programa
        WHERE aspecto_normativo = @p_aspecto_normativo AND programa = @p_programa;

        SET @p_resultado = (SELECT mensaje = 'Relación AN-Programa eliminada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- ============================================================
-- TOMÁS - TABLA: programa_ac (PK compuesta, solo INSERT/DELETE)
-- ============================================================

CREATE OR ALTER PROCEDURE sp_borrar_programa_ac
    @p_programa INT,
    @p_area_conocimiento INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        DELETE FROM programa_ac
        WHERE programa = @p_programa AND area_conocimiento = @p_area_conocimiento;

        SET @p_resultado = (SELECT mensaje = 'Relación Programa-AC eliminada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- ============================================================
-- TOMÁS - TABLA: docente_departamento (PK compuesta + campos extra)
-- INSERT, UPDATE, DELETE
-- ============================================================

CREATE OR ALTER PROCEDURE sp_insertar_docente_departamento
    @p_docente INT,
    @p_departamento INT,
    @p_dedicacion NVARCHAR(15),
    @p_modalidad NVARCHAR(45),
    @p_fecha_ingreso DATE,
    @p_fecha_salida DATE = NULL,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        INSERT INTO docente_departamento (docente, departamento, dedicacion, modalidad, fecha_ingreso, fecha_salida)
        VALUES (@p_docente, @p_departamento, @p_dedicacion, @p_modalidad, @p_fecha_ingreso, @p_fecha_salida);

        SET @p_resultado = (SELECT mensaje = 'Asignación docente creada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_actualizar_docente_departamento
    @p_docente INT,
    @p_departamento INT,
    @p_dedicacion NVARCHAR(15),
    @p_modalidad NVARCHAR(45),
    @p_fecha_ingreso DATE,
    @p_fecha_salida DATE = NULL,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        UPDATE docente_departamento
        SET dedicacion = @p_dedicacion,
            modalidad = @p_modalidad,
            fecha_ingreso = @p_fecha_ingreso,
            fecha_salida = @p_fecha_salida
        WHERE docente = @p_docente AND departamento = @p_departamento;

        SET @p_resultado = (SELECT mensaje = 'Asignación docente actualizada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_borrar_docente_departamento
    @p_docente INT,
    @p_departamento INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        DELETE FROM docente_departamento
        WHERE docente = @p_docente AND departamento = @p_departamento;

        SET @p_resultado = (SELECT mensaje = 'Asignación docente eliminada exitosamente' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
