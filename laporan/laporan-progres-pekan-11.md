# Laporan Progres Pekan 12

**Kelompok:** Kelompok 5  
**Proses bisnis:** Online Sales  
**Database sumber:** MySQL `adventureworks`  
**Database Data Warehouse:** MyDSQL `dw_kelompok_5`  
**ETL Tool:** Pentaho Data Integration Community Edition 9.4.0.0-343  
**Status:** Kuning

> Status kuning menunjukkan bahwa pekerjaan struktur Data Warehouse, validasi constraint, dokumentasi data dictionary, reverse engineering ERD, dan pembaruan Source-to-Target Mapping telah dilakukan. Implementasi staging dan workflow ETL menggunakan Pentaho belum dimulai. Pemuatan dimension dan fact, konfigurasi Mondrian, serta integrasi dashboard masih menjadi pekerjaan berikutnya.

---

## 1. Target dan Capaian

| Target Pekan Ini | Status | Bukti / Keterangan |
|---|---|---|
| Memasang dan memeriksa `dim_tanggal` sesuai skrip standar dosen. | Selesai | Tabel berisi 2.192 baris, termasuk anggota unknown dengan `tanggal_key = -1`; rentang tanggal kalender 2010-01-01 sampai 2015-12-31. |
| Menyusun dan menjalankan `sql/ddl.sql` untuk tabel Data Warehouse. | Selesai pada tahap pengujian import | [Import ddl.sql](../06-database/evidence-pekan11/import_idl_pertama.png) Skrip berhasil dijalankan dua kali [Import ddl.sql Kedua](../06-database/evidence-pekan11/import_ddl_kedua.png). Jumlah baris dan anggota unknown tidak bertambah pada import kedua. |
| Menguji idempotensi import DDL. | Selesai pada tahap verifikasi data |[Menguji idempotensi](../06-database/evidence-pekan11/verifikasi_idempotensi.png) Hasil pemeriksaan setelah import pertama dan kedua menunjukkan jumlah data tetap. Catatan: verifikasi ini memastikan data tidak terduplikasi; belum membuktikan bahwa `CREATE TABLE IF NOT EXISTS` memperbarui struktur tabel yang sudah ada. |
| Menguji Primary Key. | Selesai | [Menguji Primary Key](../06-database/evidence-pekan11/uji_primery_key.png) Percobaan memasukkan `sales_order_detail_id` duplikat menghasilkan error duplicate entry. |
| Menguji Foreign Key. | Selesai | [Menguji idempotensi](../06-database/evidence-pekan11/uji_foreign_key.png)Percobaan memasukkan `product_key` yang tidak tersedia pada `dim_product` ditolak oleh constraint foreign key. |
| Menguji Unique Key. | Selesai |[Menguji idempotensi](../06-database/evidence-pekan11/uji_unique_key.png) Percobaan memasukkan `currency_code = 'UNKNOWN'` yang sudah ada ditolak oleh constraint unique. |
| Membersihkan data sementara hasil pengujian constraint. | Selesai | Data percobaan dihapus; pemeriksaan akhir menunjukkan `dim_currency` memiliki satu baris anggota unknown dan `fact_online_sales` kembali kosong. |
| Menyusun kamus data seluruh tabel DW. | Selesai pada tahap dokumentasi | [Kamus Data](../03-data-model/kamus-data.md) Dokumen `docs/kamus-data.md` disiapkan. Tipe dan panjang data perlu dicocokkan kembali dengan struktur aktual sebelum finalisasi. |
| Melakukan reverse engineering ERD dari database aktual. | Selesai | [ERD](../06-database/evidence-pekan11/erd_dw_kelompok_5.png)ERD dibuat melalui DBeaver dan menampilkan satu fact table serta enam dimension yang terhubung. |
| Membandingkan ERD dengan Star Schema V2. | Selesai pada pemeriksaan visual | Struktur ERD menunjukkan `fact_online_sales` terhubung dengan `dim_tanggal`, `dim_product`, `dim_customer`, `dim_territory`, `dim_promotion`, dan `dim_currency`. |
| Menambahkan daftar staging table pada Source-to-Target Mapping. | Selesai pada tahap dokumentasi | [Update Staging](../03-data-model/source-to-target-mapping-pekan-11-revisi.md)Dokumen mapping revisi memuat rancangan `stg_product`, `stg_customer`, `stg_territory`, `stg_promotion`, `stg_currency`, dan `stg_online_sales`. Nama tersebut masih berupa rancangan, bukan tabel fisik yang telah dibuat. |
| Membangun tabel staging dan workflow ETL di Pentaho. | Belum dilakukan | Implementasi staging dan transformation/job Pentaho belum dimulai. |
| Memuat data dimension dan fact ke Data Warehouse. | Belum dilakukan | Seluruh proses load masih menjadi pekerjaan lanjutan. |
| Mengonfigurasi Mondrian dan menguji query MDX. | Belum dilakukan | Desain OLAP Cube telah tersedia, tetapi implementasi belum dilakukan. |
| Mengintegrasikan dashboard dengan data aktual. | Belum dilakukan | Wireframe tersedia; implementasi dan integrasi dashboard belum dilakukan. |

