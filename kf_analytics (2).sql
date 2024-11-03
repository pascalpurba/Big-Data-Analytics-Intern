ALTER TABLE kimia_farma.kf_final_transaction
ADD COLUMN nett_sales float64;

UPDATE kimia_farma.kf_final_transaction
SET nett_sales = price - (price * discount_percentage)
WHERE nett_sales IS NULL;

### Membuat kolom nett_sales untuk menganalisis hasil penjualan yang diterima perusahaan


ALTER TABLE kimia_farma.kf_final_transaction
ADD COLUMN persentase_gross_laba float64;

UPDATE kimia_farma.kf_final_transaction
SET persentase_gross_laba =
CASE
  WHEN nett_sales <= 50000 THEN 0.10
  WHEN nett_sales <= 100000 THEN 0.15
  WHEN nett_sales <= 300000 THEN 0.20
  WHEN nett_sales <= 500000 THEN 0.25
  ELSE 0.30
END
WHERE persentase_gross_laba IS NULL;


### Membuat kolom persentase_gross_laba berdasarkan threeshold perusahan, untuk menganalisis laba yang diperoleh perusahaan dari hasil penjualan


ALTER TABLE kimia_farma.kf_final_transaction
ADD COLUMN nett_profit float64;

UPDATE kimia_farma.kf_final_transaction
SET nett_profit = nett_sales - (price - (nett_sales * persentase_gross_laba))
WHERE nett_profit IS not NULL;

### membuat kolom nett_profit untuk menganalisa laba bersih yang diterima perusahaan


CREATE TABLE kimia_farma.kf_analytics AS
SELECT
transaction_id,
date,
branch_id,
customer_name,
product_id,
price,
discount_percentage,
rating,
nett_sales,
persentase_gross_laba,
nett_profit
FROM kimia_farma.kf_final_transaction;


SELECT
    ka.transaction_id,
    ka.date,
    ka.customer_name,
    ka.product_id,
    ka.price,
    ka.discount_percentage,
    ka.rating,
    ka.nett_sales,
    ka.persentase_gross_laba,
    ka.nett_profit,
    kkc.branch_id,
    kkc.branch_name,
    kkc.kota,
    kkc.provinsi,
    kkc.rating as rating_cabang,
    kp.product_name
FROM
    kimia_farma.kf_analytics AS ka
LEFT JOIN kimia_farma.kf_kantor_cabang AS kkc ON ka.branch_id = kkc.branch_id
LEFT JOIN kimia_farma.kf_product AS kp ON ka.product_id = kp.product_id;

## Membuat tabel baru untuk keperluan analisis yang berasal dari hasil query sebelumnya
