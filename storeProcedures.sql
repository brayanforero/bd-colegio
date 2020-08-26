-- #########ESTUDIANTES#################
DROP PROCEDURE IF EXISTS sp_registrar_estudiante;
DELIMITER $$
CREATE PROCEDURE sp_registrar_estudiante(
 
	_cedula VARCHAR(15),_nombres VARCHAR(50), _apellidos VARCHAR(50), _nacimiento DATE, _genero VARCHAR(1),
    _id_estado INT, _id_municipio INT, _id_parroquia INT,
    _canaina BOOLEAN, _beca BOOLEAN, _des_salud VARCHAR(300), _des_recomendaciones VARCHAR(300),
    _momPhone VARCHAR(20), _dadPhone VARCHAR(20)
)
BEGIN

	DECLARE id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
    ROLLBACK;
    END;
    
    START TRANSACTION;
		INSERT INTO estudiantes
        (cedula,nombre_nombres,nombre_apellidos,fecha_nacimiento,genero,dir_estado,dir_municipio,dir_parroquia,posee_canaima,posee_beca,info_salud,recomendaciones)
		VALUES
        (_cedula,_nombres,_apellidos,_nacimiento,_genero,_id_estado,_id_municipio, _id_parroquia, _canaina, _beca, _des_salud,_des_recomendaciones);
        SET id = (SELECT id_estudiante FROM estudiantes ORDER BY id_estudiante DESC LIMIT 1);
        INSERT INTO telefonos_de_estudiantes (id_estudiante, telefono) VALUE (id, _momPhone),(id, _dadPhone);
	COMMIT;
    SELECT id;
END $$
DELIMITER ;

-- call sp_registrar_estudiante('1234','ROSWELL GABRIEL', 'AMESTY OSORIO', '2010-07-07', 'M',1,1,1, true, true,'','','1234','4321');

DROP PROCEDURE IF EXISTS sp_consulta_estudiante;
DELIMITER $$
CREATE PROCEDURE sp_consulta_estudiante(_cedula VARCHAR(15))
BEGIN
	SELECT cedula, 
    est.nombre_nombres, 
    est.nombre_apellidos, 
    est.fecha_nacimiento, 
    get_age_now(fecha_nacimiento) AS edad, 
    est.genero, 
    IF(est.posee_canaima, 'SI', 'NO') AS canaima, 
    IF(est.posee_beca,'SI','NO') AS beca, 
    est.info_salud, 
    est.recomendaciones,
    
    es.nombre AS estado,
    mun.nombre AS municipio,
    paq.nombre AS parroquia
    FROM estudiantes AS est 
		INNER JOIN localidad.estado AS es
			ON es.id = est.dir_estado
		INNER JOIN localidad.municipio AS mun
				ON mun.id = est.dir_municipio
		INNER JOIN localidad.parroquia AS paq
				ON paq.id = est.dir_parroquia
    
    WHERE cedula = _cedula;
END$$
DELIMITER ;
-- #########REPRESENTANTE#################
DROP PROCEDURE  IF EXISTS sp_registrar_familiar;
DELIMITER $$
CREATE PROCEDURE sp_registrar_familiar(
 
	_cedula VARCHAR(15),_nombres VARCHAR(50), _apellidos VARCHAR(50), _naciemiento DATE,
    _si_vive BOOLEAN, _tipo_vivienda VARCHAR(10), _tipo_familiar VARCHAR(10), _ocupacion VARCHAR(300), _religion VARCHAR(50),
    _email VARCHAR(300)
)
BEGIN
	DECLARE id  INT;
    INSERT INTO familiares
    (cedula, nombre_nombres, nombre_apellidos, fecha_nacimiento, si_vive, tipo_vivienda, tipo_familiar, oficio, religion,email)
    VALUES 
    (_cedula,_nombres, _apellidos, _naciemiento, _si_vive, _tipo_vivienda, _tipo_familiar, _ocupacion, _religion, _email);
    SET id = (SELECT id_familiar FROM familiares ORDER BY id_familiar DESC LIMIT 1);
    
    SELECT id;
END $$
DELIMITER ;
-- #########ESTUDIANTE Y FAMILIA -- TABLAS COBINADAS#################
DROP PROCEDURE IF EXISTS sp_registrar_est_fami;
DELIMITER $$
CREATE PROCEDURE sp_registrar_est_fami(_id_estudiante INT, _id_familiar INT)
BEGIN

	INSERT INTO estudiante_y_familia (id_estudiante, id_familiar) VALUES (_id_estudiante, _id_familiar);
END $$
DELIMITER ;