### 1.1 Ringkasan Struktur Star Schema

Struktur Data Warehouse `dw_kelompok_5` terdiri dari tujuh tabel:

| Komponen | Nama Tabel | Fungsi |
|---|---|---|
| Fact | `fact_online_sales` | Menyimpan detail transaksi penjualan online pada grain satu baris detail produk per transaksi. |
| Dimension | `dim_tanggal` | Analisis penjualan berdasarkan waktu. |
| Dimension | `dim_product` | Informasi produk, model, subkategori, dan kategori. |
| Dimension | `dim_customer` | Informasi pelanggan, person, dan store. |
| Dimension | `dim_territory` | Informasi wilayah penjualan. |
| Dimension | `dim_promotion` | Informasi promosi. |
| Dimension | `dim_currency` | Informasi kode dan nama mata uang. |

### 1.2 Ringkasan Pemeriksaan `dim_tanggal`

| Pemeriksaan | Hasil |
|---|---|
| Jumlah seluruh baris | 2.192 |
| Jumlah tanggal kalender | 2.191 |
| Tanggal minimum | 2010-01-01 |
| Tanggal maksimum | 2015-12-31 |
| Anggota unknown | `tanggal_key = -1` tersedia |
| Primary Key | `tanggal_key` |
| Unique Key | `tanggal` |

### 1.3 Ringkasan Pengujian Constraint

| Jenis Pengujian | Skenario | Hasil |
|---|---|---|
| Primary Key | Memasukkan `sales_order_detail_id` yang sama dua kali | Ditolak: duplicate entry |
| Foreign Key | Memasukkan `product_key` yang tidak tersedia pada dimension | Ditolak: foreign key constraint fails |
| Unique Key | Memasukkan `currency_code = 'UNKNOWN'` yang sudah digunakan | Ditolak: duplicate entry |

**Catatan:** Data uji telah dibersihkan setelah pengujian. Fact table kembali kosong dan anggota unknown pada dimensi mata uang tetap satu baris.

### 1.4 Ringkasan Reverse Engineering ERD

Reverse engineering dilakukan pada database `dw_kelompok_5` menggunakan DBeaver. Diagram memperlihatkan `fact_online_sales` sebagai tabel pusat yang terhubung dengan enam tabel dimensi melalui foreign key.

Hasil pemeriksaan visual menunjukkan struktur tabel sesuai dengan Star Schema V2. Screenshot ERD disimpan sebagai bukti pengerjaan Pekan 11.

### 1.5 Ringkasan Staging pada Source-to-Target Mapping

