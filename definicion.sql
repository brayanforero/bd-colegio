-- Eliminando la base de datos si esta existe.
DROP DATABASE IF EXISTS colegio_santa_rita;
-- Creando la base de datos.
CREATE DATABASE IF NOT EXISTS colegio_santa_rita CHARACTER SET = UTF8;
USE colegio_santa_rita;


-- -------------------------------
-- TABLAS MAYORES-----------------
-- -------------------------------

-- PERIODOS ESCOLARES
DROP TABLE IF EXISTS periodos;
CREATE TABLE IF NOT EXISTS periodos(
    id_periodo INT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(9) NOT NULL,
    inicio DATE NOT NULL,
    cierre DATE NOT NULL,
    vigencia BOOLEAN DEFAULT TRUE,
    estatus BOOLEAN DEFAULT TRUE,
    fecha_registro DATETIME DEFAULT current_timestamp,
    
    CONSTRAINT pk_periodos PRIMARY KEY(id_periodo),
    CONSTRAINT uk_periodos UNIQUE INDEX (codigo)
);


-- CLASIFICACION DE GRADOS
DROP TABLE IF EXISTS secciones;
CREATE TABLE IF NOT EXISTS secciones(
    id_seccion SMALLINT UNSIGNED AUTO_INCREMENT,
    letra VARCHAR(1) NOT NULL,

    CONSTRAINT pk_secciones PRIMARY KEY(id_seccion),
    CONSTRAINT uk_secciones UNIQUE INDEX (letra)
);

INSERT INTO secciones (letra)
			VALUES  ('A'),('B'),('C'),('D'),('E'),
                    ('F'),('G'),('H'),('I'),('J');

-- AULAS --------------------------------------------
DROP TABLE IF EXISTS aulas;
CREATE TABLE IF NOT EXISTS aulas(
    id_aula SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(20) NOT NULL,
    capacidad SMALLINT UNSIGNED DEFAULT 0,
    -- ocupado BOOLEAN DEFAULT FALSE,
    fecha_registro DATETIME DEFAULT current_timestamp,
    
    CONSTRAINT pk_aulas PRIMARY KEY(id_aula),
    CONSTRAINT uk_aulas UNIQUE INDEX (nombre)
);

INSERT INTO aulas (nombre)
			VALUES('EDA ZAMBRANO'), ('YADIRA ROSALES'),
					('VIOLETA RAMIREZ'),('TERESA CARDENAS'),
                    ('NANCY MALDONADO'),('ELEIDE FANNY MARQUEZ'),
                    ('ZENAIDA RUBIO');
-- MAXIMO DOS GRADOS POR AULA

-- PERSONAL -----------------------------------------
DROP TABLE IF EXISTS personal;
CREATE TABLE IF NOT EXISTS personal(
    id_personal INT UNSIGNED AUTO_INCREMENT,
    cedula VARCHAR(15) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) DEFAULT 'SIN ESPECIFICAR',
    cargo VARCHAR(50) DEFAULT 'SIN ESPECIFICAR',
    telefono VARCHAR (20) DEFAULT 'SIN ESPECIFICAR',

    CONSTRAINT pk_personal PRIMARY KEY(id_personal),
    CONSTRAINT uk_personal UNIQUE INDEX(cedula)
);


-- FAMILIARES
DROP TABLE IF EXISTS familiares;
CREATE TABLE IF NOT EXISTS familiares (
    id_familiar INT UNSIGNED AUTO_INCREMENT,
    cedula VARCHAR(15) NOT NULL,
    nombre_nombres VARCHAR(50) NOT NULL,
    nombre_apellidos VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    si_vive BOOLEAN NOT NULL,
    tipo_vivienda ENUM('RANCHO', 'CASA', 'QUINTA') NOT NULL,
    tipo_familiar VARCHAR(10) NOT NULL,
    oficio VARCHAR(100) NOT NULL,
    religion VARCHAR(50) DEFAULT 'SIN ESPEFICAR',
    email VARCHAR(100) DEFAULT 'SIN ESPECIFICAR',
    fecha_registro DATETIME DEFAULT current_timestamp,
    
    CONSTRAINT pk_familiares PRIMARY KEY (id_familiar),
    CONSTRAINT uk_familiares UNIQUE (cedula)
);
-- -------------------------------
-- TABLAS MAYORES-----------------
-- -------------------------------



-- -------------------------------
-- TABLAS DEBILES-----------------
-- -------------------------------
-- TABLAS
-- ESTUDIANTES -----------------------------------------------------
DROP TABLE IF EXISTS estudiantes;

