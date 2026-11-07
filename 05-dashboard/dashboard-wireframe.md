# Dashboard Wireframe --- Online Sales Performance

**Proyek:** Data Warehouse AdventureWorks --- Online Sales\
**Kelompok:** 5\
**Dashboard:** Online Sales Performance\
**Sumber data:** Data Warehouse `dw_kelompok_5`\
**OLAP Cube:** Online Sales Cube\
**Status:** Rancangan wireframe (belum terhubung ke data aktual)

------------------------------------------------------------------------

## 1. Tujuan Dashboard

Dashboard **Online Sales Performance** dirancang untuk memantau dan
menganalisis kinerja penjualan online pada AdventureWorks. Dashboard
menyajikan ringkasan KPI dan lima visualisasi analitis yang mengacu pada
lima Business Questions (BQ1--BQ5).

Dashboard menggunakan enam dimension pada Star Schema V2:

1.  `dim_date`
2.  `dim_product`
3.  `dim_customer`
4.  `dim_territory`
5.  `dim_promotion`
6.  `dim_currency`

Data yang ditampilkan pada dashboard direncanakan berasal dari
`fact_online_sales` dan dimension terkait melalui OLAP Cube.

## 2. Informasi Layout

  -----------------------------------------------------------------------
  Komponen                            Rancangan
  ----------------------------------- -----------------------------------
  Nama dashboard                      Online Sales Performance

  Subtitle                            AdventureWorks \| Online Sales
                                      Analytics

  Platform                            Desktop

  Ukuran frame                        1440 × 1024 px

  Gaya desain                         Minimalis, profesional, dan
                                      berorientasi data

  Tema                                Light theme

  Navigasi                            Sidebar di sisi kiri

  Konten utama                        Header, global filters, KPI cards,
                                      dan lima visualisasi

  Status data                         Placeholder / schematic only, bukan
                                      data aktual
  -----------------------------------------------------------------------

### 2.1 Sidebar Navigation

Sidebar menampilkan navigasi workspace berikut:

  Menu                 Fungsi
  -------------------- --------------------------------------------
  Overview             Halaman ringkasan kinerja penjualan online
  Sales Analysis       Analisis tren dan nilai penjualan
  Product Analysis     Analisis performa produk
  Customer Analysis    Analisis pelanggan
  Territory Analysis   Analisis wilayah penjualan
  Promotion Analysis   Analisis penggunaan promosi
  Settings             Pengaturan dashboard

Sidebar juga menampilkan ringkasan OLAP Cube dengan enam dimension:
Date, Product, Customer, Territory, Promotion, dan Currency.

### 2.2 Header

Header menampilkan: - Judul: `Online Sales Performance` - Deskripsi:
`Monitor and analyze online sales performance.` - Informasi waktu
pembaruan terakhir (`Last updated`) - Placeholder profil pengguna

### 2.3 Global Filters

Filter global yang tersedia pada wireframe:

  -------------------------------------------------------------------------------------
  Filter                  Dimension / Atribut                   Fungsi
  ----------------------- ------------------------------------- -----------------------
  Year                    `dim_date.year_number`                Memilih tahun analisis

  Quarter                 `dim_date.quarter_number`             Memilih kuartal

  Month                   `dim_date.month_number`, `month_name` Memilih bulan

  Product Category        `dim_product.product_category_name`   Memfilter kategori
                                                                produk

  Territory               `dim_territory.territory_name`        Memfilter wilayah

  Currency                `dim_currency.currency_code`          Memfilter mata uang
                                                                transaksi
  -------------------------------------------------------------------------------------

Filter dirancang untuk membantu pengguna mempersempit data yang
ditampilkan pada KPI dan visualisasi.

------------------------------------------------------------------------

## 3. KPI Summary Cards

