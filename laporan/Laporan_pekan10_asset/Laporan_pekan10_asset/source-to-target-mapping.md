# Source-to-Target Mapping --- Star Schema V2

**Proyek:** Data Warehouse AdventureWorks --- Online Sales\
**Database sumber:** `adventureworks`\
**Database target:** `dw_kelompok_5`\
**Fact table:** `fact_online_sales`\
**Grain:** Satu baris pada `fact_online_sales` merepresentasikan satu
baris detail produk dalam satu transaksi penjualan online
(`onlineorderflag = TRUE`).

> **Catatan:** Dokumen ini merupakan rancangan mapping untuk
> implementasi ETL. Aturan yang masih berupa asumsi, khususnya penetapan
> USD untuk transaksi tanpa `currencyrateid`, harus divalidasi sebelum
> ETL final.

------------------------------------------------------------------------

## Target: dim_date (SCD: Type 0)

**Sumber utama:** Generated Calendar (dibentuk pada proses ETL, bukan
diambil dari satu tabel sumber).

  ----------------------------------------------------------------------------------
  Kolom target     Tipe           Tabel.kolom sumber   Transformasi   Aturan NULL
  ---------------- -------------- -------------------- -------------- --------------
  date_key         INT            Generated            Format tanggal Tidak boleh
                                  Calendar.full_date   menjadi        NULL
                                                       `YYYYMMDD`     

  full_date        DATE           Generated Calendar   Generate       Tidak boleh
                                                       seluruh        NULL
                                                       tanggal dalam  
                                                       rentang        
                                                       periode data   

  day_number       INT            Generated            Ekstrak angka  Tidak boleh
                                  Calendar.full_date   hari (1--31)   NULL

  day_name         VARCHAR        Generated            Ambil nama     Tidak boleh
                                  Calendar.full_date   hari           NULL
                                                       berdasarkan    
                                                       tanggal        

  month_number     INT            Generated            Ekstrak angka  Tidak boleh
                                  Calendar.full_date   bulan (1--12)  NULL

  month_name       VARCHAR        Generated            Ambil nama     Tidak boleh
                                  Calendar.full_date   bulan          NULL

  quarter_number   INT            Generated            Hitung kuartal Tidak boleh
                                  Calendar.full_date   berdasarkan    NULL
                                                       bulan          

  year_number      INT            Generated            Ekstrak tahun  Tidak boleh
                                  Calendar.full_date                  NULL

  is_weekend       BOOLEAN        Generated            TRUE jika hari Tidak boleh
                                  Calendar.full_date   Sabtu atau     NULL
                                                       Minggu         
  ----------------------------------------------------------------------------------

------------------------------------------------------------------------

## Target: dim_product (SCD: Type 2)

