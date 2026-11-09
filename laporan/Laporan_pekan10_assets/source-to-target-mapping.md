# Source-to-Target Mapping — Star Schema V2

**Proyek:** Data Warehouse AdventureWorks — Online Sales  
**Kelompok:** 5  
**Database sumber:** `adventureworks` (MySQL/MariaDB)  
**Database target:** `dw_kelompok_5` (MariaDB)  
**Fact table:** `fact_online_sales`  
**ETL Tool:** Pentaho Data Integration (PDI)  
**Versi dokumen:** Revisi — mengikuti standar `dim_tanggal` dosen

---

## 1. Tujuan dan Grain

Dokumen ini menjelaskan pemetaan kolom dari database sumber AdventureWorks ke tabel-tabel pada Data Warehouse `dw_kelompok_5` sebagai acuan implementasi ETL menggunakan Pentaho Data Integration.

**Grain fact table:** Satu baris pada `fact_online_sales` merepresentasikan satu baris detail produk dalam satu transaksi penjualan online.

Transaksi online dipilih menggunakan kondisi:

```sql
WHERE soh.onlineorderflag = 1
```

> **Catatan:** Nama tabel sumber di dokumen ini mengikuti hasil import AdventureWorks ke MySQL, yaitu nama tabel dengan awalan nama schema, misalnya `sales_salesorderheader` dan `production_product`. Nama tersebut bukan schema terpisah.

## 2. Ringkasan Source dan Target

| Target | Sumber utama | Sumber tambahan | Strategi |
|---|---|---|---|
| `dim_tanggal` | Generated Calendar | — | Type 0 |
| `dim_product` | `production_product` | `production_productmodel`, `production_productsubcategory`, `production_productcategory` | Type 2 |
| `dim_customer` | `sales_customer` | `person_person`, `sales_store` | Type 2 |
| `dim_territory` | `sales_salesterritory` | — | Type 1 |
| `dim_promotion` | `sales_specialoffer` | — | Type 1 |
| `dim_currency` | `sales_currency` | `sales_currencyrate` untuk lookup transaksi | Type 0 |
| `fact_online_sales` | `sales_salesorderdetail` | `sales_salesorderheader`, `sales_currencyrate`, dan seluruh dimensi DW | Transaction fact |

---

## 3. Mapping Dimensi

### 3.1 Target: `dim_tanggal` (SCD Type 0)

**Sumber:** Generated Calendar. Tabel ini dibuat langsung pada database Data Warehouse menggunakan skrip standar dosen, bukan diambil dari tabel transaksi sumber.

**Ketentuan standar:**
- Rentang tanggal: `2010-01-01` sampai `2015-12-31`.
- Jumlah tanggal kalender: 2.191 hari.
- Satu baris tambahan untuk tanggal tidak diketahui dengan `tanggal_key = -1`.
- Total yang diharapkan: 2.192 baris.
- Struktur dan nama kolom mengikuti skrip dosen; jangan diubah.

| Kolom target | Tipe target | Sumber / asal | Transformasi | Aturan |
|---|---|---|---|---|
| `tanggal_key` | INT (PK) | Generated Calendar | Format `tanggal` menjadi `YYYYMMDD`; nilai `-1` untuk unknown | NOT NULL |
| `tanggal` | DATE | Generated Calendar | Satu baris untuk setiap tanggal pada rentang standar | NOT NULL, UNIQUE |
| `tahun` | INT | `tanggal` | `YEAR(tanggal)` | NOT NULL |
| `semester` | INT | `tanggal` | 1 jika bulan 1–6; 2 jika bulan 7–12 | NOT NULL |
| `kuartal` | INT | `tanggal` | `QUARTER(tanggal)` | NOT NULL |
| `bulan` | INT | `tanggal` | `MONTH(tanggal)` | NOT NULL |
| `nama_bulan` | VARCHAR(15) | `tanggal` | Nama bulan bahasa Indonesia | NOT NULL |
| `minggu_dalam_tahun` | INT | `tanggal` | Minggu ISO 8601, misalnya `WEEK(tanggal, 3)` | NOT NULL |
| `tanggal_dalam_bulan` | INT | `tanggal` | `DAY(tanggal)` | NOT NULL |
| `hari_dalam_minggu` | INT | `tanggal` | `WEEKDAY(tanggal) + 1`; Senin = 1 sampai Minggu = 7 | NOT NULL |
| `nama_hari` | VARCHAR(15) | `tanggal` | Nama hari bahasa Indonesia | NOT NULL |
| `is_akhir_pekan` | BOOLEAN | `tanggal` | TRUE untuk Sabtu dan Minggu | NOT NULL |