-- #########PERIODOS#################
DROP PROCEDURE IF EXISTS sp_registro_periodo;
DELIMITER $$
CREATE PROCEDURE sp_registro_periodo(_inicio DATE, _cierre DATE)
BEGIN
	DECLARE cod VARCHAR(9);
    
    SET cod = generar_codigo(_inicio, _cierre);
    INSERT INTO periodos(codigo, inicio, cierre) VALUES (cod, _inicio , _cierre);
END$$
DELIMITER ;

-- #########PERSONAL#################
DROP PROCEDURE IF EXISTS sp_registro_usuario;
DELIMITER $$
CREATE PROCEDURE sp_registro_usuario(_id_persona INT,_nombre VARCHAR(50),_contrasena VARCHAR(50),_rol VARCHAR(12))
BEGIN
	INSERT INTO usuarios (id_personal,nombre,contrasena,rol) VALUES (_id_persona ,_nombre ,md5(_contrasena),_rol);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_personal;
DELIMITER $$
CREATE PROCEDURE sp_registro_personal(_cedula VARCHAR(15), _nombre VARCHAR(50), _apellido VARCHAR(50),_email VARCHAR(100), _cargo VARCHAR(12), _telefono VARCHAR(20))
BEGIN
	DECLARE id INT;
	INSERT INTO personal (cedula, nombre, apellido,email, cargo, telefono)
    VALUES (_cedula, _nombre, _apellido,_email, _cargo, _telefono);
    
	SET id = (SELECT id_personal FROM personal ORDER BY id_personal DESC LIMIT 1);
    SELECT id;
END$$
DELIMITER ;


-- #########PERSONAL#################
DROP PROCEDURE IF EXISTS sp_consulta_grados;
DELIMITER $$
CREATE PROCEDURE sp_consulta_grados()
BEGIN

	SELECT 
		g.id_grado,
        g.nivel,
        g.turno,
        a.id_aula,
        a.nombre AS aula,
        mat.id_matricula,
        mat.cod_matricula,
        ps.id_personal,
        concat(ps.nombre,' ', ps.apellido) as personal
    FROM grados AS g
    INNER JOIN matriculas AS mat
			ON mat.id_matricula = g.id_matricula
    INNER JOIN personal AS ps
			ON ps.id_personal = g.id_personal
    INNER JOIN aulas AS a
			ON a.id_aula = g.id_aula;
END$$
DELIMITER ;

-- #########LOGIN#################
DROP PROCEDURE IF EXISTS sp_login_user;
DELIMITER $$
CREATE PROCEDURE sp_login_user(_username VARCHAR(50), _password VARCHAR(50))
BEGIN
	DECLARE pass_hash VARCHAR(300); 
    SET pass_hash = md5(_password);
	SELECT 
		us.id_usuario,
        us.nombre,
        us.contrasena,
        us.rol,
        ps.id_personal,
        concat(ps.nombre,' ', ps.apellido) as personal
    FROM usuarios AS us
    INNER JOIN personal AS ps
			ON ps.id_personal = us.id_personal
            
	WHERE us.nombre = _username AND us.contrasena = pass_hash;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_grado_asignado;
DELIMITER $$
CREATE PROCEDURE sp_grado_asignado(_id INT)
BEGIN
	
    SELECT 	grd.id_grado,
            grd.nivel, 
            sec.letra AS seccion,
            grd.turno,
            per.codigo AS periodo
			FROM grados AS grd
            INNER JOIN matriculas AS mat
				ON mat.id_matricula = grd.id_matricula
			INNER JOIN periodos AS per
				ON per.id_periodo = mat.id_periodo
			INNER JOIN secciones AS sec
				ON sec.id_seccion = grd.id_seccion
            
            WHERE id_personal = _id;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_lista_estudiante_grado;
DELIMITER $$
CREATE PROCEDURE sp_lista_estudiante_grado(_id INT)
BEGIN
	
		SELECT
			st.id_estudiante,
			st.cedula,
			concat(st.nombre_nombres,' ', st.nombre_apellidos) AS nombres,
			st.fecha_nacimiento AS nacimiento,
			get_age_now(st.fecha_nacimiento) AS edad,
			IF(ins.repitiente, 'SI','NO') AS repitiente,
			st.genero,
			IF(ST.posee_canaima, 'SI','NO') AS canaima,
			IF(ST.posee_beca, 'SI','NO') AS beca,
			concat(fam.nombre_nombres,' ',fam.nombre_apellidos) AS nombres_mama,
            fam.cedula AS cedula_mama
			FROM inscripciones AS ins
			INNER JOIN estudiantes AS st
				ON st.id_estudiante = ins.id_estudiante
			
            INNER JOIN estudiante_y_familia AS est_fam
				ON est_fam.id_estudiante = st.id_estudiante
			
            INNER JOIN familiares AS fam
				ON fam.id_familiar = est_fam.id_familiar
		WHERE fam.tipo_familiar = 'MAMA' AND ins.id_grado = _id;
END $$
DELIMITER ;




