DROP DATABASE `lahormiguitadb`;

CREATE DATABASE IF NOT EXISTS `lahormiguitadb`;

USE `lahormiguitadb`;

-- SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

CREATE TABLE IF NOT EXISTS usuarios (
    usu_id int AUTO_INCREMENT,
    usu_fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usu_nombre varchar(45) NOT NULL,
    usu_apellidos varchar(45) NOT NULL,
    usu_dni char(8) UNIQUE NOT NULL,
    usu_username varchar(45) NOT NULL,
    usu_contrasena varchar(85) NOT NULL,
    PRIMARY KEY (usu_id)
);

CREATE TABLE IF NOT EXISTS pedidos (
    ped_id int AUTO_INCREMENT,
    ped_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ped_estado int DEFAULT 1 NOT NULL,
    usu_id int NOT NULL,
    PRIMARY KEY (ped_id),
    FOREIGN KEY (usu_id) REFERENCES usuarios(usu_id)
);

CREATE TABLE IF NOT EXISTS estados (
    est_id int AUTO_INCREMENT,
    est_nombre varchar(45) NOT NULL,
    PRIMARY KEY (est_id)
);

CREATE TABLE IF NOT EXISTS productos (
    prod_id int AUTO_INCREMENT,
    prod_nombre varchar(45) NOT NULL,
    prod_precio float NOT NULL,
    prod_costo float NOT NULL,
    prod_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    prod_etiqueta varchar(12) UNIQUE NOT NULL,
    prod_es_activo tinyint DEFAULT 1,
    est_id int NOT NULL,
    PRIMARY KEY (prod_id),
    FOREIGN KEY (est_id) REFERENCES estados(est_id)
);

CREATE TABLE IF NOT EXISTS pedidos_productos (
    ped_prod_id int AUTO_INCREMENT,
    ped_prod_precio float NOT NULL,
    ped_prod_cantidad int NOT NULL,
    prod_id int NOT NULL,
    ped_id int NOT NULL,
    PRIMARY KEY (ped_prod_id),
    FOREIGN KEY (prod_id) REFERENCES productos(prod_id),
    FOREIGN KEY (ped_id) REFERENCES pedidos(ped_id)
);

CREATE TABLE IF NOT EXISTS reportes (
    rep_id int AUTO_INCREMENT,
    rep_titulo varchar(45) NOT NULL,
    rep_descripcion text NOT NULL,
    rep_fecha_ini TIMESTAMP NOT NULL,
    rep_fecha_fin TIMESTAMP NOT NULL,
    rep_fecha_reg TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usu_id int NOT NULL,
    PRIMARY KEY (rep_id),
    FOREIGN KEY (usu_id) REFERENCES usuarios(usu_id)
);

CREATE TABLE IF NOT EXISTS proveedores (
    prov_id int AUTO_INCREMENT,
    prov_nombre varchar(45) NOT NULL,
    prov_celular varchar(12) NOT NULL,
    prov_ruc varchar(16) UNIQUE NOT NULL,
    prov_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    prov_estado int DEFAULT 1,
    PRIMARY KEY (prov_id)
);

CREATE TABLE IF NOT EXISTS cotizaciones (
    cot_id int AUTO_INCREMENT,
    cot_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cot_cantidad int NOT NULL,
    cot_estado int DEFAULT 1,
    usu_id int NOT NULL,
    prod_id int NOT NULL,
    PRIMARY KEY (cot_id),
    FOREIGN KEY (usu_id) REFERENCES usuarios(usu_id),
    FOREIGN KEY (prod_id) REFERENCES productos(prod_id)
);

CREATE TABLE IF NOT EXISTS cotizaciones_proveedores (
    cot_prod_id int AUTO_INCREMENT,
    cot_id int NOT NULL,
    prov_id int NOT NULL,
    PRIMARY KEY (cot_prod_id),
    FOREIGN KEY (cot_id) REFERENCES cotizaciones(cot_id),
    FOREIGN KEY (prov_id) REFERENCES proveedores(prov_id)
);

CREATE TABLE IF NOT EXISTS almacenes (
    alm_id int AUTO_INCREMENT,
    alm_nombre varchar(45) NOT NULL,
    alm_direccion varchar(35) NOT NULL,
    PRIMARY KEY (alm_id)
);

CREATE TABLE IF NOT EXISTS almacenes_productos (
    alm_prod_id int AUTO_INCREMENT,
    alm_prod_stock int DEFAULT 0 NOT NULL,
    alm_id int NOT NULL,
    prod_id int NOT NULL,
    PRIMARY KEY (alm_prod_id),
    FOREIGN KEY (alm_id) REFERENCES almacenes(alm_id),
    FOREIGN KEY (prod_id) REFERENCES productos(prod_id)
);

CREATE TABLE IF NOT EXISTS temperaturas (
    temp_id int AUTO_INCREMENT,
    temp_valor float NOT NULL,
    temp_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alm_id int NOT NULL,
    PRIMARY KEY (temp_id),
    FOREIGN KEY (alm_id) REFERENCES almacenes(alm_id)
);

CREATE TABLE IF NOT EXISTS humedades (
    hum_id int AUTO_INCREMENT,
    hum_valor float NOT NULL,
    hum_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alm_id int NOT NULL,
    PRIMARY KEY (hum_id),
    FOREIGN KEY (alm_id) REFERENCES almacenes(alm_id)
);

CREATE TABLE IF NOT EXISTS reportes_productos (
    rep_prod_id int AUTO_INCREMENT,
    rep_prod_cant_vendida int NOT NULL,
    rep_prod_total_ingreso float NOT NULL,
    rep_prod_costo float NOT NULL,
    rep_id int NOT NULL,
    prod_id int NOT NULL,
    PRIMARY KEY (rep_prod_id),
    FOREIGN KEY (rep_id) REFERENCES reportes(rep_id),
    FOREIGN KEY (prod_id) REFERENCES productos(prod_id)
);

CREATE TABLE IF NOT EXISTS categorias (
    cat_id int AUTO_INCREMENT,
    cat_nombre varchar(45) NOT NULL,
    cat_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cat_estado int DEFAULT 1,
    PRIMARY KEY (cat_id)
);

CREATE TABLE IF NOT EXISTS proveedores_categorias (
    prov_cat_id int AUTO_INCREMENT,
    prov_id int NOT NULL,
    cat_id int NOT NULL,
    PRIMARY KEY (prov_cat_id),
    FOREIGN KEY (prov_id) REFERENCES proveedores(prov_id),
    FOREIGN KEY (cat_id) REFERENCES categorias(cat_id)
);

CREATE TABLE IF NOT EXISTS productos_categorias (
    prod_cat_id int AUTO_INCREMENT,
    prod_id int NOT NULL,
    cat_id int NOT NULL,
    PRIMARY KEY (prod_cat_id),
    FOREIGN KEY (prod_id) REFERENCES productos(prod_id),
    FOREIGN KEY (cat_id) REFERENCES categorias(cat_id)
);

CREATE TABLE IF NOT EXISTS configuraciones (
    conf_id int AUTO_INCREMENT,
    temp_limite float NOT NULL,
    hum_limite float NOT NULL,
    alm_id int NOT NULL,
    PRIMARY KEY (conf_id),
    FOREIGN KEY (alm_id) REFERENCES almacenes(alm_id)
);

-- CREATE TABLE IF NOT EXISTS etiquetas (
--     eti_id int AUTO_INCREMENT,
--     eti_codigo varchar(12) UNIQUE NOT NULL,
--     prod_id int NOT NULL,
--     PRIMARY KEY (eti_id),
--     FOREIGN KEY (prod_id) REFERENCES Productos(prod_id)
-- );

