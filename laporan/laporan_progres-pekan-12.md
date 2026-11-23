# Laporan Progres Pekan 12

**Kelompok:** Kelompok 5  
**Proses bisnis:** Online Sales  
**Database sumber:** MySQL `adventureworks`  
**Database Data Warehouse:** MySQL `dw_kelompok_5`  
**ETL Tool:** Pentaho Data Integration Community Edition 9.4.0.0-343  
**Status:** Kuning

> Status kuning menunjukkan bahwa implementasi staging, transformation, job ETL, pemuatan dimension dan fact, serta pengujian konsistensi eksekusi ulang telah dilakukan. Namun, konfigurasi Mondrian, pengujian query MDX, integrasi dashboard dengan data aktual.

---

## 1. Target dan Capaian

| Target Pekan Ini | Status | Bukti / Keterangan |
|---|---|---|
| Membuat tabel staging untuk kebutuhan proses ETL. | Selesai | Sebanyak 13 tabel staging dibuat pada database `dw_kelompok_5` dan digunakan sebagai sumber transformasi Pentaho. |
| Membuat transformasi ekstraksi `t01_ekstrak.ktr`. | Selesai | Transformasi menyalin data dari 13 tabel sumber `adventureworks` ke tabel staging. Seluruh step ekstraksi berhasil dijalankan. |
| Memvalidasi jumlah baris sumber dan staging. | Selesai | Jumlah baris sumber dan staging cocok: `production_product` 504, `production_productmodel` 128, `production_productsubcategory` 37, `production_productcategory` 4, `sales_customer` 19.820, `person_person` 19.972, `sales_store` 701, `sales_salesterritory` 10, `sales_specialoffer` 16, `sales_currency` 105, `sales_currencyrate` 13.532, `sales_salesorderheader` 31.465, dan `sales_salesorderdetail` 121.317. |
| Membuat transformasi `t02_dim_product.ktr` dengan SCD Type 2. | Selesai | Transformasi memeriksa perubahan atribut produk, menutup versi lama, dan menambahkan versi baru. Pemeriksaan menunjukkan 798 baris, 505 produk unik termasuk unknown member, dan 504 versi aktif. Tidak ditemukan produk dengan lebih dari satu versi aktif. |
| Membuat transformasi `t03_dim_customer.ktr` dengan SCD Type 2. | Selesai | Transformasi memeriksa perubahan atribut pelanggan, menutup versi lama, dan menambahkan versi baru. Dimensi berisi 19.822 baris, 19.821 customer unik termasuk unknown member, dan 19.820 versi aktif. Tidak ditemukan customer dengan lebih dari satu versi aktif. |
| Membuat transformasi dimensi territory, promotion, dan currency. | Selesai | `t04_dim_territory.ktr`, `t05_dim_promotion.ktr`, dan `t06_dim_currency.ktr` dibuat menggunakan proses Insert/Update. |
| Membuat transformasi fact online sales. | Selesai | `t07_fact_online_sales.ktr` memuat 60.398 detail transaksi online ke `fact_online_sales`. |
| Memvalidasi lookup dan foreign key fact terhadap seluruh dimensi. | Selesai | Pemeriksaan terhadap `dim_tanggal`, `dim_product`, `dim_customer`, `dim_territory`, `dim_promotion`, dan `dim_currency` menghasilkan 0 data invalid pada setiap relasi. |
| Memvalidasi perhitungan nilai penjualan dan diskon. | Selesai | Total gross sales sebesar 29.358.677,2207 dan total net sales sebesar 29.358.677,2207. Total diskon 0 karena seluruh 60.398 detail transaksi online pada staging memiliki `unitpricediscount = 0`. |
| Membuat Job utama `job_utama.kjb`. | Selesai | Job menghubungkan tujuh transformasi secara berurutan dari ekstraksi staging, pemuatan dimensi, hingga pemuatan fact. |
| Menjalankan Job utama pertama kali. | Selesai | Seluruh entry dari `t01_ekstrak` sampai `t07_fact_online_sales` berhasil dan Job berakhir pada entry `Success`. Log fact menunjukkan 60.398 baris dibaca dan 60.398 baris ditulis tanpa error. |
| Menguji konsistensi Job dengan menjalankannya dua kali. | Selesai | Job berhasil dijalankan kembali. Jumlah baris keenam tabel dimension dan fact sama dengan hasil eksekusi pertama. |
| Mengonfigurasi Mondrian dan menguji query MDX. | Belum dilakukan | Implementasi OLAP masih menjadi pekerjaan lanjutan. |
| Mengintegrasikan dashboard dengan data aktual. | Belum dilakukan | Wireframe dashboard tersedia, tetapi integrasi dengan OLAP/data warehouse belum dilakukan. |

