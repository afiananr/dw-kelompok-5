# Kamus Data Data Warehouse -- Online Sales

## 1. Informasi Dokumen

  Atribut           Keterangan
  ----------------- ---------------------------------------------
  Proyek            Data Warehouse AdventureWorks -- Kelompok 5
  Proses bisnis     Online Sales
  Database sumber   `adventureworks`
  Database target   `dw_kelompok_5`
  DBMS              MySQL/MariaDB
  Dokumen           Kamus Data
  Versi             1.0

Dokumen ini menjelaskan struktur tabel pada database `dw_kelompok_5`,
meliputi nama kolom, tipe data, kunci, dan fungsi setiap atribut.
Struktur disusun berdasarkan hasil pemeriksaan tabel aktual melalui
`information_schema` dan hasil pemeriksaan struktur yang telah
dilakukan.

## 2. Gambaran Umum Star Schema

Skema Data Warehouse terdiri dari satu tabel fakta dan enam tabel
dimensi:

-   `fact_online_sales`
-   `dim_tanggal`
-   `dim_product`
-   `dim_customer`
-   `dim_territory`
-   `dim_promotion`
-   `dim_currency`

**Grain tabel fakta:** satu baris pada `fact_online_sales`
merepresentasikan satu baris detail produk dalam satu transaksi
penjualan online (*one row per sales order detail*).

Tabel fakta terhubung ke enam dimensi melalui surrogate key. Tabel
`dim_tanggal` menggunakan skrip standar kelas versi 1.0 dan tidak dibuat
ulang oleh DDL kelompok.

## 3. Kamus Data Tabel Dimensi

### 3.1 `dim_tanggal`

**Fungsi:** menyimpan atribut kalender untuk analisis penjualan
berdasarkan waktu. Tabel ini menggunakan skrip standar kelas versi 1.0.

  -----------------------------------------------------------------------------
  Nama kolom              Tipe data         Key               Keterangan
  ----------------------- ----------------- ----------------- -----------------
  `tanggal_key`           INT               PK                Kunci pengganti
                                                              (surrogate key)
                                                              untuk tanggal

  `tanggal`               DATE              UNIQUE            Nilai tanggal
                                                              kalender

  `tahun`                 INT               ---               Tahun kalender

  `semester`              INT               ---               Semester dalam
                                                              tahun

  `kuartal`               INT               ---               Kuartal dalam
                                                              tahun

  `bulan`                 INT               ---               Nomor bulan

  `nama_bulan`            VARCHAR           ---               Nama bulan

  `minggu_dalam_tahun`    INT               ---               Nomor minggu
                                                              dalam tahun

  `tanggal_dalam_bulan`   INT               ---               Nomor hari dalam
                                                              bulan

  `hari_dalam_minggu`     INT               ---               Nomor hari dalam
                                                              minggu

  `nama_hari`             VARCHAR           ---               Nama hari

  `is_akhir_pekan`        TINYINT(1)        ---               Penanda apakah
                                                              tanggal termasuk
                                                              akhir pekan
  -----------------------------------------------------------------------------

**Catatan implementasi:** hasil pemeriksaan menunjukkan 2.192 baris,
terdiri dari satu unknown member (`tanggal_key = -1`) dan 2.191 tanggal
kalender pada rentang 2010-01-01 sampai 2015-12-31. `tanggal_key`
merupakan primary key dan `tanggal` memiliki unique key. Nama kolom dan
tipe data di atas mengikuti struktur skrip standar; panjang VARCHAR dan
detail tipe integer dapat dilihat pada skrip `dim_tanggal.sql` yang
disertakan dalam proyek.

### 3.2 `dim_product`

