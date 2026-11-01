# Laporan Progres Pekan 9

**Kelompok**      : Kelompok 5  
**Proses bisnis** : Online Sales  
**Status**        : Hijau

> Status kuning menunjukkan persiapan database, pemeriksaan awal, dan perancangan telah dilakukan. Implementasi ETL, OLAP, dan dashboard masih menjadi pekerjaan berikutnya.

## 1. Target dan capaian

| Target pekan ini | Status | Bukti (tautan file, commit, tangkapan layar) |
|---|---|---|
| Menyiapkan lingkungan PostgreSQL dan pgAdmin. | Selesai | Koneksi PostgreSQL Local berhasil digunakan untuk menjalankan query. |
| Menjalankan instalasi AdventureWorks for PostgreSQL. | Selesai | [Bukti proses instalasi dan daftar tabel](laporan_pekan9_assets/01-restore-adventureworks.png) |
| Memastikan jumlah tabel pada database sumber. | Selesai | Query `pg_tables` menghasilkan total **68 tabel**. [Bukti](laporan_pekan9_assets/02-total-68-tabel.png) |
| Memeriksa distribusi tabel pada schema. | Selesai | Terlihat tabel pada schema `humanresources`, `person`, `production`, `purchasing`, dan `sales`. [Bukti](laporan_pekan9_assets/03-jumlah-tabel-per-skema.png) |
| Mengidentifikasi struktur kolom tabel sumber yang relevan untuk Online Sales. | Selesai | Struktur kolom diperiksa pada tabel `sales.customer`, `sales.salesorderheader`, `sales.salesorderdetail`, `sales.salesterritory`, dan `sales.specialoffer`. |
| Melakukan profiling jumlah record pada tabel sumber terpilih. | Selesai untuk pemeriksaan awal | Hasil yang terlihat: `production.product` 504 baris, `production.productsubcategory` 37 baris, `production.productcategory` 4 baris, dan `person.person` 19.972 baris. [Bukti](laporan_pekan9_assets/04-profil-jumlah-record.png) |
| Memeriksa rentang tanggal dan jumlah transaksi online. | Selesai | Transaksi online berjumlah **27.659**, dengan rentang tanggal **30 Mei 2022–29 Juni 2025**. [Bukti](laporan_pekan9_assets/05-rentang-transaksi-online.png) |
| Memeriksa NULL pada kolom-kolom penting. | Selesai untuk pemeriksaan awal | Ditemukan **701 NULL** pada `sales.customer.personid`; kolom penting lain yang tampak pada hasil query memiliki 0 NULL. [Bukti](laporan_pekan9_assets/06-null-kolom-penting.png) |
| Menyusun pertanyaan bisnis, fakta, dan dimensi. | Selesai | Mengacu pada kebutuhan analisis Online Sales dalam perencanaan proyek. |
| Merancang Star Schema versi 1 dan menyatakan grain. | Selesai | [Diagram Star Schema versi 1](laporan_pekan9_assets/08-star-schema-v1.png) |
| Menyusun Bus Matrix dan menandai dimensi yang digunakan. | Selesai | [Diagram Bus Matrix](laporan_pekan9_assets/09-bus-matrix.png) |
| Menyusun daftar risiko awal dan mitigasi. | Selesai | Risiko awal mencakup kompatibilitas perangkat lunak, pemulihan database, kualitas data, rekonsiliasi, perubahan skema, dan koordinasi tim. |

### Pernyataan grain

Satu baris pada `FACT_ONLINE_SALES` merepresentasikan satu baris detail produk dalam satu transaksi penjualan online (*one row per sales order detail line*).

### Ringkasan profiling yang telah terverifikasi dari tangkapan layar

| Tabel/kolom | Hasil |
|---|---:|
| Seluruh tabel non-system pada database | 68 tabel |
| `production.product` | 504 baris |
| `production.productsubcategory` | 37 baris |
| `production.productcategory` | 4 baris |
| `person.person` | 19.972 baris |
| `sales.salesorderheader` dengan `onlineorderflag = TRUE` | 27.659 transaksi |
| Rentang `orderdate` transaksi online | 2022-05-30 s.d. 2025-06-29 |
| `sales.customer.personid IS NULL` | 701 baris |

**Catatan:** Profiling ini masih merupakan pemeriksaan awal terhadap tabel dan kolom terpilih, bukan audit NULL untuk seluruh 68 tabel. Jumlah baris `sales.salesorderdetail` dan tabel lain tidak dicantumkan di ringkasan ini karena tangkapan layar yang disertakan belum menjadi bukti yang cukup untuk seluruh tabel.

## 2. Kendala pengerjaan

1. **Perbedaan format database.** File dump yang sebelumnya diterima menggunakan format MySQL/MariaDB sehingga tidak dapat langsung dijalankan sebagai skrip PostgreSQL. Penanganan yang dilakukan adalah menggunakan port AdventureWorks for PostgreSQL yang menyediakan skrip instalasi dan file CSV.
2. **Ruby belum dikenali oleh Command Prompt.** Pada awalnya perintah `ruby -v` tidak dikenali. Setelah instalasi/konfigurasi Ruby, perintah tersebut berhasil dijalankan dan `ruby update_csvs.rb` selesai memproses file CSV yang ditampilkan pada terminal.
3. **Pemeriksaan kualitas data menemukan nilai NULL.** Ditemukan 701 nilai NULL pada kolom `sales.customer.personid`. Data tersebut perlu dipertimbangkan saat membentuk dimensi pelanggan dan proses ETL; nilai sumber tidak boleh dihapus atau diubah tanpa aturan transformasi yang disepakati.
4. **Validasi data sumber masih berlangsung.** Database berhasil dipasang dan beberapa tabel sudah diperiksa, tetapi profiling menyeluruh terhadap semua kolom penting masih perlu dilengkapi.