-- ----------------------- Funciones -------------------------

SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER //

CREATE FUNCTION `FUN_INSERTAR_COTIZACION_Y_OBTENER_ID`(COT_CANTIDAD INT, USU_ID INT, PROD_ID INT) 
    RETURNS int
BEGIN
	DECLARE ULTIMA_COT_ID INTEGER;
	INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (COT_CANTIDAD, USU_ID, PROD_ID);
	SET ULTIMA_COT_ID = (
    SELECT cot_id 
    FROM cotizaciones
	WHERE cot_cantidad = COT_CANTIDAD 
    AND usu_id = USU_ID 
    AND prod_id = PROD_ID 
    ORDER BY cot_id 
    DESC LIMIT 1);

    RETURN ULTIMA_COT_ID;
END; //

CREATE FUNCTION `FUN_OBTENER_ESTADO_POR_STOCK`(P_STOCK INT) RETURNS int
BEGIN
	DECLARE V_ESTADO INT;

	IF P_STOCK >= 16 THEN
		SET V_ESTADO = 1;
	ELSEIF P_STOCK THEN
		SET V_ESTADO = 2;
	ELSE
		SET V_ESTADO = 3;
	END IF;
RETURN V_ESTADO;
END; //

CREATE FUNCTION `FUN_INSERTAR_REPORTE_Y_OBTENER_ID`(P_REP_TITULO VARCHAR(45), P_REP_DESCRIPCION TEXT, P_REP_FECHA_INI TIMESTAMP, P_REP_FECHA_FIN TIMESTAMP, P_USU_ID INT) RETURNS int
BEGIN
	DECLARE ULTIMO_REP_ID INTEGER;
	
    INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES (P_REP_TITULO, P_REP_DESCRIPCION, P_REP_FECHA_INI, P_REP_FECHA_FIN, P_USU_ID);
	SET ULTIMO_REP_ID = (
    SELECT rep_id 
    FROM reportes
	WHERE rep_titulo = P_REP_TITULO 
    AND rep_descripcion = P_REP_DESCRIPCION 
    AND rep_fecha_ini = P_REP_FECHA_INI
    AND rep_fecha_fin = P_REP_FECHA_FIN
    AND usu_id = P_USU_ID
    ORDER BY rep_id DESC LIMIT 1);

    RETURN ULTIMO_REP_ID;
END; //

-- ----------------------- Procedimientos -------------------------

CREATE PROCEDURE `PRC_ACTUALIZAR_PRODUCTO`(OUT P_ERROR_MESSAGE VARCHAR(48), OUT P_EXIST_ERROR TINYINT(1), P_ALM_PROD_ID INT, P_PROD_ID INT, P_PROD_NOMBRE VARCHAR(45), P_PROD_PRECIO FLOAT,  P_PROD_COSTO FLOAT, P_PROD_STOCK INT, P_PROD_ETIQUETA VARCHAR(12))
BEGIN
	DECLARE V_EXIST_RELACION_ALM_PROD INT;
    DECLARE V_EXIST_PRODUCTO INT;
    
    SET P_EXIST_ERROR = 0;
	SET P_ERROR_MESSAGE = "Solicitud ejecutada correctamente";
    
    SELECT COUNT(alm_prod_id) INTO V_EXIST_RELACION_ALM_PROD FROM almacenes_productos WHERE alm_prod_id = P_ALM_PROD_ID;
    SELECT COUNT(prod_id) INTO V_EXIST_PRODUCTO FROM productos WHERE prod_id = P_PROD_ID;
    
	IF V_EXIST_RELACION_ALM_PROD <= 0 THEN
		SET P_ERROR_MESSAGE = "El producto especificado no existe en el almac├®n";
		SET P_EXIST_ERROR = 1;
	END IF;
    
    IF V_EXIST_PRODUCTO <= 0 THEN
		SET P_ERROR_MESSAGE = "No existe el producto especificado";
        SET P_EXIST_ERROR = 1;
    END IF;
    
    IF P_EXIST_ERROR = 0 THEN
		UPDATE productos
        SET prod_nombre = P_PROD_NOMBRE, prod_precio = P_PROD_PRECIO, prod_costo = P_PROD_COSTO, prod_etiqueta = P_PROD_ETIQUETA
        WHERE prod_id = P_PROD_ID;
        
        UPDATE almacenes_productos
        SET alm_prod_stock = P_PROD_STOCK
        WHERE alm_prod_id = P_ALM_PROD_ID;
        
    END IF;
END; //

CREATE PROCEDURE `PRC_REGISTRAR_PRODUCTO`(OUT P_ERROR_MESSAGE VARCHAR(100), OUT P_EXIST_ERROR TINYINT(1), OUT P_PROD_NRO_OUT INT, P_PROD_NOMBRE VARCHAR(45), P_PROD_PRECIO FLOAT,  P_PROD_COSTO FLOAT, P_PROD_STOCK INT, P_PROD_ETIQUETA VARCHAR(12), P_ALM_ID INT, P_PROD_NRO_IN INT)
BEGIN
	DECLARE V_EXIST_ALMACEN INT;
    DECLARE V_EXIST_ETIQUETA INT;
    DECLARE V_ESTADO INT;
    DECLARE V_PROD_ID INT;
    
    SET P_EXIST_ERROR = 0;
	SET P_ERROR_MESSAGE = "Solicitud ejecutada correctamente";
    SET P_PROD_NRO_OUT = P_PROD_NRO_IN;
    
    SELECT COUNT(alm_id) INTO V_EXIST_ALMACEN FROM almacenes WHERE alm_id = P_ALM_ID;
    SELECT COUNT(prod_id) INTO V_EXIST_ETIQUETA FROM productos WHERE prod_etiqueta = P_PROD_ETIQUETA;
    
	IF V_EXIST_ALMACEN <= 0 THEN
		SET P_ERROR_MESSAGE = "No existe el almacén especificado";
		SET P_EXIST_ERROR = 1;
	END IF;
    
    IF V_EXIST_ETIQUETA > 0 THEN
		SET P_ERROR_MESSAGE = "La etiqueta ingresada ya existe en la base de datos";
		SET P_EXIST_ERROR = 1;
	END IF;
    
    IF P_EXIST_ERROR = 0 THEN
        SELECT FUN_OBTENER_ESTADO_POR_STOCK(P_PROD_STOCK) INTO V_ESTADO;
    
		INSERT INTO productos (prod_nombre, prod_precio, prod_costo, prod_etiqueta, est_id)
        VALUES (P_PROD_NOMBRE, P_PROD_PRECIO, P_PROD_COSTO, P_PROD_ETIQUETA, V_ESTADO);
        
		SELECT prod_id INTO V_PROD_ID FROM productos 
        WHERE prod_nombre = P_PROD_NOMBRE AND prod_precio = P_PROD_PRECIO
        AND prod_etiqueta = P_PROD_ETIQUETA AND prod_etiqueta = P_PROD_ETIQUETA
        AND est_id = V_ESTADO ORDER BY prod_id LIMIT 1;
        
        INSERT almacenes_productos (alm_prod_stock, alm_id, prod_id)
        VALUES (P_PROD_STOCK, P_ALM_ID, V_PROD_ID);
    END IF;
END; //

-- DELIMITER ;

-- ----------------------- Triggers -------------------------