**Fungsi:** menyimpan informasi produk, model, subkategori, kategori,
dan atribut harga produk. Dimensi ini dirancang untuk mendukung
perubahan historis menggunakan SCD Type 2.

  ------------------------------------------------------------------------------------
  Nama kolom                   Tipe data         Key               Keterangan
  ---------------------------- ----------------- ----------------- -------------------
  `product_key`                INT(11)           PK,               Surrogate key versi
                                                 AUTO_INCREMENT    produk

  `product_id`                 INT(11)           ---               ID produk dari
                                                                   sistem sumber

  `product_name`               VARCHAR(100)      ---               Nama produk

  `product_number`             VARCHAR(25)       ---               Nomor/kode produk

  `product_model_id`           INT(11)           ---               ID model produk

  `product_model_name`         VARCHAR(100)      ---               Nama model produk

  `product_subcategory_id`     INT(11)           ---               ID subkategori
                                                                   produk

  `product_subcategory_name`   VARCHAR(100)      ---               Nama subkategori
                                                                   produk

  `product_category_id`        INT(11)           ---               ID kategori produk

  `product_category_name`      VARCHAR(100)      ---               Nama kategori
                                                                   produk

  `color`                      VARCHAR(20)       ---               Warna produk

  `size`                       VARCHAR(10)       ---               Ukuran produk

  `standard_cost`              DECIMAL(18,4)     ---               Biaya standar
                                                                   produk

  `list_price`                 DECIMAL(18,4)     ---               Harga jual yang
                                                                   tercantum

  `effective_start_date`       DATE              ---               Tanggal mulai
                                                                   berlakunya versi
                                                                   data

  `effective_end_date`         DATE              ---               Tanggal akhir
                                                                   berlakunya versi
                                                                   data

  `is_current`                 TINYINT(1)        ---               Penanda versi data
                                                                   yang masih aktif

  `current_product_id`         INT(11),          UNIQUE            Menghasilkan
                               generated stored                    `product_id` ketika
                                                                   `is_current = 1`,
                                                                   selain itu NULL
  ------------------------------------------------------------------------------------

**Aturan SCD Type 2:** perubahan atribut produk dapat disimpan sebagai
versi baru dengan rentang tanggal berlaku. Kolom `current_product_id`
merupakan generated column dengan ekspresi
`CASE WHEN is_current = 1 THEN product_id ELSE NULL END`, dan memiliki
unique key `uq_product_current` untuk membatasi satu versi aktif per
produk.

**Unknown member:** `product_key = -1`.

### 3.3 `dim_customer`

**Fungsi:** menyimpan informasi pelanggan, baik pelanggan perorangan
maupun pelanggan toko. Dimensi ini dirancang untuk mendukung SCD Type 2.

  --------------------------------------------------------------------------------
  Nama kolom               Tipe data         Key               Keterangan
  ------------------------ ----------------- ----------------- -------------------
  `customer_key`           INT(11)           PK,               Surrogate key versi
                                             AUTO_INCREMENT    pelanggan

  `customer_id`            INT(11)           ---               ID pelanggan dari
                                                               sistem sumber

  `person_id`              INT(11)           ---               ID person yang
                                                               terkait, jika
                                                               tersedia

  `store_id`               INT(11)           ---               ID toko yang
                                                               terkait, jika
                                                               tersedia

  `customer_type`          VARCHAR(30)       ---               Jenis pelanggan

  `customer_name`          VARCHAR(150)      ---               Nama pelanggan

  `store_name`             VARCHAR(150)      ---               Nama toko

  `effective_start_date`   DATE              ---               Tanggal mulai
                                                               berlakunya versi
                                                               data

  `effective_end_date`     DATE              ---               Tanggal akhir
                                                               berlakunya versi
                                                               data

  `is_current`             TINYINT(1)        ---               Penanda versi data
                                                               yang masih aktif

  `current_customer_id`    INT(11),          UNIQUE            Menghasilkan
                           generated stored                    `customer_id`
                                                               ketika
                                                               `is_current = 1`,
                                                               selain itu NULL
  --------------------------------------------------------------------------------

**Aturan SCD Type 2:** perubahan atribut pelanggan dapat disimpan
sebagai versi baru dengan rentang tanggal berlaku. Kolom
`current_customer_id` merupakan generated column dengan ekspresi
`CASE WHEN is_current = 1 THEN customer_id ELSE NULL END`, dan memiliki
unique key `uq_customer_current` untuk membatasi satu versi aktif per
pelanggan.

**Unknown member:** `customer_key = -1`.

### 3.4 `dim_territory`

**Fungsi:** menyimpan informasi wilayah penjualan untuk analisis
kontribusi penjualan berdasarkan wilayah.

  -----------------------------------------------------------------------------
  Nama kolom              Tipe data         Key               Keterangan
  ----------------------- ----------------- ----------------- -----------------
  `territory_key`         INT(11)           PK,               Surrogate key
                                            AUTO_INCREMENT    wilayah

  `territory_id`          INT(11)           UNIQUE            ID wilayah dari
                                                              sistem sumber

  `territory_name`        VARCHAR(100)      ---               Nama wilayah

  `country_region_code`   VARCHAR(10)       ---               Kode negara atau
                                                              wilayah

  `territory_group`       VARCHAR(50)       ---               Kelompok wilayah
  -----------------------------------------------------------------------------