**Hierarki waktu untuk OLAP:** Year → Semester → Quarter → Month → Date.

**Relasi ke fact:** `dim_tanggal.tanggal_key` → `fact_online_sales.tanggal_key`.

**Aturan lookup fact:** Ambil tanggal dari `sales_salesorderheader.orderdate`, ubah menjadi key `YYYYMMDD`, lalu lookup ke `dim_tanggal.tanggal_key`. Gunakan `-1` hanya jika tanggal transaksi kosong atau tidak dapat dipetakan.

### 3.2 Target: `dim_product` (SCD Type 2)

**Sumber utama:** `production_product`  
**Sumber tambahan:** `production_productmodel`, `production_productsubcategory`, `production_productcategory`.

| Kolom target | Tipe target | Tabel.kolom sumber | Transformasi | Aturan NULL |
|---|---|---|---|---|
| `product_key` | INT (PK) | DW | Surrogate key, AUTO_INCREMENT | NOT NULL |
| `product_id` | INT | `production_product.productid` | Ambil sebagai business key | NOT NULL |
| `product_name` | VARCHAR(100) | `production_product.name` | Ambil langsung | Boleh NULL sesuai DDL target |
| `product_number` | VARCHAR(25) | `production_product.productnumber` | Ambil langsung | Boleh NULL sesuai DDL target |
| `product_model_id` | INT | `production_product.productmodelid` | Ambil langsung | Boleh NULL |
| `product_model_name` | VARCHAR(100) | `production_productmodel.name` | LEFT JOIN melalui `productmodelid` | Isi `Not Assigned` jika tidak tersedia |
| `product_subcategory_id` | INT | `production_product.productsubcategoryid` | Ambil langsung | Boleh NULL |
| `product_subcategory_name` | VARCHAR(100) | `production_productsubcategory.name` | LEFT JOIN melalui `productsubcategoryid` | Isi `Not Assigned` jika tidak tersedia |
| `product_category_id` | INT | `production_productcategory.productcategoryid` | LEFT JOIN melalui `production_productsubcategory.productcategoryid` | Boleh NULL |
| `product_category_name` | VARCHAR(100) | `production_productcategory.name` | LEFT JOIN melalui subcategory | Isi `Not Assigned` jika tidak tersedia |
| `color` | VARCHAR(20) | `production_product.color` | Ambil langsung | Isi `Not Specified` jika NULL |
| `size` | VARCHAR(10) | `production_product.size` | Ambil langsung | Isi `Not Specified` jika NULL |
| `standard_cost` | DECIMAL(18,4) | `production_product.standardcost` | Ambil langsung | NULL diperbolehkan |
| `list_price` | DECIMAL(18,4) | `production_product.listprice` | Ambil langsung | NULL diperbolehkan |
| `effective_start_date` | DATE | ETL process | Tanggal mulai versi | NOT NULL; default awal sesuai kebijakan ETL |
| `effective_end_date` | DATE | ETL process | Tanggal akhir versi; versi aktif memakai tanggal maksimum | NOT NULL |
| `is_current` | TINYINT(1) | ETL process | 1 untuk versi aktif; 0 untuk versi lama | NOT NULL |