**Sumber utama:** `production.product`\
**Sumber tambahan:** `production.productmodel`,
`production.productsubcategory`, `production.productcategory`.

  ------------------------------------------------------------------------------------------------------------------------------------------------------
  Kolom target               Tipe            Tabel.kolom sumber                               Transformasi                             Aturan NULL
  -------------------------- --------------- ------------------------------------------------ ---------------------------------------- -----------------
  product_key                INT             \-                                               Surrogate key dari DW (identity)         Tidak boleh NULL

  product_id                 INT             `production.product.productid`                   Ambil langsung sebagai business key      Tidak boleh NULL

  product_name               VARCHAR         `production.product.name`                        Ambil langsung                           Tidak boleh NULL

  product_number             VARCHAR         `production.product.productnumber`               Ambil langsung                           Tidak boleh NULL

  product_model_id           INT             `production.product.productmodelid`              Ambil langsung                           NULL
                                                                                                                                       diperbolehkan
                                                                                                                                       jika tidak
                                                                                                                                       memiliki model

  product_model_name         VARCHAR         `production.productmodel.name`                   LEFT JOIN berdasarkan `productmodelid`   Jika NULL, isi
                                                                                                                                       `Not Assigned`

  product_subcategory_id     INT             `production.product.productsubcategoryid`        Ambil langsung                           NULL
                                                                                                                                       diperbolehkan
                                                                                                                                       jika tidak
                                                                                                                                       memiliki
                                                                                                                                       subkategori

  product_subcategory_name   VARCHAR         `production.productsubcategory.name`             LEFT JOIN berdasarkan                    Jika NULL, isi
                                                                                              `productsubcategoryid`                   `Not Assigned`

  product_category_id        INT             `production.productcategory.productcategoryid`   LEFT JOIN melalui                        NULL
                                                                                              `productsubcategory.productcategoryid`   diperbolehkan
                                                                                                                                       jika tidak
                                                                                                                                       memiliki kategori

  product_category_name      VARCHAR         `production.productcategory.name`                LEFT JOIN melalui tabel subkategori      Jika NULL, isi
                                                                                                                                       `Not Assigned`

  color                      VARCHAR         `production.product.color`                       Ambil langsung                           Jika NULL, isi
                                                                                                                                       `Not Specified`

  size                       VARCHAR         `production.product.size`                        Ambil langsung                           Jika NULL, isi
                                                                                                                                       `Not Specified`

  standard_cost              NUMERIC(18,4)   `production.product.standardcost`                Ambil langsung                           NULL
                                                                                                                                       diperbolehkan
                                                                                                                                       jika sumber NULL

  list_price                 NUMERIC(18,4)   `production.product.listprice`                   Ambil langsung                           NULL
                                                                                                                                       diperbolehkan
                                                                                                                                       jika sumber NULL

  effective_start_date       DATE            ETL process                                      Tanggal mulai berlakunya versi dimension Tidak boleh NULL;
                                                                                                                                       default awal
                                                                                                                                       sesuai kebijakan
                                                                                                                                       ETL

  effective_end_date         DATE            ETL process                                      Tanggal akhir berlakunya versi; versi    Tidak boleh NULL
                                                                                              aktif menggunakan tanggal maksimum       

  is_current                 BOOLEAN         ETL process                                      TRUE untuk versi terbaru, FALSE untuk    Tidak boleh NULL
                                                                                              versi sebelumnya                         
  ------------------------------------------------------------------------------------------------------------------------------------------------------

**Aturan SCD Type 2:** Jika atribut yang dipantau berubah, tutup versi
lama dengan mengisi `effective_end_date` dan `is_current = FALSE`,
kemudian buat baris versi baru dengan surrogate key baru. Sumber saat
ini tidak otomatis menyediakan seluruh riwayat perubahan masa lalu.

------------------------------------------------------------------------

## Target: dim_customer (SCD: Type 2)

**Sumber utama:** `sales.customer`\
**Sumber tambahan:** `person.person`, `sales.store`.

  -----------------------------------------------------------------------------------------------------------
  Kolom target           Tipe           Tabel.kolom sumber            Transformasi           Aturan NULL
  ---------------------- -------------- ----------------------------- ---------------------- ----------------
  customer_key           INT            \-                            Surrogate key dari DW  Tidak boleh NULL
                                                                      (identity)             

  customer_id            INT            `sales.customer.customerid`   Ambil langsung sebagai Tidak boleh NULL
                                                                      business key           

  person_id              INT            `sales.customer.personid`     Ambil langsung         NULL
                                                                                             diperbolehkan

  store_id               INT            `sales.customer.storeid`      Ambil langsung         NULL
                                                                                             diperbolehkan

  customer_type          VARCHAR        `sales.customer.personid`,    Jika `storeid`         Jika keduanya
                                        `sales.customer.storeid`      tersedia: `Store`;     NULL, isi
                                                                      jika `personid`        `Unknown`
                                                                      tersedia:              
                                                                      `Individual`; selain   
                                                                      itu: `Unknown`         

  customer_name          VARCHAR        `person.person.firstname`,    LEFT JOIN melalui      Jika tidak
                                        `middlename`, `lastname`      `customer.personid`,   tersedia, isi
                                                                      gabungkan nama yang    `Not Assigned`
                                                                      tersedia               

  store_name             VARCHAR        `sales.store.name`            LEFT JOIN melalui      Jika NULL, isi
                                                                      `customer.storeid`     `Not Assigned`

  effective_start_date   DATE           ETL process                   Tanggal mulai          Tidak boleh NULL
                                                                      berlakunya versi       
                                                                      dimension              

  effective_end_date     DATE           ETL process                   Tanggal akhir          Tidak boleh NULL
                                                                      berlakunya versi;      
                                                                      versi aktif            
                                                                      menggunakan tanggal    
                                                                      maksimum               

  is_current             BOOLEAN        ETL process                   TRUE untuk versi       Tidak boleh NULL
                                                                      terbaru, FALSE untuk   
                                                                      versi sebelumnya       
  -----------------------------------------------------------------------------------------------------------