**Unknown member:** `territory_key = -1`.

### 3.5 `dim_promotion`

**Fungsi:** menyimpan informasi promosi atau penawaran khusus yang
terkait dengan transaksi penjualan.

  --------------------------------------------------------------------------
  Nama kolom           Tipe data         Key               Keterangan
  -------------------- ----------------- ----------------- -----------------
  `promotion_key`      INT(11)           PK,               Surrogate key
                                         AUTO_INCREMENT    promosi

  `special_offer_id`   INT(11)           UNIQUE            ID penawaran
                                                           khusus dari
                                                           sistem sumber

  `description`        VARCHAR(255)      ---               Deskripsi promosi

  `offer_type`         VARCHAR(50)       ---               Jenis penawaran

  `category`           VARCHAR(50)       ---               Kategori promosi

  `discount_pct`       DECIMAL(8,4)      ---               Persentase diskon

  `promotion_status`   VARCHAR(30)       ---               Status promosi
  --------------------------------------------------------------------------

**Unknown member:** `promotion_key = -1`.

### 3.6 `dim_currency`

**Fungsi:** menyimpan identitas mata uang yang digunakan dalam transaksi
sehingga data penjualan dapat dianalisis berdasarkan mata uang.

  -----------------------------------------------------------------------
  Nama kolom        Tipe data         Key               Keterangan
  ----------------- ----------------- ----------------- -----------------
  `currency_key`    INT(11)           PK,               Surrogate key
                                      AUTO_INCREMENT    mata uang

  `currency_code`   VARCHAR(10)       UNIQUE            Kode mata uang

  `currency_name`   VARCHAR(100)      ---               Nama mata uang
  -----------------------------------------------------------------------

**Unknown member:** `currency_key = -1`, `currency_code = 'UNK'`, dan
`currency_name = 'Tidak diketahui'`.

## 4. Kamus Data Tabel Fakta

### 4.1 `fact_online_sales`

**Fungsi:** menyimpan fakta penjualan online pada tingkat detail produk
per transaksi. Tabel ini menghubungkan transaksi dengan dimensi tanggal,
produk, pelanggan, wilayah, promosi, dan mata uang.

  ---------------------------------------------------------------------------------------------
  Nama kolom                Tipe data         Key               Keterangan
  ------------------------- ----------------- ----------------- -------------------------------
  `sales_order_detail_id`   INT(11)           PK                ID unik baris detail pesanan
                                                                dari sumber

  `sales_order_id`          INT(11)           ---               ID transaksi/pesanan

  `tanggal_key`             INT(11)           FK                Referensi ke
                                                                `dim_tanggal.tanggal_key`

  `product_key`             INT(11)           FK                Referensi ke
                                                                `dim_product.product_key`

  `customer_key`            INT(11)           FK                Referensi ke
                                                                `dim_customer.customer_key`

  `territory_key`           INT(11)           FK                Referensi ke
                                                                `dim_territory.territory_key`

  `promotion_key`           INT(11)           FK                Referensi ke
                                                                `dim_promotion.promotion_key`

  `currency_key`            INT(11)           FK                Referensi ke
                                                                `dim_currency.currency_key`

  `currency_rate_id`        INT(11)           ---               ID nilai kurs dari sumber,
                                                                dapat NULL

  `average_rate`            DECIMAL(18,8)     ---               Nilai kurs rata-rata, dapat
                                                                NULL

  `end_of_day_rate`         DECIMAL(18,8)     ---               Nilai kurs akhir hari, dapat
                                                                NULL

  `order_qty`               INT(11)           ---               Jumlah unit produk yang dipesan

  `unit_price`              DECIMAL(18,4)     ---               Harga per unit

  `discount_pct`            DECIMAL(8,4)      ---               Persentase diskon; default
                                                                0.0000

  `gross_sales`             DECIMAL(18,4)     ---               Nilai penjualan kotor sebelum
                                                                diskon

  `discount_amount`         DECIMAL(18,4)     ---               Nilai potongan diskon

  `net_sales`               DECIMAL(18,4)     ---               Nilai penjualan bersih setelah
                                                                diskon
  ---------------------------------------------------------------------------------------------

