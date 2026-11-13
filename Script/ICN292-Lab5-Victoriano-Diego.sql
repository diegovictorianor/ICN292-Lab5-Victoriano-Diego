-- =====================================================================
-- Lab5 - SQL (2/2)
-- =====================================================================

-- Entregable 1: Creación de la base

DROP DATABASE IF EXISTS andesbike;
CREATE DATABASE andesbike;
USE andesbike;

CREATE TABLE tiendas (
    id_tienda INT          NOT NULL AUTO_INCREMENT,
    nombre    VARCHAR(60)  NOT NULL,
    comuna    VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id_tienda)
);

CREATE TABLE bicicletas (
    id_bicicleta INT           NOT NULL AUTO_INCREMENT,
    modelo       VARCHAR(60)   NOT NULL,
    categoria    ENUM('Eléctrica', 'Infantil', 'Montaña', 'Ruta', 'Urbana') NOT NULL,
    precio       DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_bicicleta),
    CONSTRAINT chk_bicicletas_precio CHECK (precio > 0)
);

CREATE TABLE vendedores (
    id_vendedor   INT         NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(80) NOT NULL,
    id_tienda     INT         NULL,
    fecha_ingreso DATE        NOT NULL,
    PRIMARY KEY (id_vendedor),
    CONSTRAINT fk_vendedores_tienda
        FOREIGN KEY (id_tienda) REFERENCES tiendas (id_tienda)
);

CREATE TABLE ventas (
    id_venta     INT  NOT NULL AUTO_INCREMENT,
    id_vendedor  INT  NOT NULL,
    id_bicicleta INT  NOT NULL,
    fecha        DATE NOT NULL,
    unidades     INT  NOT NULL,
    PRIMARY KEY (id_venta),
    CONSTRAINT fk_ventas_vendedor
        FOREIGN KEY (id_vendedor)  REFERENCES vendedores (id_vendedor),
    CONSTRAINT fk_ventas_bicicleta
        FOREIGN KEY (id_bicicleta) REFERENCES bicicletas (id_bicicleta),
    CONSTRAINT chk_ventas_unidades CHECK (unidades > 0)
);

-- Carga oficial de datos
INSERT INTO tiendas (id_tienda, nombre, comuna) VALUES
    (1, 'Andes Providencia', 'Providencia'),
    (2, 'Andes Maipú',       'Maipú'),
    (3, 'Andes Concepción',  'Concepción'),
    (4, 'Andes La Serena',   'La Serena');

INSERT INTO vendedores (id_vendedor, nombre, id_tienda, fecha_ingreso) VALUES
    (1, 'Camila Ortiz',    1,    '2024-06-20'),
    (2, 'Diego Fuentes',   1,    '2024-01-15'),
    (3, 'Javiera Soto',    2,    '2023-07-24'),
    (4, 'Matías Herrera',  2,    '2024-01-15'),
    (5, 'Paula Riquelme',  3,    '2022-11-02'),
    (6, 'Ignacio Vera',    3,    '2024-08-19'),
    (7, 'Fernanda Lillo',  1,    '2025-02-03'),
    (8, 'Rubén Castro',    NULL, '2025-06-10');

INSERT INTO bicicletas (id_bicicleta, modelo, categoria, precio) VALUES
    (1, 'Cordillera 29',  'Montaña',   549990.00),
    (2, 'Ruta Austral',   'Ruta',      899990.00),
    (3, 'Urbana Pro',     'Urbana',    329990.00),
    (4, 'Pequeño Andes',  'Infantil',  149990.00),
    (5, 'Volt City',      'Eléctrica', 1249990.00),
    (6, 'Trail Master',   'Montaña',   749990.00),
    (7, 'Urbana Lite',    'Urbana',    229990.00),
    (8, 'Sprint R7',      'Ruta',      1099990.00);

INSERT INTO ventas (id_vendedor, id_bicicleta, fecha, unidades) VALUES
    (1, 1, '2025-03-04', 2),
    (1, 3, '2025-03-18', 1),
    (1, 5, '2025-04-02', 1),
    (2, 2, '2025-03-04', 1),
    (2, 1, '2025-04-11', 3),
    (2, 7, '2025-05-06', 2),
    (3, 4, '2025-03-21', 4),
    (3, 3, '2025-04-15', 2),
    (3, 6, '2025-05-20', 1),
    (4, 1, '2025-03-27', 1),
    (4, 5, '2025-05-09', 2),
    (5, 2, '2025-04-08', 1),
    (5, 6, '2025-04-23', 2),
    (5, 4, '2025-06-02', 5),
    (6, 3, '2025-05-13', 3),
    (6, 7, '2025-06-17', 1),
    (6, 1, '2025-06-24', 2),
    (1, 6, '2025-06-30', 1);

-- Entregable 2: Consultas

-- ---------------------------------------------------------------------
-- Consulta 1: todos los vendedores con su cantidad de ventas
-- ---------------------------------------------------------------------
SELECT v.nombre,
       COUNT(ve.id_venta) AS cantidad_ventas
FROM vendedores v
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
GROUP BY v.id_vendedor, v.nombre
ORDER BY cantidad_ventas DESC, v.nombre;