### 1.1 Ringkasan Struktur Star Schema

Struktur Data Warehouse `dw_kelompok_5` terdiri dari satu fact table dan enam dimension:

| Komponen | Nama Tabel | Fungsi |
|---|---|---|
| Fact | `fact_online_sales` | Menyimpan detail transaksi penjualan online dengan grain satu baris untuk setiap detail produk dalam transaksi. |
| Dimension | `dim_tanggal` | Mendukung analisis penjualan berdasarkan waktu. |
| Dimension | `dim_product` | Menyimpan informasi produk, model, subkategori, dan kategori. |
| Dimension | `dim_customer` | Menyimpan informasi pelanggan, person, dan store. |
| Dimension | `dim_territory` | Menyimpan informasi wilayah penjualan. |
| Dimension | `dim_promotion` | Menyimpan informasi promosi. |
| Dimension | `dim_currency` | Menyimpan kode dan nama mata uang. |

### 1.2 Ringkasan Tabel Staging

Sebanyak 13 tabel staging telah digunakan pada proses ekstraksi. Hasil validasi jumlah baris adalah sebagai berikut:

| Tabel staging | Jumlah baris |
|---|---:|
| `stg_product` | 504 |
| `stg_productmodel` | 128 |
| `stg_productsubcategory` | 37 |
| `stg_productcategory` | 4 |
| `stg_customer` | 19.820 |
| `stg_person` | 19.972 |
| `stg_store` | 701 |
| `stg_territory` | 10 |
| `stg_specialoffer` | 16 |
| `stg_currency` | 105 |
| `stg_currencyrate` | 13.532 |
| `stg_salesorderheader` | 31.465 |
| `stg_salesorderdetail` | 121.317 |

Jumlah baris pada setiap tabel staging telah dicocokkan dengan tabel sumber yang bersesuaian di database `adventureworks`.

### 1.3 Ringkasan Hasil Pemuatan Dimension dan Fact

Jumlah baris setelah eksekusi pertama dan kedua `job_utama.kjb` adalah:

| Tabel | Eksekusi pertama | Eksekusi kedua | Selisih |
|---|---:|---:|---:|
| `dim_product` | 798 | 798 | 0 |
| `dim_customer` | 19.822 | 19.822 | 0 |
| `dim_territory` | 11 | 11 | 0 |
| `dim_promotion` | 18 | 18 | 0 |
| `dim_currency` | 106 | 106 | 0 |
| `fact_online_sales` | 60.398 | 60.398 | 0 |

Hasil tersebut menunjukkan bahwa jumlah baris pada keenam tabel tetap sama setelah Job dijalankan kembali dengan data staging yang sama.

### 1.4 Ringkasan Penerapan SCD Type 2

Penerapan SCD Type 2 dilakukan pada `dim_product` dan `dim_customer`.

| Pemeriksaan | `dim_product` | `dim_customer` |
|---|---:|---:|
| Total baris | 798 | 19.822 |
| Jumlah ID unik (termasuk unknown) | 505 | 19.821 |
| Versi aktif | 504 | 19.820 |
| Unknown member | 1 | 1 |
| Duplikasi versi aktif | 0 | 0 |

Pemeriksaan duplikasi dilakukan dengan mengelompokkan setiap ID dimensi yang memiliki `is_current = 1`. Kedua query tidak menghasilkan baris, sehingga tidak ditemukan ID produk maupun customer dengan lebih dari satu versi aktif.

**Catatan:** Pada hasil agregasi, jumlah versi historis yang dihitung menggunakan `is_current = 0` juga mencakup unknown member. Pengujian rerun menunjukkan jumlah total baris kedua dimensi tidak bertambah.

### 1.5 Ringkasan Validasi Fact Table

Fact table berisi 60.398 baris dengan 60.398 `sales_order_detail_id` unik.

| Pemeriksaan | Hasil |
|---|---:|
| Total fact | 60.398 |
| Detail transaksi unik | 60.398 |
| Total gross sales | 29.358.677,2207 |
| Total discount | 0,0000 |
| Total net sales | 29.358.677,2207 |

