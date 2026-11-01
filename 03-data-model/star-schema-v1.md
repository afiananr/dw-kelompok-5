# Star Schema V1 — Online Sales

**Penanggung jawab:** Zyndi Auralia Wibowo (Data Modeler)  
**Proyek:** Data Warehouse Kelompok 5  
**Sumber:** AdventureWorks PostgreSQL  
**Proses bisnis:** Online Sales

## 1. Grain Fact Table

Satu baris pada `FACT_ONLINE_SALES` merepresentasikan **satu baris detail pesanan (sales order detail) dari pesanan online**. Pesanan online ditentukan menggunakan `SalesOrderHeader.OnlineOrderFlag = TRUE`.

Grain ini harus dipertahankan saat ETL agar nilai pada tingkat header tidak terduplikasi ketika digabungkan dengan detail pesanan.

## 2. Fact Table

### `FACT_ONLINE_SALES`

| Kolom | Keterangan |
|---|---|
| `sales_order_detail_id` | Identitas unik baris detail; kandidat primary key/degenerate identifier |
| `sales_order_id` | Nomor/identitas pesanan, dapat digunakan untuk menghitung transaksi unik |
| `date_key` | Foreign key ke `DIM_DATE` |
| `product_key` | Foreign key ke `DIM_PRODUCT` |
| `customer_key` | Foreign key ke `DIM_CUSTOMER` |
| `territory_key` | Foreign key ke `DIM_TERRITORY` |
| `promotion_key` | Foreign key ke `DIM_PROMOTION` |
| `order_qty` | Kuantitas produk pada baris detail |
| `unit_price` | Harga satuan |
| `discount_pct` | Persentase diskon yang benar-benar diterapkan pada baris detail |
| `gross_sales` | Nilai sebelum diskon |
| `discount_amount` | Nilai potongan harga |
| `net_sales` | Nilai setelah diskon |

### Rumus measure

- `gross_sales = order_qty × unit_price`
- `discount_amount = order_qty × unit_price × discount_pct`
- `net_sales = gross_sales − discount_amount`

Gunakan nilai `UnitPriceDiscount` dari detail pesanan sebagai diskon aktual pada baris. Jangan menganggap `SpecialOffer.DiscountPct` selalu sama dengan diskon aktual yang diterapkan.

## 3. Dimension Tables

### `DIM_DATE`

| Kolom | Keterangan |
|---|---|
| `date_key` | Primary key dimensi tanggal |
| `full_date` | Tanggal lengkap |
| `day` | Hari dalam bulan |
| `month` | Nomor bulan |
| `month_name` | Nama bulan |
| `quarter` | Kuartal |
| `year` | Tahun |

### `DIM_PRODUCT`

| Kolom | Keterangan |
|---|---|
| `product_key` | Primary key surrogate |
| `product_id` | ID produk dari sumber |
| `product_name` | Nama produk |
| `product_number` | Nomor produk |
| `subcategory_name` | Nama subkategori |
| `category_name` | Nama kategori |

### `DIM_CUSTOMER`

| Kolom | Keterangan |
|---|---|
| `customer_key` | Primary key surrogate |
| `customer_id` | ID customer dari sumber |
| `person_id` | ID person jika tersedia |
| `store_id` | ID store jika tersedia |
| `customer_type` | Jenis customer (individual/store) |
| `customer_name` | Nama customer jika tersedia |
| `store_name` | Nama toko jika tersedia |

`PersonID` yang NULL tidak otomatis berarti data customer tidak valid; customer dapat berasosiasi dengan store. Validasi relasi dan kelengkapan atribut sebelum menetapkan aturan cleansing.

### `DIM_TERRITORY`

| Kolom | Keterangan |
|---|---|
| `territory_key` | Primary key surrogate |
| `territory_id` | ID territory dari sumber |
| `territory_name` | Nama wilayah |
| `country_region_code` | Kode negara/wilayah |
| `territory_group` | Grup wilayah |

### `DIM_PROMOTION`

| Kolom | Keterangan |
|---|---|
| `promotion_key` | Primary key surrogate |
| `special_offer_id` | ID special offer dari sumber |
| `description` | Deskripsi promosi |
| `offer_type` | Jenis penawaran |
| `category` | Kategori penawaran |
| `discount_pct` | Persentase diskon pada master offer |
| `promotion_status` | Status/kategori promosi sesuai aturan bisnis |

Sediakan satu anggota dimensi khusus untuk kondisi **tanpa promosi** agar baris transaksi tanpa special offer tetap dapat memiliki foreign key yang valid. Penetapan nilai kunci khusus dilakukan saat implementasi ETL.

## 4. Relasi

- Satu tanggal dapat terkait dengan banyak baris fact.
- Satu produk dapat terkait dengan banyak baris fact.
- Satu customer dapat terkait dengan banyak baris fact.
- Satu territory dapat terkait dengan banyak baris fact.
- Satu promotion dapat terkait dengan banyak baris fact.
- Setiap baris fact mengacu pada satu anggota dari masing-masing dimensi.

## 5. Catatan agregasi

`SalesOrderHeader.TotalDue` merupakan nilai pada tingkat header pesanan. Jangan menjumlahkan `TotalDue` setelah join ke `SalesOrderDetail`, karena satu pesanan dapat memiliki banyak baris detail dan nilai header akan terduplikasi.

Untuk analisis nilai penjualan per produk atau detail, gunakan measure yang dihitung dari `SalesOrderDetail` (gross, discount, net sales). Untuk total nilai pesanan, agregasikan pada tingkat order/header secara terpisah.

## 6. Pernyataan Grain (Grain Statement)
Satu baris pada tabel fakta merepresentasikan satu item produk dalam satu transaksi penjualan online (online sales order) berdasarkan SalesOrderID dan SalesOrderDetailID, yang mencatat jumlah produk, harga satuan, diskon, dan nilai penjualan.
