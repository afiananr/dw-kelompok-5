# Source Tables

Tabel berikut dipilih karena mendukung pertanyaan bisnis Online Sales dan rancangan Star Schema versi 1.

| Schema | Tabel sumber | Kegunaan dalam analisis |
|---|---|---|
| `sales` | `salesorderheader` | Informasi header transaksi, tanggal, pelanggan, wilayah, dan penanda transaksi online. |
| `sales` | `salesorderdetail` | Rincian produk per transaksi, kuantitas, harga satuan, dan diskon aktual. |
| `sales` | `customer` | Identitas pelanggan serta relasi ke individu atau toko. |
| `sales` | `salesterritory` | Informasi wilayah penjualan, negara, dan kelompok wilayah. |
| `sales` | `specialoffer` | Informasi penawaran/promosi. |
| `production` | `product` | Informasi produk dan subkategori produk. |
| `production` | `productsubcategory` | Informasi subkategori dan relasi ke kategori produk. |
| `production` | `productcategory` | Informasi kategori utama produk. |
| `person` | `person` | Informasi nama pelanggan individu yang terkait melalui `customer.personid`. |
| `sales` | `store` | Sumber nama toko untuk pelanggan yang memiliki `storeid` (digunakan bila atribut nama toko diperlukan). |

## Kolom penting yang telah diperiksa

- `sales.salesorderheader`: `salesorderid`, `orderdate`, `onlineorderflag`, `customerid`, `territoryid`, `subtotal`, `taxamt`, `freight`, `totaldue`.
- `sales.salesorderdetail`: `salesorderid`, `salesorderdetailid`, `orderqty`, `productid`, `specialofferid`, `unitprice`, `unitpricediscount`.
- `sales.customer`: `customerid`, `personid`, `storeid`, `territoryid`.
- `sales.salesterritory`: `territoryid`, `name`, `countryregioncode`, `group`.
- `sales.specialoffer`: `specialofferid`, `description`, `discountpct`, `type`, `category`, `startdate`, `enddate`.
- `production.product`: `productid`, `name`, `productnumber`, `productsubcategoryid`, `standardcost`, `listprice`.
- `production.productsubcategory`: `productsubcategoryid`, `productcategoryid`, `name`.
- `production.productcategory`: `productcategoryid`, `name`.

Catatan: daftar ini adalah tabel yang relevan dengan cakupan analisis, bukan keseluruhan 68 tabel database.