DELIMITER //
CREATE TRIGGER `TRI_UPD_STOCK` BEFORE UPDATE
ON `almacenes_productos`
FOR EACH ROW
BEGIN
    DECLARE V_ESTADO INT;
    SELECT FUN_OBTENER_ESTADO_POR_STOCK(NEW.alm_prod_stock) INTO V_ESTADO;

    UPDATE productos SET est_id = V_ESTADO WHERE prod_id = NEW.prod_id;
END; //
DELIMITER ;


-- ----------------------- Inserts ---------------------------

USE lahormiguitadb;

SET NAMES utf8mb4;

-- ############################################ Almacenes ############################################

INSERT INTO almacenes (alm_direccion, alm_nombre) VALUES ("Calle principal 789. Urb Principal", "Almacén principal");


-- ############################################ Categorías ############################################

INSERT INTO categorias (cat_nombre) VALUES ("Ferretería Doméstica");
INSERT INTO categorias (cat_nombre) VALUES ("Cerrajería");
INSERT INTO categorias (cat_nombre) VALUES ("Baño y Fontanería");
INSERT INTO categorias (cat_nombre) VALUES ("Calefacción y Ventilación");
INSERT INTO categorias (cat_nombre) VALUES ("Material Eléctrico");
INSERT INTO categorias (cat_nombre) VALUES ("Electroportátiles");
INSERT INTO categorias (cat_nombre) VALUES ("Equipos de trabajo");
INSERT INTO categorias (cat_nombre) VALUES ("Protección y Vestuario");
INSERT INTO categorias (cat_nombre) VALUES ("Pinturas y Complementos");
INSERT INTO categorias (cat_nombre) VALUES ("Sellantes - Fijación y Tornillería");
INSERT INTO categorias (cat_nombre) VALUES ("Construcción");


-- ############################################ Estados ############################################

INSERT INTO estados (est_nombre) VALUES ("Disponible");
INSERT INTO estados (est_nombre) VALUES ("Por agotarse");
INSERT INTO estados (est_nombre) VALUES ("Agotado");
INSERT INTO estados (est_nombre) VALUES ("Eliminado");


-- ############################################ Humedades ############################################

INSERT INTO humedades (alm_id, hum_valor) VALUES (1, 73);
INSERT INTO humedades (alm_id, hum_valor) VALUES (1, 85);
INSERT INTO humedades (alm_id, hum_valor) VALUES (1, 85);
INSERT INTO humedades (alm_id, hum_valor) VALUES (1, 77);
INSERT INTO humedades (alm_id, hum_valor) VALUES (1, 85);


-- ############################################ Temperaturas ############################################

INSERT INTO temperaturas (alm_id, temp_valor) VALUES (1, 37.64);
INSERT INTO temperaturas (alm_id, temp_valor) VALUES (1, 35.26);
INSERT INTO temperaturas (alm_id, temp_valor) VALUES (1, 35.49);
INSERT INTO temperaturas (alm_id, temp_valor) VALUES (1, 36.45);
INSERT INTO temperaturas (alm_id, temp_valor) VALUES (1, 35.99);


-- ############################################ Productos ############################################

INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Nivel", "c5:d0:0f", 34.3, 60.4);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (2, "Cascos", "1a:3c:47", 8.3, 11.6);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Tuercas", "9f:0f:89", 32.5, 42.5);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (3, "Serrucho", "da:19:72", 31.5, 58.9);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Cortadoras de metal", "62:01:84", 24.9, 33.3);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Cables eléctricos", "8f:a1:dc", 39.1, 51.1);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Tijeras industriales", "86:10:48", 20.7, 35.0);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (3, "Enchufes rápidos", "91:9f:25", 48.9, 95.3);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Gafas de protección", "61:1b:07", 9.5, 17.0);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (3, "Destornillador de paleta", "04:a6:6c", 72.5, 96.2);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (2, "Tornillos", "50:f5:f4", 7.5, 14.0);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Brocas para construcción", "bd:73:ea", 57.0, 93.5);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Pinzas", "0d:e4:0c", 56.5, 73.8);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Martillo", "7b:3d:ba", 39.1, 60.5);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Rampas", "b8:77:de", 45.5, 87.4);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (2, "Pegamento", "1d:c7:77", 18.4, 24.4);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Iluminación", "af:c9:5a", 43.4, 72.5);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (3, "Escalera", "33:01:aa", 50.7, 64.2);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Ladrillos", "f8:cf:82", 11.8, 18.4);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (2, "Pintura", "ae:fa:dc", 28.3, 55.7);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (3, "Cerraduras", "03:54:e8", 35.6, 46.7);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (3, "Mangueras", "13:dd:fb", 53.3, 71.9);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Taladro", "15:ae:b1", 14.3, 25.0);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Brochas", "b0:88:d6", 10.1, 14.6);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Cerámica", "11:37:8c", 48.5, 73.9);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Cortacables", "d2:d1:e1", 10.6, 14.1);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Discos abrasivos", "62:17:1a", 73.6, 97.0);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Guantes de seguridad", "35:20:f9", 22.2, 35.9);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (3, "Lijadoras", "40:cb:21", 39.2, 52.3);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Cinta de medir o métrica", "73:7b:48", 62.4, 95.9);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Espátulas", "a1:42:8d", 43.9, 79.1);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Lubricante multiuso", "27:83:a5", 19.0, 30.2);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (3, "Alicate", "81:2a:72", 48.2, 94.3);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Tubería PVC", "2f:61:fc", 60.0, 92.8);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (2, "Bloques", "46:36:6c", 29.4, 53.4);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Disolventes", "b1:e7:94", 38.7, 69.9);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Lámparas de pared", "03:bc:c9", 25.4, 44.2);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Clavijas", "0c:53:7c", 28.2, 41.7);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (2, "Juego de llaves", "44:6d:29", 44.2, 57.3);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Linterna de baterías", "04:c6:eb", 64.2, 94.6);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (3, "Cemento", "73:96:ed", 46.6, 64.0);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Pico", "0a:57:ec", 7.2, 13.3);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Codos", "30:ce:50", 42.7, 57.7);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Amarres de nylon", "48:0d:18", 17.6, 25.5);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Clavos", "c5:a5:4e", 38.7, 53.9);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Calzado de seguridad", "eb:ca:cd", 19.4, 25.0);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (1, "Sopletes", "fd:b1:3e", 9.7, 12.2);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (3, "Candados", "5e:56:f2", 51.8, 69.6);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (2, "Pala", "16:fd:cd", 35.2, 69.8);
INSERT INTO productos (est_id, prod_nombre, prod_etiqueta, prod_costo, prod_precio) VALUES (3, "Tenazas de corte", "12:56:63", 27.6, 52.4);


-- ############################################ almacenes_productos ############################################

INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 1, 53);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 2, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 3, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 4, 83);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 5, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 6, 99);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 7, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 8, 14);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 9, 87);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 10, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 11, 32);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 12, 21);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 13, 29);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 14, 53);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 15, 50);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 16, 16);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 17, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 18, 77);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 19, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 20, 56);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 21, 16);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 22, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 23, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 24, 5);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 25, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 26, 46);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 27, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 28, 84);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 29, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 30, 36);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 31, 40);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 32, 20);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 33, 50);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 34, 6);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 35, 29);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 36, 92);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 37, 0);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 38, 20);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 39, 77);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 40, 93);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 41, 5);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 42, 68);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 43, 15);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 44, 72);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 45, 79);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 46, 65);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 47, 94);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 48, 96);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 49, 76);
INSERT INTO almacenes_productos (alm_id, prod_id, alm_prod_stock) VALUES (1, 50, 63);


-- ############################################ productos_categorias ############################################