**Aturan SCD Type 2:** Jika atribut customer yang dipantau berubah, buat
versi baru. Saat fact dimuat, cari `customer_key` berdasarkan
`customer_id` dan rentang tanggal transaksi agar versi yang sesuai
dengan transaksi digunakan.

------------------------------------------------------------------------

## Target: dim_territory (SCD: Type 1)

**Sumber utama:** `sales.salesterritory`.

  -------------------------------------------------------------------------------------------------------------
  Kolom target          Tipe           Tabel.kolom sumber                         Transformasi   Aturan NULL
  --------------------- -------------- ------------------------------------------ -------------- --------------
  territory_key         INT            \-                                         Surrogate key  Tidak boleh
                                                                                  dari DW        NULL
                                                                                  (identity)     

  territory_id          INT            `sales.salesterritory.territoryid`         Ambil langsung Tidak boleh
                                                                                  sebagai        NULL
                                                                                  business key   

  territory_name        VARCHAR        `sales.salesterritory.name`                Ambil langsung Tidak boleh
                                                                                                 NULL

  country_region_code   VARCHAR        `sales.salesterritory.countryregioncode`   Ambil langsung Jika NULL, isi
                                                                                                 `Unknown`

  territory_group       VARCHAR        `sales.salesterritory."group"`             Ambil          Jika NULL, isi
                                                                                  langsung;      `Unknown`
                                                                                  gunakan tanda  
                                                                                  kutip ganda    
                                                                                  untuk nama     
                                                                                  kolom `group`  
                                                                                  di PostgreSQL  
  -------------------------------------------------------------------------------------------------------------

**Aturan SCD Type 1:** Perubahan atribut memperbarui nilai yang
tersimpan tanpa mempertahankan versi sebelumnya. Territory tidak
dihubungkan ke satu salesperson karena satu territory dapat memiliki
beberapa salesperson dan seluruh transaksi online yang diperiksa
memiliki `salespersonid` NULL.

------------------------------------------------------------------------

## Target: dim_promotion (SCD: Type 1)

**Sumber utama:** `sales.specialoffer`.

  -------------------------------------------------------------------------------------------------------
  Kolom target       Tipe           Tabel.kolom sumber                    Transformasi   Aturan NULL
  ------------------ -------------- ------------------------------------- -------------- ----------------
  promotion_key      INT            \-                                    Surrogate key  Tidak boleh NULL
                                                                          dari DW        
                                                                          (identity)     

  special_offer_id   INT            `sales.specialoffer.specialofferid`   Ambil langsung Tidak boleh NULL
                                                                          sebagai        untuk promosi
                                                                          business key   sumber

  description        VARCHAR        `sales.specialoffer.description`      Ambil langsung Jika NULL, isi
                                                                                         `Not Assigned`

  offer_type         VARCHAR        `sales.specialoffer.type`             Ambil langsung Jika NULL, isi
                                                                                         `Not Assigned`

  category           VARCHAR        `sales.specialoffer.category`         Ambil langsung Jika NULL, isi
                                                                                         `Not Assigned`

  discount_pct       NUMERIC(8,4)   `sales.specialoffer.discountpct`      Ambil          Jika NULL, isi 0
                                                                          persentase     
                                                                          diskon dari    
                                                                          master promosi 

  promotion_status   VARCHAR        `sales.specialoffer.startdate`,       Hitung status  Jika tanggal
                                    `enddate`                             berdasarkan    tidak lengkap,
                                                                          tanggal proses isi `Unknown`
                                                                          ETL:           
                                                                          `Upcoming`,    
                                                                          `Active`, atau 
                                                                          `Expired`      
  -------------------------------------------------------------------------------------------------------

**Anggota khusus:** Buat satu baris `No Promotion` pada `dim_promotion`
untuk transaksi yang tidak menggunakan promosi. Gunakan surrogate key
anggota tersebut saat lookup fact.