CREATE TABLE IF NOT EXISTS estudiantes(
    id_estudiante INT UNSIGNED AUTO_INCREMENT,
    cedula VARCHAR(15) NOT NULL,
    nombre_nombres VARCHAR(50) NOT NULL,
    nombre_apellidos VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero ENUM('M', 'F') DEFAULT 'M',
    dir_estado INT NOT NULL, -- foraneos
    dir_municipio INT NOT NULL, -- foraneos
    dir_parroquia INT NOT NULL, -- foraneos
    posee_canaima BOOLEAN DEFAULT FALSE,
    posee_beca BOOLEAN DEFAULT FALSE,
    info_salud VARCHAR(300) DEFAULT 'SIN ESPECIFICAR',
    recomendaciones VARCHAR(300) DEFAULT 'SIN ESPECIFICAR',
    fecha_registro DATETIME DEFAULT current_timestamp,
    
    CONSTRAINT pk_estudiante_id PRIMARY KEY (id_estudiante),
    CONSTRAINT uk_cedula UNIQUE INDEX (cedula)
);

ALTER TABLE estudiantes ADD CONSTRAINT fk_estudiantes_estado  FOREIGN KEY (dir_estado)
			REFERENCES localidad.estado (id)
            ON DELETE RESTRICT ON UPDATE RESTRICT;
            
ALTER TABLE estudiantes ADD CONSTRAINT fk_estudiantes_municipio  FOREIGN KEY (dir_municipio)
			REFERENCES localidad.municipio (id)
            ON DELETE RESTRICT ON UPDATE RESTRICT;
            
ALTER TABLE estudiantes ADD CONSTRAINT fk_estudiantes_parroquia  FOREIGN KEY (dir_parroquia)
			REFERENCES localidad.parroquia (id)
            ON DELETE RESTRICT ON UPDATE RESTRICT;
            
-- ---------------------------------------------------------------
-- ESTUDIANTES - FAMILIAS DEPENDE DE -----> ESTUDIANTES Y FAMILIARES
DROP TABLE IF EXISTS estudiante_y_familia;

CREATE TABLE IF NOT EXISTS estudiante_y_familia(
    id_estudiante INT UNSIGNED NOT NULL,
    id_familiar INT UNSIGNED NOT NULL
);

ALTER TABLE estudiante_y_familia ADD  CONSTRAINT fk_eyf_estudiante FOREIGN KEY (id_estudiante) 
			REFERENCES estudiantes(id_estudiante) 
            ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE estudiante_y_familia ADD CONSTRAINT fk_eyf_familiar FOREIGN KEY (id_familiar) 
			REFERENCES familiares(id_familiar) 
            ON DELETE RESTRICT ON UPDATE RESTRICT;
            

-- TELEFONOS DE ESTUDIANTES
-- TELEFENOS DE ESTUDIANTES  Y DEPENDE DE  ---> ESTUDIANTES -----------------------------------------------------
DROP TABLE IF EXISTS telefonos_de_estudiantes;

CREATE TABLE IF NOT EXISTS telefonos_de_estudiantes(
	id INT UNSIGNED AUTO_INCREMENT,
    id_estudiante INT UNSIGNED NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    fecha_registro DATETIME DEFAULT current_timestamp,
    CONSTRAINT pk_tde PRIMARY KEY (id)
);

ALTER TABLE telefonos_de_estudiantes ADD CONSTRAINT uq_tde UNIQUE (id_estudiante, telefono);
ALTER TABLE telefonos_de_estudiantes ADD CONSTRAINT fk_tde_estudiantes FOREIGN KEY (id_estudiante) 
			REFERENCES estudiantes(id_estudiante) 
			ON DELETE RESTRICT
            ON UPDATE RESTRICT;

-- --------------------------------------------------
-- USUARIOS DEL SISTEMA DEPENDE DE ---- > PERSONAL
DROP TABLE IF EXISTS usuarios;
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT UNSIGNED AUTO_INCREMENT,
    id_personal INT UNSIGNED NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    contrasena VARCHAR(300) NOT NULL,
    rol ENUM('ADMINSTRADOR', 'COORDINADOR', 'DOCENTE') DEFAULT 'ADMINSTRADOR',
    estado BOOLEAN DEFAULT TRUE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_usuarios PRIMARY KEY (id_usuario),
    CONSTRAINT uk_usuarios UNIQUE (nombre)
);

