
WITH online_retail_convert AS (
select invoiceno, stockcode, description,
CAST (quantity AS int) as quantity,
to_timestamp(invoicedate,'mm/dd/yyyy hh24:mi:ss') AS invoicedate , 
cast(unitprice AS numeric) as unitprice, customerid, country 
from online_retail where customerid <>''
and CAST(quantity AS int) >0 and cast(unitprice AS numeric) >0)
, online_retail_main AS ( 
select * from (SELECT *,
ROW_NUMBER () OVER(PARTITION BY invoiceno, stockcode, quantity ORDER BY invoicedate) as stt
from online_retail_convert ) as t
	where stt=1),
r as									 
(select * from

 (select *,

row_number() over(partition by invoiceno, stockcode, quantity order by invoicedate) as dup_flag

from online_retail_convert ) x

where dup_flag =1)

, online_retail_index as(

SELECT

customerid,

amount,

TO_CHAR (first_purchase_date, 'yyyy-mm') as cohort_date,

invoicedate,

(extract (year from invoicedate)-extract (year from first_purchase_date)) *12

+ (extract(month from invoicedate)-extract (month from first_purchase_date) +1) as index

FROM (

SELECT customerid,

quantity*unitprice AS amount,

MIN(invoicedate) over (PARTITION BY customerid) as first_purchase_date ,

invoicedate

from online_retail_main
	) a)
SELECT
cohort_date, index,
count (distinct customerid) as cnt, 
sum (amount) as revenue from online_retail_index 
	group by cohort_date, index
