DROP DATABASE `lahormiguitadb`;

CREATE DATABASE IF NOT EXISTS `lahormiguitadb`;

USE `lahormiguitadb`;

-- SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

CREATE TABLE IF NOT EXISTS Usuarios (
    usu_id int AUTO_INCREMENT,
    usu_fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usu_nombre varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    usu_apellidos varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    usu_dni char(8) UNIQUE NOT NULL,
    usu_username varchar(45) NOT NULL,
    usu_contrasena varchar(85) NOT NULL,
    PRIMARY KEY (usu_id)
);

CREATE TABLE IF NOT EXISTS Pedidos (
    ped_id int AUTO_INCREMENT,
    ped_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ped_estado int DEFAULT 1 NOT NULL,
    usu_id int NOT NULL,
    PRIMARY KEY (ped_id),
    FOREIGN KEY (usu_id) REFERENCES Usuarios(usu_id)
);

CREATE TABLE IF NOT EXISTS Estados (
    est_id int AUTO_INCREMENT,
    est_nombre varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    PRIMARY KEY (est_id)
);

CREATE TABLE IF NOT EXISTS Productos (
    prod_id int AUTO_INCREMENT,
    prod_nombre varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    prod_precio float NOT NULL,
    prod_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    prod_etiqueta varchar(12) UNIQUE NOT NULL,
    prod_es_activo tinyint DEFAULT 1,
    est_id int NOT NULL,
    PRIMARY KEY (prod_id),
    FOREIGN KEY (est_id) REFERENCES Estados(est_id)
);

CREATE TABLE IF NOT EXISTS Pedidos_Productos (
    ped_prod_id int AUTO_INCREMENT,
    ped_prod_precio float NOT NULL,
    ped_prod_cantidad int NOT NULL,
    prod_id int NOT NULL,
    ped_id int NOT NULL,
    PRIMARY KEY (ped_prod_id),
    FOREIGN KEY (prod_id) REFERENCES Productos(prod_id),
    FOREIGN KEY (ped_id) REFERENCES Pedidos(ped_id)
);

CREATE TABLE IF NOT EXISTS Reportes (
    rep_id int AUTO_INCREMENT,
    rep_titulo varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    rep_descripcion text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    rep_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usu_id int NOT NULL,
    PRIMARY KEY (rep_id),
    FOREIGN KEY (usu_id) REFERENCES Usuarios(usu_id)
);

CREATE TABLE IF NOT EXISTS Proveedores (
    prov_id int AUTO_INCREMENT,
    prov_nombre varchar(45) NOT NULL,
    prov_celular varchar(12) NOT NULL,
    prov_ruc varchar(16) UNIQUE NOT NULL,
    prov_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    prov_estado int DEFAULT 1,
    PRIMARY KEY (prov_id)
);

CREATE TABLE IF NOT EXISTS Cotizaciones (
    cot_id int AUTO_INCREMENT,
    cot_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cot_cantidad int NOT NULL,
    cot_estado int DEFAULT 1,
    usu_id int NOT NULL,
    prod_id int NOT NULL,
    PRIMARY KEY (cot_id),
    FOREIGN KEY (usu_id) REFERENCES Usuarios(usu_id),
    FOREIGN KEY (prod_id) REFERENCES Productos(prod_id)
);

CREATE TABLE IF NOT EXISTS Cotizaciones_Proveedores (
    cot_prod_id int AUTO_INCREMENT,
    cot_id int NOT NULL,
    prov_id int NOT NULL,
    PRIMARY KEY (cot_prod_id),
    FOREIGN KEY (cot_id) REFERENCES Cotizaciones(cot_id),
    FOREIGN KEY (prov_id) REFERENCES Proveedores(prov_id)
);

CREATE TABLE IF NOT EXISTS Almacenes (
    alm_id int AUTO_INCREMENT,
    alm_nombre varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    alm_direccion varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    PRIMARY KEY (alm_id)
);

CREATE TABLE IF NOT EXISTS Almacenes_Productos (
    alm_prod_id int AUTO_INCREMENT,
    alm_prod_stock int DEFAULT 0 NOT NULL,
    alm_id int NOT NULL,
    prod_id int NOT NULL,
    PRIMARY KEY (alm_prod_id),
    FOREIGN KEY (alm_id) REFERENCES Almacenes(alm_id),
    FOREIGN KEY (prod_id) REFERENCES Productos(prod_id)
);

CREATE TABLE IF NOT EXISTS Temperaturas (
    temp_id int AUTO_INCREMENT,
    temp_valor float NOT NULL,
    temp_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alm_id int NOT NULL,
    PRIMARY KEY (temp_id),
    FOREIGN KEY (alm_id) REFERENCES Almacenes(alm_id)
);

CREATE TABLE IF NOT EXISTS Humedades (
    hum_id int AUTO_INCREMENT,
    hum_valor float NOT NULL,
    hum_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alm_id int NOT NULL,
    PRIMARY KEY (hum_id),
    FOREIGN KEY (alm_id) REFERENCES Almacenes(alm_id)
);