**Foreign key yang diterapkan:**

  ---------------------------------------------------------------------------
  Nama constraint       Kolom fakta       Tabel referensi   Kolom referensi
  --------------------- ----------------- ----------------- -----------------
  `fk_fact_tanggal`     `tanggal_key`     `dim_tanggal`     `tanggal_key`

  `fk_fact_product`     `product_key`     `dim_product`     `product_key`

  `fk_fact_customer`    `customer_key`    `dim_customer`    `customer_key`

  `fk_fact_territory`   `territory_key`   `dim_territory`   `territory_key`

  `fk_fact_promotion`   `promotion_key`   `dim_promotion`   `promotion_key`

  `fk_fact_currency`    `currency_key`    `dim_currency`    `currency_key`
  ---------------------------------------------------------------------------

**Rumus measure:**

-   Penjualan kotor: `gross_sales = order_qty × unit_price`
-   Nilai diskon: `discount_amount = gross_sales × discount_pct`
-   Penjualan bersih: `net_sales = gross_sales - discount_amount`

Rumus di atas mengasumsikan `discount_pct` disimpan sebagai nilai
proporsi (misalnya 0.10 untuk 10%). Pastikan transformasi ETL
menggunakan konvensi yang sama dengan sumber data.

**Catatan analisis:** jumlah transaksi dihitung dengan
`COUNT(DISTINCT sales_order_id)`, bukan menghitung jumlah baris fakta.
Nilai `TotalDue` dari tabel header tidak boleh dijumlahkan setelah
digabung dengan detail karena nilainya berada pada tingkat header
transaksi.

## 5. Ringkasan Relasi Antar Tabel

  -----------------------------------------------------------------------------------
  Tabel dimensi           Primary key             Relasi ke tabel fakta
  ----------------------- ----------------------- -----------------------------------
  `dim_tanggal`           `tanggal_key`           `fact_online_sales.tanggal_key`

  `dim_product`           `product_key`           `fact_online_sales.product_key`

  `dim_customer`          `customer_key`          `fact_online_sales.customer_key`

  `dim_territory`         `territory_key`         `fact_online_sales.territory_key`

  `dim_promotion`         `promotion_key`         `fact_online_sales.promotion_key`

  `dim_currency`          `currency_key`          `fact_online_sales.currency_key`
  -----------------------------------------------------------------------------------

## 6. Penjelasan Dimensi Tanggal dan Versi Skrip

Dimensi tanggal digunakan untuk menyediakan informasi kalender yang
konsisten dalam analisis penjualan. Dengan dimensi ini, data transaksi
dapat dikelompokkan berdasarkan tahun, semester, kuartal, bulan, minggu,
tanggal, maupun hari. Hierarki waktu yang dapat digunakan dalam analisis
adalah **Tahun → Semester → Kuartal → Bulan → Tanggal**.

Tabel `dim_tanggal` pada proyek ini menggunakan **skrip standar kelas
versi 1.0**. Hasil pemeriksaan menunjukkan total 2.192 baris, yaitu satu
baris unknown member dengan `tanggal_key = -1` dan 2.191 tanggal
kalender dari 1 Januari 2010 sampai 31 Desember 2015. Tabel tersebut
dipertahankan sesuai skrip standar dan tidak dibuat ulang oleh DDL
kelompok.

## 7. Catatan Validasi dan Batasan Informasi

1.  Kamus data ini mendokumentasikan nama kolom dan tipe data yang telah
    diperoleh dari pemeriksaan struktur tabel. Untuk `dim_tanggal`,
    panjang tipe `VARCHAR` dan detail tipe integer perlu dicocokkan
    kembali dengan file standar `dim_tanggal.sql` jika diperlukan pada
    dokumentasi final.
2.  Tipe data, nullability, default, dan generated expression untuk
    kolom dimensi selain yang dijelaskan secara khusus dapat diperiksa
    kembali melalui `information_schema.COLUMNS`.
3.  DDL menggunakan unknown member pada lima dimensi selain
    `dim_tanggal`. Nilai unknown `dim_currency` yang terverifikasi
    adalah kode `UNK`.
4.  Kolom `currency_rate_id`, `average_rate`, dan `end_of_day_rate`
    disimpan pada tabel fakta karena nilai kurs dapat berkaitan dengan
    tanggal dan pasangan mata uang, bukan hanya identitas mata uang.
5.  Dokumen ini menjelaskan struktur target Data Warehouse. Pemetaan
    rinci dari setiap kolom tabel sumber ke kolom target dijelaskan pada
    dokumen *source-to-target mapping*.

------------------------------------------------------------------------

**Akhir dokumen --- Kamus Data Data Warehouse Online Sales Kelompok 5**
