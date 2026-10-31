# Bus Matrix — Kelompok 5

**Proses bisnis yang dimodelkan:** Online Sales

| Proses Bisnis | Date | Product | Customer | Territory | Promotion |
|---|:---:|:---:|:---:|:---:|:---:|
| Online Sales | ✓ | ✓ | ✓ | ✓ | ✓ |

## Dimensi yang direncanakan sebagai conformed dimensions

- `DIM_DATE`
- `DIM_PRODUCT`
- `DIM_CUSTOMER`
- `DIM_TERRITORY`
- `DIM_PROMOTION`

Dimensi di atas dirancang agar berpotensi digunakan kembali oleh proses bisnis lain pada pengembangan berikutnya. Karena saat ini matriks hanya memuat satu proses bisnis, status conformed lintas proses **belum terbukti melalui implementasi** dan masih merupakan rencana desain.

## Keterangan
Tanda ✓ menunjukkan dimensi yang digunakan oleh proses Online Sales pada rancangan saat ini.
