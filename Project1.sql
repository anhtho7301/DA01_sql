--1.
alter table sales_dataset_rfm_prj
alter column ordernumber type bigint USING ordernumber::bigint
------
alter table sales_dataset_rfm_prj
alter column quantityordered type int USING quantityordered::int
------
alter table sales_dataset_rfm_prj
alter column priceeach type numeric USING priceeach::numeric
------
alter table sales_dataset_rfm_prj
alter column orderlinenumber type int USING orderlinenumber::int
------
alter table sales_dataset_rfm_prj
alter column sales type numeric USING sales::numeric
------
UPDATE sales_dataset_rfm_prj
SET orderdate = SUBSTRING(orderdate FROM 0 FOR (POSITION(' 0:00' IN orderdate)))

update sales_dataset_rfm_prj
set orderdate=to_date(orderdate, 'mm/dd/YYYY')

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN orderdate TYPE DATE USING orderdate::date
------
alter table sales_dataset_rfm_prj
alter column status type text USING status::text
------
alter table sales_dataset_rfm_prj
alter column productline type text USING productline::text
------
alter table sales_dataset_rfm_prj
alter column msrp type int USING msrp::int
------
alter table sales_dataset_rfm_prj
alter column productcode type varchar(8) USING productcode::varchar(8)

------------------------------------------------------------------------------------
--2.
SELECT * FROM sales_dataset_rfm_prj
WHERE ORDERNUMBER IS NULL OR QUANTITYORDERED IS NULL
  OR PRICEEACH IS NULL OR ORDERLINENUMBER IS NULL
  OR SALES IS NULL OR ORDERDATE IS NULL

------------------------------------------------------------------------------------
--3.
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN CONTACTLASTNAME VARCHAR

ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN CONTACTFIRSTNAME VARCHAR

update sales_dataset_rfm_prj
set CONTACTLASTNAME=UPPER(LEFT(SUBSTRING(CONTACTFULLNAME FROM 0 FOR POSITION('-' IN CONTACTFULLNAME)),1))||
SUBSTRING(CONTACTFULLNAME FROM 2 FOR POSITION('-' IN CONTACTFULLNAME)-2)

update sales_dataset_rfm_prj
set CONTACTFIRSTNAME=UPPER(LEFT(SUBSTRING(CONTACTFULLNAME FROM POSITION('-' IN CONTACTFULLNAME)+1),1))||
SUBSTRING(CONTACTFULLNAME FROM POSITION('-' IN CONTACTFULLNAME)+2)

--4.
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN QTR_ID int

update sales_dataset_rfm_prj
set QTR_ID=extract(quarter from orderdate)
------
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN MONTH_ID int

update sales_dataset_rfm_prj
set MONTH_ID=extract(month from orderdate)
------
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN YEAR_ID int

update sales_dataset_rfm_prj
set YEAR_ID=extract(YEAR from orderdate)

--5.
with a as
(select QUANTITYORDERED,
(select avg(QUANTITYORDERED)
from sales_dataset_rfm_prj) as avg,
(select stddev(QUANTITYORDERED)
from sales_dataset_rfm_prj) as stddev
from sales_dataset_rfm_prj)
select QUANTITYORDERED,(QUANTITYORDERED- avg)/stddev as z_score
from a
where abs((QUANTITYORDERED- avg)/stddev)>3

------
with twt_outlier as
(select (QUANTITYORDERED- avg)/stddev as z_score
from a
where abs((QUANTITYORDERED- avg)/stddev)>3)
update sales_dataset_rfm_prj
set QUANTITYORDERED=(select avg(QUANTITYORDERED)
from sales_dataset_rfm_prj)
where QUANTITYORDERED in (select QUANTITYORDERED from twt_outlier)
------
delete from sales_dataset_rfm_prj
where QUANTITYORDERED in (select QUANTITYORDERED from twt_outlier)