Dashboard menampilkan empat KPI cards pada bagian atas konten utama.

  -------------------------------------------------------------------------------------------------------
  No.               KPI               Sumber / Measure                                  Keterangan
  ----------------- ----------------- ------------------------------------------------- -----------------
  1                 Total Net Sales   `SUM(fact_online_sales.net_sales)`                Total nilai
                                                                                        penjualan setelah
                                                                                        diskon

  2                 Total             Distinct Count `sales_order_id`                   Jumlah transaksi
                    Transactions                                                        unik

  3                 Total Quantity    `SUM(fact_online_sales.order_qty)`                Total unit produk
                                                                                        terjual

  4                 Average Discount  `SUM(discount_amount) / SUM(gross_sales) × 100`   Persentase diskon
                                                                                        tertimbang
  -------------------------------------------------------------------------------------------------------

Setiap KPI card menampilkan label, nilai utama, satuan, dan area
indikator perbandingan dengan periode sebelumnya. Nilai aktual belum
ditampilkan pada wireframe dan menggunakan placeholder.

**Catatan:** Total Net Sales harus ditampilkan bersama mata uang yang
sedang dipilih. Jangan menjumlahkan nilai dari mata uang berbeda tanpa
konversi yang telah disepakati.

------------------------------------------------------------------------

## 4. Rancangan Visualisasi Dashboard

Setiap visualisasi diberi nomor dan Business Question ID agar
keterkaitannya dengan kebutuhan analisis dapat diperiksa.

### 4.1 Visualisasi 01 --- Monthly Online Sales Trend

**Business Question (BQ1):**\
Bagaimana tren jumlah transaksi dan nilai penjualan online per
bulan/tahun?

  Elemen              Rancangan
  ------------------- ---------------------------------
  Nomor visualisasi   01
  Judul               Monthly Online Sales Trend
  Tipe visualisasi    Line Chart
  Dimension           `dim_date`
  Atribut waktu       Year, Month
  Measure             Net Sales, Transaction Count
  Sumbu X             Month / Year
  Sumbu Y             Net Sales dan Transaction Count

**Tujuan:** Memantau perubahan nilai penjualan dan jumlah transaksi
online dari waktu ke waktu.

**Catatan desain:** Net Sales dan Transaction Count memiliki satuan yang
berbeda. Pada implementasi, gunakan dua sumbu Y yang terpisah atau dua
grafik agar perbandingan tidak menyesatkan. Label mata uang perlu
mengikuti filter Currency.

### 4.2 Visualisasi 02 --- Top 10 Products by Sales

**Business Question (BQ2):**\
Produk atau kategori apa yang memiliki nilai penjualan online tertinggi?

  Elemen              Rancangan
  ------------------- ---------------------------------
  Nomor visualisasi   02
  Judul               Top 10 Products by Sales
  Tipe visualisasi    Horizontal Bar Chart
  Dimension           `dim_product`
  Atribut analisis    Product, Category, Subcategory
  Measure utama       Net Sales
  Pengurutan          Net Sales tertinggi ke terendah
  Jumlah data         Top 10 Products

**Tujuan:** Mengidentifikasi produk dengan kontribusi penjualan online
tertinggi.

Wireframe menyediakan pilihan tingkat analisis Product, Category, dan
Subcategory. Pengguna dapat melihat performa produk secara lebih rinci
atau mengelompokkannya berdasarkan kategori.

### 4.3 Visualisasi 03 --- Sales Contribution by Territory

**Business Question (BQ3):**\
Wilayah mana yang memberikan kontribusi nilai penjualan online terbesar?

  Elemen              Rancangan
  ------------------- ---------------------------------
  Nomor visualisasi   03
  Judul               Sales Contribution by Territory
  Tipe visualisasi    Horizontal Bar Chart
  Dimension           `dim_territory`
  Atribut analisis    Territory Group, Territory Name
  Measure             Net Sales
  Pengurutan          Net Sales tertinggi ke terendah

**Tujuan:** Membandingkan kontribusi penjualan online antarwilayah.