INSERT INTO productos_categorias (cat_id, prod_id) VALUES (8, 32);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (10, 46);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (9, 1);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (11, 15);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (5, 19);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (10, 23);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (9, 27);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (9, 25);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (9, 50);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (1, 30);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (1, 31);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (4, 47);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (5, 1);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (5, 22);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (3, 23);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (3, 40);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (5, 49);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (1, 6);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (8, 22);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (2, 5);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (8, 44);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (11, 1);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (11, 28);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (5, 15);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (9, 37);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (5, 27);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (4, 16);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (1, 2);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (10, 48);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (4, 29);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (6, 39);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (8, 33);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (8, 14);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (11, 34);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (2, 50);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (10, 5);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (2, 45);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (7, 49);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (6, 7);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (4, 28);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (1, 3);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (5, 9);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (10, 11);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (5, 16);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (7, 10);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (1, 23);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (2, 24);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (2, 18);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (9, 12);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (2, 49);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (9, 28);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (7, 17);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (4, 36);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (2, 4);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (11, 43);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (3, 44);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (11, 44);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (8, 35);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (7, 13);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (6, 21);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (9, 26);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (8, 42);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (11, 4);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (3, 11);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (7, 38);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (6, 36);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (7, 42);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (10, 41);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (4, 33);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (11, 20);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (10, 13);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (5, 8);
INSERT INTO productos_categorias (cat_id, prod_id) VALUES (2, 37);


-- ############################################ Proveedores ############################################

INSERT INTO proveedores (prov_nombre, prov_ruc, prov_celular) VALUES ("Victor Ramon Figueroa Castillo", "96761017456", "+51992906031");
INSERT INTO proveedores (prov_nombre, prov_ruc, prov_celular) VALUES ("Emiliano Fernando Castro Vargas", "99469353982", "+51992906031");
INSERT INTO proveedores (prov_nombre, prov_ruc, prov_celular) VALUES ("Marco Iker Godoy Escobar", "69486507230", "+51992906031");
INSERT INTO proveedores (prov_nombre, prov_ruc, prov_celular) VALUES ("Emma Laura Soria Cardozo", "92108002832", "+51992906031");
INSERT INTO proveedores (prov_nombre, prov_ruc, prov_celular) VALUES ("Samantha Lucia Villalba Ramirez", "89381847499", "+51992906031");
INSERT INTO proveedores (prov_nombre, prov_ruc, prov_celular) VALUES ("Delfina Guadalupe Caceres Farias", "57616711858", "+51992906031");
INSERT INTO proveedores (prov_nombre, prov_ruc, prov_celular) VALUES ("Francisco Santiago Morales Ruiz", "49174406980", "+51992906031");
INSERT INTO proveedores (prov_nombre, prov_ruc, prov_celular) VALUES ("Silvia Trinidad Cruz Hernandez", "56718280637", "+51992906031");
INSERT INTO proveedores (prov_nombre, prov_ruc, prov_celular) VALUES ("Emiliano Benjamin Arce Torres", "48747773554", "+51992906031");
INSERT INTO proveedores (prov_nombre, prov_ruc, prov_celular) VALUES ("Matias Alberto Vega Franco", "26605800067", "+51992906031");


-- ############################################ Proveedores_Categorías ############################################

INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (11, 4);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (2, 8);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (1, 3);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (2, 7);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (7, 4);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (2, 4);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (2, 3);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (8, 9);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (2, 2);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (5, 10);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (9, 10);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (11, 9);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (3, 3);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (3, 7);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (1, 10);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (5, 4);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (9, 2);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (4, 8);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (11, 8);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (7, 2);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (6, 7);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (3, 6);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (10, 5);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (6, 10);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (5, 5);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (11, 5);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (9, 1);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (7, 5);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (11, 10);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (11, 2);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (6, 1);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (3, 1);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (1, 1);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (11, 3);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (10, 2);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (11, 1);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (2, 6);
INSERT INTO proveedores_categorias (cat_id, prov_id) VALUES (2, 9);


-- ############################################ Usuarios ############################################

INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Trinidad Andrea", "Rios Mendez", "25279476", "trinidamendez", "b08c5979d316e38e6dea46a9a98d109f7e46fc737bdcf8b486690e19e16de610");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Amala Amalia", "Lucero Ortiz", "98559865", "amalaortiz", "0e69649386700b639730d95d9f7af590209f582f473392048eb5149522b69646");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Maritza Genesis", "Maidana Castillo", "88969358", "maritzacastillo", "cba5387bea8715ddd8d302640aec94651b4c10c997c292ec4c11767958b5b17c");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Marina Alma", "Mendez Olivera", "37356651", "marinolivera", "a3d6c639bc23d30b0c0e04c725ccf30a0406090123f19e28f0a634f576d87810");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Ana Dolores", "Mendez Martinez", "60344173", "anadmartinez", "479d8cc416c6ea97123f0cae252b021df27a16dc4f9bfa1742bb826987f16afc");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Claudia Camila", "Ojeda Arias", "95100159", "claudiaarias", "99c4db42742ad25bb4f87318661d3128f5b41f3acfa096431bc0fae7d67df519");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Laura Antonia", "Soria Castillo", "35962196", "lauraastillo", "4c560ee6800387e55d2b25d070d921ed1f3a583bf29484f0fb2ae079a1884273");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Gabriela Morena", "Aguirre Castillo", "18335960", "gabrielcastillo", "68d3979ba0d4808e84d08a1087e8885b41287d961cd440dede664028ec1543db");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Eduardo Santos", "Hernandez Mansilla", "47306235", "eduardomansilla", "c368cd0c725c2a84fe832dd320cf40679522ff6e8fdc212f9d2ba43b51c8e40e");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Dayana Mariangel", "Medina Navarro", "23443384", "dayanamnavarro", "02d7dff4dfb4dfeddfdb6f3631efbaab7f7f6844f66ac1a96c5eceee0a4b0e6a");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Beatriz Isabel", "Herrera Sosa", "39657708", "beatrizasosa", "755de51b3796a99ac0f4c7e6939f59c7c3cf10d701155a31b619e5ac29f88640");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Luz Isabel", "Leguizamon Luna", "15844149", "luzimonluna", "5e577f4ea9a992f63f08a0ca842a5ad980063f2c732c658f45eae50b75e7d320");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Juan Jayden", "Correa Rojas", "33427931", "juanrojas", "65d3b568726469b862511964a3464a0ec83e1839fcebadc0225f5ee91d0d6bca");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Alexander Juan", "Montenegro Ortiz", "13617985", "alexandroortiz", "3e668797d65ccd5a5fbcfe9f79bd99b01fcab1880ce2a307df8a8187beb13566");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Rosa Danna", "Morales Rivero", "37570803", "rosarivero", "5d548acb37a613306764ef4b93dec06f48a91038998cab078ea0134ec9a63bf5");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Nelson Hugo", "Martinez Soria", "73901790", "nelsozsoria", "165dc2452cf43dd374d6cdd1a7f77912c9a6cd3e28d8df9be79e416416c55206");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Emilio Eduardo", "Garcia Ramirez", "64924549", "emilioramirez", "a3e877c4369131c45149194b09c2d73ce89e24ed89efd7d80a48774b2ce28959");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Alonso Bautista", "Leiva Roldan", "78555341", "alonsoroldan", "f61685d745ff8c1b9cf3bdcad3d413ce3b53153ac910ba8fc15f02a8fa160a00");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Gabriela Raquel", "Franco Rojas", "23743103", "gabrielrojas", "73463133e46ca2e839d3934fd544cd97d1b3e838b5993eba75f3a47bccf834e6");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Fernanda Alicia", "Caceres Ruiz", "59949311", "fernandsruiz", "6970293cf1db3b1501bdff4ea0ab562d733cd2cf52761d76aabd892864212048");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Ricardo Alejandro", "Quiroga Vargas", "37212088", "ricardovargas", "07b39ce9b23f19b709d80fb56b17532e9409293f675cb314cd6e891f163fe7c2");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Josefa Yanelis", "Medina Arias", "99533120", "josefaarias", "216355423ad3567cf2323d115eb09ffcbb198967d336b3d7a2e6b378497cabd5");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Gabriela Rosmery", "Andrade Soria", "16734984", "gabrielaesoria", "c41c8fa6dc7188a28466bc301163a7c928c45a29205a4624653ad5409d7afbbb");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Diego Gregorio", "Rios Herrera", "37304011", "diegogerrera", "b8e6d55d5f58fd0afbc4bacce56377db13ffc735de5bd5b5b51e40f24eecbc37");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Jose Erik", "Farias Molina", "12197852", "josemolina", "5bca4d70a8997bf5ac39bfb9c52f7449cd4bcb5da8853ebce2fc0d27c3112b5a");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Ana Sofia", "Cruz Lopez", "88393713", "analopez", "2a4c8b680ffccfdcc09ab0ebe35dd41d1ad3fc2395cdf023fc04671204911821");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Lidia Roxana", "Benitez Mansilla", "42608180", "lidiamansilla", "1e653266d7fd92a8a419e3a564bbf84097b30f38cb9af99ed2fd100015d534f3");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Samuel Rafael", "Gimenez Montenegro", "70375759", "samuelontenegro", "7da9af93ea9025f6a9c7e5111e9a40525f0480c02fe97a2a5753fc188a61f91f");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Justin Lautaro", "Toledo Paz", "70763081", "justinopaz", "a28298a4fa01737e50a2ae5f8747f58ba7e9e37bf54c1496056c1dc8b95b1413");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Trinidad Daniela", "Ramirez Romero", "71842116", "trinidadromero", "3ab3ed1aea67486b0b54f844de7e0be0f2a641142f8dd16a7bf72f86fd07e427");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Marina Olga", "Coronel Suarez", "32581077", "marinsuarez", "32dfe1868075f03519d2e9515bb2fee991081148c5f40fc204a2879bbf81d483");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Bautista Lucas", "Alvarez Leiva", "23171480", "bautistzleiva", "effa8f5d56b50cf8f3a3f6f1c996e4a42431d068a340e040a1926ba8a18d2e33");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Daniela Noemi", "Moreno Lopez", "99049073", "daniellopez", "c90bd81d23568ba8a90b7e1dc9360745c66e136c56821b2840f9b11adae876e6");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Ignacio Lautaro", "Rojas Vera", "31149711", "ignaciovera", "8aa8269dbfc93438218bd15a04a37f8196e4285f75ac0f8239fadc0896cf7634");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Angel Pablo", "Silva Sanchez", "25622136", "angelsanchez", "ba2571bc7f13d41a6ed162a13ddca7d2bad51ffdde1694ff5b25c1e992fa470d");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Belen Amala", "Flores Ojeda", "30616307", "belenojeda", "e6413786008a41310b6791e88bf16b83389556b38c92f103a4ae8ddb06b40c7f");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Jose Cristobal", "Sosa Ortiz", "36325653", "josecrortiz", "1e644c6d3d292cad43bc8d480eab33734f6341c18aa3751545f97dfebc16df91");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Marco Emilio", "Moreno Morales", "57471016", "marcomorales", "50efd7db55564fa43c60bde9e70bd2a3444cd91fcccdbd25584f9bb3de86e7e7");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Luisa Leticia", "Caceres Aguirre", "97157652", "luisaaguirre", "998d5cc9d4dae66b44280574281afdb15ce9a72d40ceabfeb84c376e6bb19574");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Jeronimo Adrian", "Morales Luna", "91989074", "jeronimsluna", "4c3bf41c14e7c16e8edec1752288089dd87842226e3c92c9c83477d34b0dabe1");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Rafael Emiliano", "Arce Avila", "21984008", "rafaelavila", "54b5fa4f34db5ede2f6cf464a36d1781d3b7dd112391dc532ef35132fff5e099");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Antonella Sonia", "Mansilla Ponce", "15752478", "antonelaponce", "24553e937427389a6b665543a1cf2b37b8edc87ebc80e0117928dba9565e58c4");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Iker Javier", "Leiva Paez", "48207987", "ikerpaez", "52d62762983695b5fa6f879227e9ca9a68dea0c13372ca6d19b7f1998b074f0b");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Gabriela Alaia", "Duarte Vargas", "61224845", "gabrielvargas", "6656f71e791bdadb7c62c5b5ca43f1cc463a99f43984b1119dc686f363a97e24");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Jeremy Gustavo", "Villalba Soto", "88304296", "jeremybasoto", "59736d4914ce8768d4dd75e6d4d7ef30bf00d71707504dac7fd39fd9dc9638c2");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Oscar Adolfo", "Franco Fernandez", "23038033", "oscarernandez", "57d347fe15cbc2700ee639051d2b7c475227fea4450a54bc8f83813fe9261847");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Mercedes Emily", "Ramirez Suarez", "22156165", "mercedesuarez", "7d137c540c696e5b8318f9699c905f9aac13ea87819bbec02bf5262be407c36a");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Daniel Ignacio", "Quiroga Ramirez", "25664507", "danielramirez", "451e48a200dbbba46d415288bfa1e2be01a814d76db6ea7d27f794ce7435d54d");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Abigail Kamila", "Correa Moyano", "45466480", "abigailmoyano", "f3384fd6748d2ce0b86ce5e9412ba5f67f81717d56714335897b81b6ebface82");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Felipe Gaspar", "Beltran Paz", "81967974", "felipeanpaz", "a37930b09d11a52a64244cf4feee69280da5e48efe6541cf1f99c2113eb74740");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Alana Zoe", "Rios Maldonado", "39663296", "alanldonado", "35073add962c90ad17363882b356af986f7d42d8e0d6a44a8b7d75afe63e2472");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Francisco Lorenzo", "Campos Beltran", "51583407", "franciscbeltran", "6032b87b168140134835435ca8763af18403d6ccacc5f52e4284ed3ed2619d5c");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Fernando Esteban", "Mendoza Juarez", "86983812", "fernandojuarez", "d6ab44d74d4b852767893a1d81a72ca0ba982d2e4a63e878475343a7da690dde");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Lian Carlos", "Figueroa Martinez", "61933892", "lianmartinez", "3ec87bb415bc97c5048e8bf3111d8bab055855aec020faa3dc8b363e7d53b044");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Luciana Carmen", "Roldan Paez", "36186642", "luciananpaez", "92da838ea8fa6cfc6070a9844f98e7ed978c080ff6631958d4f710e0e7a42577");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Josefa Carolina", "Herrera Perez", "31380571", "josefaaperez", "2679d36760c6aa311dcf000d7806255471fa98df1811cd8323a96bd1c7a03096");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Jeronimo Tomas", "Moyano Cruz", "46431972", "jeronimocruz", "0ff08db55aa9a4f7e594d033ca0417e800d67a901e4976e88bd11bdee2076382");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Kamila Celeste", "Ojeda Ruiz", "80178093", "kamilaruiz", "952067ae37d7aa6c1d26e63ce392afc587d50a4eb969ca0014ee1a895d87ac8e");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Manuel Lucas", "Rios Diaz", "72845663", "manueldiaz", "1ed28f6875dfea3422a07f033530c78a977cccc470dc58ec80e8213366892aab");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Emily Valentina", "Benavides Garcia", "65813883", "emilyvsgarcia", "abff69a28a96e889d80d3de5409b720d2f793d4fb8a4972b4862bc301f0e9040");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Andres Adolfo", "Rivero Rodriguez", "30337490", "andresodriguez", "8b85565b9059660816d5d134475e7ec6699fc3f6b858f903736526e149c3671f");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Ricardo Maykel", "Castro Alvarez", "42492588", "ricardoalvarez", "09cfda8c7440cb1f3bfa0cd60d840acb3dd3a83e016b8638ab01682a9a69b67c");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Felipe Pedro", "Benitez Vega", "11376857", "felipezvega", "e41e42f39f4f6bf19944af1c79110aaafe7b707ffc748cfdbdc350b374e41851");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Daniela Lucia", "Lucero Maldonado", "24158990", "danielaldonado", "ee18e42116dc769430b25aab0b702d0281b2c8fc08ac539bf66cb22e307c619c");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Laura Amala", "Cordoba Luna", "13213020", "lauraaluna", "2685a24584441db8161b998a38faabc9b6b6b770695c229958897aee48412397");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Samuel Ian", "Beltran Flores", "29298642", "samueflores", "b0a98c56cd68af38ff395df6fba41ab7be0fdfb9bd2836d9e0d1026de723710f");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Abril Carmen", "Benitez Rojas", "16506939", "abrilzrojas", "fa7f05cbb48d98fdb06197247f5e955ac6dc935cf2e4d2e0d06c56cb28ee5dce");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Antonia Dulce", "Hernandez Ponce", "91630644", "antoniezponce", "c7b92e62b8640f1d4cb4d19c2708650511ee6b36b45a31b020b42f87efeb1ca8");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Matias Benjamin", "Maidana Mendez", "65589377", "matiasmendez", "bcc68bde1b9353ea766fa211aef95046d22ed2db4eea982ec442a079e895428b");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Ignacio Santiago", "Gimenez Castillo", "26218865", "ignaciocastillo", "2d7d2d46127d7763c753d4098c18fb29314505a9c90ec75a060e56806fc6186f");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Paula Morena", "Paz Ponce", "32239455", "paulaponce", "10ab46fb5fa5289025e74f8464f7753216dd6dcefeba913b4f08090a4b9e09c7");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Roxana Amanda", "Toledo Campos", "89320123", "roxanacampos", "f162475734c46b23208706342f12bf24ebf1ad76447fba981e344dacf84f4d65");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Gaspar Emiliano", "Villalba Franco", "28272637", "gasparafranco", "2782afcaafc6670162e62c7433c29227ac8d6d1553a7642a1527211aaf1f2826");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Hugo Ernesto", "Ramos Gonzales", "91467869", "hugoeonzales", "80646482762ff7e47c39e7aaadee71450d7366155c019671a8f58b72b1f2a61b");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Kamila Patricia", "Ramirez Sosa", "85479889", "kamilazsosa", "6262e0c41abe025fafd68ea49804d3180065d613653ff250268b8a95acd013f6");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Lidia Valeria", "Garcia Diaz", "41625297", "lidiaadiaz", "7fa787da98b32a6c322491c08c89f0c7010cc92483ddd4dcfe703094879f5ca9");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Isabel Sofia", "Carrizo Farias", "32449305", "isabelfarias", "d1d41a5722b8f9ff5d0971b7b551bbba4d244be466b145bd0bb912f35b5efdac");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Rafael Dylan", "Beltran Correa", "25516328", "rafaelcorrea", "e9bde7d2b713e2ce6c117c1bab383f5510452584e0780eca32a753e7d1d5e3fd");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Yake Victor", "Nunura Baylon", "54840289", "yakenunura", "8e3eb870192db143ad2c402153261295a803c889c059bb8bb77ffa694869e514");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Carlos Alberto", "Quispe León", "28272545", "carlosquispe", "d6603231d753a675b7f6aa06378cf61317e51330e3a051b3d73f3516d25bf8ae");


