# Database Source Documentation

## 1. Informasi Database

| Keterangan | Detail |
|---|---|
| Nama database sumber | `adventureworks` |
| DBMS | PostgreSQL |
| Tools administrasi | pgAdmin 4 |
| Sumber implementasi | AdventureWorks for PostgreSQL (repository GitHub) |
| Proses bisnis | Online Sales |
| Nama database target yang direncanakan | `dw_kelompok_5` |

## 2. Persiapan database

Database AdventureWorks disiapkan menggunakan port AdventureWorks untuk PostgreSQL. File CSV disiapkan bersama skrip repository, kemudian diproses menggunakan Ruby melalui `update_csvs.rb`. Setelah itu, skrip `install.sql` dijalankan untuk membentuk schema, tabel, dan data pada PostgreSQL.

## 3. Validasi awal

Pemeriksaan awal melalui PostgreSQL menunjukkan:
- Database `adventureworks` berhasil dibuat dan diakses melalui pgAdmin 4.
- Terdapat 68 tabel pada schema aplikasi.
- Schema yang relevan dengan analisis mencakup `sales`, `production`, dan `person`.
- Tabel penjualan online tersedia dan dapat ditanyakan menggunakan SQL.

## 4. Catatan sumber

File SQL MariaDB yang sempat diterima tidak digunakan sebagai file restore langsung ke PostgreSQL. Untuk pengerjaan PostgreSQL, digunakan port AdventureWorks for PostgreSQL sesuai arahan tugas.
