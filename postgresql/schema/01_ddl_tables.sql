-- =======================================================
-- MÓDULO TRANSACCIONAL - ECOMMIFY (PostgreSQL)
-- =======================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 1. Tabla de Geolocalización (Uso de PostGIS)
CREATE TABLE geolocation (
    zip_code_prefix VARCHAR(10) PRIMARY KEY,
    lat FLOAT NOT NULL,
    lng FLOAT NOT NULL,
    geom GEOMETRY(Point, 4326),
    city VARCHAR(100),
    state VARCHAR(2)
);
-- Índice espacial
CREATE INDEX idx_geolocation_geom ON geolocation USING GIST(geom);

-- 2. Clientes
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    zip_code_prefix VARCHAR(10) REFERENCES geolocation(zip_code_prefix),
    city VARCHAR(100),
    state VARCHAR(2)
);

-- 3. Vendedores
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    zip_code_prefix VARCHAR(10) REFERENCES geolocation(zip_code_prefix),
    city VARCHAR(100),
    state VARCHAR(2)
);

-- 4. Productos (Uso de JSONB y Arrays, y pg_trgm)
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    category_name VARCHAR(100),
    product_name TEXT,
    specifications JSONB, -- Almacena peso, largo, ancho, alto, etc.
    photos TEXT[]         -- Arreglo de URLs o identificadores de fotos
);
-- Índice GIN para búsqueda de texto tolerante a errores (pg_trgm)
CREATE INDEX idx_products_name_trgm ON products USING GIN (product_name gin_trgm_ops);
-- Índice GIN para consultas eficientes sobre el JSONB
CREATE INDEX idx_products_specs ON products USING GIN (specifications);

-- 5. Pedidos (Particionamiento por rango de fecha)
CREATE TABLE orders (
    order_id VARCHAR(50) NOT NULL,
    customer_id VARCHAR(50) NOT NULL REFERENCES customers(customer_id),
    status VARCHAR(20) NOT NULL,
    purchase_timestamp TIMESTAMP NOT NULL,
    delivered_customer_date TIMESTAMP,
    PRIMARY KEY (order_id, purchase_timestamp)
) PARTITION BY RANGE (purchase_timestamp);

-- Creación de particiones (Ejemplo)
CREATE TABLE orders_2017_h1 PARTITION OF orders
    FOR VALUES FROM ('2017-01-01') TO ('2017-07-01');
CREATE TABLE orders_2017_h2 PARTITION OF orders
    FOR VALUES FROM ('2017-07-01') TO ('2018-01-01');
CREATE TABLE orders_2018_h1 PARTITION OF orders
    FOR VALUES FROM ('2018-01-01') TO ('2018-07-01');
CREATE TABLE orders_2018_h2 PARTITION OF orders
    FOR VALUES FROM ('2018-07-01') TO ('2019-01-01');

-- 6. Items del Pedido
CREATE TABLE order_items (
    order_id VARCHAR(50) NOT NULL,
    purchase_timestamp TIMESTAMP NOT NULL, -- Propagada para satisfacer la llave foránea de la partición
    order_item_id INT NOT NULL,
    product_id VARCHAR(50) NOT NULL REFERENCES products(product_id),
    seller_id VARCHAR(50) NOT NULL REFERENCES sellers(seller_id),
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, purchase_timestamp, order_item_id),
    FOREIGN KEY (order_id, purchase_timestamp) REFERENCES orders(order_id, purchase_timestamp)
);

-- 7. Pagos del Pedido
CREATE TABLE order_payments (
    order_id VARCHAR(50) NOT NULL,
    purchase_timestamp TIMESTAMP NOT NULL, -- Propagada para la llave foránea
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(20) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, purchase_timestamp, payment_sequential),
    FOREIGN KEY (order_id, purchase_timestamp) REFERENCES orders(order_id, purchase_timestamp)
);