-- ############################################ Cotizaciones ############################################

INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (270, 45, 24);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (440, 22, 7);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (260, 80, 20);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (440, 58, 33);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (140, 14, 9);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (420, 18, 23);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (420, 6, 26);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (450, 9, 46);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (90, 32, 25);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (440, 25, 28);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (300, 27, 5);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (420, 38, 14);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (290, 48, 27);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (320, 54, 12);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (390, 15, 1);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (430, 6, 23);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (360, 44, 30);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (470, 42, 43);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (250, 79, 49);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (300, 40, 7);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (300, 46, 47);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (130, 52, 35);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (330, 32, 24);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (190, 26, 29);
INSERT INTO cotizaciones (cot_cantidad, usu_id, prod_id) VALUES (440, 48, 48);


-- ############################################ Cotizaciones_Proveedores ############################################

INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (1, 2);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (2, 1);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (3, 6);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (4, 9);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (5, 6);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (6, 1);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (7, 2);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (8, 7);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (9, 1);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (10, 7);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (11, 5);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (12, 10);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (13, 4);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (14, 7);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (15, 5);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (16, 10);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (17, 8);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (18, 3);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (19, 7);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (20, 9);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (21, 10);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (22, 9);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (23, 5);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (24, 1);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (25, 5);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (15, 3);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (24, 6);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (4, 1);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (19, 4);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (8, 9);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (12, 3);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (9, 6);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (4, 5);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (5, 9);
INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES (4, 4);



-- ############################################ Pedidos ############################################

-- Estados ----> 1: Terminado; 2: Pendiente; 3: Cancelado"

INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 42, '2022-03-15');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 58, '2022-03-12');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (3, 37, '2022-03-05');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 61, '2022-03-22');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (3, 2, '2022-02-18');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 16, '2022-01-21');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (3, 26, '2022-03-01');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 68, '2022-04-25');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 18, '2022-03-06');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 18, '2022-03-17');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 78, '2022-03-13');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (2, 33, '2022-03-26');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 66, '2022-04-16');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 38, '2022-03-17');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 52, '2022-03-18');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 55, '2022-05-08');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 4, '2022-05-10');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 33, '2022-05-03');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (3, 22, '2022-05-03');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 46, '2022-05-04');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 73, '2022-05-11');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 25, '2022-05-03');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 40, '2022-05-07');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 2, '2022-05-04');
INSERT INTO pedidos (ped_estado, usu_id, ped_fecha) VALUES (1, 57, '2022-05-01');


-- ############################################ Pedidos_Productos ############################################

INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (19.4, 6, 45, 16);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (10.9, 9, 43, 22);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (42.9, 2, 22, 19);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (15.3, 1, 19, 7);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (10.6, 6, 43, 13);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (42.2, 2, 48, 8);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (23.2, 8, 6, 3);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (41.5, 6, 6, 24);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (12.7, 3, 32, 21);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (41.0, 2, 16, 4);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (37.8, 3, 47, 6);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (33.8, 7, 20, 18);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (6.5, 4, 21, 14);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (19.4, 9, 44, 2);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (32.0, 6, 39, 9);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (33.7, 7, 35, 12);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (13.2, 10, 5, 1);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (14.8, 9, 41, 20);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (21.4, 3, 15, 23);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (31.2, 4, 3, 17);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (18.5, 2, 15, 15);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (10.7, 5, 29, 10);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (7.7, 1, 37, 25);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (19.7, 6, 3, 5);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (27.5, 3, 25, 11);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (22.1, 9, 37, 9);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (22.9, 5, 31, 10);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (37.3, 4, 6, 5);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (27.2, 9, 47, 23);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (19.1, 4, 50, 19);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (17.7, 7, 1, 15);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (33.5, 9, 49, 3);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (12.4, 7, 3, 16);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (33.9, 3, 17, 15);
INSERT INTO pedidos_productos (ped_prod_precio, ped_prod_cantidad, prod_id, ped_id) VALUES (12.9, 5, 31, 5);


