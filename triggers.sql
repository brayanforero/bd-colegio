-- #########ESTUDIANTES#################
DROP TRIGGER IF EXISTS tg_estudiante_BI;
DELIMITER $$
CREATE TRIGGER tg_estudiante_BI BEFORE INSERT ON estudiantes 
	FOR EACH ROW BEGIN
        DECLARE age_admited SMALLINT;
        
        SET age_admited = get_age_now(NEW.fecha_nacimiento);
		
        IF age_admited > 12 OR age_admited <3 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Edad no valida para el Niño(a).';
		END IF;
        IF NEW.fecha_nacimiento = 0000-00-00 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Fecha de nacimiento no valida para el Niño(a).';
		END IF;
        
        IF NEW.info_salud = '' THEN
			SET NEW.info_salud = 'SIN ESPEFICAR';
        END IF;
        
        IF NEW.recomendaciones = '' THEN
			SET NEW.recomendaciones = 'SIN ESPEFICAR';
        END IF;
        IF NEW.cedula = '' THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Cedula no valida para el Niño(a).';
        END IF;
    END $$
 DELIMITER ;
 
 DROP TRIGGER IF EXISTS tg_estudiante_BU;
DELIMITER $$
CREATE TRIGGER tg_estudiante_BU BEFORE UPDATE ON estudiantes 
	FOR EACH ROW BEGIN
        DECLARE age_admited SMALLINT;
        
        SET age_admited = get_age_now(NEW.fecha_nacimiento);
		
        IF age_admited > 12 OR age_admited < 3 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Edad no valida para el Niño(a).';
		END IF;
        IF NEW.fecha_nacimiento = 0000-00-00 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Fecha de nacimiento no valida para el Niño(a).';
		END IF;
        
        IF NEW.info_salud = '' THEN
			SET NEW.info_salud = 'SIN ESPEFICAR';
        END IF;
        
        IF NEW.recomendaciones = '' THEN
			SET NEW.recomendaciones = 'SIN ESPEFICAR';
        END IF;
        IF NEW.cedula = '' THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Cedula no valida para el Niño(a).';
        END IF;
    END $$
 DELIMITER ;
 
-- #########ESTUDIANTES#################


-- #########ESTUDIANTES - TELEFONOS#################

DROP TRIGGER IF EXISTS tg_telefonos_BI;
DELIMITER $$
CREATE TRIGGER tg_telefonos_BI BEFORE INSERT ON telefonos_de_estudiantes 
	FOR EACH ROW BEGIN
        
        IF NEW.telefono = '' OR NEW.telefono < 11 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Exiten ambigueadad en los números de Telefono';
        END IF;
    END $$

-- #########ESTUDIANTES - TELEFONOS################# 
DELIMITER ;

-- #########FAMILIARES#################
DROP TRIGGER IF EXISTS tg_familiares_BI;
DELIMITER $$
CREATE TRIGGER tg_familiares_BI BEFORE INSERT ON familiares
	FOR EACH ROW BEGIN
    
		DECLARE age_admited SMALLINT;
        SET age_admited = get_age_now(NEW.fecha_nacimiento);
        
        IF NEW.fecha_nacimiento = 0000-00-00 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Fecha de nacimiento no valida para el Representate.';
		END IF;
        
        IF NEW.email = '' THEN
			SET NEW.email = 'SIN ESPEFICAR';
        END IF;
        
        IF NEW.religion = '' THEN
			SET NEW.religion = 'SIN ESPEFICAR';
        END IF;
    
		IF age_admited < 18 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Edad no valida para el Representante.';
        END IF;
    
    END $$ 
DELIMITER ;

DROP TRIGGER IF EXISTS tg_familiares_BU;
DELIMITER $$
CREATE TRIGGER tg_familiares_BU BEFORE UPDATE ON familiares 
	FOR EACH ROW BEGIN
    
		DECLARE age_admited SMALLINT;
        SET age_admited = get_age_now(NEW.fecha_nacimiento);
        
        IF NEW.fecha_nacimiento = 0000-00-00 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Fecha de nacimiento no valida para el Representate.';
		END IF;
        
        IF NEW.email = '' THEN
			SET NEW.email = 'SIN ESPEFICAR';
        END IF;
        
        IF NEW.religion = '' THEN
			SET NEW.religion = 'SIN ESPEFICAR';
        END IF;
    
		IF age_admited < 18 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Edad no valida para el Representante.';
        END IF;
    
    END $$ 