**Aturan SCD Type 2:** Jika atribut yang dipantau berubah, tutup versi lama dengan memperbarui `effective_end_date` dan `is_current = 0`, kemudian buat versi baru dengan surrogate key baru. Riwayat perubahan sebelum ETL mulai berjalan tidak dapat direkonstruksi jika tidak tersedia pada sumber.

### 3.3 Target: `dim_customer` (SCD Type 2)

**Sumber utama:** `sales_customer`  
**Sumber tambahan:** `person_person`, `sales_store`.

| Kolom target | Tipe target | Tabel.kolom sumber | Transformasi | Aturan NULL |
|---|---|---|---|---|
| `customer_key` | INT (PK) | DW | Surrogate key, AUTO_INCREMENT | NOT NULL |
| `customer_id` | INT | `sales_customer.customerid` | Ambil sebagai business key | NOT NULL |
| `person_id` | INT | `sales_customer.personid` | Ambil langsung | Boleh NULL |
| `store_id` | INT | `sales_customer.storeid` | Ambil langsung | Boleh NULL |
| `customer_type` | VARCHAR(30) | `sales_customer.personid`, `sales_customer.storeid` | `Store` jika `storeid` tersedia; `Individual` jika `personid` tersedia; selain itu `Unknown` | Isi `Unknown` jika keduanya NULL |
| `customer_name` | VARCHAR(150) | `person_person.firstname`, `middlename`, `lastname` | LEFT JOIN melalui `personid`; gabungkan nama yang tersedia | Isi `Not Assigned` jika tidak tersedia |
| `store_name` | VARCHAR(150) | `sales_store.name` | LEFT JOIN melalui `storeid` | Isi `Not Assigned` jika NULL |
| `effective_start_date` | DATE | ETL process | Tanggal mulai versi | NOT NULL |
| `effective_end_date` | DATE | ETL process | Tanggal akhir versi; versi aktif memakai tanggal maksimum | NOT NULL |
| `is_current` | TINYINT(1) | ETL process | 1 untuk versi aktif; 0 untuk versi lama | NOT NULL |

**Aturan SCD Type 2:** Jika atribut customer yang dipantau berubah, buat versi baru. Saat fact dimuat, cari `customer_key` berdasarkan `customer_id` dan rentang tanggal transaksi agar versi yang sesuai dengan transaksi digunakan.

### 3.4 Target: `dim_territory` (SCD Type 1)

**Sumber utama:** `sales_salesterritory`.

| Kolom target | Tipe target | Tabel.kolom sumber | Transformasi | Aturan NULL |
|---|---|---|---|---|
| `territory_key` | INT (PK) | DW | Surrogate key, AUTO_INCREMENT | NOT NULL |
| `territory_id` | INT | `sales_salesterritory.territoryid` | Ambil sebagai business key | NOT NULL |
| `territory_name` | VARCHAR(100) | `sales_salesterritory.name` | Ambil langsung | Boleh NULL sesuai DDL target |
| `country_region_code` | VARCHAR(10) | `sales_salesterritory.countryregioncode` | Ambil langsung | Isi `Unknown` jika NULL |
| `territory_group` | VARCHAR(50) | `sales_salesterritory.group` | Ambil langsung; `group` merupakan nama kolom yang perlu di-escape dengan backtick pada MySQL | Isi `Unknown` jika NULL |

**Aturan SCD Type 1:** Perubahan atribut memperbarui nilai yang tersimpan tanpa mempertahankan versi sebelumnya. Territory tidak dihubungkan ke satu salesperson karena satu territory dapat memiliki beberapa salesperson. Ketersediaan `salespersonid` pada transaksi online MySQL perlu dipastikan melalui profiling sumber sebelum menyimpulkan nilainya.

### 3.5 Target: `dim_promotion` (SCD Type 1)

**Sumber utama:** `sales_specialoffer`.

