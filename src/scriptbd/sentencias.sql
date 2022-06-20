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

INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Cesar Bautista", "Ferreyra Ruiz", "65532694", "Cesar Bra Ruiz", "f04ab684c1042d2198e91b6b134460734ffd0dc7ff10f55d622391bb8d1ec30e");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Kimberly Agustina", "Maldonado Flores", "14195296", "Kimberlyo Flores", "c563eb0a58d8f53d88973b62298ab3a895deaf6da5380472cab2f600225d9f1f");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Javier Kevin", "Olivera Arce", "43827055", "Javiera Arce", "c8932547c9ac0596618555dadad60fe9afef1320a18dc0c130b3e3932292ae93");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Delfina Maite", "Gomez Navarro", "38737409", "DelfinNavarro", "6c4a8e51bb9b207af39e9c4ab74ef4ba53ecf1403ba28a4fe3658d92e171cf83");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Miguel Emiliano", "Martinez Castillo", "13299684", "Miguel  Castillo", "64c1decf7f940fd1a85f021d6aa01c8a5fc4cc3e48d86c8fb0a5311c9a58f88b");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Kiara Maite", "Villalba Peralta", "85764968", "Kiara Peralta", "8035299a2f71f7cafebc5546916acc73a3c9b124db8a1b3f3c343e58ac02ad48");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Francisco Ethan", "Ledesma Martinez", "21103682", "FrancisMartinez", "3ad2f8d0a5a6a40a5ef8f564bc5090302947a064afebb34e3ab61d63eec43434");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Patricia Dayana", "Gimenez Cabrera", "73030440", "Patrici Cabrera", "c20910e1d38a522294c007c00715d91049988fd33c419efc057ea309589f2bd6");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Laura Josefa", "Mendez Valdez", "88301247", "Laura  Valdez", "1b4ffb82cb952f568fdbdcb5d3689e263bb554d97b93cec07dbd2d79586a9bd1");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Cesar Ricardo", "Villalba Ruiz", "68438275", "Cesar ba Ruiz", "a82cb8781977d5086fdcaec7e70b6e09290731c5e8835ef41ab4ce0ad1ab9359");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Juan Jayden", "Vera Duarte", "73904853", "Juan Duarte", "3e0c9463dc2de300a7d472dd1955568f60498e69a5b3d2b5c32eb932dc17a385");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Genesis Reina", "Valdez Roldan", "16375885", "Genesi Roldan", "3996ce34566fe3cdb184f6a8b9909d9d82e13f818be31a086127e2fff27ea36f");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Trinidad Genesis", "Ortiz Valdez", "24613048", "TrinidadValdez", "f5db9fa8006f80dc29371a768df5ecedbc126b7c46ec130b567c6544356512ee");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Martin Benicio", "Ramirez Ferreyra", "24408255", "Martin Ferreyra", "90e73bd348adcdfaad793bd20db94d88a86e11a6a31217a3591d721c7bdc5dce");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Felix Esteban", "Juarez Avila", "45509836", "Felix  Avila", "a6272e26736cefea3aebad07bfbe8ae9b549d15abd83d2dcf761a260d7b7a5ba");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Bautista Emmanuel", "Moreno Hernandez", "97428890", "Bautistaernandez", "2e9a715e6f787c9ff771c54f6be664618abbc39459a552b35072252d34e6e024");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Olga Alicia", "Barrios Vazquez", "64195915", "Olga  Vazquez", "28edae033884d7a246aa569598f09c7c1b22714ad7ee252865f3c64a568af8d3");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Jorge Vicente", "Mendoza Rios", "56291343", "Jorge a Rios", "419d4a98fe8b87c38ae792caf61a98eb25da9df8d12a7df2e33b9d9fda266187");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Noemi Concepcion", "Escobar Leiva", "82695099", "Noemi Cor Leiva", "7b2a4564786e8c680bc82bd818d61007f62355299b24ab15ce58ac80aa27610a");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Carlos Ethan", "Blanco Alvarez", "14210241", "CarlosAlvarez", "2b48611abac2fcaea0be84ce22d1a5e588b48a52e8ec3cbb5ec58ade21c5c0b1");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Noah Ignacio", "Navarro Fernandez", "75709299", "Noah IFernandez", "f9ffad683505780cdb8e4f03393faa2a23dfed04717a629e2bd175f59f206020");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Roxana Ramona", "Maidana Godoy", "89028177", "Roxanaa Godoy", "6515f45a9a773d1ac9bacc766479fa033a8f02989dd6bed6131c4a6e8801a66a");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Kamila Carolina", "Alvarez Caceres", "88206087", "Kamila  Caceres", "bbcdddfcb2f20432f93dbc80ed24cd0a9070673c18910f27913fd8f218c13e79");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Jayden Facundo", "Silva Sosa", "26311805", "Jayden  Sosa", "90b52d103e8a63986e1590f4dbf9edef0411e7e7fdb61e2df0ecba482a0968ff");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Alba Claudia", "Mendez Rojas", "44653951", "Alba C Rojas", "5e82307f74a3f6ae909cba568d66b846f798914756b9478865cdffcc89b04cdd");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Belen Ramona", "Costa Lucero", "95713417", "Belen Lucero", "da1f4a1e6a3fda8adc0526eb7aae6cb801c6cbe298f54f64c48a145646371ff6");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Rafael Gustavo", "Mendez Paz", "85066034", "Rafael z Paz", "4e56fd0cc9dee6b9e8cb698f35b88b779446437989a536bd3ea6165a782fc020");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Facundo Joaquin", "Ramirez Caceres", "88843332", "Facundo Caceres", "905513153217844a6208d17b832eed8a9ceffac90b3f7c1d5a1bb2bd76a038e2");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Jose Andres", "Coronel Ruiz", "60508581", "Jose l Ruiz", "6597687d6a9be763711af8c820240f4532c8d7b1477e03ca42dc5cdd11fa404c");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Margarita Delfina", "Ojeda Leiva", "11363095", "Margarit Leiva", "7599e82bc26ae9cd774dad119067c5071415727210b1c99cfb711a18468ff94b");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Jorge Rafael", "Perez Costa", "43491712", "Jorge  Costa", "52dd5c08257e5972935e42f47250bf52c48262bf47eb1ccab626212929c5009e");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Esteban Adolfo", "Paez Gonzales", "72300828", "Estebanonzales", "e53488d355bba3c20e75ac62e580ab32306cb4cb893a5f42b0526e6e8070178b");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Kamila Concepcion", "Vargas Fernandez", "76014617", "Kamila Cernandez", "be1938e30e319aa7b90d30c9b24185456a3f8fdd351a47083f6e889baf83056d");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Tania Amanda", "Soto Chavez", "21977367", "Tania Chavez", "aa5bc24ea7a4bb36f9bfb185084ea40bacdd3c49dba8f246f38ef99dd1589210");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Agustin Martin", "Toledo Quiroga", "57847733", "AgustinQuiroga", "b580da151aebdaba4d9179c30093358000b28b30966c94f7535dfd82b7d771c3");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Alexander Vicente", "Ponce Romero", "54117469", "AlexandeRomero", "f03b7f665359b95ad6b0b70840513318bd3c70cb23d88ba3ddf0b27660e710a3");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Lisandra Mariangel", "Benavides Hernandez", "32961433", "Lisandra  Hernandez", "c2352796bcf3e7f71d364f7f44b9a01c60e30f8c249992650872b47b688a93b3");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Mariana Rosmery", "Soria Sanchez", "83759313", "MarianaSanchez", "ba4f2765cd3b2457779144a37f3507a3f958ed6234c9dc923fbb6c4bf10033a4");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Justin Victor", "Sanchez Paz", "64237052", "Justinez Paz", "9c7ea5b042e5615da1cc51c4cb4866d34b75cc39ee3ad2c0a64951ea98a21994");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Sophia Mariana", "Vera Ramos", "41343260", "Sophia Ramos", "50bc7cb2cc7853a7c0e204f001482c17bc9198b1ddbc6d0353998901bcd2eb50");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Julieta Elena", "Ruiz Romero", "93324866", "JulietRomero", "faffeda2baf89b4dce3d10b3446e6241052f072198d89d9ea81ab49e24c3a790");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Marco Jose", "Gomez Escobar", "79362168", "MarcoEscobar", "d7f07366fc87cd674ca764d9e2e41e30492264d3cfbe02334e96c0e6d4858f1f");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Raul Liam", "Chavez Bravo", "61179660", "Raul Bravo", "bc4879d9bb3e4325af8b7706392c3477d50acff4841ad410c7df3f366021388c");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Jayden Santos", "Franco Figueroa", "20631477", "JaydenFigueroa", "5558916787caf5ec1b6ee9531fafdd2ca7f4d33bee4f70c24f0360c54a9db5e1");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Justin Liam", "Paez Luna", "85280561", "Justi Luna", "5389e83599a7d350be7c5a57ee01c958560dd45d74548e5c2b7323ec936e3ed9");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Mikaela Dayana", "Farias Rivero", "82159163", "Mikaela Rivero", "e5e52e34b24915de3f64e5ae01cc8f014ee8f3e54dcf94f3fa66edbbb7f7f938");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Maximiliano Santiago", "Fernandez Franco", "93858437", "Maximilianz Franco", "69ee92e14a10088e6994b0d8f10b5bbea541c0917c50bf2070054451a0493aa1");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Briana Lisandra", "Duarte Leguizamon", "16411224", "Briana eguizamon", "4a7d90f4a103cae603c82f85dadd1e53653322d604968de9841c5ba0adfca290");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Celeste Amala", "Caceres Gomez", "99752515", "Celests Gomez", "f75d587e912f59b1b1a4ba07de2a8348085fd63f1ce6481e11ee216f8df21d41");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Luz Sophia", "Cardozo Cordoba", "78802115", "Luz S Cordoba", "a18170fc8eba6b5390392fd14fcbe7da2d28b8e1d3c5367ef29642116bdf0708");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Alba Mikaela", "Ferreyra Moreno", "66180817", "Alba Ma Moreno", "5ab020bf782454669ed7b0c80b454196fa74ddc98d20919fbcc60f8965563ff1");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Celeste Camila", "Soria Rios", "81392695", "Celeste Rios", "27a8db1b9b69964712a64667f4ceff92a4d328622a293febad06fcba1b6906b6");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Angel Alonso", "Quiroga Herrera", "32918293", "Angel  Herrera", "7881fa9ebf5b9f773bde13879438ddb218be7fea4346b6d281cb9d7d4298be22");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Yaima Elena", "Villalba Cruz", "40983402", "Yaimaba Cruz", "597a85c516123b5791690497a7419ed4261a82529e18d9069b75e719ce368784");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Liam Enrique", "Correa Diaz", "54773314", "Liam Ea Diaz", "64ef119d567a1908d77b1f017666d8954ce6d2b56a344da1d90eeef1200e2f93");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Dolores Fernanda", "Gomez Ojeda", "62880535", "Dolores  Ojeda", "b52209b00c126525cfd06fa84bca0fbf67a8d23a694f5243de06a05b6c0c07fb");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Julio Alejandro", "Ortiz Arias", "24519493", "Julio A Arias", "85b7dee931004d177fb4539f0d3498c6fa20b6acb5deefaa7ba8483dcc5b56f5");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Morena Julia", "Vera Aguirre", "76514428", "Morenaguirre", "86d1b1df0a1cd1d4320744ba97bd7d9d80a81469a9bc0500e058cfe4f523935b");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Oscar Iker", "Rodriguez Cordoba", "10159763", "Oscarz Cordoba", "a6b21cfa5c9120f730177ec97fbad5277b0ed3f2e34fb33b1956ead1aa764f3a");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Emmanuel Adrian", "Coronel Cruz", "57432801", "Emmanuel Cruz", "ffe75c4b276b2c9661c638df87a8f79aaf192f05d41804f30842131176cefe53");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Alejandra Abigail", "Rodriguez Ledesma", "56343681", "Alejandrz Ledesma", "3597083ea74b9299627aeeeab5f4802ecf648bc2af7f6196b8c61f3dfeda0dd6");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Ana Amanda", "Ramirez Cardozo", "19861176", "Ana A Cardozo", "6fd886a6b39f2e77ce0cbb26c1095b30c0dc81009bb9aba57c39ba9ced4cd991");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Santiago Lorenzo", "Quiroga Arce", "97550247", "Santiagoa Arce", "57ed22c82bd2838142675d4ffa922e6ac90d4436cc59dbe17de8d54c2a3997b0");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Iker Matias", "Gonzales Ruiz", "40660432", "Iker es Ruiz", "2aa5e10788068c1268b5c20ab29b78276b3b1dd982b4c809338589bc4c65e8f0");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Celeste Abigail", "Molina Vera", "12736772", "Celestea Vera", "59f9ea458d383b1a3f890117002169ff5c1a3917c92144c25296ea93f9750baf");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Florencia Alaia", "Andrade Castillo", "52661855", "FlorencCastillo", "dcdf8d3c41370c7c2c8a56b68bca30f7530ccd5e37869397beef2a6b0ccd8c18");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Ian Jesus", "Luna Flores", "67938185", "Ian Flores", "9528630a402ef29f9fd09b15a3408910a573022cce9a84f92258060e900afa79");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Jeronimo Maximiliano", "Lucero Valdez", "54904904", "Jeronimo M Valdez", "a04f777035eeb8e65a70aa02d03b85971ea9e9970a0a67268616c52e02d409f6");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Alonso Bautista", "Sosa Rios", "91846030", "Alonso  Rios", "a91e737853f3e633a4f4e09008aefff86bb83c2ba226b6bdba9f7a2569236da3");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Hugo Luis", "Benitez Gutierrez", "36680542", "HugoGutierrez", "b8e2eb5e41f5bdfcb75d0bd3b4ccbe35ea46e96876751e16f80787ba4d2cf8ba");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Emiliano Liam", "Moyano Godoy", "91991856", "Emilia Godoy", "b041ed40ec1bd5fa0d5252e273a20d0b25c80aff4452001669a9c6eefae85a98");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Alonso Jesus", "Pereyra Silva", "76830232", "Alonsoa Silva", "3f3f33542ade2dc433cff3bc015df0567ccbacb74e8d46b95583c62a6564be09");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Agustina Alejandra", "Cabrera Vega", "65744222", "Agustina a Vega", "ba880e4b2f1c1b8ec7bd38243b013aa0053e66191a49955de4930a7fb27ac3d5");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Yaima Mabel", "Mendez Miranda", "40018373", "YaimaMiranda", "cc2783e63f58c775a7b605549037f6ef185baf66564ece22cb07c7cd2fcfda79");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Oscar Roberto", "Ramirez Ramos", "79038258", "Oscar z Ramos", "bc9fa5e6ddf03111bb07b8f6601ef0f97c902b21b00afae7a0d116789f08521f");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Valentina Beatriz", "Moyano Mendez", "31856036", "Valentin Mendez", "1a7d1f336f1a95cc24412b48194bc26fc623ef27f52667a480b682991245babd");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Martin Santos", "Leguizamon Garcia", "24466436", "Martinon Garcia", "98629825efb1ca61169b91c4f7e71009f2ddf129c39a5af50274db0d07222737");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Zoe Mikaela", "Soria Moyano", "41468650", "Zoe MMoyano", "f5047588b165c43e0308dffdaed56db4dcd24c2e37ace50ee43b96e787666902");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Ariana Luisa", "Fernandez Farias", "59041377", "Arianaz Farias", "f1fedf22e267ef43449198b8bc500a923603776f39a77ad31823587931f7348c");
INSERT INTO usuarios (usu_nombre, usu_apellidos, usu_dni, usu_username, usu_contrasena) VALUES ("Gabriel Felipe", "Herrera Farias", "75203784", "Gabriel Farias", "9efe5d76cdcdca465bd3c807c3ac2844843579d4a43161db40521ccbc70f9cee");


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

INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (24, 12, 22, 124.89);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (3, 2, 6, 30.39);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (38, 19, 16, 179.31);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (6, 14, 22, 92.96);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (40, 24, 7, 44.42);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (25, 2, 10, 136.06);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (9, 18, 15, 58.92);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (32, 21, 19, 176.93);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (19, 17, 14, 146.88);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (47, 9, 11, 126.70);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (6, 7, 12, 123.88);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (34, 21, 17, 38.58);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (19, 9, 24, 54.79);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (18, 5, 23, 110.85);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (42, 3, 6, 101.82);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (38, 25, 5, 128.55);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (19, 1, 19, 110.22);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (29, 15, 7, 113.76);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (48, 16, 8, 86.40);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (13, 16, 23, 53.37);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (1, 8, 18, 53.34);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (30, 4, 24, 143.97);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (41, 14, 11, 160.76);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (43, 16, 7, 31.48);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (6, 14, 13, 105.24);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (24, 4, 15, 149.10);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (31, 23, 18, 170.86);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (30, 21, 19, 181.31);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (11, 12, 20, 93.64);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (23, 15, 20, 31.45);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (34, 7, 22, 46.89);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (4, 25, 9, 71.01);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (4, 7, 24, 122.12);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (38, 19, 22, 52.84);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (13, 7, 18, 91.11);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (2, 1, 21, 63.30);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (49, 18, 11, 67.30);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (31, 2, 6, 47.09);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (14, 5, 20, 94.43);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (24, 11, 11, 178.95);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (25, 18, 8, 160.54);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (35, 2, 5, 139.62);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (1, 10, 10, 45.42);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (24, 6, 20, 72.78);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (8, 5, 21, 57.23);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (18, 14, 13, 50.93);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (30, 14, 24, 62.84);
INSERT INTO reportes_productos (prod_id, rep_id, rep_prod_cant_vendida, rep_prod_total_ingreso) VALUES (39, 4, 7, 87.95);


-- ############################################ Configuraciones ############################################

INSERT INTO configuraciones (temp_limite, hum_limite, alm_id) VALUES (35.0, 75.0, 1);


-- Activa el trigger que corrige los estados

UPDATE almacenes_productos SET alm_prod_stock = alm_prod_stock;
