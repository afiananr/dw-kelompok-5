- **Fact Table:** `FACT_ONLINE_SALES`
- **Dimension Tables:**
  - `DIM_DATE`
  - `DIM_PRODUCT`
  - `DIM_CUSTOMER`
  - `DIM_TERRITORY`
  - `DIM_PROMOTION`

### Pemetaan Business Questions

| No. | Pertanyaan Bisnis | Dimensi yang Digunakan | Measure |
|---|---|---|---|
| 1 | Bagaimana tren jumlah transaksi dan nilai penjualan online berdasarkan periode waktu? | Date | Transaction Count, Net Sales |
| 2 | Produk dan kategori produk apa yang memiliki nilai penjualan online tertinggi? | Product | Net Sales, Quantity |
| 3 | Wilayah penjualan mana yang memberikan kontribusi nilai penjualan online terbesar? | Territory | Net Sales, Transaction Count |
| 4 | Siapa pelanggan dengan jumlah transaksi dan total pembelian tertinggi? | Customer | Transaction Count, Net Sales |
| 5 | Bagaimana perbandingan nilai penjualan, jumlah transaksi, dan rata-rata diskon antara transaksi yang menggunakan promosi dan tidak menggunakan promosi? | Promotion | Net Sales, Transaction Count, Average Discount |