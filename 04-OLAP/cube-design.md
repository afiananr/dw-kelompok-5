# Desain OLAP Cube — Online Sales

**Proyek:** Data Warehouse AdventureWorks — Online Sales  
**Kelompok:** 5  
**Database sumber:** `adventureworks`  
**Database Data Warehouse:** `dw_kelompok_5`  
**OLAP Engine:** Mondrian  
**Fact Table:** `fact_online_sales`  
**Versi desain:** V2 — disesuaikan dengan standar `dim_tanggal` dosen

---

## 1. Tujuan OLAP Cube

OLAP Cube mendukung analisis penjualan online berdasarkan waktu, produk, pelanggan, wilayah, promosi, dan mata uang. Cube menggunakan `fact_online_sales` yang terhubung dengan enam dimension pada Star Schema V2.

Analisis dibatasi pada transaksi online, yaitu transaksi dengan `sales_salesorderheader.onlineorderflag = 1` yang dipilih pada proses ETL.

## 2. Struktur Cube

| Komponen | Nama / Keterangan |
|---|---|
| Cube | `Online Sales Cube` |
| Fact table | `fact_online_sales` |
| Grain | Satu baris detail produk dalam satu transaksi penjualan online |
| Dimension | `dim_tanggal`, `dim_product`, `dim_customer`, `dim_territory`, `dim_promotion`, `dim_currency` |

### Relasi dimension dengan fact

| Dimension | Primary Key | Foreign Key pada fact |
|---|---|---|
| `dim_tanggal` | `tanggal_key` | `fact_online_sales.tanggal_key` |
| `dim_product` | `product_key` | `fact_online_sales.product_key` |
| `dim_customer` | `customer_key` | `fact_online_sales.customer_key` |
| `dim_territory` | `territory_key` | `fact_online_sales.territory_key` |
| `dim_promotion` | `promotion_key` | `fact_online_sales.promotion_key` |
| `dim_currency` | `currency_key` | `fact_online_sales.currency_key` |

Perubahan dari desain sebelumnya: `dim_date` diganti menjadi `dim_tanggal`, sedangkan `fact_online_sales.date_key` diganti menjadi `fact_online_sales.tanggal_key`. Lima dimension lainnya tetap.

---

## 3. Dimension dan Hierarki

Hierarki digunakan untuk mendukung operasi OLAP seperti **drill-down**, **roll-up**, dan **slice-and-dice**.

### 3.1 DIM_TANGGAL

**Tujuan:** Menganalisis perkembangan penjualan berdasarkan periode waktu menggunakan tabel tanggal standar dosen.

- **Tabel:** `dim_tanggal`
- **Primary key:** `tanggal_key`
- **Foreign key pada fact:** `fact_online_sales.tanggal_key`

| Level | Atribut | Keterangan |
|---|---|---|
| Year | `tahun` | Tahun kalender |
| Semester | `semester` | 1 = Januari–Juni; 2 = Juli–Desember |
| Quarter | `kuartal` | Kuartal 1–4 |
| Month | `bulan`, `nama_bulan` | Nomor dan nama bulan |
| Date | `tanggal`, `tanggal_key`, `tanggal_dalam_bulan` | Tanggal kalender dan key |

**Hierarki utama:** Year → Semester → Quarter → Month → Date.

Atribut tambahan yang tersedia:

| Atribut | Kegunaan |
|---|---|
| `minggu_dalam_tahun` | Analisis berdasarkan minggu ISO 8601 |
| `hari_dalam_minggu` | Nomor hari, Senin = 1 sampai Minggu = 7 |
| `nama_hari` | Nama hari dalam bahasa Indonesia |
| `is_akhir_pekan` | Penanda Sabtu dan Minggu |

Atribut tambahan dapat digunakan sebagai filter, slicer, atau pengelompokan analisis. Atribut tersebut tidak harus menjadi level dalam hierarki utama.

**Catatan implementasi:**
- Rentang kalender standar: 1 Januari 2010 sampai 31 Desember 2015.
- Terdapat anggota khusus `tanggal_key = -1` untuk tanggal yang tidak diketahui.
- Tanggal transaksi valid dipetakan ke `tanggal_key` berformat `YYYYMMDD`.
- Gunakan key `-1` hanya jika tanggal transaksi tidak tersedia atau tidak dapat dipetakan.
- Nama bulan dan nama hari menggunakan bahasa Indonesia.
- Struktur dan nama kolom `dim_tanggal` mengikuti file standar dosen dan tidak diubah.

### 3.2 DIM_PRODUCT

**Tujuan:** Menganalisis performa penjualan berdasarkan kategori dan detail produk.

| Level | Atribut |
|---|---|
| Category | `product_category_name` |
| Subcategory | `product_subcategory_name` |
| Product Model | `product_model_name` |
| Product | `product_name`, `product_number` |

**Hierarki:** Category → Subcategory → Product Model → Product.

