# Piagam Proyek Data Warehouse
| Keterangan | Isi |
|---|---|
| Kelompok | 5 |
| Proses Bisnis | Online Sales |
| Sponsor | Mohamad Irwan Afandi, ST, M.Sc. |
| Project Manager | Afiana Nurani |
| Database Sumber | AdventureWorks PostgreSQL |
| Database Target | `dw_kelompok_5` |

## 1. Latar belakang
Adventure Works merupakan perusahaan fiktif yang bergerak di bidang penjualan produk sepeda dan komponennya. Perusahaan memiliki data operasional yang mencakup aktivitas penjualan, pelanggan, produk, wilayah penjualan, dan promosi.

Data penjualan yang tersimpan dalam database operasional belum secara langsung menyajikan informasi analitis yang terintegrasi untuk mendukung kebutuhan manajemen dalam mengevaluasi performa penjualan.

Beberapa informasi yang perlu dianalisis oleh manajemen meliputi tren penjualan, produk dengan kontribusi penjualan tertinggi, performa penjualan berdasarkan wilayah, perilaku pembelian pelanggan, serta efektivitas promosi.

Oleh karena itu, diperlukan pembangunan Data Warehouse yang mengintegrasikan data dari berbagai tabel sumber sehingga informasi penjualan dapat diolah dan disajikan dalam bentuk dashboard untuk mendukung proses pengambilan keputusan.

## 2. Tujuan dan pertanyaan bisnis
Membangun Data Warehouse untuk proses Online Sales pada Adventure Works yang dapat mengintegrasikan data transaksi penjualan, produk, pelanggan, wilayah, dan promosi menjadi informasi analitis yang mudah dipahami melalui dashboard.

Pertanyaan bisnis yang ingin dijawab melalui dashboard:
1. Bagaimana tren jumlah transaksi dan nilai penjualan online berdasarkan periode waktu (bulanan dan tahunan)?
2. Produk dan kategori produk apa yang memiliki nilai penjualan online tertinggi?
3. Wilayah penjualan (territory) mana yang memberikan kontribusi nilai penjualan online terbesar?
4. Siapa pelanggan dengan jumlah transaksi dan total pembelian tertinggi?
5. Bagaimana perbandingan nilai penjualan, jumlah transaksi, dan rata-rata diskon antara transaksi yang menggunakan promosi dan yang tidak menggunakan promosi?

## 3. Ruang lingkup
Masuk lingkup  : 
- **Proses bisnis:** Online Sales, yaitu transaksi dengan `OnlineOrderFlag = TRUE`.
- **Rentang tahun data:** 2022–2025, berdasarkan rentang tanggal transaksi online yang ditemukan pada profiling awal, yaitu 30 Mei 2022–29 Juni 2025.
- Pembangunan Data Warehouse menggunakan pendekatan *dimensional modeling* dengan skema **Star Schema**.
- Proses ETL (*Extract, Transform, Load*) dari database sumber AdventureWorks PostgreSQL ke database target.
- Pengembangan analisis multidimensional menggunakan teknologi OLAP.
- Pembuatan dashboard untuk menyajikan KPI dan analisis penjualan online.
- **Tabel Sumber yang Digunakan:**
| Schema | Tabel |
|---|---|
| Sales | `SalesOrderHeader` |
| Sales | `SalesOrderDetail` |
| Sales | `Customer` |
| Sales | `SalesTerritory` |
| Sales | `SpecialOffer` |
| Production | `Product` |
| Production | `ProductSubcategory` |
| Production | `ProductCategory` |
| Person | `Person` |
| Person | `Address` |

Di luar lingkup: 
-  Analisis transaksi penjualan offline (`OnlineOrderFlag = FALSE`).
-  Pengembangan sistem transaksi penjualan operasional (OLTP).
-  Pengembangan aplikasi e-commerce atau sistem pemesanan baru.
-  Analisis keuangan perusahaan secara menyeluruh di luar kebutuhan analisis penjualan online.
-  Prediksi penjualan menggunakan *Machine Learning*.

## 4. Tim dan peran
| Nama | NPM | Peran utama |
|---|---|---|
| Afiana Nurani | 23082010162 | Project Manager |
| Caroline Febryanty | 23082010167 | Dashboard Developer |
| Reva Luvika Apriliani | 23082010198 | OLAP Developer |
| Zyndi Auralia Wibowo | 23082010185 | Data Modeler |
| Vernanda Pramudya Sejati | 23082010188 | ETL Developer |