Wireframe menyediakan pilihan pengelompokan berdasarkan Territory Group
dan Territory Name.

### 4.4 Visualisasi 04 --- Top 10 Customers

**Business Question (BQ4):**\
Pelanggan mana yang memiliki jumlah transaksi dan total pembelian
tertinggi?

  Elemen              Rancangan
  ------------------- ------------------------------
  Nomor visualisasi   04
  Judul               Top 10 Customers
  Tipe visualisasi    Data Table
  Dimension           `dim_customer`
  Measure             Transaction Count, Net Sales
  Jumlah data         Top 10 Customers

**Kolom tabel:**

  Kolom               Keterangan
  ------------------- ------------------------------
  Rank                Peringkat pelanggan
  Customer Name       Nama pelanggan atau toko
  Customer Type       Jenis pelanggan
  Transaction Count   Jumlah transaksi unik
  Total Net Sales     Total nilai penjualan bersih

**Tujuan:** Mengidentifikasi pelanggan dengan aktivitas transaksi dan
nilai pembelian tertinggi.

### 4.5 Visualisasi 05 --- Promotion Performance Comparison

**Business Question (BQ5):**\
Bagaimana perbandingan nilai penjualan, jumlah transaksi, dan rata-rata
diskon antara transaksi dengan dan tanpa promosi?

  Elemen              Rancangan
  ------------------- ------------------------------------------------
  Nomor visualisasi   05
  Judul               Promotion Performance Comparison
  Tipe visualisasi    Grouped Bar Chart
  Dimension           `dim_promotion`
  Kelompok            With Promotion, No Promotion
  Measures            Net Sales, Transaction Count, Average Discount

Visualisasi dibagi menjadi tiga panel perbandingan:

1.  **Net Sales:** membandingkan total penjualan bersih.
2.  **Transaction Count:** membandingkan jumlah transaksi unik.
3.  **Average Discount:** membandingkan persentase diskon tertimbang.

**Tujuan:** Menilai perbedaan performa transaksi yang menggunakan
promosi dan yang tidak menggunakan promosi.

**Catatan desain:** Ketiga measure memiliki satuan berbeda. Gunakan
skala masing-masing panel dan label satuan yang jelas. Anggota
`No Promotion` harus tersedia pada `dim_promotion`.

------------------------------------------------------------------------

## 5. Pemetaan Business Questions

  --------------------------------------------------------------------------
  ID             Business       Visualisasi    Dimension      Measures
                 Question                                     
  -------------- -------------- -------------- -------------- --------------
  BQ1            Bagaimana tren 01 --- Monthly Date           Net Sales,
                 jumlah         Online Sales                  Transaction
                 transaksi dan  Trend                         Count
                 nilai                                        
                 penjualan                                    
                 online per                                   
                 bulan/tahun?                                 

  BQ2            Produk atau    02 --- Top 10  Product        Net Sales
                 kategori apa   Products by                   
                 yang memiliki  Sales                         
                 nilai                                        
                 penjualan                                    
                 online                                       
                 tertinggi?                                   

  BQ3            Wilayah mana   03 --- Sales   Territory      Net Sales
                 yang           Contribution                  
                 memberikan     by Territory                  
                 kontribusi                                   
                 nilai                                        
                 penjualan                                    
                 online                                       
                 terbesar?                                    

  BQ4            Pelanggan mana 04 --- Top 10  Customer       Transaction
                 yang memiliki  Customers                     Count, Net
                 jumlah                                       Sales
                 transaksi dan                                
                 total                                        
                 pembelian                                    
                 tertinggi?                                   

  BQ5            Bagaimana      05 ---         Promotion      Net Sales,
                 perbandingan   Promotion                     Transaction
                 nilai          Performance                   Count, Average
                 penjualan,     Comparison                    Discount
                 jumlah                                       
                 transaksi, dan                               
                 rata-rata                                    
                 diskon antara                                
                 transaksi                                    
                 dengan dan                                   
                 tanpa promosi?                               
  --------------------------------------------------------------------------

