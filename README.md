# 🎓 Sistema de Gestión de Información del Conocimiento Universitario
## Módulo: Innovación Curricular


---

## 📋 Descripción del Proyecto

Sistema de información web multicapa diseñado para gestionar el conocimiento generado en una universidad con sedes y seccionales en varias ciudades del país. Este proyecto permite registrar, consultar y analizar información académica, de investigación y curricular para apoyar la toma de decisiones y el mejoramiento continuo.

**Proyecto de Aula - Grupo 8**  
**Profesor:** Carlos Arturo Castro Castro

---

## 🏗️ Arquitectura del Sistema

El sistema está compuesto por **6 módulos** en una única base de datos relacional:

1. ✅ **Gestión Profesoral** (16 tablas)
2. ✅ **Innovación Curricular** (22 tablas) ← **NUESTRO MÓDULO**
3. ✅ **Mapa de Conocimiento** (18 tablas)
4. ✅ **Investigación** (16 tablas)
5. ✅ **Caracterización** (3 tablas)
6. ✅ **Gestión de Usuarios** (3 tablas)


<img width="552" height="621" alt="image" src="https://github.com/user-attachments/assets/77278dd3-8e57-4ba3-a2ab-4b4e329d97ec" />

📦 FASE 1: Tablas Sin Claves Foráneas (Primera Entrega - 06/03/2026)
Estas tablas son independientes y no dependen de ninguna otra. Se pueden crear, leer, actualizar y eliminar sin restricciones.

<img width="641" height="650" alt="image" src="https://github.com/user-attachments/assets/0d7dd716-c933-4ce3-a2bd-76dd702ebccb" />

 📊 Tabla 1: universidad
SQL



 CREATE TABLE universidad (
  id INT NOT NULL PRIMARY KEY,
  nombre NVARCHAR(60) NOT NULL,
  tipo NVARCHAR(45) NOT NULL,
  ciudad NVARCHAR(45) NOT NULL
);




📊 Tabla 2: aliado 
SQL
CREATE TABLE enfoque (
  id INT NOT NULL PRIMARY KEY,
  nombre NVARCHAR(45) NOT NULL,
  descripcion NVARCHAR(45) NOT NULL
);




📊 Tabla 3: aspecto_normativo
SQL
CREATE TABLE aspecto_normativo (
  id INT NOT NULL PRIMARY KEY,
  tipo NVARCHAR(45) NOT NULL,
  descripcion NVARCHAR(45) NOT NULL,
  fuente NVARCHAR(45) NOT NULL
);









📊 Tabla 4: practica_estrategia 
SQL 
CREATE TABLE practica_estrategia (
  id INT NOT NULL PRIMARY KEY,
  tipo NVARCHAR(45) NOT NULL,
  nombre NVARCHAR(45) NOT NULL,
  descripcion NVARCHAR(45) NOT NULL
);







📊 Tabla 5: car_innovacion
SQL 
CREATE TABLE car_innovacion (
  id INT NOT NULL PRIMARY KEY,
  nombre NVARCHAR(45) NOT NULL,
  descripcion NVARCHAR(MAX) NOT NULL,
  tipo NVARCHAR(45) NOT NULL
); 






📊 Tabla 6: area_conocimiento
SQL 
CREATE TABLE area_conocimiento (
  id INT NOT NULL PRIMARY KEY,
  gran_area NVARCHAR(60) NOT NULL,
  area NVARCHAR(60) NOT NULL,
  disciplina NVARCHAR(60) NOT NULL
); 




## 👥 División de Trabajo - Fase 1

<img width="958" height="206" alt="image" src="https://github.com/user-attachments/assets/7262c355-cfe3-4bdd-a228-123113120f13" />
|
#segunda entrega 
03/04/2026 (20%): CRUD de todas las tablas para la base de datos del módulo correspondiente (se incluye la primera entrega) (APIREST+FRONT-END). Cada estudiante debe tener su propia rama en GitHUB. Además, uno de los estudiantes debe administrar la rama principal.



# Tablas Restantes del Módulo



📊 Tabla 7: facultad