**Aturan SCD Type 1:** Perubahan atribut promosi memperbarui nilai yang
tersimpan tanpa membuat versi historis.

------------------------------------------------------------------------

## Target: dim_currency (SCD: Type 0)

**Sumber utama:** `sales.currency`.

  --------------------------------------------------------------------------------------------
  Kolom target    Tipe           Tabel.kolom sumber              Transformasi   Aturan NULL
  --------------- -------------- ------------------------------- -------------- --------------
  currency_key    INT            \-                              Surrogate key  Tidak boleh
                                                                 dari DW        NULL
                                                                 (identity)     

  currency_code   VARCHAR        `sales.currency.currencycode`   Ambil langsung Tidak boleh
                                                                 sebagai        NULL
                                                                 business key   

  currency_name   VARCHAR        `sales.currency.name`           Ambil langsung Tidak boleh
                                                                                NULL
  --------------------------------------------------------------------------------------------

**Aturan lookup mata uang transaksi:** Dari
`sales.salesorderheader.currencyrateid`, LEFT JOIN ke
`sales.currencyrate.currencyrateid`, lalu gunakan `tocurrencycode` untuk
lookup ke `sales.currency.currencycode`.

**Asumsi yang perlu divalidasi:** Transaksi dengan `currencyrateid` NULL
sementara dipetakan ke USD sebagai mata uang dasar. Validasi asumsi ini
terhadap aturan bisnis atau metadata sumber sebelum ETL final.

**Aturan SCD Type 0:** Nilai dimension dipertahankan dan tidak
diperbarui melalui mekanisme historisasi.

------------------------------------------------------------------------

## Target: fact_online_sales (Grain: satu baris detail produk per transaksi online)

**Sumber utama:** `sales.salesorderdetail`\
**Sumber tambahan:** `sales.salesorderheader`, `sales.currencyrate`,
serta seluruh dimension pada DW.

  -----------------------------------------------------------------------------------------------------------------------------------------------------
  Kolom target            Tipe            Tabel.kolom sumber                            Transformasi                                   Aturan NULL
  ----------------------- --------------- --------------------------------------------- ---------------------------------------------- ----------------
  sales_order_detail_id   INT             `sales.salesorderdetail.salesorderdetailid`   Ambil ID detail sebagai primary key fact       Tidak boleh NULL

  sales_order_id          INT             `sales.salesorderdetail.salesorderid`         Ambil ID transaksi                             Tidak boleh NULL

  date_key                INT             `sales.salesorderheader.orderdate`            Lookup ke `dim_date` menggunakan format        Jika tidak
                                                                                        `YYYYMMDD`                                     ditemukan,
                                                                                                                                       gunakan unknown
                                                                                                                                       date key

  product_key             INT             `dim_product.product_id`                      Lookup surrogate key berdasarkan `product_id`  Jika tidak
                                                                                        dan versi yang berlaku pada tanggal transaksi  ditemukan,
                                                                                                                                       gunakan unknown
                                                                                                                                       product key

  customer_key            INT             `sales.salesorderheader.customerid` →         Lookup surrogate key berdasarkan customer dan  Jika tidak
                                          `dim_customer.customer_id`                    tanggal transaksi                              ditemukan,
                                                                                                                                       gunakan unknown
                                                                                                                                       customer key

  territory_key           INT             `sales.salesorderheader.territoryid` →        Lookup surrogate key berdasarkan territory_id  Jika tidak
                                          `dim_territory.territory_id`                                                                 ditemukan,
                                                                                                                                       gunakan unknown
                                                                                                                                       territory key

  promotion_key           INT             `sales.salesorderdetail.specialofferid` →     Lookup surrogate key berdasarkan               Jika tidak ada
                                          `dim_promotion.special_offer_id`              specialofferid                                 promosi, gunakan
                                                                                                                                       anggota
                                                                                                                                       `No Promotion`

  currency_key            INT             `sales.currencyrate.tocurrencycode` →         Lookup surrogate key berdasarkan kode mata     Jika tidak
                                          `dim_currency.currency_code`                  uang transaksi                                 ditemukan,
                                                                                                                                       gunakan unknown
                                                                                                                                       currency key;
                                                                                                                                       USD untuk rate
                                                                                                                                       NULL masih
                                                                                                                                       asumsi

  currency_rate_id        INT             `sales.salesorderheader.currencyrateid`       Ambil langsung                                 NULL
                                                                                                                                       diperbolehkan

  average_rate            NUMERIC(18,8)   `sales.currencyrate.averagerate`              Ambil nilai kurs rata-rata                     NULL
                                                                                                                                       diperbolehkan
                                                                                                                                       jika tidak ada
                                                                                                                                       currency rate

  end_of_day_rate         NUMERIC(18,8)   `sales.currencyrate.endofdayrate`             Ambil nilai kurs akhir hari                    NULL
                                                                                                                                       diperbolehkan
                                                                                                                                       jika tidak ada
                                                                                                                                       currency rate

  order_qty               INT             `sales.salesorderdetail.orderqty`             Ambil jumlah produk                            Tidak boleh NULL

  unit_price              NUMERIC(18,4)   `sales.salesorderdetail.unitprice`            Ambil harga satuan                             Tidak boleh NULL

  discount_pct            NUMERIC(8,4)    `sales.salesorderdetail.unitpricediscount`    Ambil persentase diskon dalam bentuk desimal   Jika NULL, isi 0

  gross_sales             NUMERIC(18,4)   `sales.salesorderdetail.orderqty`,            Hitung `orderqty * unitprice`                  Tidak boleh NULL
                                          `unitprice`                                                                                  

  discount_amount         NUMERIC(18,4)   `orderqty`, `unitprice`, `unitpricediscount`  Hitung                                         Jika diskon
                                                                                        `(orderqty * unitprice) * unitpricediscount`   NULL, gunakan 0

  net_sales               NUMERIC(18,4)   Hasil perhitungan                             Hitung `gross_sales - discount_amount`         Tidak boleh NULL
  -----------------------------------------------------------------------------------------------------------------------------------------------------

