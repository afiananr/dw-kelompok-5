# Laporan Progres Pekan 10

**Kelompok** : Kelompok 5  
**Proses bisnis** : Online Sales  
**Status** : Kuning

> Status kuning menunjukkan revisi rancangan, dokumentasi mapping, desain OLAP, wireframe dashboard, dan pengujian awal Pentaho telah dilakukan. Implementasi ETL penuh, pemuatan Data Warehouse, konfigurasi OLAP Mondrian, dan integrasi dashboard masih menjadi pekerjaan berikutnya.

## 1. Target dan capaian

| Target pekan ini | Status | Bukti (tautan file, commit, tangkapan layar) |
|---|---|---|
| Merevisi Star Schema versi 1 menjadi versi 2 berdasarkan masukan Steering Review. | Selesai pada tahap desain | [Star Schema V2](../03-data-model/star-schema-v2.png) |
| Menambahkan atribut Product Model pada DIM_PRODUCT. | Selesai pada tahap desain | DIM_PRODUCT V2 mencakup Product Model, Subcategory, dan Category. [Dokumentasi Star Schema V2](../03-data-model/star-schema-v2.png) |
| Meninjau kembali DIM_TERRITORY dan keterkaitan salesperson. | Selesai pada tahap analisis dan desain | DIM_TERRITORY memuat identitas wilayah. DIM_SALESPERSON tidak dimasukkan ke fact online sales karena transaksi online yang diperiksa memiliki salespersonid NULL dan satu territory dapat memiliki beberapa salesperson. |
| Menambahkan dimensi mata uang untuk mendukung analisis currency. | Selesai pada tahap desain | DIM_CURRENCY ditambahkan ke Star Schema V2. Asumsi USD untuk transaksi dengan currencyrateid NULL masih perlu divalidasi. [Dokumentasi Star Schema V2](../03-data-model/star-schema-v2.png) |
| Menyusun Source-to-Target Mapping untuk seluruh tabel target. | Selesai pada tahap dokumentasi | [Source-to-Target Mapping](../03-data-model/source-to-target-mapping.md) |
| Menentukan strategi SCD untuk setiap dimension. | Selesai pada tahap desain | DIM_DATE Type 0, DIM_PRODUCT Type 2, DIM_CUSTOMER Type 2, DIM_TERRITORY Type 1, DIM_PROMOTION Type 1, dan DIM_CURRENCY Type 0. [Source-to-Target Mapping](../03-data-model/source-to-target-mapping.md) |
| Menentukan urutan load dari staging hingga fact table. | Selesai pada tahap desain | Urutan load staging, dimension, dan fact didokumentasikan pada [Source-to-Target Mapping](../03-data-model/source-to-target-mapping.md). |
| Merancang OLAP Cube beserta dimension, hierarki, measures, dan calculated member. | Selesai pada tahap desain | [Desain OLAP Cube](../04-OLAP/cube-design.md) |
| Membuat wireframe dashboard untuk menjawab lima Business Questions. | Selesai pada tahap wireframe | [Dokumentasi Wireframe Dashboard](../05-dashboard/dashboard-wireframe.md) dan [Wireframe Dashboard PNG](../05-dashboard/dashboard-wireframe.png) |
| Menjalankan query sederhana menggunakan Table Input. | Selesai | Query transaksi online berhasil dijalankan dan Preview Data menampilkan data. [Bukti Table Input dan hasil query](../04-olap/pentaho/table_input_query_result.png) |
| Mengimplementasikan seluruh proses ETL untuk dimension dan fact. | Belum dilakukan | Menjadi pekerjaan lanjutan setelah pengujian koneksi dasar Pentaho. |
| Mengonfigurasi OLAP Cube pada Mondrian dan menguji query MDX. | Belum dilakukan | Desain cube telah tersedia; konfigurasi dan pengujian implementasi belum dilakukan. |
| Mengintegrasikan dashboard dengan data aktual dari OLAP Cube. | Belum dilakukan | Wireframe telah tersedia; integrasi data dan implementasi dashboard menjadi pekerjaan berikutnya. |

