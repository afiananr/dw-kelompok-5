# Desain OLAP Cube --- Online Sales

**Proyek:** Data Warehouse AdventureWorks --- Online Sales\
**Kelompok:** 5\
**Database sumber:** `adventureworks`\
**Database Data Warehouse:** `dw_kelompok_5`\
**OLAP Engine:** Mondrian\
**Fact Table:** `fact_online_sales`

------------------------------------------------------------------------

## 1. Tujuan OLAP Cube

OLAP Cube dirancang untuk mendukung analisis penjualan online
berdasarkan waktu, produk, pelanggan, wilayah, promosi, dan mata uang.
Cube menggunakan data pada `fact_online_sales` yang terhubung dengan
enam dimension pada Star Schema V2.

Analisis dibatasi pada transaksi online, yaitu transaksi dengan
`salesorderheader.onlineorderflag = TRUE` yang dipilih pada proses ETL.

## 2. Struktur Cube

  -----------------------------------------------------------------------
  Komponen                            Nama
  ----------------------------------- -----------------------------------
  Cube                                `Online Sales Cube`

  Fact table                          `fact_online_sales`

  Grain                               Satu baris detail produk dalam satu
                                      transaksi penjualan online

  Dimension                           `dim_date`, `dim_product`,
                                      `dim_customer`, `dim_territory`,
                                      `dim_promotion`, `dim_currency`
  -----------------------------------------------------------------------

### Relasi dimension dengan fact

-   `dim_date.date_key` → `fact_online_sales.date_key`
-   `dim_product.product_key` → `fact_online_sales.product_key`
-   `dim_customer.customer_key` → `fact_online_sales.customer_key`
-   `dim_territory.territory_key` → `fact_online_sales.territory_key`
-   `dim_promotion.promotion_key` → `fact_online_sales.promotion_key`
-   `dim_currency.currency_key` → `fact_online_sales.currency_key`

------------------------------------------------------------------------

## 3. Dimension dan Hierarki

Hierarki digunakan untuk mendukung operasi OLAP seperti **drill-down**,
**roll-up**, dan **slice-and-dice**.

### 3.1 DIM_DATE

**Tujuan:** Menganalisis perkembangan penjualan berdasarkan periode
waktu.

  Level     Atribut
  --------- ------------------------------
  Year      `year_number`
  Quarter   `quarter_number`
  Month     `month_number`, `month_name`
  Date      `full_date`, `date_key`

**Hierarki:** Year → Quarter → Month → Date.

### 3.2 DIM_PRODUCT

**Tujuan:** Menganalisis performa penjualan berdasarkan kategori dan
detail produk.

  Level           Atribut
  --------------- ----------------------------------
  Category        `product_category_name`
  Subcategory     `product_subcategory_name`
  Product Model   `product_model_name`
  Product         `product_name`, `product_number`

**Hierarki:** Category → Subcategory → Product Model → Product.

**Catatan:** Produk yang tidak memiliki kategori, subkategori, atau
model tetap dipertahankan. Nilai `Not Assigned` dapat digunakan sebagai
anggota hierarki ketika atribut sumber tidak tersedia.

### 3.3 DIM_CUSTOMER

**Tujuan:** Menganalisis kontribusi pelanggan berdasarkan tipe dan
pelanggan individual.

  Level           Atribut
  --------------- ----------------------------------------------
  Customer Type   `customer_type`
  Customer        `customer_name`, `store_name`, `customer_id`

**Hierarki:** Customer Type → Customer.

### 3.4 DIM_TERRITORY

**Tujuan:** Menganalisis distribusi penjualan berdasarkan wilayah
geografis.

  Level             Atribut
  ----------------- ----------------------------------
  Territory Group   `territory_group`
  Country/Region    `country_region_code`
  Territory         `territory_name`, `territory_id`

**Hierarki:** Territory Group → Country/Region → Territory.

**Catatan:** Hierarki ini merupakan susunan analisis yang diusulkan.
Validasi kembali keunikan dan hubungan antarlevel pada data sumber
sebelum konfigurasi Mondrian.