Daftar staging yang dicantumkan dalam dokumen mapping merupakan rancangan untuk mengelompokkan data sumber sebelum transformasi ke tabel dimension dan fact.

| Nama staging rancangan | Data sumber yang direncanakan |
|---|---|
| `stg_product` | Product, Product Model, Product Subcategory, Product Category |
| `stg_customer` | Customer, Person, Store |
| `stg_territory` | Sales Territory |
| `stg_promotion` | Special Offer |
| `stg_currency` | Currency dan kebutuhan lookup Currency Rate |
| `stg_online_sales` | Sales Order Detail, Sales Order Header, dan Currency Rate |

**Catatan:** Tabel staging di atas belum dibuat secara fisik. Implementasinya akan ditentukan saat pembangunan transformation dan job di Pentaho. Data juga dapat diproses sebagai aliran antar-step Pentaho tanpa harus disimpan permanen sebagai tabel staging.

---

## 2. Kendala Pengerjaan

1. **Implementasi ETL belum dimulai.** Walaupun struktur target dan dokumen mapping telah disiapkan, tabel staging serta transformation/job Pentaho belum dibangun. Akibatnya, data dimension dan fact belum dimuat.
2. **Aturan mata uang untuk transaksi dengan `currencyrateid` NULL.** Pemetaan transaksi tersebut masih memerlukan validasi aturan bisnis atau metadata sumber. Asumsi USD tidak boleh dianggap sebagai keputusan final sebelum dikonfirmasi.
3. **Penerapan SCD Type 2.** `dim_product` dan `dim_customer` dirancang menggunakan Type 2. Mekanisme untuk mendeteksi perubahan, menutup versi lama, dan membuat versi baru masih perlu diimplementasikan di Pentaho.
4. **Kamus data perlu dicocokkan dengan struktur aktual.** Sebelum dokumen final diserahkan, tipe data dan panjang setiap kolom perlu diverifikasi terhadap struktur tabel di MariaDB.
5. **OLAP dan dashboard belum terimplementasi.** Desain cube dan wireframe telah tersedia, tetapi Mondrian belum dikonfigurasi dan dashboard belum terhubung dengan data aktual.

---

## 3. Kendala Tim

Belum tersedia informasi terverifikasi mengenai kendala koordinasi, komunikasi, pembagian beban kerja, atau keterlambatan anggota pada Pekan 11. Bagian ini perlu dikonfirmasi kepada seluruh anggota sebelum laporan diserahkan.

---

## 4. Keputusan yang Membutuhkan Persetujuan Sponsor

1. Konfirmasi aturan pemetaan mata uang untuk transaksi dengan `currencyrateid` NULL.
2. Konfirmasi kebijakan analisis nilai penjualan dengan beberapa mata uang: menggunakan filter mata uang atau konversi ke mata uang dasar yang disepakati.
3. Konfirmasi rancangan staging dan pendekatan implementasinya pada Pentaho, apakah menggunakan tabel staging fisik atau aliran data antar-step.
4. Konfirmasi strategi SCD Type 2 untuk `dim_product` dan `dim_customer`, termasuk atribut yang dipantau untuk mendeteksi perubahan.

---

## 5. Rencana Pekan Berikutnya

| Target | Penanggung Jawab |
|---|---|
| Meninjau kembali ERD, struktur tabel, dan kamus data agar konsisten dengan database aktual. | Zyndi Auralia Wibowo — Data Modeler |
| Memulai pembangunan alur staging dan transformation Pentaho untuk load dimension secara bertahap. | Vernanda Pramudya Sejati — ETL Developer |
| Menyiapkan implementasi schema Mondrian berdasarkan desain Online Sales Cube. | Reva Luvika Apriliani — OLAP Developer |
| Meninjau kebutuhan data dan kesiapan wireframe dashboard untuk integrasi setelah cube tersedia. | Caroline Febryanty — Dashboard Developer |
| Mengkoordinasikan pembagian tugas, pemantauan progres, dokumentasi, dan keputusan sponsor. | Afiana Nurani — Project Manager |