Pemeriksaan sumber menunjukkan 0 dari 60.398 detail transaksi online memiliki nilai `unitpricediscount` lebih besar dari 0. Oleh karena itu, total diskon sebesar 0 sesuai dengan data sumber yang digunakan.

### 1.6 Ringkasan Validasi Foreign Key

Pemeriksaan dilakukan dengan menghubungkan setiap foreign key pada `fact_online_sales` ke primary key tabel dimension terkait.

| Relasi | Jumlah data invalid |
|---|---:|
| `tanggal_key` ke `dim_tanggal` | 0 |
| `product_key` ke `dim_product` | 0 |
| `customer_key` ke `dim_customer` | 0 |
| `territory_key` ke `dim_territory` | 0 |
| `promotion_key` ke `dim_promotion` | 0 |
| `currency_key` ke `dim_currency` | 0 |

Seluruh foreign key pada fact berhasil menemukan baris pasangan pada tabel dimension.

### 1.7 Struktur Job Utama

Job utama `job_utama.kjb` menjalankan transformasi dalam urutan berikut:

1. `t01_ekstrak.ktr` — ekstraksi data sumber ke staging.
2. `t02_dim_product.ktr` — pemuatan dimensi produk.
3. `t03_dim_customer.ktr` — pemuatan dimensi pelanggan.
4. `t04_dim_territory.ktr` — pemuatan dimensi wilayah.
5. `t05_dim_promotion.ktr` — pemuatan dimensi promosi.
6. `t06_dim_currency.ktr` — pemuatan dimensi mata uang.
7. `t07_fact_online_sales.ktr` — pemuatan fact online sales.

Setiap transformasi dihubungkan menggunakan alur keberhasilan (success hop), sehingga proses berikutnya dijalankan setelah proses sebelumnya berhasil. Job berakhir pada entry `Success`.

### 1.8 Ringkasan Pengujian Eksekusi Ulang

Job utama telah dijalankan dua kali menggunakan Spoon dan Terminal Kitchen. Kedua eksekusi berhasil mencapai entry `Success`. Hasil perbandingan jumlah baris menunjukkan tidak ada perubahan jumlah record pada keenam tabel dimension dan fact.

Pengujian juga menunjukkan bahwa tidak ada duplikasi versi aktif pada `dim_product` dan `dim_customer`. Dengan demikian, pengujian konsistensi berdasarkan jumlah record dan pemeriksaan versi aktif telah berhasil. 

---

## 2. Kendala Pengerjaan

1. **Kesalahan konfigurasi key pada Insert/Update territory.** Saat Job pertama kali dijalankan, transformasi `t04_dim_territory.ktr` gagal dengan pesan `Field [null] is required and couldn't be found!`. Penyebabnya adalah terdapat baris key lookup kosong pada konfigurasi Insert/Update. Baris kosong dihapus dan key lookup disisakan hanya `territory_id`. Setelah perbaikan, transformasi berhasil dijalankan tanpa error.
2. **Penyesuaian lookup produk dan pelanggan berdasarkan tanggal transaksi.** Pada pemeriksaan awal, sejumlah transaksi tidak menemukan versi produk dan pelanggan yang sesuai dengan tanggal transaksi. Tanggal awal versi pertama pada kedua dimension disesuaikan menjadi `1900-01-01`, dengan tetap mempertahankan tanggal akhir dan riwayat versi berikutnya. Pemeriksaan ulang menghasilkan 0 produk dan 0 pelanggan yang tidak ditemukan.
3. **Penyesuaian konfigurasi Insert/Update dimensi.** Key lookup pada territory, promotion, dan currency diperiksa agar menggunakan ID/kode unik masing-masing. Atribut yang perlu diperbarui dikonfigurasi dengan nilai Update = Y.
4. **Pengujian eksekusi ulang.** Pengujian dilakukan dengan menjalankan Job utama dua kali. Jumlah record tetap sama, tetapi pembuktian kesamaan isi setiap record belum dilakukan melalui checksum atau perbandingan data per baris.

---

## 3. Kendala Tim

Belum tersedia informasi terverifikasi mengenai kendala koordinasi, komunikasi, pembagian beban kerja, atau keterlambatan anggota pada pekan ini. Bagian ini perlu dikonfirmasi kepada seluruh anggota sebelum laporan diserahkan.

---

## 4. Keputusan yang Membutuhkan Persetujuan Sponsor

