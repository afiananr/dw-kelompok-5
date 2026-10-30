# Piagam Proyek Data Warehouse
Kelompok      : 5
Proses bisnis : Penjualan Online
Sponsor       : Mohamad Irwan Afandi, ST, M.Sc.

## 1. Latar belakang
Adventure Works merupakan perusahaan yang memiliki aktivitas penjualan melalui berbagai saluran, salah satunya adalah penjualan online. Dalam proses penjualan online, perusahaan menghasilkan data transaksi yang mencakup informasi pesanan, detail produk, pelanggan, waktu transaksi, wilayah penjualan, promosi, dan metode pengiriman. Data tersebut dapat dimanfaatkan untuk memahami performa penjualan serta mendukung pengambilan keputusan bisnis.

Namun, data transaksi yang tersimpan dalam basis data operasional belum secara khusus dirancang untuk kebutuhan analisis multidimensional. Manajemen membutuhkan informasi yang terintegrasi untuk mengetahui perkembangan penjualan dari waktu ke waktu, mengidentifikasi produk dengan penjualan tertinggi, menganalisis kontribusi penjualan berdasarkan wilayah dan pelanggan, serta mengevaluasi penggunaan promosi dalam transaksi online.

Oleh karena itu, diperlukan pembangunan Data Warehouse yang berfokus pada proses bisnis penjualan online. Data dari berbagai tabel terkait akan diintegrasikan dan disusun menggunakan pendekatan dimensional modeling dengan skema bintang (Star Schema). Melalui Data Warehouse ini, data penjualan online diharapkan dapat disajikan secara terstruktur dan dianalisis melalui dashboard sehingga menghasilkan informasi yang membantu manajemen dalam mengevaluasi performa penjualan dan mendukung pengambilan keputusan secara lebih tepat.

## 2. Tujuan dan pertanyaan bisnis
Tujuan proyek ini adalah membangun Data Warehouse yang dapat mengintegrasikan data transaksi penjualan online Adventure Works untuk menghasilkan informasi analitis mengenai performa penjualan. Informasi tersebut disajikan melalui dashboard guna membantu manajemen dalam memantau, mengevaluasi, dan mendukung pengambilan keputusan bisnis.

Pertanyaan bisnis yang ingin dijawab melalui dashboard:
1. Bagaimana tren nilai dan jumlah penjualan online berdasarkan bulan dan tahun?
2. Produk dan kategori produk apa yang menghasilkan nilai penjualan online tertinggi?
3. Wilayah mana yang memberikan kontribusi nilai penjualan online terbesar?
4. Siapa pelanggan dengan jumlah transaksi dan total nilai pembelian tertinggi?
5. Bagaimana pengaruh penggunaan promosi terhadap nilai penjualan online?

## 3. Ruang lingkup
Masuk lingkup  : 
- **Proses bisnis:** Analisis transaksi penjualan online (Online Sales) pada Adventure Works dengan mengambil data pesanan yang memiliki `OnlineOrderFlag = TRUE`.
- **Rentang tahun data:** Mengikuti rentang tanggal transaksi yang tersedia pada database sumber berdasarkan hasil data profiling.
- **Tabel sumber:**
  - `Sales.SalesOrderHeader` – informasi utama pesanan penjualan online.
  - `Sales.SalesOrderDetail` – detail produk dalam setiap transaksi.
  - `Production.Product` – informasi produk.
  - `Production.ProductSubcategory` – informasi subkategori produk.
  - `Production.ProductCategory` – informasi kategori produk.
  - `Sales.Customer` – informasi pelanggan.
  - `Person.Person` – informasi nama pelanggan.
  - `Person.Address` – informasi alamat pelanggan.
  - `Sales.SalesTerritory` – informasi wilayah penjualan.
  - `Sales.SpecialOffer` – informasi promosi.
- Perancangan Data Warehouse menggunakan pendekatan dimensional modeling dengan skema bintang (Star Schema).
- Pengolahan dan integrasi data menggunakan Pentaho Data Integration CE.
- Analisis data multidimensional menggunakan Mondrian.
- Penyajian hasil analisis penjualan online melalui dashboard.

Di luar lingkup: 
- Analisis transaksi penjualan offline atau penjualan langsung.
- Analisis proses bisnis pembelian, persediaan, dan produksi.
- Analisis kinerja salesperson dan vendor.
- Pembangunan atau pengembangan sistem transaksi penjualan online.
- Prediksi penjualan menggunakan machine learning.
- Analisis keuangan perusahaan secara keseluruhan di luar proses penjualan online.

## 4. Tim dan peran
| Nama | NPM | Peran utama |
| Afiana Nurani | 23082010162 | Project Manager |
| Caroline | 23082010167 | Dashboard Developer |
| Reva | 23082010298 | OLAP Developer |
| Zyndi | 23082010185 | Data Modeler |
| Veve | 23082010188 | ETL Developer |

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
- **Version Control:** Git dan GitHub.

## 6. Risiko awal
| Risiko | Dampak | Rencana penanganan |
|---|---|---|
| Ketidakcocokan versi Java dengan Pentaho Data Integration | Proses ETL tidak dapat dijalankan atau mengalami error. | Memastikan versi Java kompatibel dengan Pentaho sebelum proses instalasi dan implementasi. |
| Database Adventure Works gagal direstore | Data sumber tidak dapat diakses sehingga menghambat pengerjaan proyek. | Memastikan file database tersedia dan mengikuti prosedur restore PostgreSQL dengan benar. |
| Terdapat data NULL, duplikat, atau tidak valid pada database sumber | Kualitas data menurun dan hasil analisis menjadi kurang akurat. | Melakukan data profiling, validasi, dan penanganan data sebelum proses ETL. |
| Ketidaksesuaian hasil perhitungan antara database sumber dan Data Warehouse | Informasi yang ditampilkan pada dashboard tidak akurat. | Melakukan pengujian dan rekonsiliasi hasil query pada database sumber dengan hasil pemuatan ke Data Warehouse. |
| Perubahan rancangan Star Schema saat proses pengembangan | Proses ETL, OLAP, dan dashboard perlu disesuaikan kembali. | Memvalidasi grain, dimensi, dan fakta sebelum implementasi serta mendokumentasikan setiap perubahan. |
| Keterlambatan penyelesaian tugas anggota kelompok | Target pengerjaan mingguan tidak tercapai. | Membagi tugas sesuai peran, memantau progres secara berkala, dan melakukan koordinasi antaranggota. |


## 7. Kriteria sukses
Proyek Data Warehouse Penjualan Online Adventure Works dinyatakan berhasil apabila memenuhi kriteria berikut:

1. Data Warehouse berhasil dibangun menggunakan pendekatan Star Schema sesuai dengan kebutuhan analisis penjualan online.
2. Data transaksi penjualan online berhasil diekstraksi, ditransformasikan, dan dimuat dari database sumber ke database Data Warehouse menggunakan Pentaho Data Integration.
3. Data yang dimuat ke Data Warehouse memiliki kualitas dan konsistensi yang baik berdasarkan hasil validasi data.
4. Skema Mondrian berhasil dikonfigurasi dan query MDX dapat dijalankan untuk mendukung analisis multidimensional.
5. Dashboard berhasil menampilkan visualisasi yang dapat menjawab minimal lima pertanyaan bisnis yang telah ditentukan.
6. Hasil perhitungan nilai dan jumlah penjualan pada dashboard sesuai dengan hasil query pembanding pada database sumber.
7. Dokumentasi proyek, rancangan Data Warehouse, script SQL, proses ETL, dan hasil pengembangan tersimpan dalam repository GitHub kelompok.