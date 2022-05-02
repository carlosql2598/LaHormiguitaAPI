CREATE DATABASE IF NOT EXISTS `lahormiguitadb`;

USE `lahormiguitadb`;

SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

CREATE TABLE IF NOT EXISTS Usuarios (
    usu_id int AUTO_INCREMENT,
    usu_fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usu_nombre varchar(45) NOT NULL,
    usu_apellidos varchar(45) NOT NULL,
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
    est_nombre varchar(45),
    PRIMARY KEY (est_id)
);

CREATE TABLE IF NOT EXISTS Etiquetas (
    eti_id int AUTO_INCREMENT,
    eti_code varchar(16) UNIQUE NOT NULL,
    eti_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (eti_id)
);

CREATE TABLE IF NOT EXISTS Productos (
    prod_id int AUTO_INCREMENT,
    prod_nombre varchar(45) NOT NULL,
    prod_precio float NOT NULL,
    prod_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    eti_id int NOT NULL,
    est_id int NOT NULL,
    PRIMARY KEY (prod_id),
    FOREIGN KEY (eti_id) REFERENCES Etiquetas(eti_id),
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
    rep_titulo varchar(45) NOT NULL,
    rep_descripcion text NOT NULL,
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
    alm_nombre varchar(45) NOT NULL,
    alm_direccion varchar(35) NOT NULL,
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
    cat_nombre varchar(45) NOT NULL,
    cat_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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