ALTER TABLE usuarios ADD CONSTRAINT fk_usuarios_personal FOREIGN KEY (id_personal)
        REFERENCES personal (id_personal)
        ON DELETE RESTRICT ON UPDATE RESTRICT;

-- MATRICULA ---- DEPENDE DE ----> PERIODOS
DROP TABLE IF EXISTS matriculas;
CREATE TABLE IF NOT EXISTS matriculas(
    id_matricula INT UNSIGNED AUTO_INCREMENT,
    id_periodo INT UNSIGNED NOT NULL,
    cod_matricula VARCHAR(10) NOT NULL,
    fecha_registro DATETIME DEFAULT current_timestamp,

    CONSTRAINT pk_matrucula_id PRIMARY KEY(id_matricula),
    CONSTRAINT uk_cod_matricula UNIQUE(cod_matricula)
);

ALTER TABLE matriculas ADD CONSTRAINT fk_matriculas_periodos FOREIGN KEY(id_periodo) 
        REFERENCES periodos(id_periodo)
        ON DELETE RESTRICT ON UPDATE RESTRICT;

-- GRADOS

DROP TABLE IF EXISTS grados;
CREATE TABLE IF NOT EXISTS grados(
	id_grado INT UNSIGNED AUTO_INCREMENT,
    id_matricula INT UNSIGNED NOT NULL,
    id_personal INT UNSIGNED NOT NULL,
    id_aula SMALLINT UNSIGNED NOT NULL,
    id_seccion SMALLINT UNSIGNED NOT NULL,
    nivel VARCHAR(3) NOT NULL,
    turno ENUM('MAÑANA', 'TARDE', 'NOCHE') DEFAULT 'MAÑANA',
	
    CONSTRAINT pk_grados PRIMARY KEY(id_grado)
);


ALTER TABLE grados ADD CONSTRAINT fk_grados_personal FOREIGN KEY(id_personal)
			REFERENCES personal(id_personal)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT;

ALTER TABLE grados ADD CONSTRAINT fk_grados_matriculas FOREIGN KEY(id_matricula)
            REFERENCES matriculas(id_matricula)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT;

ALTER TABLE grados ADD CONSTRAINT fk_grados_aulas FOREIGN KEY(id_aula) 
     REFERENCES aulas(id_aula)
     ON DELETE RESTRICT
     ON UPDATE RESTRICT;
     
ALTER TABLE grados ADD CONSTRAINT fk_grados_secciones FOREIGN KEY(id_seccion) 
     REFERENCES secciones(id_seccion)
     ON DELETE RESTRICT
     ON UPDATE RESTRICT;
-- ----------------------------------------------------------

-- INCRIPCION

DROP TABLE IF EXISTS inscripciones;
CREATE TABLE IF NOT EXISTS inscripciones(
	id_inscripcion INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_estudiante INT UNSIGNED NOT NULL,
    id_grado INT UNSIGNED NOT NULL,
    repitiente BOOLEAN NOT NULL,
    CONSTRAINT pk_inscripciones PRIMARY KEY (id_inscripcion)
);

ALTER TABLE inscripciones ADD CONSTRAINT fk_inscripciones_estudiantes FOREIGN KEY(id_estudiante)
     REFERENCES estudiantes(id_estudiante)
     ON DELETE RESTRICT
     ON UPDATE RESTRICT;
     
ALTER TABLE inscripciones ADD CONSTRAINT fk_inscripciones_grados FOREIGN KEY(id_grado)
     REFERENCES grados(id_grado)
     ON DELETE RESTRICT
     ON UPDATE RESTRICT;

DROP TABLE IF EXISTS historial_academico;
CREATE TABLE IF NOT EXISTS historial_academico(
	id_historia INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_estudiante INT UNSIGNED NOT NULL,
    id_grado INT UNSIGNED NOT NULL,
    CONSTRAINT pk_historial_academico PRIMARY KEY(id_historia)
);

ALTER TABLE historial_academico ADD CONSTRAINT fk_historial_academico_estudiantes FOREIGN KEY (id_estudiante)
	REFERENCES estudiantes(id_estudiante)
     ON DELETE RESTRICT
     ON UPDATE RESTRICT;
ALTER TABLE historial_academico ADD CONSTRAINT fk_historial_academico_grado FOREIGN KEY (id_grado)
	REFERENCES grados(id_grado)
     ON DELETE RESTRICT
     ON UPDATE RESTRICT;
-- -------------------------------
-- TABLAS DEBILES-----------------
-- -------------------------------