| Kolom target | Tipe target | Tabel.kolom sumber | Transformasi | Aturan NULL |
|---|---|---|---|---|
| `promotion_key` | INT (PK) | DW | Surrogate key, AUTO_INCREMENT | NOT NULL |
| `special_offer_id` | INT | `sales_specialoffer.specialofferid` | Ambil sebagai business key | NOT NULL untuk promosi sumber |
| `description` | VARCHAR(255) | `sales_specialoffer.description` | Ambil langsung | Isi `Not Assigned` jika NULL |
| `offer_type` | VARCHAR(50) | `sales_specialoffer.type` | Ambil langsung | Isi `Not Assigned` jika NULL |
| `category` | VARCHAR(50) | `sales_specialoffer.category` | Ambil langsung | Isi `Not Assigned` jika NULL |
| `discount_pct` | DECIMAL(8,4) | `sales_specialoffer.discountpct` | Ambil nilai diskon dari master promosi | Isi 0 jika NULL |
| `promotion_status` | VARCHAR(30) | `sales_specialoffer.startdate`, `enddate` | Hitung berdasarkan tanggal proses ETL: `Upcoming`, `Active`, atau `Expired` | `Unknown` jika tanggal tidak lengkap |

**Anggota khusus:** Buat satu baris `No Promotion` pada `dim_promotion` untuk transaksi tanpa promosi. Fact menggunakan surrogate key anggota tersebut saat lookup.

**Aturan SCD Type 1:** Perubahan atribut promosi memperbarui nilai yang tersimpan tanpa membuat versi historis.

### 3.6 Target: `dim_currency` (SCD Type 0)

**Sumber utama:** `sales_currency`.

| Kolom target | Tipe target | Tabel.kolom sumber | Transformasi | Aturan NULL |
|---|---|---|---|---|
| `currency_key` | INT (PK) | DW | Surrogate key, AUTO_INCREMENT | NOT NULL |
| `currency_code` | VARCHAR(10) | `sales_currency.currencycode` | Ambil sebagai business key | NOT NULL |
| `currency_name` | VARCHAR(100) | `sales_currency.name` | Ambil langsung | Boleh NULL sesuai DDL target |

**Aturan lookup mata uang transaksi:** Dari `sales_salesorderheader.currencyrateid`, LEFT JOIN ke `sales_currencyrate.currencyrateid`, gunakan `tocurrencycode`, lalu lookup ke `sales_currency.currencycode`.

**Asumsi yang perlu divalidasi:** Transaksi dengan `currencyrateid` NULL sementara dipetakan ke USD sebagai mata uang dasar. Validasi asumsi ini terhadap data sumber atau aturan bisnis sebelum ETL final.

**Aturan SCD Type 0:** Nilai dimension dipertahankan dan tidak diperbarui melalui mekanisme historisasi.

---

## 4. Mapping Fact Table

### 4.1 Target: `fact_online_sales`

**Sumber utama:** `sales_salesorderdetail`  
**Sumber tambahan:** `sales_salesorderheader`, `sales_currencyrate`, serta seluruh dimension pada Data Warehouse.