### Pernyataan grain

Satu baris pada `FACT_ONLINE_SALES` merepresentasikan satu baris detail produk dalam satu transaksi penjualan online (*one row per sales order detail line*), dengan transaksi dibatasi pada `onlineorderflag = TRUE`.

### Ringkasan rancangan Star Schema V2

| Komponen | Nama | Keterangan |
|---|---|---|
| Fact table | `fact_online_sales` | Satu baris per detail produk dalam transaksi online |
| Dimension 1 | `dim_date` | Analisis berdasarkan waktu |
| Dimension 2 | `dim_product` | Memuat produk, model, subkategori, dan kategori |
| Dimension 3 | `dim_customer` | Memuat informasi pelanggan, person, dan store |
| Dimension 4 | `dim_territory` | Memuat identitas dan kelompok wilayah |
| Dimension 5 | `dim_promotion` | Memuat informasi promosi |
| Dimension 6 | `dim_currency` | Memuat kode dan nama mata uang |

### Ringkasan strategi SCD

| Dimension | Strategi SCD |
|---|---|
| `dim_date` | Type 0 |
| `dim_product` | Type 2 |
| `dim_customer` | Type 2 |
| `dim_territory` | Type 1 |
| `dim_promotion` | Type 1 |
| `dim_currency` | Type 0 |

### Ringkasan desain OLAP Cube

| Komponen | Rancangan |
|---|---|
| Nama cube | Online Sales Cube |
| Fact table | `fact_online_sales` |
| Dimension | Date, Product, Customer, Territory, Promotion, Currency |
| Measures | Gross Sales, Discount Amount, Net Sales, Total Quantity, Transaction Count |
| Calculated member | Average Discount (%) dan Average Selling Price |
| OLAP engine | Mondrian |

### Ringkasan wireframe dashboard

| ID | Business Question | Visualisasi |
|---|---|---|
| BQ1 | Bagaimana tren jumlah transaksi dan nilai penjualan online per bulan/tahun? | Monthly Online Sales Trend — Line Chart dengan dual Y-axis |
| BQ2 | Produk atau kategori apa yang memiliki nilai penjualan online tertinggi? | Top 10 Products by Sales — Horizontal Bar Chart |
| BQ3 | Wilayah mana yang memberikan kontribusi nilai penjualan online terbesar? | Sales Contribution by Territory — Horizontal Bar Chart |
| BQ4 | Pelanggan mana yang memiliki jumlah transaksi dan total pembelian tertinggi? | Top 10 Customers — Data Table |
| BQ5 | Bagaimana perbandingan penjualan, transaksi, dan rata-rata diskon antara transaksi dengan dan tanpa promosi? | Promotion Performance Comparison — tiga panel perbandingan |

### Ringkasan pengujian Pentaho

| Komponen | Hasil |
|---|---|
| Pentaho Data Integration | Community Edition 9.4.0.0-343 |
| Antarmuka | Spoon berhasil dibuka |
| Database sumber | MySQL `adventureworks` |
| Step | Table Input |
| Query | Mengambil 10 transaksi dengan `onlineorderflag = TRUE` |
| Hasil | Query berhasil dijalankan dan Preview Data menampilkan data transaksi |

**Catatan:** Pengujian ini membuktikan koneksi dasar Pentaho ke MySQL dan eksekusi query sederhana. Pengujian belum mencakup workflow ETL penuh, load dimension, load fact, maupun penanganan SCD.

## 2. Kendala pengerjaan

