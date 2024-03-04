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