Dengan pemetaan tersebut, seluruh lima Business Questions memiliki
visualisasi yang direncanakan pada dashboard.

------------------------------------------------------------------------

## 6. Susunan Layout

Susunan komponen pada frame desktop 1440 × 1024 px:

  -----------------------------------------------------------------------
  Urutan                  Area                    Komponen
  ----------------------- ----------------------- -----------------------
  1                       Sidebar                 Logo, navigasi,
                                                  ringkasan OLAP Cube,
                                                  Settings

  2                       Header                  Judul dashboard,
                                                  deskripsi, last
                                                  updated, profil

  3                       Filter section          Year, Quarter, Month,
                                                  Product Category,
                                                  Territory, Currency

  4                       KPI section             Total Net Sales, Total
                                                  Transactions, Total
                                                  Quantity, Average
                                                  Discount

  5                       Baris visualisasi 1     01 --- Monthly Online
                                                  Sales Trend (lebar
                                                  penuh)

  6                       Baris visualisasi 2     02 --- Top 10 Products
                                                  by Sales dan 03 ---
                                                  Sales Contribution by
                                                  Territory

  7                       Baris visualisasi 3     04 --- Top 10 Customers
                                                  dan 05 --- Promotion
                                                  Performance Comparison
  -----------------------------------------------------------------------

Konten utama dapat dibuat scrollable secara vertikal apabila seluruh
visualisasi tidak muat pada tinggi layar.

------------------------------------------------------------------------

## 7. Catatan Implementasi dan Validasi

1.  Wireframe merupakan rancangan tampilan, bukan dashboard yang sudah
    terhubung ke database atau Mondrian.
2.  Angka pada wireframe menggunakan placeholder (`--`). Tidak ada nilai
    penjualan aktual yang direpresentasikan.
3.  Filter global direncanakan memengaruhi KPI dan visualisasi yang
    relevan.
4.  Transaction Count harus dihitung menggunakan distinct count pada
    `sales_order_id`, karena satu transaksi dapat memiliki beberapa
    baris detail produk.
5.  Average Discount dihitung menggunakan
    `SUM(discount_amount) / SUM(gross_sales) × 100`, bukan rata-rata
    sederhana persentase diskon per baris.
6.  Nilai penjualan dalam mata uang berbeda tidak boleh dijumlahkan
    langsung tanpa konversi ke mata uang dasar yang telah disepakati.
7.  Untuk BQ1, Net Sales dan Transaction Count perlu ditampilkan dengan
    skala yang sesuai karena satuannya berbeda.
8.  Untuk BQ5, setiap panel perbandingan perlu menunjukkan satuan dan
    skala masing-masing measure.
9.  Top 10 Products dan Top 10 Customers harus diurutkan berdasarkan
    measure yang sesuai.
10. Data pada visualisasi harus divalidasi terhadap hasil query SQL di
    Data Warehouse atau hasil query OLAP Cube setelah implementasi.

------------------------------------------------------------------------

## 8. Output dan Status Pekerjaan

  -----------------------------------------------------------------------
  Output                  Format                  Keterangan
  ----------------------- ----------------------- -----------------------
  Dashboard wireframe     PNG / Figma             Rancangan visual
                                                  desktop

  Dokumentasi wireframe   Markdown (`.md`)        Penjelasan layout, KPI,
                                                  visualisasi, dan
                                                  mapping BQ

  Implementasi dashboard  Menyesuaikan teknologi  Tahap lanjutan, belum
                          yang dipilih            termasuk dalam
                                                  wireframe
  -----------------------------------------------------------------------

**Status:** Rancangan wireframe telah dibuat menggunakan Figma AI
berdasarkan lima Business Questions dan struktur OLAP Cube. Integrasi
data aktual, validasi hasil analisis, serta implementasi dashboard
interaktif masih merupakan pekerjaan lanjutan.