## 3. Kendala tim

Belum ada informasi terverifikasi mengenai kendala komunikasi, anggota yang sulit dihubungi, atau keterlambatan pembagian tugas pada pekan ini. Bagian ini perlu diperbarui berdasarkan kondisi aktual tim.

## 4. Keputusan yang butuh persetujuan sponsor

1. Menyetujui grain `FACT_ONLINE_SALES`, yaitu satu baris untuk setiap detail produk dalam satu transaksi penjualan online.
2. Menyetujui lima dimensi pada rancangan versi 1: `DIM_DATE`, `DIM_PRODUCT`, `DIM_CUSTOMER`, `DIM_TERRITORY`, dan `DIM_PROMOTION`.
3. Menyetujui aturan penanganan 701 nilai NULL pada `sales.customer.personid`, misalnya menggunakan anggota dimensi khusus untuk pelanggan yang tidak memiliki `PersonID`, tanpa menghilangkan transaksi.
4. Menyetujui penggunaan nilai penjualan pada tingkat detail transaksi untuk agregasi penjualan produk. Nilai header seperti `totaldue` tidak boleh dijumlahkan berulang setelah join ke banyak baris detail.

## 5. Rencana pekan depan

| Target | Penanggung jawab |
|---|---|
| Finalisasi Star Schema, grain, fakta, dimensi, dan Bus Matrix. | Zyndi Auralia Wibowo (Data Modeler) |
| Melengkapi profiling dan menetapkan aturan transformasi/penanganan NULL. | Vernanda Pramudya Sejati (ETL Developer) |
| Menyusun rancangan dan mulai membangun alur ETL ke database Data Warehouse. | Vernanda Pramudya Sejati (ETL Developer) |
| Menyiapkan rancangan kebutuhan OLAP berdasarkan pertanyaan bisnis. | Reva Luvika Apriliani (OLAP Developer) |
| Menyiapkan rancangan awal dashboard dan KPI. | Caroline Febryanty (Dashboard Developer) |
| Mengkoordinasikan progres, pembagian tugas, dan persetujuan sponsor. | Afiana Nurani (Project Manager) |

## 6. Kontribusi anggota

| Nama | Peran | Yang dikerjakan pekan ini | Bukti commit |
|---|---|---|---|
| Afiana Nurani | Project Manager | Koordinasi dan pemantauan proyek; rincian aktivitas aktual perlu dikonfirmasi oleh anggota. | [Bukti commit untuk project planning piagam charter](laporan_pekan9_assets/bukti-commit-afiana.png) |
| Caroline Febryanty | Dashboard Developer | Persiapan kebutuhan visualisasi berdasarkan pertanyaan bisnis; rincian aktivitas aktual perlu dikonfirmasi. | Belum ada |
| Reva Luvika Apriliani | OLAP Developer | Persiapan kebutuhan analisis OLAP; rincian aktivitas aktual perlu dikonfirmasi. | Belum ada |
| Zyndi Auralia Wibowo | Data Modeler | Penyusunan rancangan Star Schema versi 1 dan Bus Matrix; konfirmasi pembagian kerja aktual diperlukan. | [Bukti commit untuk data model](laporan_pekan9_assets/bukti-commit-zyndi.png) |
| Vernanda Pramudya Sejati | ETL Developer | Persiapan database sumber, pemrosesan CSV, instalasi PostgreSQL AdventureWorks, dan pemeriksaan awal data; konfirmasi pelaksana aktual diperlukan. | [Bukti commit untuk data source](laporan_pekan9_assets/bukti-commit-vernanda.png) |


## Lampiran bukti tangkapan layar

### A. Pemrosesan file CSV

![Proses update CSV](laporan_pekan9_assets/10-proses-update-csv.png)

### B. Instalasi database dan daftar tabel

![Output instalasi AdventureWorks](laporan_pekan9_assets/01-restore-adventureworks.png)

### C. Validasi jumlah tabel: 68 tabel

![Query jumlah tabel](laporan_pekan9_assets/02-total-68-tabel.png)

### D. Distribusi tabel berdasarkan schema

![Jumlah tabel per schema](laporan_pekan9_assets/03-jumlah-tabel-per-skema.png)

### E. Profiling jumlah record tabel terpilih

![Jumlah record tabel](laporan_pekan9_assets/04-profil-jumlah-record.png)

### F. Rentang tanggal dan jumlah transaksi online

![Rentang transaksi online](laporan_pekan9_assets/05-rentang-transaksi-online.png)

### G. Pemeriksaan NULL pada kolom penting

![Pemeriksaan NULL](laporan_pekan9_assets/06-null-kolom-penting.png)

### H. Rincian pelanggan dengan dan tanpa PersonID

![Rincian PersonID pelanggan](laporan_pekan9_assets/07-profil-personid-customer.png)

### I. Star Schema versi 1

![Star Schema versi 1](laporan_pekan9_assets/08-star-schema-v1.png)

### J. Bus Matrix Kelompok 5

![Bus Matrix](laporan_pekan9_assets/09-bus-matrix.png)

## Kesimpulan

Pada pekan ke-9, Kelompok 5 berhasil menyiapkan database sumber AdventureWorks pada PostgreSQL, memvalidasi keberadaan 68 tabel, dan melakukan profiling awal terhadap tabel-tabel yang relevan dengan proses bisnis Online Sales. Tim juga telah menyusun rancangan Star Schema versi 1, Bus Matrix, serta daftar risiko awal. Tahap berikutnya adalah menyelesaikan validasi kualitas data, memfinalisasi rancangan dimensional, dan mulai membangun proses ETL sebelum melanjutkan ke OLAP serta dashboard.
