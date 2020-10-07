-- FUNCIONES PARA AYUDAS DE LA PLATAFORMA
-- USE colegio_santa_rita;

-- OBTENER LA EDAD ACTUAL DE UNA FECHA DE NACIMIENTO.
DROP FUNCTION IF EXISTS get_age_now;
DELIMITER $$
CREATE FUNCTION get_age_now(_date_born DATE)
RETURNS SMALLINT
BEGIN
	SET @date_now = now();
    SET @age_now = timestampdiff(YEAR, _date_born, @date_now);
    RETURN  @age_now;
END $$
DELIMITER ;
-- -----------------------

-- GENERACION DE UN CÓDIGO PARA LOS PERIODOS A PARTIR DE UNAS FECHAS.
DROP FUNCTION IF EXISTS generar_codigo;
DELIMITER $$
CREATE FUNCTION generar_codigo(_go DATE, _end DATE)
RETURNS VARCHAR(9)
BEGIN
	SET @age_now = year(_go);
    SET @age_next = year(_end);
    SET @cod = concat(@age_now, '-', @age_next);
    RETURN  @cod;
END $$
DELIMITER ;
-- -----------------------

-- VERIFICA SI UN PERIODO AUN ESTA EN VIGENCIA.
DROP FUNCTION IF EXISTS chequeo_vigencia;
DELIMITER $$
CREATE FUNCTION chequeo_vigencia()
RETURNS BOOLEAN
BEGIN
	DECLARE _exists BOOLEAN;
    SET _exists = (SELECT id_periodo FROM periodos WHERE vigencia = true LIMIT 1);
    
    IF _exists THEN
		RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END $$
DELIMITER ;
-- -----------------------


-- VERIFICA SI UN PERIODO AUN ESTA EN VIGENCIA.
DROP FUNCTION IF EXISTS posee_grados_persona;
DELIMITER $$
CREATE FUNCTION posee_grados_persona(_id INT)
RETURNS BOOLEAN
BEGIN
	DECLARE _exists INT;
    SET _exists = (SELECT COUNT(g.id_grado) AS cantidad FROM grados AS g, periodos AS p WHERE g.id_personal = _id AND p.vigencia = 1 AND g.id_periodo = p.id_periodo);
    
    IF _exists THEN
		RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END $$
DELIMITER ;
-- -----------------------
SHOW FUNCTION STATUS;