### Deskripsi Tanggung Jawab

1. **Afiana Nurani – Project Manager**
   - Menjaga target dan jadwal pengerjaan mingguan.
   - Menyusun dan menyampaikan laporan progres proyek.
   - Mencatat kendala dan keputusan selama pengerjaan.
   - Mengatur pembagian tugas dan koordinasi antaranggota.

2. **Caroline Febryanty – Dashboard Developer**
   - Merancang wireframe dan tampilan dashboard.
   - Membangun dashboard menggunakan chart library.
   - Menyajikan hasil analisis data dalam bentuk visualisasi yang informatif.

3. **Reva Luvika Apriliani – OLAP Developer**
   - Menyusun skema Mondrian.
   - Membuat query MDX untuk kebutuhan analisis.
   - Memastikan hasil analisis multidimensional sesuai dengan pertanyaan bisnis.

4. **Zyndi Auralia Wibowo – Data Modeler**
   - Menerjemahkan kebutuhan bisnis menjadi rancangan Star Schema.
   - Menentukan grain, dimensi, dan fakta.
   - Menyusun serta menjaga konsistensi kamus data.

5. **Vernanda Pramudya Sejati – ETL Developer**
   - Membuat proses transformasi dan job menggunakan Pentaho Data Integration.
   - Melakukan ekstraksi, transformasi, dan pemuatan data.
   - Menjaga kualitas data dan melakukan rekonsiliasi hasil ETL.

## 5. Lingkungan teknis
- **Sumber Data:** PostgreSQL (`adventureworks`).
- **Target Database:** PostgreSQL (`dw_kelompok_5`). 
- **ETL:** Pentaho Data Integration Community Edition (PDI CE).
- **OLAP:** Mondrian.
- **Dashboard:** Chart.js (visualisasi data pada dashboard web).
- **Data modeling:** Star Schema
- **Version Control:** Git dan GitHub.
- **Development environment:** Visual Studio Code

## 6. Risiko awal
| Risiko | Dampak | Rencana Penanganan |
|---|---|---|
| Ketidakcocokan versi Java dan Pentaho | Proses ETL tidak dapat berjalan dengan baik | Memeriksa kompatibilitas versi Java dan Pentaho sebelum implementasi |
| Kesalahan proses ETL | Data pada Data Warehouse tidak sesuai dengan sumber | Melakukan validasi jumlah record dan rekonsiliasi nilai penjualan |
| Data NULL atau tidak valid | Hasil analisis berpotensi tidak akurat | Melakukan *data profiling* dan menetapkan aturan *data cleansing* |
| Kesalahan rancangan Star Schema | Terjadi duplikasi atau kesalahan agregasi data | Memvalidasi *grain fact table* dan relasi dimensi |
| Keterlambatan pengerjaan anggota | Integrasi proyek tidak sesuai target | Membuat *task tracker* dan melakukan evaluasi progres secara rutin |
| Ketidaksesuaian hasil dashboard | Informasi yang ditampilkan tidak akurat | Membandingkan hasil dashboard dengan query pada database sumber atau Data Warehouse |


## 7. Kriteria sukses
Proyek Data Warehouse Kelompok 5 dinyatakan berhasil apabila memenuhi kriteria berikut:

1. Database sumber AdventureWorks PostgreSQL berhasil diakses dan digunakan dalam proses pengolahan data.
2. Data Warehouse berhasil dibangun dengan struktur *fact table* dan *dimension table* berdasarkan rancangan Star Schema.
3. Proses ETL berhasil memindahkan dan mengolah data transaksi Online Sales ke database target.
4. Hasil ETL memiliki kesesuaian jumlah record dengan data sumber setelah menerapkan filter dan aturan transformasi yang ditentukan.
5. Nilai penjualan pada Data Warehouse dapat direkonsiliasi dengan hasil query sumber menggunakan rumus perhitungan yang sama.
6. Model OLAP dapat digunakan untuk melakukan analisis multidimensional, seperti *drill-down*, *roll-up*, *slice*, dan *dice*.
7. Dashboard mampu menyajikan informasi untuk menjawab minimal lima pertanyaan bisnis yang telah ditetapkan.
8. Seluruh dokumentasi, kode, dan bukti pengerjaan tersimpan dalam repository GitHub kelompok.