1. **Penentuan mata uang untuk transaksi tanpa currencyrateid.** Sebagian transaksi online memiliki `currencyrateid` NULL. USD sementara digunakan sebagai asumsi mata uang dasar, tetapi perlu dikonfirmasi melalui aturan bisnis atau metadata sumber sebelum proses ETL final.
2. **Riwayat perubahan untuk penerapan SCD Type 2.** Sumber data saat ini belum tentu menyediakan riwayat perubahan atribut produk dan pelanggan. Riwayat sebelum ETL mulai berjalan tidak dapat direkonstruksi jika tidak tersedia pada sumber. Mekanisme historisasi perlu diterapkan sejak proses ETL berjalan.
3. **Relasi salesperson dan territory.** Satu territory dapat memiliki beberapa salesperson. Selain itu, seluruh transaksi online yang diperiksa memiliki `salespersonid` NULL. Karena itu, salesperson tidak dimasukkan sebagai satu atribut pemilik tunggal pada DIM_TERRITORY atau sebagai foreign key fact online sales.
4. **Perbedaan satuan mata uang.** Data penjualan menggunakan beberapa mata uang. Agregasi lintas mata uang tidak boleh dilakukan secara langsung tanpa konversi ke mata uang dasar yang disepakati.
5. **Implementasi ETL belum dilakukan secara penuh.** Pengujian Pentaho baru membuktikan koneksi dan pembacaan data melalui Table Input. Proses staging, transformasi dimension, lookup surrogate key, dan load fact masih perlu dibangun.
6. **Konfigurasi OLAP dan dashboard masih dalam tahap rancangan.** Desain cube dan wireframe telah disusun, tetapi Mondrian dan dashboard belum dihubungkan dengan data aktual.

## 3. Kendala tim

Belum ada informasi terverifikasi mengenai kendala komunikasi, anggota yang sulit dihubungi, atau keterlambatan pembagian tugas pada Pekan 10. Bagian ini perlu diperbarui berdasarkan kondisi aktual tim.

## 4. Keputusan yang butuh persetujuan sponsor

1. Menyetujui Star Schema V2 yang terdiri dari `FACT_ONLINE_SALES` dan enam dimension: `DIM_DATE`, `DIM_PRODUCT`, `DIM_CUSTOMER`, `DIM_TERRITORY`, `DIM_PROMOTION`, dan `DIM_CURRENCY`.
2. Menyetujui atribut tambahan Product Model, Subcategory, dan Category pada DIM_PRODUCT.
3. Menyetujui rancangan DIM_CURRENCY dan aturan penentuan mata uang transaksi ketika `currencyrateid` bernilai NULL, termasuk validasi asumsi USD.
4. Menyetujui strategi SCD yang diusulkan: DIM_DATE Type 0, DIM_PRODUCT Type 2, DIM_CUSTOMER Type 2, DIM_TERRITORY Type 1, DIM_PROMOTION Type 1, dan DIM_CURRENCY Type 0.
5. Menyetujui penanganan transaksi tanpa promosi melalui anggota khusus `No Promotion` pada DIM_PROMOTION dan anggota `Unknown` pada dimension yang diperlukan.
6. Menyetujui rancangan hierarki, measures, dan calculated member pada Online Sales Cube.
7. Mengonfirmasi kebijakan analisis nilai penjualan multi-currency: menggunakan filter mata uang transaksi atau mengonversi nilai ke mata uang dasar yang ditetapkan.

## 5. Rencana pekan depan

| Target | Penanggung jawab |
|---|---|
| Memfinalisasi Star Schema V2 dan menindaklanjuti persetujuan sponsor. | Zyndi Auralia Wibowo (Data Modeler) |
| Memvalidasi aturan currency, NULL, dan source-to-target mapping; mulai membangun staging serta ETL dimension dan fact di Pentaho. | Vernanda Pramudya Sejati (ETL Developer) |
| Menyiapkan konfigurasi schema Mondrian berdasarkan desain cube dan mulai menguji hierarki serta measures. | Reva Luvika Apriliani (OLAP Developer) |
| Menyempurnakan wireframe dan menyiapkan rancangan implementasi dashboard berdasarkan lima Business Questions. | Caroline Febryanty (Dashboard Developer) |
| Mengkoordinasikan progres, pembagian tugas, dokumentasi, dan persetujuan sponsor. | Afiana Nurani (Project Manager) |

