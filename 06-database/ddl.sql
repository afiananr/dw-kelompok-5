-- =============================================================
-- Data Warehouse Kelompok 5 - Online Sales
-- Target database : dw_kelompok_5 (MySQL/MariaDB)
-- DDL baseline    : Pekan 11
-- Catatan:
-- 1. dim_tanggal tidak dibuat ulang karena menggunakan script
--    standar dosen (versi 1.0).
-- 2. CREATE TABLE IF NOT EXISTS tidak mengubah tabel yang sudah ada.
-- 3. INSERT IGNORE membuat unknown member hanya sekali.
-- 4. Tidak ada DROP TABLE / DELETE pada script ini.
-- =============================================================

USE dw_kelompok_5;

-- =============================================================
-- 1. DIM_PRODUCT (SCD Type 2)
-- =============================================================
CREATE TABLE IF NOT EXISTS dim_product (
    product_key INT(11) NOT NULL AUTO_INCREMENT,
    product_id INT(11) NOT NULL,
    product_name VARCHAR(100) DEFAULT NULL,
    product_number VARCHAR(25) DEFAULT NULL,
    product_model_id INT(11) DEFAULT NULL,
    product_model_name VARCHAR(100) DEFAULT NULL,
    product_subcategory_id INT(11) DEFAULT NULL,
    product_subcategory_name VARCHAR(100) DEFAULT NULL,
    product_category_id INT(11) DEFAULT NULL,
    product_category_name VARCHAR(100) DEFAULT NULL,
    color VARCHAR(20) DEFAULT NULL,
    size VARCHAR(10) DEFAULT NULL,
    standard_cost DECIMAL(18,4) DEFAULT NULL,
    list_price DECIMAL(18,4) DEFAULT NULL,
    effective_start_date DATE NOT NULL DEFAULT '1900-01-01',
    effective_end_date DATE NOT NULL DEFAULT '9999-12-31',
    is_current TINYINT(1) NOT NULL DEFAULT 1,
    current_product_id INT(11) GENERATED ALWAYS AS
        (CASE WHEN is_current = 1 THEN product_id ELSE NULL END) STORED,
    PRIMARY KEY (product_key),
    UNIQUE KEY uq_product_current (current_product_id),
    KEY idx_product_id (product_id),
    KEY idx_product_category (product_category_id),
    KEY idx_product_subcategory (product_subcategory_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- 2. DIM_CUSTOMER (SCD Type 2)
-- =============================================================
CREATE TABLE IF NOT EXISTS dim_customer (
    customer_key INT(11) NOT NULL AUTO_INCREMENT,
    customer_id INT(11) NOT NULL,
    person_id INT(11) DEFAULT NULL,
    store_id INT(11) DEFAULT NULL,
    customer_type VARCHAR(30) DEFAULT NULL,
    customer_name VARCHAR(150) DEFAULT NULL,
    store_name VARCHAR(150) DEFAULT NULL,
    effective_start_date DATE NOT NULL DEFAULT '1900-01-01',
    effective_end_date DATE NOT NULL DEFAULT '9999-12-31',
    is_current TINYINT(1) NOT NULL DEFAULT 1,
    current_customer_id INT(11) GENERATED ALWAYS AS
        (CASE WHEN is_current = 1 THEN customer_id ELSE NULL END) STORED,
    PRIMARY KEY (customer_key),
    UNIQUE KEY uq_customer_current (current_customer_id),
    KEY idx_customer_id (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- 3. DIM_TERRITORY (SCD Type 1)
-- =============================================================
CREATE TABLE IF NOT EXISTS dim_territory (
    territory_key INT(11) NOT NULL AUTO_INCREMENT,
    territory_id INT(11) NOT NULL,
    territory_name VARCHAR(100) DEFAULT NULL,
    country_region_code VARCHAR(10) DEFAULT NULL,
    territory_group VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (territory_key),
    UNIQUE KEY uq_territory_id (territory_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- 4. DIM_PROMOTION (SCD Type 1)
-- =============================================================
CREATE TABLE IF NOT EXISTS dim_promotion (
    promotion_key INT(11) NOT NULL AUTO_INCREMENT,
    special_offer_id INT(11) NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    offer_type VARCHAR(50) DEFAULT NULL,
    category VARCHAR(50) DEFAULT NULL,
    discount_pct DECIMAL(8,4) DEFAULT NULL,
    promotion_status VARCHAR(30) DEFAULT NULL,
    PRIMARY KEY (promotion_key),
    UNIQUE KEY uq_special_offer_id (special_offer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- 5. DIM_CURRENCY (SCD Type 0)
-- =============================================================
CREATE TABLE IF NOT EXISTS dim_currency (
    currency_key INT(11) NOT NULL AUTO_INCREMENT,
    currency_code VARCHAR(10) NOT NULL,
    currency_name VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (currency_key),
    UNIQUE KEY uq_currency_code (currency_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- 6. FACT_ONLINE_SALES
-- Grain: satu baris untuk satu detail produk pada transaksi online.
-- =============================================================
CREATE TABLE IF NOT EXISTS fact_online_sales (
    sales_order_detail_id INT(11) NOT NULL,
    sales_order_id INT(11) NOT NULL,
    tanggal_key INT(11) NOT NULL,
    product_key INT(11) NOT NULL,
    customer_key INT(11) NOT NULL,
    territory_key INT(11) NOT NULL,
    promotion_key INT(11) NOT NULL,
    currency_key INT(11) NOT NULL,
    currency_rate_id INT(11) DEFAULT NULL,
    average_rate DECIMAL(18,8) DEFAULT NULL,
    end_of_day_rate DECIMAL(18,8) DEFAULT NULL,
    order_qty INT(11) NOT NULL,
    unit_price DECIMAL(18,4) NOT NULL,
    discount_pct DECIMAL(8,4) DEFAULT 0.0000,
    gross_sales DECIMAL(18,4) NOT NULL,
    discount_amount DECIMAL(18,4) NOT NULL,
    net_sales DECIMAL(18,4) NOT NULL,
    PRIMARY KEY (sales_order_detail_id),
    KEY idx_fact_sales_order (sales_order_id),
    KEY idx_fact_tanggal (tanggal_key),
    KEY idx_fact_product (product_key),
    KEY idx_fact_customer (customer_key),
    KEY idx_fact_territory (territory_key),
    KEY idx_fact_promotion (promotion_key),
    KEY idx_fact_currency (currency_key),
    CONSTRAINT fk_fact_tanggal FOREIGN KEY (tanggal_key)
        REFERENCES dim_tanggal (tanggal_key),
    CONSTRAINT fk_fact_product FOREIGN KEY (product_key)
        REFERENCES dim_product (product_key),
    CONSTRAINT fk_fact_customer FOREIGN KEY (customer_key)
        REFERENCES dim_customer (customer_key),
    CONSTRAINT fk_fact_territory FOREIGN KEY (territory_key)
        REFERENCES dim_territory (territory_key),
    CONSTRAINT fk_fact_promotion FOREIGN KEY (promotion_key)
        REFERENCES dim_promotion (promotion_key),
    CONSTRAINT fk_fact_currency FOREIGN KEY (currency_key)
        REFERENCES dim_currency (currency_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- 7. UNKNOWN MEMBERS (surrogate key = -1)
-- INSERT IGNORE menjaga agar script dapat dijalankan berulang.
-- =============================================================

INSERT IGNORE INTO dim_product (
    product_key, product_id, product_name, product_number,
    effective_start_date, effective_end_date, is_current
) VALUES (
    -1, -1, 'Tidak diketahui', 'UNKNOWN',
    '1900-01-01', '9999-12-31', 0
);

INSERT IGNORE INTO dim_customer (
    customer_key, customer_id, customer_type, customer_name,
    effective_start_date, effective_end_date, is_current
) VALUES (
    -1, -1, 'Unknown', 'Tidak diketahui',
    '1900-01-01', '9999-12-31', 0
);

INSERT IGNORE INTO dim_territory (
    territory_key, territory_id, territory_name,
    country_region_code, territory_group
) VALUES (
    -1, -1, 'Tidak diketahui', 'UNK', 'Tidak diketahui'
);

INSERT IGNORE INTO dim_promotion (
    promotion_key, special_offer_id, description,
    offer_type, category, discount_pct, promotion_status
) VALUES (
    -1, -1, 'Tidak diketahui', 'Unknown', 'Unknown', 0.0000, 'Unknown'
);

INSERT IGNORE INTO dim_currency (
    currency_key, currency_code, currency_name
) VALUES (
    -1, 'UNK', 'Tidak diketahui'
);

-- dim_tanggal unknown member (-1) sudah disediakan oleh script standar.
-- Selesai.