1. Konfirmasi kebijakan analisis nilai penjualan dengan beberapa mata uang, apakah menggunakan filter mata uang atau konversi ke mata uang dasar yang disepakati.
2. Konfirmasi aturan pemetaan mata uang untuk transaksi dengan `currencyrateid` NULL, apabila kasus tersebut ditemukan pada data transaksi.
3. Konfirmasi apakah hasil implementasi SCD Type 2 pada `dim_product` dan `dim_customer` telah sesuai dengan atribut yang dipantau dan kebutuhan analisis historis.
4. Konfirmasi prioritas implementasi Mondrian dan dashboard setelah proses ETL selesai.

---

## 5. Rencana Pekan Berikutnya

| Target | Penanggung Jawab |
|---|---|
| Meninjau kembali hasil pemodelan dimensi, fact, dan validasi data agar dokumentasi sesuai dengan implementasi aktual. | Zyndi Auralia Wibowo — Data Modeler |
| Menyiapkan implementasi schema Mondrian berdasarkan desain Online Sales Cube dan mulai menguji query MDX. | Reva Luvika Apriliani — OLAP Developer |
| Meninjau kebutuhan visualisasi dan menyiapkan integrasi dashboard dengan data aktual setelah OLAP tersedia. | Caroline Febryanty — Dashboard Developer |
| Mengkoordinasikan pembagian tugas, pemantauan progres, dokumentasi, dan keputusan sponsor. | Afiana Nurani — Project Manager |

---

## 6. Kontribusi Anggota

| Nama | Peran | Pekerjaan Pekan Ini | Bukti |
|---|---|---|---|
| Afiana Nurani | Project Manager | Mengkoordinasikan pekerjaan dan pemantauan progres anggota, mengumpulkan bukti pengerjaan, serta mengoordinasikan penyusunan laporan progres. | Perlu dilengkapi oleh anggota |
| Vernanda Pramudya Sejati | ETL Developer | Membangun dan menjalankan transformasi ekstraksi, transformasi dimension dan fact, menyusun Job utama, memperbaiki konfigurasi ETL, serta melakukan pengujian eksekusi ulang dan validasi hasil. | [Bukti](laporan/Tugas_pekan_12/) |
| Zyndi Auralia Wibowo | Data Modeler | Meninjau kesesuaian struktur dimension dan fact terhadap Star Schema V2, serta mendukung validasi struktur dan relasi data warehouse. | Perlu dilengkapi oleh anggota |
| Reva Luvika Apriliani | OLAP Developer | Meninjau kesiapan struktur dimension dan fact untuk kebutuhan OLAP Cube serta menyiapkan tahapan implementasi Mondrian. | Perlu dilengkapi oleh anggota |
| Caroline Febryanty | Dashboard Developer | Meninjau kesiapan data warehouse terhadap kebutuhan visualisasi dan menyiapkan tahapan integrasi dashboard. | Perlu dilengkapi oleh anggota |


---

## Kesimpulan

Pada Pekan 13, Kelompok 5 telah melanjutkan implementasi Data Warehouse untuk proses bisnis Online Sales melalui pembangunan staging dan workflow ETL menggunakan Pentaho Data Integration. Sebanyak 13 tabel staging berhasil digunakan untuk menampung data dari database sumber `adventureworks`. Transformasi dimension dan fact berhasil dibuat, termasuk penerapan SCD Type 2 pada `dim_product` dan `dim_customer`.

Pemuatan data menghasilkan 798 baris pada `dim_product`, 19.822 baris pada `dim_customer`, 11 baris pada `dim_territory`, 18 baris pada `dim_promotion`, 106 baris pada `dim_currency`, dan 60.398 baris pada `fact_online_sales`. Pemeriksaan foreign key fact terhadap enam dimension menghasilkan 0 data invalid. Pemeriksaan juga menunjukkan tidak terdapat duplikasi versi aktif pada dimensi produk maupun pelanggan.

Job utama `job_utama.kjb` berhasil dijalankan dua kali melalui Spoon dan Terminal. Perbandingan jumlah baris setelah kedua eksekusi menunjukkan tidak ada perubahan jumlah record pada seluruh tabel dimension dan fact. Hasil ini menunjukkan konsistensi jumlah data pada pengujian eksekusi ulang.

Pekerjaan berikutnya adalah melanjutkan implementasi Mondrian, pengujian query MDX, serta integrasi dashboard dengan data aktual.