## 6. Kontribusi anggota

| Nama | Peran | Yang dikerjakan pekan ini | Bukti commit |
|---|---|---|---|
| Afiana Nurani | Project Manager | Koordinasi dan pemantauan progres proyek serta dokumentasi laporan Pekan 10. Rincian aktivitas aktual perlu dikonfirmasi. | Belum dicantumkan |
| Caroline Febryanty | Dashboard Developer | Menyusun wireframe Online Sales Performance Dashboard menggunakan Figma AI, mencakup KPI dan lima visualisasi BQ1–BQ5. | [Bukti commit untuk wireframe dashboard](Laporan_pekan10_assets/bukti_commit_caroline.png) |
| Reva Luvika Apriliani | OLAP Developer | Menyusun desain Online Sales Cube, hierarki dimension, measures, dan calculated member. | [Bukti commit untuk cube design](Laporan_pekan10_assets/bukti_commit_reva.png)|
| Zyndi Auralia Wibowo | Data Modeler | Menyempurnakan rancangan Star Schema V2, Source-to-Target Mapping, dan strategi SCD. | [Bukti commit untuk star schema v2 dan source to source target mapping](Laporan_pekan10_assets/bukti_commit_zyndi.png) |
| Vernanda Pramudya Sejati | ETL Developer | Menyiapkan PDI CE 9.4, menjalankan Spoon, menghubungkan MySQL `adventureworks`, dan menguji query menggunakan Table Input. | [Bukti commit untuk test connection pentaho](Laporan_pekan10_assets/bukti_commit_vernanda.png) |

**Catatan:** Kolom bukti commit perlu diisi dengan tautan commit GitHub yang benar-benar tersedia. Pembagian kontribusi di atas mengikuti area tanggung jawab masing-masing anggota dan perlu dikonfirmasi sebelum laporan diserahkan.

## Lampiran bukti tangkapan layar

Simpan bukti tangkapan layar pada folder `laporan_pekan10_assets/`, kemudian sesuaikan nama file dan tautan relatif di bawah dengan file yang benar-benar tersedia di repository.

### A. Revisi Star Schema V2

![Star Schema V2](laporan_pekan10_assets/star-schema-v2.png)

### B. Source-to-Target Mapping

[Buka dokumen Source-to-Target Mapping](../03-data-model/source-to-target-mapping.md)

### C. Desain OLAP Cube

[Buka dokumen Desain OLAP Cube](../04-olap/cube-design.md)

### D. Wireframe Online Sales Performance Dashboard

![Wireframe Dashboard Pekan 10](../05-dashboard/dashboard-wireframe.png)


### E. Table Input dan hasil query transaksi online

![Table Input dan hasil query](laporan_pekan10_assets/table_input_query_result.png)

## Kesimpulan

Pada Pekan 10, Kelompok 5 telah melanjutkan pekerjaan Data Warehouse Online Sales dari tahap persiapan sumber data dan rancangan awal menuju penyempurnaan model dimensional, desain OLAP, wireframe dashboard, dan pengujian awal perangkat ETL. Star Schema V2 telah dirancang dengan enam dimension, Source-to-Target Mapping telah disusun, strategi SCD dan urutan load telah ditentukan, serta desain Online Sales Cube dan wireframe dashboard telah dibuat untuk menjawab lima Business Questions.

Pengujian Pentaho Data Integration Community Edition 9.4 berhasil dilakukan. Spoon dapat dibuka, koneksi ke MySQL `adventureworks` berhasil digunakan, dan query sederhana melalui Table Input berhasil menampilkan data transaksi online.

Tahap berikutnya adalah mengimplementasikan proses ETL secara bertahap, memuat tabel dimension dan fact ke database Data Warehouse, mengonfigurasi Mondrian, serta mengintegrasikan dashboard dengan data aktual.
