# Data Model Notes & Validation Checklist

## Keputusan desain
1. Proses bisnis yang dimodelkan adalah Online Sales.
2. Grain fact adalah satu baris per sales order detail untuk order dengan `OnlineOrderFlag = TRUE`.
3. Fact menyimpan foreign key ke lima dimensi: Date, Product, Customer, Territory, Promotion.
4. `sales_order_detail_id` menjadi identitas unik baris fact sesuai grain; validasi keunikan saat ETL.
5. Dimensi menggunakan surrogate key (`*_key`) pada target data warehouse; source ID tetap disimpan sebagai business key.
6. Baris tanpa promosi ditangani menggunakan anggota khusus pada `DIM_PROMOTION`.

## Hal yang wajib divalidasi sebelum implementasi
- Pastikan `SalesOrderDetail` memiliki kolom identitas detail yang unik (misalnya `SalesOrderDetailID`).
- Pastikan jalur join Product ke Subcategory dan Category sesuai foreign key aktual.
- Pastikan sumber nama customer/store tersedia dan aturan customer individual vs store disepakati.
- Pastikan relasi order ke territory dan special offer sesuai skema sumber.
- Tentukan kebijakan untuk nilai NULL dan unknown member pada setiap dimensi.
- Tentukan strategi perubahan atribut dimensi (misalnya SCD Type 1 atau Type 2) bersama tim; belum ditetapkan pada rancangan V1.
- Uji bahwa jumlah baris fact sesuai jumlah baris detail dari order online setelah filter.
- Rekonsiliasi total kuantitas dan nilai penjualan dengan hasil perhitungan dari sumber.

## Batasan rancangan
Dokumen ini adalah logical design awal. Tipe data fisik, constraint, indeks, strategi SCD, dan skrip pembuatan tabel target belum ditetapkan. Jangan menganggap rancangan ini sudah menjadi implementasi database.