Produk yang tidak memiliki kategori, subkategori, atau model tetap dipertahankan. Nilai `Not Assigned` dapat digunakan sebagai anggota hierarki ketika atribut sumber tidak tersedia.

### 3.3 DIM_CUSTOMER

**Tujuan:** Menganalisis kontribusi pelanggan berdasarkan tipe dan pelanggan individual.

| Level | Atribut |
|---|---|
| Customer Type | `customer_type` |
| Customer | `customer_name`, `store_name`, `customer_id` |

**Hierarki:** Customer Type → Customer.

Pemilihan `customer_name` atau `store_name` sebagai caption perlu disesuaikan dengan `customer_type`. `customer_id` tetap digunakan sebagai identitas pembeda.

### 3.4 DIM_TERRITORY

**Tujuan:** Menganalisis distribusi penjualan berdasarkan wilayah geografis.

| Level | Atribut |
|---|---|
| Territory Group | `territory_group` |
| Country/Region | `country_region_code` |
| Territory | `territory_name`, `territory_id` |

**Hierarki yang diusulkan:** Territory Group → Country/Region → Territory.

Hierarki ini perlu divalidasi terhadap data aktual. Pastikan setiap territory memiliki hubungan yang konsisten dengan country/region dan territory group. `country_region_code` merupakan kode, bukan nama negara.

### 3.5 DIM_PROMOTION

**Tujuan:** Menganalisis performa transaksi berdasarkan jenis dan kategori promosi.

| Level | Atribut |
|---|---|
| Offer Type | `offer_type` |
| Category | `category` |
| Promotion | `description`, `special_offer_id` |

**Hierarki:** Offer Type → Category → Promotion.

Anggota `No Promotion` disediakan untuk transaksi tanpa promosi agar dapat dibandingkan dengan transaksi yang menggunakan promosi. Pastikan anggota ini tersedia di `dim_promotion` dan digunakan oleh fact table untuk transaksi tanpa promosi.

### 3.6 DIM_CURRENCY

**Tujuan:** Mengelompokkan penjualan berdasarkan mata uang transaksi.

| Level | Atribut |
|---|---|
| Currency | `currency_name`, `currency_code` |

**Hierarki:** Currency.

Mata uang transaksi diperoleh melalui `sales_salesorderheader.currencyrateid` dan `sales_currencyrate.tocurrencycode`. Pemetaan USD untuk transaksi dengan `currencyrateid` NULL masih merupakan asumsi yang harus divalidasi. Jangan menjumlahkan nilai penjualan dari mata uang berbeda seolah-olah satu mata uang yang sama tanpa konversi yang disepakati.

---

## 4. Measures

| Measure | Kolom / Formula | Aggregation | Keterangan |
|---|---|---|---|
| Gross Sales | `gross_sales` | SUM | Total penjualan sebelum diskon |
| Discount Amount | `discount_amount` | SUM | Total nilai diskon |
| Net Sales | `net_sales` | SUM | Total penjualan setelah diskon |
| Total Quantity | `order_qty` | SUM | Total unit produk terjual |
| Transaction Count | `sales_order_id` | Distinct Count | Jumlah transaksi unik |
| Average Discount (%) | `SUM(discount_amount) / SUM(gross_sales) * 100` | Calculated | Persentase diskon tertimbang |
| Average Selling Price | `SUM(net_sales) / SUM(order_qty)` | Calculated | Rata-rata nilai penjualan bersih per unit |

### Catatan agregasi

- `Transaction Count` wajib menggunakan distinct count karena satu transaksi dapat terdiri dari beberapa baris detail produk.
- `Average Discount (%)` dihitung dari total `discount_amount` dibagi total `gross_sales`, bukan rata-rata sederhana persentase diskon setiap baris.
- `Average Selling Price` dihitung dari total `net_sales` dibagi total `order_qty`.
- Jika `gross_sales` atau `order_qty` bernilai nol, calculated measure terkait harus menangani pembagian dengan nol.
- Nilai penjualan disimpan dalam mata uang transaksi. Analisis lintas mata uang memerlukan kebijakan konversi yang disepakati.

---

## 5. Calculated Member

### 5.1 Average Discount (%)

**Formula bisnis:**

```text
(SUM(discount_amount) / SUM(gross_sales)) * 100
```

Tujuan: mengetahui persentase diskon tertimbang terhadap total penjualan sebelum diskon.

### 5.2 Average Selling Price

**Formula bisnis:**

```text
SUM(net_sales) / SUM(order_qty)
```

Tujuan: mengetahui rata-rata nilai penjualan bersih untuk setiap unit produk yang terjual.

> Formula di atas merupakan definisi bisnis. Sintaks implementasinya perlu disesuaikan dengan MDX dan konfigurasi Mondrian. Pembagian dengan nol harus ditangani.

---

## 6. Pemetaan Business Questions ke Cube