| Kolom target | Tipe target | Tabel.kolom sumber | Transformasi | Aturan |
|---|---|---|---|---|
| `sales_order_detail_id` | INT (PK) | `sales_salesorderdetail.salesorderdetailid` | Ambil ID detail sebagai primary key fact | NOT NULL |
| `sales_order_id` | INT | `sales_salesorderdetail.salesorderid` | Ambil ID transaksi | NOT NULL |
| `tanggal_key` | INT (FK) | `sales_salesorderheader.orderdate` | Format tanggal `YYYYMMDD`, lookup ke `dim_tanggal.tanggal_key` | Gunakan `-1` jika tanggal tidak diketahui/tidak dapat dipetakan |
| `product_key` | INT (FK) | `sales_salesorderdetail.productid` → `dim_product.product_id` | Lookup surrogate key berdasarkan product dan versi yang berlaku | Gunakan anggota Unknown jika tidak ditemukan |
| `customer_key` | INT (FK) | `sales_salesorderheader.customerid` → `dim_customer.customer_id` | Lookup surrogate key berdasarkan customer dan rentang tanggal transaksi | Gunakan anggota Unknown jika tidak ditemukan |
| `territory_key` | INT (FK) | `sales_salesorderheader.territoryid` → `dim_territory.territory_id` | Lookup surrogate key berdasarkan territory_id | Gunakan anggota Unknown jika tidak ditemukan |
| `promotion_key` | INT (FK) | `sales_salesorderdetail.specialofferid` → `dim_promotion.special_offer_id` | Lookup surrogate key berdasarkan specialofferid | Gunakan anggota `No Promotion` jika tidak ada promosi |
| `currency_key` | INT (FK) | `sales_salesorderheader.currencyrateid` → `sales_currencyrate.tocurrencycode` → `dim_currency.currency_code` | Lookup surrogate key berdasarkan kode mata uang transaksi | Gunakan anggota Unknown jika tidak ditemukan; USD untuk rate NULL masih asumsi |
| `currency_rate_id` | INT | `sales_salesorderheader.currencyrateid` | Ambil langsung | NULL diperbolehkan |
| `average_rate` | DECIMAL(18,8) | `sales_currencyrate.averagerate` | Ambil nilai kurs rata-rata | NULL jika tidak ada currency rate |
| `end_of_day_rate` | DECIMAL(18,8) | `sales_currencyrate.endofdayrate` | Ambil nilai kurs akhir hari | NULL jika tidak ada currency rate |
| `order_qty` | INT | `sales_salesorderdetail.orderqty` | Ambil jumlah produk | NOT NULL |
| `unit_price` | DECIMAL(18,4) | `sales_salesorderdetail.unitprice` | Ambil harga satuan | NOT NULL |
| `discount_pct` | DECIMAL(8,4) | `sales_salesorderdetail.unitpricediscount` | Ambil persentase diskon desimal; contoh 0.10 = 10% | Isi 0 jika NULL |
| `gross_sales` | DECIMAL(18,4) | `orderqty`, `unitprice` | `orderqty * unitprice` | NOT NULL |
| `discount_amount` | DECIMAL(18,4) | `orderqty`, `unitprice`, `unitpricediscount` | `(orderqty * unitprice) * unitpricediscount` | Gunakan 0 jika diskon NULL |
| `net_sales` | DECIMAL(18,4) | Hasil perhitungan | `gross_sales - discount_amount` | NOT NULL |

### 4.2 Query dasar pengambilan fact dari sumber MySQL

Contoh query untuk mengambil transaksi online dari database `adventureworks`:

```sql
SELECT
    sod.salesorderdetailid,
    sod.salesorderid,
    soh.orderdate,
    soh.customerid,
    soh.territoryid,
    soh.currencyrateid,
    sod.productid,
    sod.specialofferid,
    sod.orderqty,
    sod.unitprice,
    sod.unitpricediscount
FROM sales_salesorderdetail AS sod
INNER JOIN sales_salesorderheader AS soh
    ON sod.salesorderid = soh.salesorderid
WHERE soh.onlineorderflag = 1;
```

Query tersebut merupakan staging awal. Lookup surrogate key ke seluruh dimension dan perhitungan measure dilakukan pada tahap transformasi ETL.

### 4.3 Rumus measure

| Measure | Rumus |
|---|---|
| `gross_sales` | `order_qty * unit_price` |
| `discount_amount` | `gross_sales * discount_pct` |
| `net_sales` | `gross_sales - discount_amount` |
| Transaction Count | `COUNT(DISTINCT sales_order_id)` |
| Average Discount (%) | `SUM(discount_amount) / SUM(gross_sales) * 100` |