CREATE TABLE IF NOT EXISTS Reportes_Productos (
    rep_prod_id int AUTO_INCREMENT,
    rep_id int NOT NULL,
    prod_id int NOT NULL,
    PRIMARY KEY (rep_prod_id),
    FOREIGN KEY (rep_id) REFERENCES Reportes(rep_id),
    FOREIGN KEY (prod_id) REFERENCES Productos(prod_id)
);

CREATE TABLE IF NOT EXISTS Categorias (
    cat_id int AUTO_INCREMENT,
    cat_nombre varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    cat_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cat_estado int DEFAULT 1,
    PRIMARY KEY (cat_id)
);

CREATE TABLE IF NOT EXISTS Proveedores_Categorias (
    prov_cat_id int AUTO_INCREMENT,
    prov_id int NOT NULL,
    cat_id int NOT NULL,
    PRIMARY KEY (prov_cat_id),
    FOREIGN KEY (prov_id) REFERENCES Proveedores(prov_id),
    FOREIGN KEY (cat_id) REFERENCES Categorias(cat_id)
);

CREATE TABLE IF NOT EXISTS Productos_Categorias (
    prod_cat_id int AUTO_INCREMENT,
    prod_id int NOT NULL,
    cat_id int NOT NULL,
    PRIMARY KEY (prod_cat_id),
    FOREIGN KEY (prod_id) REFERENCES Productos(prod_id),
    FOREIGN KEY (cat_id) REFERENCES Categorias(cat_id)
);

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

-- ----------------------- Procedimientos -------------------------

CREATE PROCEDURE `PRC_ACTUALIZAR_PRODUCTO`(OUT P_ERROR_MESSAGE VARCHAR(48), OUT P_EXIST_ERROR TINYINT(1), P_ALM_PROD_ID INT, P_PROD_ID INT, P_PROD_NOMBRE VARCHAR(45), P_PROD_PRECIO FLOAT, P_PROD_STOCK INT, P_PROD_ETIQUETA VARCHAR(12))
BEGIN
	DECLARE V_EXIST_RELACION_ALM_PROD INT;
    DECLARE V_EXIST_PRODUCTO INT;
    
    SET P_EXIST_ERROR = 0;
	SET P_ERROR_MESSAGE = "Solicitud ejecutada correctamente";
    
    SELECT COUNT(alm_prod_id) INTO V_EXIST_RELACION_ALM_PROD FROM almacenes_productos WHERE alm_prod_id = P_ALM_PROD_ID;
    SELECT COUNT(prod_id) INTO V_EXIST_PRODUCTO FROM productos WHERE prod_id = P_PROD_ID;
    
	IF V_EXIST_RELACION_ALM_PROD <= 0 THEN
		SET P_ERROR_MESSAGE = "El producto especificado no existe en el almacén";
		SET P_EXIST_ERROR = 1;
	END IF;
    
    IF V_EXIST_PRODUCTO <= 0 THEN
		SET P_ERROR_MESSAGE = "No existe el producto especificado";
        SET P_EXIST_ERROR = 1;
    END IF;
    
    IF P_EXIST_ERROR = 0 THEN
		UPDATE productos
        SET prod_nombre = P_PROD_NOMBRE, prod_precio = P_PROD_PRECIO, prod_etiqueta = P_PROD_ETIQUETA
        WHERE prod_id = P_PROD_ID;
        
        UPDATE almacenes_productos
        SET alm_prod_stock = P_PROD_STOCK
        WHERE alm_prod_id = P_ALM_PROD_ID;
        
    END IF;
END; //

CREATE DEFINER=`root`@`localhost` PROCEDURE `PRC_REGISTRAR_PRODUCTO`(OUT P_ERROR_MESSAGE VARCHAR(100), OUT P_EXIST_ERROR TINYINT(1), P_PROD_NOMBRE VARCHAR(45), P_PROD_PRECIO FLOAT, P_PROD_STOCK INT, P_PROD_ETIQUETA VARCHAR(12), P_ALM_ID INT)
BEGIN
	DECLARE V_EXIST_ALMACEN INT;
    DECLARE V_EXIST_ETIQUETA INT;
    DECLARE V_ESTADO INT;
    DECLARE V_PROD_ID INT;
    
    SET P_EXIST_ERROR = 0;
	SET P_ERROR_MESSAGE = "Solicitud ejecutada correctamente";
    
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
    
		INSERT INTO productos (prod_nombre, prod_precio, prod_etiqueta, est_id)
        VALUES (P_PROD_NOMBRE, P_PROD_PRECIO, P_PROD_ETIQUETA, V_ESTADO);
        
		SELECT prod_id INTO V_PROD_ID FROM productos 
        WHERE prod_nombre = P_PROD_NOMBRE AND prod_precio = P_PROD_PRECIO
        AND prod_etiqueta = P_PROD_ETIQUETA AND prod_etiqueta = P_PROD_ETIQUETA
        AND est_id = V_ESTADO ORDER BY prod_id LIMIT 1;
        
        INSERT almacenes_productos (alm_prod_stock, alm_id, prod_id)
        VALUES (P_PROD_STOCK, P_ALM_ID, V_PROD_ID);
    END IF;
END

DELIMITER ;

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