| ID | Business Question | Dimension | Measures |
|---|---|---|---|
| BQ1 | Bagaimana tren jumlah transaksi dan nilai penjualan online per bulan/tahun? | `DIM_TANGGAL` | Transaction Count, Net Sales |
| BQ2 | Produk atau kategori apa yang memiliki nilai penjualan online tertinggi? | `DIM_PRODUCT` | Net Sales, Total Quantity |
| BQ3 | Wilayah mana yang memberikan kontribusi nilai penjualan online terbesar? | `DIM_TERRITORY` | Net Sales, Transaction Count |
| BQ4 | Pelanggan mana yang memiliki jumlah transaksi dan total pembelian tertinggi? | `DIM_CUSTOMER` | Transaction Count, Net Sales |
| BQ5 | Bagaimana perbandingan nilai penjualan, jumlah transaksi, dan rata-rata diskon antara transaksi dengan dan tanpa promosi? | `DIM_PROMOTION` | Net Sales, Transaction Count, Average Discount (%) |

### Contoh operasi OLAP

| Operasi | Contoh penggunaan |
|---|---|
| Roll-up | Menggabungkan penjualan bulanan menjadi kuartalan, semesteran, atau tahunan |
| Drill-down | Melihat penjualan tahunan hingga semester, kuartal, bulan, dan tanggal |
| Slice | Melihat penjualan hanya untuk satu tahun atau semester tertentu |
| Dice | Melihat penjualan produk tertentu pada wilayah dan periode tertentu |
| Pivot | Mengubah sudut pandang analisis, misalnya membandingkan produk berdasarkan wilayah |

---

## 7. Catatan Desain dan Batasan

1. Cube menggunakan Star Schema V2 yang terdiri dari satu fact table dan enam dimension.
2. Seluruh fact hanya berisi transaksi online sesuai filter `onlineorderflag = 1` pada ETL.
3. Dimensi waktu menggunakan tabel standar dosen `dim_tanggal`, bukan `dim_date`.
4. Rentang tanggal standar `dim_tanggal` adalah 2010-01-01 sampai 2015-12-31, ditambah anggota tidak diketahui dengan `tanggal_key = -1`.
5. Foreign key tanggal pada fact table adalah `fact_online_sales.tanggal_key`, yang mengacu ke `dim_tanggal.tanggal_key`.
6. Nilai penjualan disimpan dalam mata uang transaksi. Penjumlahan lintas mata uang tidak boleh dianggap sebagai satu total yang sebanding tanpa konversi ke mata uang dasar yang disepakati.
7. Kurs pada `average_rate` dan `end_of_day_rate` tersedia untuk mendukung penelusuran nilai tukar. Kebijakan konversi ke mata uang dasar perlu ditentukan terpisah.
8. `DIM_TERRITORY` tidak memasukkan salesperson sebagai satu atribut pemilik wilayah karena satu territory dapat memiliki beberapa salesperson. Ketersediaan `salespersonid` pada dataset yang digunakan perlu divalidasi.
9. Hierarki yang melibatkan beberapa atribut harus divalidasi agar setiap anggota pada level bawah memiliki hubungan yang konsisten dengan level di atasnya.
10. Dokumen ini merupakan desain konseptual cube. Konfigurasi schema Mondrian, pengujian query MDX, dan integrasi dashboard merupakan tahap implementasi berikutnya.

---

## 8. Urutan Implementasi Berikutnya

1. Pastikan seluruh tabel dimension dan fact pada `dw_kelompok_5` sudah dibuat dan terisi.
2. Validasi foreign key dan anggota `Unknown`/`No Promotion`.
3. Pastikan ETL memetakan tanggal transaksi ke `dim_tanggal.tanggal_key` dan mengisi `fact_online_sales.tanggal_key`.
4. Konfigurasikan schema Mondrian berdasarkan fact table, dimension, hierarchy, level, dan measure pada dokumen ini.
5. Uji measure dan calculated member menggunakan query MDX.
6. Cocokkan hasil agregasi cube dengan query SQL langsung pada Data Warehouse.
7. Hubungkan cube ke dashboard untuk menjawab lima Business Questions.

---

## 9. Riwayat Perubahan Desain

| Bagian | Desain sebelumnya | Desain terbaru |
|---|---|---|
| Tabel dimensi waktu | `dim_date` | `dim_tanggal` |
| Primary key waktu | `date_key` | `tanggal_key` |
| Foreign key fact | `fact_online_sales.date_key` | `fact_online_sales.tanggal_key` |
| Atribut kalender | Tahun, kuartal, bulan, tanggal | Tahun, semester, kuartal, bulan, minggu ISO, tanggal, hari, akhir pekan |
| Hierarki waktu | Year → Quarter → Month → Date | Year → Semester → Quarter → Month → Date |
| Rentang kalender | Rancangan awal | 2010-01-01 s.d. 2015-12-31 dan satu anggota unknown |

**Bagian lain pada Star Schema V2 tetap dipertahankan.** Perubahan ini dilakukan agar desain OLAP Cube konsisten dengan struktur `dim_tanggal` standar dosen yang telah diterapkan pada database `dw_kelompok_5`.
