-- ============================================================
-- Proyecto: Análisis de ventas e-commerce (Amazon Sale Report)
-- PostgreSQL — 128.975 filas
-- ============================================================

-- 1. Creación de la tabla
-- Se tipó "Date" directamente como DATE en un primer intento,
-- pero el CSV trae fechas en formato MM-DD-YY, incompatible
-- con el DateStyle por defecto de Postgres. Se resolvió más
-- abajo pasándola a VARCHAR y parseándola después con TO_DATE().
CREATE TABLE amazon_sales_report (
    "Index"              SERIAL PRIMARY KEY,
    "Order ID"           VARCHAR(50),
    "Date"                VARCHAR(50),   -- se carga como texto, se parsea después
    "Status"              VARCHAR(100),
    "Fulfilment"          VARCHAR(50),
    "Sales Channel"       VARCHAR(100),
    "ship-service-level"  VARCHAR(50),
    "Style"               VARCHAR(50),
    "SKU"                 VARCHAR(50),
    "Category"            VARCHAR(50),
    "Size"                VARCHAR(50),
    "ASIN"                VARCHAR(50),
    "Courier Status"      VARCHAR(100),
    "qty"                 VARCHAR(50),
    "currency"            VARCHAR(50),
    "Amount"              VARCHAR(50),
    "ship-city"           VARCHAR(50),
    "ship-state"          VARCHAR(50),
    "ship-postal-code"    VARCHAR(50),
    "ship-country"        VARCHAR(50),
    "promotion-ids"       VARCHAR,       -- sin límite: el campo trae listas largas de IDs concatenados
    "B2B"                 VARCHAR(50),
    "fulfilled-by"        VARCHAR(100),
    "Unnamed :22"         VARCHAR(10)
);

-- 2. Carga del CSV (corrida desde psql, en el cliente, no en el servidor)
\copy amazon_sales_report ("Index", "Order ID", "Date", "Status", "Fulfilment", "Sales Channel", "ship-service-level", "Style", "SKU", "Category", "Size", "ASIN", "Courier Status", "qty", "currency", "Amount", "ship-city", "ship-state", "ship-postal-code", "ship-country", "promotion-ids", "B2B", "fulfilled-by", "Unnamed :22") FROM 'C:\Users\mmack\dataAn\Amazon_Sale_Report.csv' DELIMITER ',' CSV HEADER;

-- 3. Materializar la fecha real como columna DATE
ALTER TABLE amazon_sales_report ADD COLUMN order_date DATE;

UPDATE amazon_sales_report
SET order_date = TO_DATE("Date", 'MM-DD-YY');

-- ============================================================
-- Consultas de análisis
-- ============================================================

-- Distribución de pedidos por estado
SELECT "Status", COUNT(*)
FROM amazon_sales_report
GROUP BY "Status"
ORDER BY COUNT(*) DESC;

-- Tasa de cancelación global (%)
SELECT ROUND(100.0 * SUM(CASE WHEN "Status" = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_cancelado
FROM amazon_sales_report;

-- Cancelaciones por mes (cantidad, total y %)
SELECT
    DATE_TRUNC('month', order_date) AS mes,
    COUNT(*) FILTER (WHERE "Status" = 'Cancelled') AS cancelados,
    COUNT(*) AS total,
    ROUND(100.0 * COUNT(*) FILTER (WHERE "Status" = 'Cancelled') / COUNT(*), 2) AS pct
FROM amazon_sales_report
GROUP BY mes
ORDER BY mes;

-- Cancelaciones por categoría de producto
SELECT
    "Category",
    COUNT(*) FILTER (WHERE "Status" = 'Cancelled') AS cancelados,
    COUNT(*) AS total,
    ROUND(100.0 * COUNT(*) FILTER (WHERE "Status" = 'Cancelled') / COUNT(*), 2) AS pct
FROM amazon_sales_report
GROUP BY "Category"
ORDER BY pct DESC;


-- ============================================================
-- Proyecto: Superstore (train)
-- PostgreSQL — 9.800 filas
-- ============================================================

-- Ventas totales por año
SELECT EXTRACT(YEAR FROM "Order Date"::date) AS anio, SUM("Sales") AS total
FROM train
GROUP BY anio
ORDER BY anio;