-- ############################################ Reportes ############################################

INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Quiquia dolorem tempora modi dolore adipisci ", "Non modi dolore dolor non quaerat neque quisquam. Labore neque sit numquam quisquam ipsum. Est sed voluptatem porro non labore sed labore. Non ipsum etincidunt dolorem quaerat sit labore quaerat. Ut dolore est porro voluptatem.", "2022-01-14", "2022-06-13", 64);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Quiquia velit sit quaerat ut magnam. Dolor se", "Quisquam quisquam porro est. Numquam quiquia modi quiquia. Labore adipisci porro dolore. Modi quiquia tempora sit est quisquam quaerat. Est ut velit amet. Velit ipsum eius labore labore eius quiquia voluptatem. Sit etincidunt magnam dolore quisquam. Ipsum quiquia adipisci adipisci. Numquam voluptatem ut ipsum quaerat tempora dolor.", "2022-03-27", "2022-06-13", 62);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Tempora quiquia dolore ipsum ipsum. Labore se", "Consectetur aliquam neque porro. Dolore consectetur sit adipisci eius ut. Quisquam dolore dolor neque numquam. Ut magnam neque amet quisquam aliquam. Dolore amet voluptatem adipisci est porro. Magnam neque labore eius modi modi numquam etincidunt. Amet amet est est eius amet. Consectetur porro consectetur numquam voluptatem tempora sed.", "2022-02-10", "2022-06-13", 41);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Numquam porro dolore ipsum. Consectetur non d", "Aliquam quaerat labore est non. Adipisci eius dolore porro quisquam dolor sit. Quiquia quisquam dolorem sit aliquam amet quiquia consectetur. Porro labore ut voluptatem dolore velit. Est est ipsum porro ipsum quiquia amet est. Tempora labore ut dolor dolorem neque. Non modi adipisci quaerat dolor est modi dolore. Voluptatem ipsum est non labore. Modi porro quiquia porro labore dolorem. Magnam labore quaerat dolor.", "2022-04-04", "2022-06-13", 53);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Dolorem est modi porro adipisci quaerat. Temp", "Etincidunt magnam magnam aliquam modi dolorem. Voluptatem eius neque quisquam neque sed. Etincidunt sed etincidunt quiquia quisquam neque adipisci dolore. Dolorem dolorem sit quaerat. Voluptatem etincidunt quiquia quaerat dolore. Etincidunt sit sit eius sed quisquam consectetur. Sed quisquam quaerat neque. Dolore magnam non ipsum dolorem sit.", "2022-05-04", "2022-06-13", 36);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Porro velit etincidunt dolore ipsum porro ips", "Magnam voluptatem dolore quisquam neque. Magnam neque etincidunt voluptatem magnam magnam modi labore. Sed voluptatem labore quisquam ut ipsum. Sit quiquia non est. Quisquam dolore consectetur sit ipsum ut tempora. Velit dolore quaerat quisquam dolor.", "2022-03-07", "2022-06-13", 1);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Dolorem dolore quisquam quisquam quiquia quiq", "Est dolorem tempora adipisci. Adipisci est magnam sed sit amet. Ut etincidunt consectetur ipsum sed consectetur. Sed magnam quisquam amet ut. Quaerat ipsum dolorem tempora non dolorem.", "2022-04-04", "2022-06-13", 60);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Ipsum tempora est quiquia. Aliquam eius porro", "Sed non quiquia quaerat porro labore non. Ipsum aliquam quiquia neque. Neque quaerat sit sed. Consectetur quaerat dolore aliquam modi eius sit. Quiquia adipisci quaerat dolore modi magnam velit consectetur. Dolore adipisci ipsum porro porro dolorem non etincidunt. Sit amet numquam quaerat dolorem est. Numquam quisquam velit ipsum magnam etincidunt ipsum.", "2022-04-16", "2022-06-13", 12);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Neque adipisci ipsum dolorem aliquam eius num", "Dolor quaerat sed numquam dolorem labore. Labore velit quiquia ipsum. Ipsum dolorem quaerat non adipisci quiquia modi tempora. Velit ut adipisci amet numquam eius etincidunt eius. Porro quaerat ipsum ipsum voluptatem ut voluptatem neque. Velit consectetur velit dolor porro numquam dolorem dolor. Dolore non porro quisquam eius. Amet aliquam quiquia dolorem quaerat neque velit aliquam. Dolore quaerat neque amet voluptatem.", "2022-02-15", "2022-06-13", 15);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Dolorem sed dolore non. Quisquam labore dolor", "Ipsum est sit neque. Modi etincidunt voluptatem adipisci. Est consectetur quaerat magnam numquam velit quiquia. Non ut sed sed aliquam amet voluptatem. Neque magnam quaerat quisquam dolor dolore dolor. Magnam dolor adipisci numquam velit. Dolorem dolor labore velit dolorem magnam tempora.", "2022-05-27", "2022-06-13", 35);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Sed amet labore dolore est. Quisquam amet neq", "Modi velit tempora sit numquam sit eius. Sed amet est velit dolore dolorem. Quaerat modi neque neque voluptatem voluptatem voluptatem quisquam. Dolorem dolore dolorem velit neque quaerat quisquam neque. Consectetur ut eius eius quaerat eius velit. Quaerat dolor est aliquam ipsum. Amet dolorem sit dolor. Ipsum quisquam dolore quaerat.", "2022-02-08", "2022-06-13", 33);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Est eius est dolorem voluptatem. Neque quiqui", "Numquam sit ut tempora eius aliquam. Voluptatem voluptatem amet ut quiquia amet adipisci. Ipsum sit quiquia labore quisquam. Neque velit quaerat quiquia etincidunt est. Quisquam eius dolorem numquam dolorem dolorem sed. Velit etincidunt porro eius.", "2022-04-19", "2022-06-13", 22);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Est amet quiquia ut. Non amet adipisci dolore", "Sit adipisci velit voluptatem dolore dolore. Dolor dolorem quaerat neque dolore modi modi ipsum. Adipisci labore ipsum sit numquam. Neque numquam quiquia amet eius eius adipisci sit. Numquam dolore quisquam tempora velit magnam voluptatem dolorem. Ut sit consectetur amet. Voluptatem porro consectetur neque dolore consectetur non dolor. Amet consectetur non amet velit numquam sit. Aliquam voluptatem quaerat numquam amet ipsum.", "2022-05-24", "2022-06-13", 75);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Eius ut labore magnam adipisci ut quaerat. Am", "Quiquia tempora amet tempora neque quaerat. Etincidunt modi quaerat sed dolor dolor sed modi. Dolorem sit labore etincidunt adipisci quaerat tempora adipisci. Est voluptatem amet sit. Modi sed quaerat voluptatem.", "2022-05-19", "2022-06-13", 63);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Neque consectetur amet porro etincidunt conse", "Modi magnam sed etincidunt ipsum. Neque est quaerat porro dolor etincidunt consectetur consectetur. Est quaerat dolore adipisci amet amet voluptatem. Ut porro sit quiquia non quaerat sit aliquam. Eius neque quaerat voluptatem dolorem quiquia. Ut aliquam ut velit magnam tempora numquam. Sed quisquam quaerat modi.", "2022-05-21", "2022-06-13", 77);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Dolor modi etincidunt magnam adipisci neque v", "Sit velit ut dolore amet labore. Quiquia velit consectetur modi dolore neque non. Eius amet adipisci labore. Dolor ipsum quisquam non labore quisquam consectetur labore. Numquam etincidunt consectetur voluptatem. Adipisci amet ipsum numquam sed adipisci aliquam. Non est amet voluptatem ut voluptatem. Ut sit voluptatem dolore dolore.", "2022-04-16", "2022-06-13", 38);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Eius velit labore velit tempora velit tempora", "Voluptatem modi tempora numquam ut neque. Magnam neque porro aliquam est porro dolor ipsum. Quisquam amet sed amet quiquia magnam. Velit quisquam quiquia adipisci ut. Numquam sit numquam numquam. Labore labore voluptatem quisquam labore. Voluptatem numquam neque est consectetur. Amet ut velit est. Quaerat sed dolore modi. Dolore consectetur velit ut numquam adipisci.", "2022-03-20", "2022-06-13", 57);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Modi non amet sit sit. Voluptatem etincidunt ", "Velit magnam velit magnam sed. Dolor non ipsum quaerat ipsum quisquam sed. Consectetur dolor numquam magnam non etincidunt. Quaerat etincidunt porro ipsum. Amet numquam voluptatem adipisci. Porro quisquam est sit voluptatem non voluptatem. Porro voluptatem dolore ut est labore. Ut magnam modi tempora. Consectetur aliquam quiquia velit modi eius tempora.", "2022-01-13", "2022-06-13", 36);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Amet dolorem porro amet. Quaerat velit etinci", "Magnam neque velit dolorem amet amet dolor. Numquam numquam quisquam aliquam. Sit sed tempora porro magnam voluptatem. Magnam non non aliquam velit. Dolor non quiquia etincidunt est. Quiquia non non velit ut neque.", "2022-01-13", "2022-06-13", 63);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Modi adipisci labore dolorem ipsum. Labore al", "Ut dolorem quisquam numquam ipsum non porro. Etincidunt quisquam modi modi adipisci. Modi sed numquam quiquia dolorem tempora quisquam tempora. Eius consectetur sit numquam eius. Ipsum magnam sit magnam. Sed quiquia numquam ut consectetur modi. Amet voluptatem velit etincidunt quaerat dolorem. Quiquia voluptatem sit ipsum modi. Velit dolorem porro numquam consectetur ipsum tempora. Ut modi dolorem neque est numquam.", "2022-01-07", "2022-06-13", 37);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Ipsum labore ut consectetur est sed non conse", "Dolor non eius neque neque ipsum eius sit. Eius aliquam neque tempora dolor dolor consectetur. Aliquam neque labore ipsum ipsum etincidunt consectetur. Dolor voluptatem aliquam voluptatem. Voluptatem magnam non labore amet labore amet.", "2022-01-26", "2022-06-13", 64);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Quisquam ipsum aliquam sit velit. Eius aliqua", "Magnam etincidunt ut numquam aliquam sed. Ut labore labore quiquia. Modi dolor non tempora quaerat ipsum. Sed numquam ut dolor sit dolore voluptatem. Quisquam aliquam dolore sit sit eius labore. Neque velit quiquia est. Neque magnam modi sed magnam voluptatem.", "2022-04-23", "2022-06-13", 41);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Neque non non neque magnam. Est ut ut amet do", "Consectetur neque porro consectetur porro est neque neque. Amet modi consectetur non labore modi. Quiquia labore est dolor numquam dolorem. Ut dolor dolorem sed non non. Quaerat amet velit velit magnam neque. Sed porro non eius. Velit numquam amet consectetur dolore. Modi magnam magnam consectetur tempora.", "2022-04-10", "2022-06-13", 45);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Aliquam est ut dolorem. Sit sit sit adipisci.", "Dolor est labore non porro numquam quisquam magnam. Voluptatem consectetur eius quaerat. Voluptatem voluptatem porro ut ipsum quiquia. Dolorem modi consectetur amet eius porro. Voluptatem sit consectetur neque dolorem eius sed. Quisquam neque numquam labore ipsum. Sed labore tempora dolorem adipisci tempora.", "2022-01-26", "2022-06-13", 49);
INSERT INTO reportes (rep_titulo, rep_descripcion, rep_fecha_ini, rep_fecha_fin, usu_id) VALUES ("Quiquia labore adipisci eius numquam dolorem ", "Quiquia amet sit dolore modi. Tempora consectetur adipisci sit dolorem velit velit numquam. Amet quisquam magnam dolore. Ipsum amet sit non. Consectetur etincidunt quaerat ut etincidunt. Porro ut voluptatem tempora. Adipisci est sed modi dolor ipsum adipisci. Quaerat eius non est consectetur consectetur sit. Sed quaerat sed consectetur. Quisquam amet eius tempora ut tempora quisquam quiquia.", "2022-02-05", "2022-06-13", 70);