**Catatan perhitungan:**
- `unitpricediscount` merupakan nilai diskon desimal; contoh `0.10` berarti 10%.
- Jangan menjumlahkan `sales_salesorderheader.totaldue` setelah join ke detail karena nilai header dapat berulang pada setiap baris detail.
- Jumlah transaksi dihitung dengan `COUNT(DISTINCT sales_order_id)`, bukan jumlah baris fact.
- Hindari pembagian dengan nol pada Average Discount dan Average Selling Price.
- Jangan menjumlahkan nilai penjualan lintas mata uang tanpa konversi ke mata uang dasar yang telah disepakati.

---

## 5. Urutan Load ETL

Urutan load yang disarankan:

1. **Staging:** Ambil data sumber yang diperlukan dari `adventureworks`, termasuk filter `onlineorderflag = 1` untuk transaksi online.
2. **`dim_tanggal`:** Tabel kalender standar dosen sudah dibuat dan diisi pada database DW. Tidak perlu dibuat ulang oleh ETL; gunakan untuk lookup `tanggal_key`.
3. **`dim_product`:** Load produk beserta model, subkategori, dan kategori.
4. **`dim_customer`:** Load customer beserta person dan store.
5. **`dim_territory`:** Load data territory.
6. **`dim_promotion`:** Load master promosi dan anggota khusus `No Promotion`.
7. **`dim_currency`:** Load master mata uang dan validasi asumsi mata uang untuk `currencyrateid` NULL.
8. **`fact_online_sales`:** Lookup seluruh surrogate key dimension, hitung measure, lalu load data fact.

> Sebelum fact dimuat, pastikan anggota `Unknown` pada dimension yang diperlukan telah tersedia dan seluruh lookup surrogate key dapat diselesaikan. Untuk tanggal tidak diketahui, gunakan anggota standar `tanggal_key = -1`.

---

## 6. Catatan Validasi Sebelum Implementasi

1. Validasi asumsi USD untuk transaksi dengan `currencyrateid` NULL.
2. Pastikan anggota khusus `No Promotion` tersedia sebelum load fact.
3. Tentukan surrogate key khusus untuk anggota `Unknown` pada setiap dimension yang membutuhkannya.
4. Pastikan aturan SCD Type 2 untuk product dan customer memiliki mekanisme pencatatan perubahan. Riwayat sebelum proses ETL mulai berjalan tidak dapat direkonstruksi jika tidak tersedia pada sumber.
5. Pastikan tipe data target sesuai DDL aktual pada database `dw_kelompok_5`.
6. Pastikan tabel sumber yang digunakan memang tersedia di database MySQL `adventureworks`.
7. Pastikan lookup tanggal menggunakan `dim_tanggal.tanggal_key`, bukan nama tabel atau kolom tanggal versi lama.
8. Validasi jumlah baris fact terhadap jumlah baris detail transaksi online yang memenuhi filter sumber.

## 7. Riwayat Perubahan Dokumen

| Bagian | Sebelumnya | Revisi terbaru |
|---|---|---|
| Dimensi waktu | `dim_date` | `dim_tanggal` standar dosen |
| Primary key tanggal | `date_key` | `tanggal_key` |
| Foreign key fact | `fact_online_sales.date_key` | `fact_online_sales.tanggal_key` |
| Atribut kalender | `year_number`, `month_name`, dan lainnya | `tahun`, `semester`, `kuartal`, `bulan`, `nama_bulan`, atribut kalender standar dosen |
| Sumber database | Nama tabel dengan schema terpisah | Nama tabel MySQL dengan prefix schema, misalnya `sales_salesorderheader` |
| Proses kalender | Generate kalender sebagai bagian ETL | Kalender dibuat dari skrip dosen di DW; ETL melakukan lookup |

**Status:** Dokumen mapping telah disesuaikan dengan database MySQL/MariaDB dan standar dimensi tanggal dosen. Aturan mata uang NULL, anggota Unknown, serta implementasi SCD Type 2 tetap perlu divalidasi sebelum ETL final.