---

## 6. Kontribusi Anggota

| Nama | Peran | Pekerjaan Pekan Ini | Bukti |
|---|---|---|---|
| Afiana Nurani | Project Manager | Mengkoordinasikan seluruh pekerjaan, memantau progres anggota, memastikan seluruh tugas Pekan 11 selesai, mengumpulkan bukti screenshot, dan menyusun laporan progres Pekan 12. | Belum dicantumkan |
| Vernanda Pramudya Sejati | ETL Developer | Menyiapkan dan menjalankan ddl.sql, menguji import DDL dua kali, melakukan pengujian constraint (Primary Key, Foreign Key, Unique Key), serta memastikan data pengujian dibersihkan kembali. | [Bukti commit ddl.sql dan pengujiannya](Laporan_pekan11_assets/bukti-commit-vernanda.png) |
| Zyndi Auralia Wibowo | Data Modeler | Memeriksa struktur dim_tanggal, memastikan kesesuaian seluruh tabel dengan Star Schema V2, melakukan reverse engineering ERD menggunakan DBeaver, dan memperbarui Source-to-Target Mapping termasuk daftar staging table. | [Bukti commit memerika dim_tanggal dan reverse engineering ERD](Laporan_pekan11_assets/bukti-commit-zyndi.png)  |
| Reva Luvika Apriliani | OLAP Developer | Memeriksa keterkaitan tabel fact dan dimension terhadap kebutuhan OLAP Cube, memastikan hierarki waktu menggunakan dim_tanggal, serta meninjau kesesuaian struktur tabel dengan desain OLAP. | Belum dicantumkan |
| Caroline Febryanty | Dashboard Developer | Memeriksa kesesuaian struktur dimensi dengan kebutuhan visualisasi dashboard, memperbarui dokumentasi kamus data bersama Data Modeler, serta menyiapkan dokumentasi dan bukti pendukung dashboard. | Belum dicantumkan |


---

## 7. Lampiran Bukti Tangkapan Layar

Lampiran yang perlu dimasukkan ke repository:

1. Screenshot hasil pemeriksaan `dim_tanggal` (jumlah baris, rentang tanggal, dan unknown member).
2. Screenshot import `ddl.sql` pertama dan kedua serta hasil verifikasi jumlah baris.
3. Screenshot pengujian Primary Key.
4. Screenshot pengujian Foreign Key.
5. Screenshot pengujian Unique Key.
6. Screenshot ERD reverse engineering dari DBeaver.
7. Dokumen `kamus-data.md`.
8. Dokumen Source-to-Target Mapping revisi yang memuat daftar staging.

Pastikan semua file bukti benar-benar tersedia. Gunakan tautan relatif sesuai struktur folder repository kelompok.

---

## Kesimpulan

Pada Pekan 11, Kelompok 5 telah menyelesaikan pemeriksaan struktur Data Warehouse, pengujian import DDL dan constraint, penyusunan kamus data, reverse engineering ERD, serta pembaruan Source-to-Target Mapping dengan daftar staging rancangan. Database `dw_kelompok_5` memiliki satu fact table dan enam dimension yang secara visual sesuai dengan Star Schema V2. Tabel `dim_tanggal` juga telah diperiksa dan berisi 2.192 baris termasuk anggota unknown.

Meskipun persiapan struktur dan dokumentasi telah dilakukan, implementasi staging dan workflow ETL menggunakan Pentaho belum dimulai. Data dimension dan fact belum dimuat. Konfigurasi Mondrian dan integrasi dashboard juga belum dilakukan.

Fokus pekerjaan berikutnya adalah memulai implementasi ETL secara bertahap, memvalidasi aturan transformasi dan SCD, memuat dimension sebelum fact, kemudian melanjutkan konfigurasi OLAP dan integrasi dashboard setelah data tersedia.