-- ############################################ Reportes_Productos ############################################

INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (50, 16, 16, 177.96, 7);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (43, 16, 21, 174.34, 10);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (6, 15, 24, 76.22, 5);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (31, 17, 16, 128.02, 9);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (11, 11, 13, 90.83, 7);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (36, 24, 22, 117.41, 9);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (47, 20, 13, 165.71, 5);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (32, 25, 15, 126.94, 9);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (3, 25, 23, 130.64, 5);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (30, 4, 5, 118.03, 5);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (15, 21, 15, 141.13, 9);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (32, 21, 10, 147.70, 7);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (50, 12, 23, 141.19, 6);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (45, 19, 8, 169.60, 7);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (2, 13, 17, 123.75, 10);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (37, 19, 16, 60.01, 5);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (46, 3, 15, 98.68, 5);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (18, 9, 18, 38.04, 5);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (7, 24, 21, 154.84, 8);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (9, 22, 25, 28.48, 10);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (18, 12, 9, 96.61, 8);        
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (34, 23, 23, 84.94, 9);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (49, 11, 17, 93.27, 9);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (7, 3, 11, 173.71, 7);        
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (48, 1, 20, 145.70, 6);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (13, 2, 24, 145.99, 8);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (10, 17, 24, 105.81, 8);      
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (9, 4, 20, 126.34, 9);        
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (26, 12, 8, 68.16, 9);        
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (42, 5, 5, 55.20, 7);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (22, 13, 19, 94.04, 9);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (19, 14, 22, 141.56, 10);     
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (15, 21, 23, 79.65, 10);      
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (18, 9, 5, 87.90, 7);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (16, 14, 16, 85.65, 8);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (43, 25, 15, 153.72, 10);     
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (22, 23, 12, 74.36, 8);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (44, 6, 18, 93.36, 9);        
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (11, 20, 15, 40.34, 8);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (9, 19, 12, 157.31, 8);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (37, 21, 8, 100.18, 7);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (49, 6, 6, 69.22, 7);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (46, 10, 16, 35.00, 7);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (26, 11, 6, 97.38, 7);        
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (20, 7, 6, 183.41, 5);        
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (3, 9, 25, 59.00, 7);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (35, 7, 20, 143.53, 7);       
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo) VALUES (41, 10, 9, 71.53, 9); 


-- ############################################ Configuraciones ############################################

INSERT INTO configuraciones (temp_limite, hum_limite, alm_id) VALUES (35.0, 75.0, 1);


-- Activa el trigger que corrige los estados

UPDATE almacenes_productos SET alm_prod_stock = alm_prod_stock;
