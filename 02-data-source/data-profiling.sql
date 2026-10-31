-- Data Profiling: AdventureWorks Online Sales
-- Jalankan pada database adventureworks di PostgreSQL / pgAdmin Query Tool.

-- 1. Jumlah record pada tabel utama penjualan
SELECT 'salesorderheader' AS nama_tabel, COUNT(*) AS jumlah_record
FROM sales.salesorderheader
UNION ALL
SELECT 'salesorderdetail', COUNT(*)
FROM sales.salesorderdetail
UNION ALL
SELECT 'customer', COUNT(*)
FROM sales.customer
UNION ALL
SELECT 'salesterritory', COUNT(*)
FROM sales.salesterritory
UNION ALL
SELECT 'specialoffer', COUNT(*)
FROM sales.specialoffer;

-- 2. Jumlah record pada tabel produk dan person
SELECT 'product' AS nama_tabel, COUNT(*) AS jumlah_record
FROM production.product
UNION ALL
SELECT 'productsubcategory', COUNT(*)
FROM production.productsubcategory
UNION ALL
SELECT 'productcategory', COUNT(*)
FROM production.productcategory
UNION ALL
SELECT 'person', COUNT(*)
FROM person.person;

-- 3. Rentang tanggal dan jumlah transaksi online
SELECT
    MIN(orderdate) AS tanggal_transaksi_pertama,
    MAX(orderdate) AS tanggal_transaksi_terakhir,
    COUNT(*) AS jumlah_transaksi_online
FROM sales.salesorderheader
WHERE onlineorderflag = TRUE;

-- 4. Distribusi transaksi online dan offline
SELECT
    onlineorderflag,
    COUNT(*) AS jumlah_transaksi,
    SUM(totaldue) AS total_penjualan_header
FROM sales.salesorderheader
GROUP BY onlineorderflag
ORDER BY onlineorderflag;

-- 5. Pemeriksaan NULL pada kolom penting
SELECT 'salesorderheader' AS nama_tabel, 'orderdate' AS nama_kolom,
       COUNT(*) FILTER (WHERE orderdate IS NULL) AS jumlah_null
FROM sales.salesorderheader
UNION ALL
SELECT 'salesorderheader', 'customerid',
       COUNT(*) FILTER (WHERE customerid IS NULL)
FROM sales.salesorderheader
UNION ALL
SELECT 'salesorderheader', 'territoryid',
       COUNT(*) FILTER (WHERE territoryid IS NULL)
FROM sales.salesorderheader
UNION ALL
SELECT 'salesorderheader', 'onlineorderflag',
       COUNT(*) FILTER (WHERE onlineorderflag IS NULL)
FROM sales.salesorderheader
UNION ALL
SELECT 'salesorderdetail', 'productid',
       COUNT(*) FILTER (WHERE productid IS NULL)
FROM sales.salesorderdetail
UNION ALL
SELECT 'salesorderdetail', 'orderqty',
       COUNT(*) FILTER (WHERE orderqty IS NULL)
FROM sales.salesorderdetail
UNION ALL
SELECT 'salesorderdetail', 'unitprice',
       COUNT(*) FILTER (WHERE unitprice IS NULL)
FROM sales.salesorderdetail
UNION ALL
SELECT 'salesorderdetail', 'unitpricediscount',
       COUNT(*) FILTER (WHERE unitpricediscount IS NULL)
FROM sales.salesorderdetail
UNION ALL
SELECT 'customer', 'personid',
       COUNT(*) FILTER (WHERE personid IS NULL)
FROM sales.customer
UNION ALL
SELECT 'customer', 'territoryid',
       COUNT(*) FILTER (WHERE territoryid IS NULL)
FROM sales.customer;

-- 6. Pemeriksaan lanjutan customer dengan PersonID NULL
SELECT
    COUNT(*) AS total_personid_null,
    COUNT(storeid) AS storeid_terisi,
    COUNT(*) FILTER (WHERE storeid IS NULL) AS storeid_null
FROM sales.customer
WHERE personid IS NULL;

-- 7. Contoh record customer dengan PersonID NULL
SELECT customerid, personid, storeid, territoryid
FROM sales.customer
WHERE personid IS NULL
LIMIT 20;
