-- #########ESTUDIANTES#################

DROP PROCEDURE IF EXISTS sp_consulta_estudiante;
DELIMITER $$
CREATE PROCEDURE sp_consulta_estudiante(_cedula VARCHAR(15))
BEGIN
	SELECT
    est.id_estudiante,
    est.cedula, 
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
        sec.id_seccion,
		sec.letra,
		g.turno,
        prs.id_personal,
		prs.nombre,
        prs.apellido,
        a.id_aula,
        a.nombre AS aula,
		pds.codigo AS periodo
	FROM grados AS g
		INNER JOIN secciones AS sec
			ON sec.id_seccion = g.id_seccion
		INNER JOIN personal AS prs
			ON prs.id_personal = g.id_personal
        INNER JOIN aulas AS a
        	ON a.id_aula = g.id_aula
		INNER JOIN periodos AS pds
			ON pds.id_periodo = g.id_periodo
	WHERE pds.vigencia = 1;
END$$
DELIMITER ;

CALL sp_consulta_grados();
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
			INNER JOIN periodos AS per
				ON per.id_periodo = grd.id_periodo
			INNER JOIN secciones AS sec
				ON sec.id_seccion = grd.id_seccion
            WHERE id_personal = _id AND per.vigencia = 1
            LIMIT 1;
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

USE colegio_santa_rita;
DROP PROCEDURE IF EXISTS sp_usuarios_activos;
DELIMITER $$
CREATE PROCEDURE sp_usuarios_activos()
BEGIN
	
	SELECT 
    u.id_usuario, 
    u.nombre, CONCAT(p.nombre, ' ', p.apellido) AS persona
    FROM usuarios AS u, personal AS p 
    WHERE u.estado = 1 AND u.id_personal = p.id_personal;	
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_usuarios_desactivos;
DELIMITER $$
CREATE PROCEDURE sp_usuarios_desactivos()
BEGIN
	
	SELECT 
    u.id_usuario, 
    u.nombre, CONCAT(p.nombre, ' ', p.apellido) AS persona
    FROM usuarios AS u, personal AS p 
    WHERE u.estado = 0 AND u.id_personal = p.id_personal;	
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_historial_academico;
DELIMITER $$
CREATE PROCEDURE sp_historial_academico(_id INT)
BEGIN
	
	SELECT 
		h.id_historia AS id,
        g.nivel AS grado,
        s.letra AS seccion,
        p.codigo AS periodo
        FROM historial_academico AS h 
        INNER JOIN grados AS g 
			ON g.id_grado = h.id_grado 
		INNER JOIN secciones AS s 
			ON s.id_seccion = g.id_seccion 
		INNER JOIN periodos AS p 
			ON p.id_periodo = g.id_periodo 
	WHERE h.id_estudiante = _id;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_padres_estudiante;
DELIMITER $$
CREATE PROCEDURE sp_padres_estudiante(_id INT)
BEGIN
	
	SELECT 
		fam.cedula, 
		fam.nombre_nombres AS nombres, 
		fam.nombre_apellidos AS apellidos 
	FROM estudiante_y_familia AS rpr 
		INNER JOIN familiares AS fam 
			ON fam.id_familiar = rpr.id_familiar 
	WHERE rpr.id_estudiante = _id;
END $$
DELIMITER ;