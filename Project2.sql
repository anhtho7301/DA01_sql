/*1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng
Thống kê tổng số lượng người mua và số lượng đơn hàng đã hoàn thành mỗi tháng ( Từ 1/2019-4/2022)
Output: month_year ( yyyy-mm) , total_user, total_order*/
select month_year,
count(distinct user_id) as total_user,
sum(case when status='Shipped' then 1 else 0 end) as total_order
from
(select *, FORMAT_DATE('%Y-%m', created_at) AS month_year
from bigquery-public-data.thelook_ecommerce.order_items
where created_at between '2019-01-01' and '2022-05-01')
group by month_year
order by month_year

/* >> Nhìn chung số lượng khách hàng và số lượng đơn hàng đều tăng. 
Đơn hàng đã hoàn thành không nhiều như số lượng khách hàng, có thể là do process order lâu, hoặc ship lâu.*/
  
/*2. Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
Thống kê giá trị đơn hàng trung bình và tổng số người dùng khác nhau mỗi tháng 
( Từ 1/2019-4/2022)
Output: month_year ( yyyy-mm), distinct_users, average_order_value*/
select month_year,
count(distinct user_id) as distinct_user,
sum(sale_price)/count(distinct order_id) as average_order_value
from
(select *, FORMAT_DATE('%Y-%m', created_at) AS month_year
from bigquery-public-data.thelook_ecommerce.order_items
where created_at between '2019-01-01' and '2022-05-01')
group by month_year
order by month_year

/* >> Số lượng khách hàng khác nhau tăng nhanh từ 2019 đến 2022. Giá trị trung bình của đơn hàng thì vẫn dao động ở một khoảng nhất định. */

/*3. Nhóm khách hàng theo độ tuổi
Tìm các khách hàng có trẻ tuổi nhất và lớn tuổi nhất theo từng giới tính ( Từ 1/2019-4/2022)
Output: first_name, last_name, gender, age, tag (hiển thị youngest nếu trẻ tuổi nhất, oldest nếu lớn tuổi nhất)*/
with young as
(select first_name, last_name, gender, age,
min(age) over (partition by gender) as min_age
from bigquery-public-data.thelook_ecommerce.users
where created_at between '2019-01-01' and '2022-05-01'
),
old as (
select first_name, last_name, gender, age,
max(age) over (partition by gender) as max_age
from bigquery-public-data.thelook_ecommerce.users
where created_at between '2019-01-01' and '2022-05-01'),
cte as
(select * from young
where age=min_age
union all
select * from old
where age=max_age)
SELECT *,
case when age=12 then 'youngest' else 'oldest' end as tag
FROM cte

------- Số lượng khách trẻ nhất:
select count(*) from
(
  with young as
(select first_name, last_name, gender, age,
min(age) over (partition by gender) as min_age
from bigquery-public-data.thelook_ecommerce.users
where created_at between '2019-01-01' and '2022-05-01'
)
select * from young
where age=min_age
)

------- Số lượng khách lớn nhất:
select count(*) from
(
  with old as
(select first_name, last_name, gender, age,
max(age) over (partition by gender) as max_age
from bigquery-public-data.thelook_ecommerce.users
where created_at between '2019-01-01' and '2022-05-01'
)
select * from old
where age=max_age
)

/* >> Khách hàng trẻ nhất 12 tuổi, số lượng 1050. Khách hàng lớn nhất 70 tuổi, số lượng 1087.*/

/*4.Top 5 sản phẩm mỗi tháng.
Thống kê top 5 sản phẩm có lợi nhuận cao nhất từng tháng (xếp hạng cho từng sản phẩm).*/
select * from 
(select *, 
dense_rank() over (partition by month_year order by profit desc) as dr
from
(select FORMAT_DATE('%Y-%m', oi.created_at) AS month_year, oi.product_id, 
p.name as product_name, oi.sale_price, p.cost,
oi.sale_price-p.cost as profit
from bigquery-public-data.thelook_ecommerce.order_items as oi
join bigquery-public-data.thelook_ecommerce.products as p 
on oi.product_id=p.id)
)
where dr<=5
order by month_year

/*5.Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục
Thống kê tổng doanh thu theo ngày của từng danh mục sản phẩm (category) trong 3 tháng qua ( giả sử ngày hiện tại là 15/4/2022)*/
select * from
(select DATE(oi.created_at) AS dates, p.category as product_categories, 
sum(oi.sale_price) as revenue
from bigquery-public-data.thelook_ecommerce.order_items as oi
join bigquery-public-data.thelook_ecommerce.products as p 
on oi.product_id=p.id
group by dates, product_categories)
where dates between '2023-12-04' and '2024-03-04'
order by dates