**Filter sumber fact:**

``` sql
WHERE soh.onlineorderflag = TRUE
```

**Catatan perhitungan:** - `unitpricediscount` merupakan nilai diskon
desimal; contoh `0.10` berarti 10%. - `gross_sales` dihitung dari
kuantitas dikali harga satuan. - `discount_amount` dihitung dari gross
sales dikali persentase diskon. - `net_sales` merupakan gross sales
setelah dikurangi discount amount. - Jangan menjumlahkan
`salesorderheader.totaldue` setelah join ke detail karena nilai header
dapat berulang pada setiap baris detail. - Jumlah transaksi dihitung
dengan `COUNT(DISTINCT sales_order_id)`, bukan jumlah baris fact.

------------------------------------------------------------------------

## Urutan load

1.  **Staging:** Ambil data sumber yang diperlukan dari
    `adventureworks`, termasuk filter `onlineorderflag = TRUE` untuk
    data transaksi online.
2.  **dim_date:** Generate kalender untuk rentang tanggal transaksi.
3.  **dim_product:** Load data produk beserta model, subkategori, dan
    kategori.
4.  **dim_customer:** Load data customer beserta person dan store.
5.  **dim_territory:** Load data territory.
6.  **dim_promotion:** Load master promosi dan anggota khusus
    `No Promotion`.
7.  **dim_currency:** Load master mata uang dan pastikan asumsi mata
    uang untuk `currencyrateid` NULL telah divalidasi.
8.  **fact_online_sales:** Lakukan lookup seluruh surrogate key
    dimension, hitung measure, lalu load data fact.

> Sebelum fact dimuat, pastikan anggota `Unknown` pada dimension yang
> diperlukan telah tersedia dan seluruh lookup surrogate key dapat
> diselesaikan.

------------------------------------------------------------------------

## Catatan validasi sebelum implementasi

1.  Konfirmasi asumsi USD untuk transaksi dengan `currencyrateid` NULL.
2.  Pastikan anggota khusus `No Promotion` tersedia sebelum load fact.
3.  Tentukan surrogate key khusus untuk anggota `Unknown` pada setiap
    dimension yang dibutuhkan.
4.  Pastikan aturan SCD Type 2 untuk product dan customer memiliki
    mekanisme pencatatan perubahan. Riwayat sebelum proses ETL mulai
    berjalan tidak dapat direkonstruksi jika tidak tersedia pada sumber.
5.  Validasi kembali tipe data target dengan DDL Star Schema V2.
