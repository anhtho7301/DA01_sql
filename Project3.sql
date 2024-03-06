--1) Doanh thu theo từng ProductLine, Year  và DealSize?
select productline, year_id, dealsize,
sum(sales) as revenue
from sales_dataset_rfm_prj
group by productline, year_id, dealsize;

--2) Đâu là tháng có bán tốt nhất mỗi năm?
select month_id, year_id,
sum(sales) as revenue,
count(*) as order_number
from sales_dataset_rfm_prj
group by month_id, year_id
order by revenue desc;

/* Năm 2003: tháng 11
Năm 2004: tháng 11
Năm 2005: tháng 5 */

--3) Product line nào được bán nhiều ở tháng 11?
select month_id, productline,
sum(sales) as revenue,
count(*) as order_number
from sales_dataset_rfm_prj
where month_id=11
group by month_id, productline
order by order_number desc, revenue desc;

/* "Classic Cars" được bán nhiều nhất */

--4) Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? Xếp hạng các các doanh thu đó theo từng năm.
select *, rank() over (partition by year_id order by revenue desc)
from (
select YEAR_ID, PRODUCTLINE,
sum(sales) as revenue
from sales_dataset_rfm_prj
where country='UK'
group by YEAR_ID, PRODUCTLINE) a;

/* 2003: "Classic Cars"
2004: "Classic Cars"
2005: "Motorcycles" */

--5) Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
with customer_rfm as
(select customername, 
current_date-max(orderdate) as R,
count(distinct ordernumber) as F,
sum(sales) as M
from sales_dataset_rfm_prj
group by customername)

, rfm_score as
(select customername,
ntile(5) over (order by R desc) as r_score,
ntile(5) over (order by F) as f_score,
ntile(5) over (order by M) as m_score
from customer_rfm)

, rfm_final as
(select customername,
cast(r_score as varchar)||cast(f_score as varchar)||cast(m_score as varchar) as rfm_score
from rfm_score)

select segment, customername from
(select rfm_final.customername, segment_score.segment
from rfm_final
join segment_score on rfm_final.rfm_score=segment_score.scores) a
where segment='Champions'

/* Khách hàng tốt nhất (Champions):
"Anna's Decorations, Ltd"
"Reims Collectables"
"Dragon Souveniers, Ltd."
"Corporate Gift Ideas Co."
"Gift Depot Inc."
"La Rochelle Gifts"
"Diecast Classics Inc."
"Handji Gifts& Co"
"Tokyo Collectables, Ltd"
"Euro Shopping Channel"
"Mini Gifts Distributors Ltd."
"Souveniers And Things Co."
"Salzburg Collectables"
"The Sharp Gifts Warehouse"
"Danish Wholesale Imports"*/