------------------------------------P2-----------------------------------------------------

create view vw_ecommerce_analyst as
(with a as
(select distinct FORMAT_DATE('%Y-%m', o.created_at) as Month,
extract(year from o.created_at) as Year,
p.category as product_category,
round(sum(oi.sale_price) over (partition by p.category order by FORMAT_DATE('%Y-%m', o.created_at)),2) as TPV,
count(*) over (partition by p.category order by FORMAT_DATE('%Y-%m', o.created_at)) as TPO,
round(sum(p.cost) over (partition by p.category order by FORMAT_DATE('%Y-%m', o.created_at)),2) as total_cost
from bigquery-public-data.thelook_ecommerce.order_items as oi
join bigquery-public-data.thelook_ecommerce.orders as o
on oi.order_id=o.order_id
join bigquery-public-data.thelook_ecommerce.products as p
on oi.product_id=p.id
order by Month)

select Month, Year, product_category, TPV, TPO,
round(((TPV-lag(TPV) over (partition by product_category order by Month))/
lag(TPV) over (partition by product_category order by Month))*100,2)||'%' as revenue_growth,
round(((TPO-lag(TPO) over (partition by product_category order by Month))/
lag(TPO) over (partition by product_category order by Month))*100,2)||'%' as order_growth,
total_cost,
round(TPV-total_cost,2) as total_profit,
round((TPV-total_cost)/total_cost,2) as profit_to_cost_ratio
from a)

---------------------------------------cohort analysis----------------------------------------------

with table_index as
(select user_id, sale_price,
FORMAT_DATE('%Y-%m', date(first_date)) as cohort_date,
created_at,
cast(extract(year from created_at)-extract(year from first_date) as decimal)*12
+cast(extract(month from created_at)-extract(month from first_date) as decimal)+1 as index,
from
(select user_id, sale_price, 
min(created_at) over (partition by user_id) as first_date,
created_at
from bigquery-public-data.thelook_ecommerce.order_items
))
  
, cohort_data as
(select cohort_date, index, 
count(distinct user_id) as cnt,
round(sum(sale_price),2) as revenue
from table_index
where index<=4
group by cohort_date, index),

customer_cohort as
(select 
cohort_date,
sum(case when index=1 then cnt else 0 end ) as m1,
sum(case when index=2 then cnt else 0 end ) as m2,
sum(case when index=3 then cnt else 0 end ) as m3,
sum(case when index=4 then cnt else 0 end ) as m4
from cohort_data
group by cohort_date
order by cohort_date),

retention_cohort as
(select cohort_date,
round(100.00* m1/m1,2)||'%' as m1,
round(100.00* m2/m1,2)||'%' as m2,
round(100.00* m3/m1,2)||'%' as m3,
round(100.00* m4/m1,2)||'%' as m4
from customer_cohort
order by cohort_date)

--churn_cohort:
select cohort_date,
(100-round(100.00* m1/m1,2))||'%' as m1,
(100-round(100.00* m2/m1,2))||'%' as m2,
(100-round(100.00* m3/m1,2))||'%' as m3,
(100-round(100.00* m4/m1,2))||'%' as m4
from customer_cohort
order by cohort_date

Link sheet cohort: https://docs.google.com/spreadsheets/d/1ops75XMiUj-gwWv6A1bkCexqz_YQGPmoHN8PVTX8kNc/edit?usp=sharing

/*Insight:
- Công ty có tăng số lượng khách hàng theo thời gian từ 2019-2024, nhưng hầu hết là khách hàng chỉ mua 1 lần.
Số lượng khách hàng mới tăng mạnh, chứng tỏ TheLook rất chú tâm vào quảng cáo trang web của họ ở các nền tảng
và điều này có kết quả rõ rệt.
- Công ty gần như không có return customers trong các năm đầu (2019-2020) nhưng con số này đã tăng trong những năm
gần đây. Tuy nhiên thì so với lượng khách hàng mới thì số lượng return customers chỉ bằng chưa đến một nửa.
- TheLook có thể triển khai các marketing campaign để vừa thu hút khách hàng mới, vừa giữ chân khách hàng cũ:
+ Đầu tư vào social media content, tương tác với khách hàng tiềm năng, influencer marketing để tăng độ nhận diện
thương hiệu,...
+ Tương tác với khách hàng cũ: tạo email list, follow up sau các lần mua hàng, gửi nhắc nhở về đồ trong giỏ hàng,
discount vào dịp đặc biệt như sinh nhật khách...*/