SQL
CREATE TABLE facultad (
  id INT NOT NULL PRIMARY KEY,
  nombre NVARCHAR(60) NOT NULL,
  tipo NVARCHAR(45) NOT NULL,
  fecha_fun DATE NOT NULL,
  universidad INT NOT NULL,
  CONSTRAINT fk_unidad_sede FOREIGN KEY (universidad)
    REFERENCES universidad (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);





📊 Tabla 8: programa

SQL
CREATE TABLE programa (
  id INT NOT NULL PRIMARY KEY,
  nombre NVARCHAR(60) NOT NULL,
  tipo NVARCHAR(45) NOT NULL,
  nivel NVARCHAR(45) NOT NULL,
  fecha_creacion NVARCHAR(45) NOT NULL,
  fecha_cierre NVARCHAR(45) NULL,
  numero_cohortes NVARCHAR(45) NOT NULL,
  cant_graduados NVARCHAR(45) NOT NULL,
  fecha_actualizacion NVARCHAR(45) NOT NULL,
  ciudad NVARCHAR(45) NOT NULL,
  facultad INT NOT NULL,
  CONSTRAINT fk_programa_facultad FOREIGN KEY (facultad)
    REFERENCES facultad (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);



📊 Tabla 9: enfoque

SQL
CREATE TABLE enfoque (
  id INT NOT NULL PRIMARY KEY,
  nombre NVARCHAR(45) NOT NULL,
  descripcion NVARCHAR(45) NOT NULL
);





📊 Tabla 10: premio

SQL
CREATE TABLE premio (
  id INT NOT NULL PRIMARY KEY,
  nombre NVARCHAR(45) NOT NULL,
  descripcion NVARCHAR(45) NOT NULL,
  fecha DATE NOT NULL,
  entidad_otorgante NVARCHAR(45) NOT NULL,
  pais NVARCHAR(45) NOT NULL,
  programa INT NOT NULL,
  CONSTRAINT fk_premio_programa FOREIGN KEY (programa)
    REFERENCES programa (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);




📊 Tabla 11: pasantia

SQL
CREATE TABLE pasantia (
  id INT NOT NULL PRIMARY KEY,
  nombre NVARCHAR(45) NOT NULL,
  pais NVARCHAR(45) NOT NULL,
  empresa NVARCHAR(45) NOT NULL,
  descripcion NVARCHAR(45) NOT NULL,
  programa INT NOT NULL,
  CONSTRAINT fk_pasantia_programa FOREIGN KEY (programa)
    REFERENCES programa (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);





📊 Tabla 12: activ_academica

SQL
CREATE TABLE activ_academica (
  id INT NOT NULL PRIMARY KEY,
  nombre NVARCHAR(45) NOT NULL,
  num_creditos INT NOT NULL,
  tipo NVARCHAR(20) NOT NULL,
  area_formacion NVARCHAR(45) NOT NULL,
  h_acom INT NOT NULL,
  h_indep INT NOT NULL,
  idioma NVARCHAR(45) NOT NULL,
  espejo BIT NOT NULL,
  entidad_espejo NVARCHAR(45) NOT NULL,
  pais_espejo NVARCHAR(45) NOT NULL,
  disenio INT NULL,
  CONSTRAINT fk_activ_academicas_programa FOREIGN KEY (disenio)
    REFERENCES programa (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);





📊 Tabla 13: registro_calificado

SQL
CREATE TABLE registro_calificado (
  codigo INT NOT NULL PRIMARY KEY,
  cant_creditos NVARCHAR(45) NOT NULL,
  hora_acom NVARCHAR(45) NOT NULL,
  hora_ind NVARCHAR(45) NOT NULL,
  metodologia NVARCHAR(45) NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  duracion_anios NVARCHAR(45) NOT NULL,
  duracion_semestres NVARCHAR(45) NOT NULL,
  tipo_titulacion NVARCHAR(45) NOT NULL,
  programa INT NOT NULL,
  CONSTRAINT fk_registro_calificado_programa FOREIGN KEY (programa)
    REFERENCES programa (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);






📊 Tabla 14: acreditacion

SQL
CREATE TABLE acreditacion (
  resolucion INT NOT NULL PRIMARY KEY,
  tipo NVARCHAR(45) NOT NULL,
  calificacion NVARCHAR(45) NOT NULL,
  fecha_inicio NVARCHAR(45) NOT NULL,
  fecha_fin NVARCHAR(45) NOT NULL,
  programa INT NOT NULL,
  CONSTRAINT fk_acreditacion_programa FOREIGN KEY (programa)
    REFERENCES programa (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);




📊 Tabla 15: enfoque_rc

SQL
CREATE TABLE enfoque_rc (
  enfoque INT NOT NULL,
  registro_calificado INT NOT NULL,
  PRIMARY KEY (enfoque, registro_calificado),
  CONSTRAINT fk_enfoque_rc_enfoque FOREIGN KEY (enfoque)
    REFERENCES enfoque (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_enfoque_rc_registro_calificado FOREIGN KEY (registro_calificado)
    REFERENCES registro_calificado (codigo)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);






📊 Tabla 16: aa_rc

SQL
CREATE TABLE aa_rc (
  activ_academicas_idcurso INT NOT NULL,
  registro_calificado_codigo INT NOT NULL,
  componente NVARCHAR(45) NOT NULL,
  semestre NVARCHAR(45) NOT NULL,
  PRIMARY KEY (activ_academicas_idcurso, registro_calificado_codigo),
  CONSTRAINT fk_aa_rc_activ_academica FOREIGN KEY (activ_academicas_idcurso)
    REFERENCES activ_academica (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_aa_rc_registro_calificado FOREIGN KEY (registro_calificado_codigo)
    REFERENCES registro_calificado (codigo)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);




📊 Tabla 17: programa_ci

SQL
CREATE TABLE programa_ci (
  programa INT NOT NULL,
  car_innovacion INT NOT NULL,
  PRIMARY KEY (programa, car_innovacion),
  CONSTRAINT fk_programa_ci_programa FOREIGN KEY (programa)
    REFERENCES programa (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_programa_ci_car_innovacion FOREIGN KEY (car_innovacion)
    REFERENCES car_innovacion (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);




📊 Tabla 18: programa_pe

SQL
CREATE TABLE programa_pe (
  programa INT NOT NULL,
  practica_estrategia INT NOT NULL,
  PRIMARY KEY (programa, practica_estrategia),
  CONSTRAINT fk_programa_pe_programa FOREIGN KEY (programa)
    REFERENCES programa (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_programa_pe_practica_estrategia FOREIGN KEY (practica_estrategia)
    REFERENCES practica_estrategia (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);




📊 Tabla 19 : an_programa

SQL
CREATE TABLE an_programa (
  aspecto_normativo INT NOT NULL,
  programa INT NOT NULL,
  PRIMARY KEY (aspecto_normativo, programa),
  CONSTRAINT fk_an_programa_aspecto_normativo FOREIGN KEY (aspecto_normativo)
    REFERENCES aspecto_normativo (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_an_programa_programa FOREIGN KEY (programa)
    REFERENCES programa (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);



📊 Tabla 20: programa_ac

SQL
CREATE TABLE programa_ac (
  programa INT NOT NULL,
  area_conocimiento INT NOT NULL,
  PRIMARY KEY (programa, area_conocimiento),
  CONSTRAINT fk_programa_ac_programa FOREIGN KEY (programa)
    REFERENCES programa (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_programa_ac_area_conocimiento FOREIGN KEY (area_conocimiento)
    REFERENCES area_conocimiento (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);



📊 Tabla 21: alianza

SQL
CREATE TABLE alianza (
  aliado BIGINT NOT NULL, 
  departamento INT NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NULL,
  docente INT NULL,
  PRIMARY KEY (aliado, departamento),
  CONSTRAINT fk_alianza_aliado FOREIGN KEY (aliado)
    REFERENCES aliado (nit)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_alianza_departamento FOREIGN KEY (departamento)
    REFERENCES programa (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_alianza_docente FOREIGN KEY (docente)
    REFERENCES docente (cedula)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);



📊 Tabla 22: docente_departamento

SQL
CREATE TABLE docente_departamento (
  docente INT NOT NULL,
  departamento INT NOT NULL,
  dedicacion NVARCHAR(15) NOT NULL,
  modalidad NVARCHAR(45) NOT NULL,
  fecha_ingreso DATE NOT NULL,
  fecha_salida DATE NULL,
  PRIMARY KEY (docente, departamento),
  CONSTRAINT fk_docente_departamento_docente FOREIGN KEY (docente)
    REFERENCES docente (cedula)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_docente_departamento_departamento FOREIGN KEY (departamento)
    REFERENCES programa (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

 ## division de trabajo entrega 2 



| Módulo | Tabla | Clave Primaria | Claves Foráneas (Relaciones) | Tipo de Tabla |
| :--- | :--- | :--- | :--- | :--- |
| **David**<br>*(Estructura Core y Relaciones Externas)* | `facultad` | `id` | `universidad` | Entidad |
| | `programa` | `id` | `facultad` | Entidad |
| | `premio` | `id` | `programa` | Entidad |
| | `pasantia` | `id` | `programa` | Entidad |
| | `alianza` | `aliado, departamento` | `aliado, departamento, docente` | Intermedia (N:M) |
| **Olman**<br>*(Núcleo Académico y Calidad)* | `registro_calificado` | `codigo` | `programa` | Entidad |
| | `acreditacion` | `resolucion` | `programa` | Entidad |
| | `activ_academica` | `id` | `programa, disenio` | Entidad |
| | `enfoque` | `id` | `-` | Catálogo |
| | `enfoque_rc` | `enfoque, registro_calificado` | `enfoque, registro_calificado` | Intermedia (N:M) |
| | `aa_rc` | `activ_academicas_idcurso, registro_calificado_codigo` | `activ_academicas_idcurso, registro_calificado_codigo` | Intermedia (N:M) |
| **Tomás**<br>*(Configuración y Características del Programa)* | `programa_ci` | `programa, car_innovacion` | `programa, car_innovacion` | Intermedia (N:M) |
| | `programa_pe` | `programa, practica_estrategia` | `programa, practica_estrategia` | Intermedia (N:M) |
| | `an_programa` | `aspecto_normativo, programa` | `aspecto_normativo, programa` | Intermedia (N:M) |
| | `programa_ac` | `programa, area_conocimiento` | `programa, area_conocimiento` | Intermedia (N:M) |
| | `docente_departamento` | `docente, departamento` | `docente, departamento` | Intermedia (N:M) |