-- ---------------------------------------------------------------------
-- Consulta 2: nombre, c° de ventas y unidades vendidas por tienda
-- ---------------------------------------------------------------------
SELECT t.nombre,
       COUNT(ve.id_venta)             AS total_ventas,
       IFNULL(SUM(ve.unidades), 0)    AS total_unidades
FROM tiendas t
LEFT JOIN vendedores v  ON t.id_tienda   = v.id_tienda
LEFT JOIN ventas     ve ON v.id_vendedor = ve.id_vendedor
GROUP BY t.id_tienda, t.nombre
ORDER BY total_unidades DESC, t.nombre;

-- ---------------------------------------------------------------------
-- Consulta 3: tiendas sin ningún vendedor asignado
-- ---------------------------------------------------------------------
SELECT t.nombre, t.comuna
FROM tiendas t
LEFT JOIN vendedores v ON t.id_tienda = v.id_tienda
WHERE v.id_vendedor IS NULL;

-- ---------------------------------------------------------------------
-- Consulta 4: modelos sin ninguna venta en junio de 2025
-- ---------------------------------------------------------------------
SELECT b.modelo, b.categoria
FROM bicicletas b
LEFT JOIN ventas ve ON b.id_bicicleta = ve.id_bicicleta
                   AND ve.fecha >= '2025-06-01'
                   AND ve.fecha <  '2025-07-01'
WHERE ve.id_venta IS NULL
ORDER BY b.modelo;

-- ---------------------------------------------------------------------
-- Consulta 5: vendedores sin ventas, con el nombre de su tienda
-- ---------------------------------------------------------------------
SELECT v.nombre AS vendedor,
       t.nombre AS tienda
FROM vendedores v
LEFT JOIN tiendas t  ON v.id_tienda   = t.id_tienda
LEFT JOIN ventas  ve ON v.id_vendedor = ve.id_vendedor
WHERE ve.id_venta IS NULL
ORDER BY v.nombre;

-- ---------------------------------------------------------------------
-- Consulta 6: pares de vendedores de la misma tienda
-- ---------------------------------------------------------------------
SELECT v1.nombre        AS vendedor_1,
       v1.fecha_ingreso AS ingreso_1,
       v2.nombre        AS vendedor_2,
       v2.fecha_ingreso AS ingreso_2,
       t.nombre         AS tienda
FROM vendedores v1
JOIN vendedores v2 ON v1.id_tienda = v2.id_tienda
                  AND (v1.fecha_ingreso < v2.fecha_ingreso
                       OR (v1.fecha_ingreso = v2.fecha_ingreso
                           AND v1.id_vendedor < v2.id_vendedor))
JOIN tiendas t ON v1.id_tienda = t.id_tienda
ORDER BY t.nombre, v1.fecha_ingreso, v2.fecha_ingreso;

-- ---------------------------------------------------------------------
-- Consulta 7: monto vendido por tienda en Montaña y Ruta (>2.000.000)
-- ---------------------------------------------------------------------
SELECT t.nombre,
       SUM(ve.unidades * b.precio) AS monto_total
FROM tiendas t
JOIN vendedores v  ON t.id_tienda    = v.id_tienda
JOIN ventas     ve ON v.id_vendedor  = ve.id_vendedor
JOIN bicicletas b  ON ve.id_bicicleta = b.id_bicicleta
WHERE b.categoria IN ('Montaña', 'Ruta')
GROUP BY t.id_tienda, t.nombre
HAVING SUM(ve.unidades * b.precio) > 2000000
ORDER BY monto_total DESC;

-- ---------------------------------------------------------------------
-- Consulta 8: bicicletas con precio sobre el promedio del catálogo
-- ---------------------------------------------------------------------
SELECT modelo, precio
FROM bicicletas
WHERE precio > (SELECT AVG(precio) FROM bicicletas)
ORDER BY precio DESC;

-- Respaldo del valor del promedio citado en el informe:
SELECT AVG(precio) AS promedio_catalogo
FROM bicicletas;

-- ---------------------------------------------------------------------
-- Consulta 9: vendedores cuyo promedio de unidades por venta supera
-- el promedio de unidades de todas las ventas de la cadena
-- ---------------------------------------------------------------------
SELECT v.nombre,
       AVG(ve.unidades) AS promedio_unidades
FROM vendedores v
JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
GROUP BY v.id_vendedor, v.nombre
HAVING AVG(ve.unidades) > (SELECT AVG(unidades) FROM ventas)
ORDER BY promedio_unidades DESC, v.nombre;

-- ---------------------------------------------------------------------
-- Consulta 10: listado del monto total vendido por cada vendedor
-- ---------------------------------------------------------------------
SELECT v.nombre,
       SUM(ve.unidades * b.precio) AS monto_total
FROM vendedores v
LEFT JOIN ventas     ve ON v.id_vendedor    = ve.id_vendedor
LEFT JOIN bicicletas b  ON ve.id_bicicleta  = b.id_bicicleta
GROUP BY v.id_vendedor, v.nombre
ORDER BY monto_total DESC, v.nombre;