DELIMITER ;

-- #########PERIODOS#################
DROP TRIGGER IF EXISTS tg_periodos_BI;
DELIMITER $$
CREATE TRIGGER tg_periodos_BI BEFORE INSERT ON periodos
FOR EACH ROW BEGIN

	IF (NEW.inicio = 0000-00-00 OR NEW.cierre = 0000-00-00) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Formato de Fecha Invalido.';
	END IF;
    
    IF (NEW.inicio > NEW.cierre) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Existe Incongruencia en las Fechas.';
	END IF;
    
    IF (NEW.inicio = NEW.cierre) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Existe Incongruencia en las Fechas.';
	END IF;
    
    IF chequeo_vigencia() THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Existe un Periodo en Vigencia.';
	END IF;
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS tg_periodos_BU;
DELIMITER $$
CREATE TRIGGER tg_periodos_BU BEFORE UPDATE ON periodos
FOR EACH ROW BEGIN

	IF (NEW.inicio = 0000-00-00 OR NEW.cierre = 0000-00-00) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Formato de Fecha Invalido.';
	END IF;
    
    IF (NEW.inicio > NEW.cierre) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Existe incongruencia en las Fechas.';
	END IF;
    
    IF (NEW.inicio = NEW.cierre) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Existe incongruencia en las Fechas.';
	END IF;
    
    IF chequeo_vigencia() THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Existe un periodo en Vigencia.';
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS tg_periodos_AI;
DELIMITER $$
CREATE TRIGGER tg_periodos_AI AFTER INSERT ON periodos
FOR EACH ROW
BEGIN
	DECLARE matricula VARCHAR(10);
    SET matricula = CONCAT('M',NEW.codigo);
    
    INSERT INTO matriculas(id_periodo, cod_matricula) VALUES (NEW.id_periodo, matricula);
END $$
-- #########PERIODOS#################
DELIMITER ;

-- #########PERSONAL#################
DROP TRIGGER IF EXISTS tg_personal_BI;
DELIMITER $$
CREATE TRIGGER tg_personal_BI BEFORE INSERT ON personal
FOR EACH ROW BEGIN
	
    IF NEW.email = '' THEN
		SET NEW.email = 'SIN ESPEFICAR';
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS tg_personal_BU;
DELIMITER $$
CREATE TRIGGER tg_personal_BU BEFORE UPDATE ON personal
FOR EACH ROW BEGIN
	
    IF NEW.email = '' THEN
		SET NEW.email = 'SIN ESPEFICAR';
    END IF;
END$$
-- #########PERSONAL#################
DELIMITER ;


-- #########GRADOS#################
DROP TRIGGER IF EXISTS tg_grados_BI;
DELIMITER $$
CREATE TRIGGER tg_grados_BI BEFORE INSERT ON grados
FOR EACH ROW BEGIN
	
    IF NEW.nivel = '' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Nivel Academico no valido';
    END IF;
    
    IF NEW.turno = '' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Turno Academico no valido';
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS tg_grados_BU;
DELIMITER $$
CREATE TRIGGER tg_grados_BU BEFORE UPDATE ON grados
FOR EACH ROW BEGIN
	
    IF NEW.nivel = '' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Nivel Academico no valido';
    END IF;
    
    IF NEW.turno = '' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Turno Academico no valido';
    END IF;
END$$
-- #########GRADOS#################
DELIMITER ;


DROP TRIGGER IF EXISTS tg_inscripciones_AI;
DELIMITER $$
CREATE TRIGGER tg_inscripciones_AI BEFORE UPDATE ON inscripciones
FOR EACH ROW BEGIN
	
    INSERT INTO historial_academico (id_estudiante, id_grado) VALUES (NEW.id_estdiante, NEW.id_grado);
END$$
-- #########GRADOS#################
DELIMITER ;