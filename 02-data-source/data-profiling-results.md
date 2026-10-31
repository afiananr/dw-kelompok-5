# Data Profiling Results

## 1. Jumlah record

Hasil query profiling yang telah diperoleh:

| Tabel | Jumlah record |
|---|---:|
| `sales.salesorderheader` | 31.465 |
| `sales.salesorderdetail` | 121.317 |
| `sales.customer` | 19.820 |
| `sales.salesterritory` | 10 |
| `sales.specialoffer` | 16 |
| `production.product` | 504 |
| `production.productsubcategory` | 37 |
| `production.productcategory` | 4 |
| `person.person` | 19.972 |

## 2. Rentang tanggal transaksi online

| Indikator | Hasil |
|---|---|
| Jumlah transaksi online | 27.659 |
| Tanggal transaksi pertama | 30 Mei 2022 |
| Tanggal transaksi terakhir | 29 Juni 2025 |

Filter yang digunakan adalah `onlineorderflag = TRUE` pada `sales.salesorderheader`.

## 3. Pemeriksaan NULL

Hasil pemeriksaan terhadap kolom penting yang ditampilkan:

| Tabel | Kolom | Jumlah NULL |
|---|---|---:|
| `sales.customer` | `personid` | 701 |
| `sales.customer` | `territoryid` | 0 |
| `sales.salesorderheader` | `orderdate` | 0 |
| `sales.salesorderheader` | `customerid` | 0 |
| `sales.salesorderheader` | `territoryid` | 0 |
| `sales.salesorderheader` | `onlineorderflag` | 0 |
| `sales.salesorderdetail` | `productid` | 0 |
| `sales.salesorderdetail` | `orderqty` | 0 |
| `sales.salesorderdetail` | `unitprice` | 0 |
| `sales.salesorderdetail` | `unitpricediscount` | 0 |

## 4. Pemeriksaan lanjutan PersonID

Terdapat 701 record customer dengan `personid` NULL. Pemeriksaan sampel menunjukkan record-record tersebut memiliki `storeid` terisi. Hal ini mengindikasikan bahwa pelanggan tersebut dapat mewakili pelanggan berbentuk toko, bukan individu.

**Catatan validasi:** pastikan hasil query agregat lanjutan menunjukkan seluruh 701 record memiliki `storeid` terisi sebelum menyimpulkan bahwa semua NULL tersebut adalah store customer. Data tidak dihapus pada tahap profiling.

## 5. Temuan distribusi online dan offline

Hasil query distribusi yang telah diperoleh:

| Jenis transaksi | Jumlah transaksi | Total nilai `totaldue` |
|---|---:|---:|
| Offline (`FALSE`) | 3.806 | 90.775.446,9931 |
| Online (`TRUE`) | 27.659 | 32.441.339,1228 |

`totaldue` merupakan nilai pada tingkat header transaksi. Untuk analisis tingkat produk, nilai dari header tidak boleh dijumlahkan setelah join ke detail tanpa pengendalian duplikasi.

## 6. Interpretasi awal

1. Tabel `salesorderheader` memiliki 31.465 transaksi dan `salesorderdetail` memiliki 121.317 baris detail.
2. Terdapat 27.659 transaksi online dalam rentang 30 Mei 2022 sampai 29 Juni 2025.
3. Pemeriksaan kolom penting menunjukkan sebagian besar kolom yang diperiksa tidak memiliki NULL.
4. Kolom `sales.customer.personid` memiliki 701 NULL dan perlu ditangani secara tepat pada tahap transformasi ETL.
5. Profiling ini menjadi dasar untuk menentukan validasi, transformasi, dan pemuatan data ke Data Warehouse.

## 7. Batasan hasil

Hasil di atas merupakan hasil pemeriksaan yang telah dilaporkan selama pengerjaan. Tidak semua kolom di seluruh tabel database diperiksa NULL-nya. Untuk itu, hasil ini tidak boleh dianggap sebagai audit lengkap seluruh kualitas database.