### 3.5 DIM_PROMOTION

**Tujuan:** Menganalisis performa transaksi berdasarkan jenis dan
kategori promosi.

  Level        Atribut
  ------------ -----------------------------------
  Offer Type   `offer_type`
  Category     `category`
  Promotion    `description`, `special_offer_id`

**Hierarki:** Offer Type → Category → Promotion.

Anggota `No Promotion` disediakan untuk transaksi tanpa promosi agar
dapat dibandingkan dengan transaksi yang menggunakan promosi.

### 3.6 DIM_CURRENCY

**Tujuan:** Mengelompokkan penjualan berdasarkan mata uang transaksi.

  Level      Atribut
  ---------- ----------------------------------
  Currency   `currency_name`, `currency_code`

**Hierarki:** Currency.

**Catatan:** Mata uang transaksi diperoleh melalui
`salesorderheader.currencyrateid` dan
`sales.currencyrate.tocurrencycode`. Pemetaan USD untuk transaksi dengan
`currencyrateid` NULL masih merupakan asumsi yang harus divalidasi.

------------------------------------------------------------------------

## 4. Measures

Measures merupakan nilai numerik yang dianalisis dari fact table.

  -------------------------------------------------------------------------------------------------------
  Measure           Kolom / Formula                                   Aggregation       Keterangan
  ----------------- ------------------------------------------------- ----------------- -----------------
  Gross Sales       `gross_sales`                                     SUM               Total penjualan
                                                                                        sebelum diskon

  Discount Amount   `discount_amount`                                 SUM               Total nilai
                                                                                        diskon

  Net Sales         `net_sales`                                       SUM               Total penjualan
                                                                                        setelah diskon

  Total Quantity    `order_qty`                                       SUM               Total unit produk
                                                                                        terjual

  Transaction Count `sales_order_id`                                  Distinct Count    Jumlah transaksi
                                                                                        unik

  Average Discount  `SUM(discount_amount) / SUM(gross_sales) * 100`   Calculated        Persentase diskon
  (%)                                                                                   tertimbang

  Average Selling   `SUM(net_sales) / SUM(order_qty)`                 Calculated        Rata-rata nilai
  Price                                                                                 penjualan bersih
                                                                                        per unit
  -------------------------------------------------------------------------------------------------------

**Catatan agregasi:**

-   `Transaction Count` wajib menggunakan distinct count karena satu
    transaksi dapat terdiri dari beberapa baris detail produk.
-   `Average Discount (%)` dihitung dari total discount amount dibagi
    total gross sales, bukan rata-rata sederhana dari persentase diskon
    setiap baris.
-   `Average Selling Price` dihitung dari total net sales dibagi total
    quantity.
-   Jika `gross_sales` bernilai nol, Average Discount harus ditangani
    agar tidak terjadi pembagian dengan nol.
-   Jika `order_qty` bernilai nol, Average Selling Price harus ditangani
    agar tidak terjadi pembagian dengan nol.

------------------------------------------------------------------------

## 5. Calculated Member

Calculated member yang diusulkan untuk cube:

### 5.1 Average Discount (%)

**Formula:**

``` text
(SUM(discount_amount) / SUM(gross_sales)) * 100
```

**Tujuan:** Mengetahui persentase diskon tertimbang terhadap total
penjualan sebelum diskon.

### 5.2 Average Selling Price

**Formula:**

``` text
SUM(net_sales) / SUM(order_qty)
```

**Tujuan:** Mengetahui rata-rata nilai penjualan bersih untuk setiap
unit produk yang terjual.

> Formula di atas merupakan definisi bisnis. Sintaks implementasinya
> perlu disesuaikan dengan MDX dan konfigurasi Mondrian.

------------------------------------------------------------------------

## 6. Pemetaan Business Questions ke Cube

  -----------------------------------------------------------------------
  ID                Business Question Dimension         Measures
  ----------------- ----------------- ----------------- -----------------
  BQ1               Bagaimana tren    DIM_DATE          Transaction
                    jumlah transaksi                    Count, Net Sales
                    dan nilai                           
                    penjualan online                    
                    per bulan/tahun?                    

  BQ2               Produk atau       DIM_PRODUCT       Net Sales, Total
                    kategori apa yang                   Quantity
                    memiliki nilai                      
                    penjualan online                    
                    tertinggi?                          

  BQ3               Wilayah mana yang DIM_TERRITORY     Net Sales,
                    memberikan                          Transaction Count
                    kontribusi nilai                    
                    penjualan online                    
                    terbesar?                           

  BQ4               Pelanggan mana    DIM_CUSTOMER      Transaction
                    yang memiliki                       Count, Net Sales
                    jumlah transaksi                    
                    dan total                           
                    pembelian                           
                    tertinggi?                          

  BQ5               Bagaimana         DIM_PROMOTION     Net Sales,
                    perbandingan                        Transaction
                    nilai penjualan,                    Count, Average
                    jumlah transaksi,                   Discount (%)
                    dan rata-rata                       
                    diskon antara                       
                    transaksi dengan                    
                    dan tanpa                           
                    promosi?                            
  -----------------------------------------------------------------------

### Contoh operasi OLAP

  -----------------------------------------------------------------------
  Operasi                             Contoh penggunaan
  ----------------------------------- -----------------------------------
  Roll-up                             Menggabungkan penjualan bulanan
                                      menjadi kuartalan atau tahunan

  Drill-down                          Melihat penjualan tahunan hingga ke
                                      detail bulan dan tanggal

  Slice                               Melihat penjualan hanya untuk satu
                                      tahun tertentu

  Dice                                Melihat penjualan produk tertentu
                                      pada wilayah dan periode tertentu

  Pivot                               Mengubah sudut pandang analisis,
                                      misalnya membandingkan produk
                                      berdasarkan wilayah
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 7. Catatan Desain dan Batasan

1.  Cube menggunakan Star Schema V2 yang terdiri dari satu fact table
    dan enam dimension.
2.  Seluruh fact hanya berisi transaksi online sesuai filter
    `onlineorderflag = TRUE` pada ETL.
3.  Nilai penjualan disimpan dalam mata uang transaksi. Penjumlahan
    lintas mata uang tidak boleh dianggap sebagai satu total yang
    sebanding tanpa konversi ke mata uang dasar yang disepakati.
4.  Kurs pada `average_rate` dan `end_of_day_rate` tersedia untuk
    mendukung penelusuran nilai tukar. Kebijakan konversi ke mata uang
    dasar perlu ditentukan terpisah.
5.  `DIM_TERRITORY` tidak memasukkan salesperson sebagai satu atribut
    pemilik wilayah karena satu territory dapat memiliki beberapa
    salesperson dan transaksi online yang diperiksa tidak memiliki
    `salespersonid`.
6.  Hierarki yang melibatkan beberapa atribut harus divalidasi agar
    setiap anggota pada level bawah memiliki hubungan yang konsisten
    dengan level di atasnya.
7.  Dokumen ini merupakan desain konseptual cube. Konfigurasi schema
    Mondrian, pengujian query MDX, dan integrasi dashboard merupakan
    tahap implementasi berikutnya.

------------------------------------------------------------------------

## 8. Urutan Implementasi Berikutnya

1.  Pastikan seluruh tabel dimension dan fact pada `dw_kelompok_5` sudah
    dibuat dan terisi.
2.  Validasi foreign key dan anggota `Unknown`/`No Promotion`.
3.  Konfigurasikan schema Mondrian berdasarkan fact table, dimension,
    hierarchy, level, dan measure pada dokumen ini.
4.  Uji measure dan calculated member menggunakan query MDX.
5.  Cocokkan hasil agregasi cube dengan query SQL langsung pada Data
    Warehouse.
6.  Hubungkan cube ke dashboard untuk menjawab lima business questions.
