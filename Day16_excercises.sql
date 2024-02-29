--ex1:
WITH cte AS 
(SELECT COUNT(DISTINCT customer_id) AS all_customers
FROM Delivery)
SELECT ROUND(((
SELECT COUNT(*) AS immediate_orders FROM
(SELECT *,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS stt
FROM Delivery) AS a
WHERE order_date=customer_pref_delivery_date AND stt=1)/
all_customers)*100,2) AS immediate_percentage
FROM cte

--ex2:
WITH a AS
(SELECT COUNT(DISTINCT player_id) AS total
FROM Activity)
SELECT ROUND((
SELECT COUNT(DISTINCT player_id) AS cons FROM
(SELECT player_id,
DATEDIFF(event_date,
LAG(event_date) OVER (PARTITION BY player_id ORDER BY event_date)) AS date_diff,
RANK() OVER (PARTITION BY player_id ORDER BY event_date) AS stt
FROM Activity) AS b
WHERE date_diff=1 AND stt=2)/ total,2) AS fraction
FROM a

--ex3:
SELECT id, 
COALESCE(CASE
    WHEN id%2!=0 THEN LEAD(student) OVER (ORDER BY id)
    ELSE LAG(student) OVER (ORDER BY id)
END,
(SELECT student
FROM seat
WHERE id=(SELECT MAX(id) FROM seat))) AS student
FROM Seat
ORDER BY id

--ex4:
SELECT c.visited_on, SUM(t.amount) as amount , ROUND((SUM(t.amount)/7),2) AS average_amount
FROM (SELECT visited_on, SUM(amount) as amount
FROM Customer GROUP BY visited_on ) as c, (SELECT visited_on, SUM(amount) as amount
FROM Customer GROUP BY visited_on ) as t
WHERE c.visited_on>=t.visited_on and DATEDIFF(c.visited_on,t.visited_on)<=6
GROUP BY c.visited_on 
HAVING COUNT(DISTINCT t.visited_on)=7

--ex5:
SELECT ROUND(SUM(tiv_2016),2) AS tiv_2016
FROM insurance
WHERE tiv_2015 IN
(SELECT tiv_2015 from insurance
GROUP BY tiv_2015
HAVING COUNT(tiv_2015)!=1)
AND CONCAT(lat,lon) NOT IN
(SELECT CONCAT(lat,lon) from insurance
group by lat, lon
having count(concat(lat,lon))!=1)

--ex6:
SELECT Department, Employee, Salary from
(SELECT e.name AS Employee, d.name AS Department, salary,
DENSE_RANK() OVER(PARTITION BY e.departmentid ORDER BY e.salary DESC) AS ran
FROM employee AS e
JOIN department AS d ON e.departmentid=d.id) AS a
WHERE ran <=3

--ex7:
SELECT person_name from
(SELECT person_name,
RANK() OVER (ORDER BY turn DESC,person_name DESC)
FROM (
SELECT person_name, turn,
SUM(weight) OVER (order by turn) AS lim
FROM queue
GROUP BY person_name, turn) AS a
WHERE lim<=1000) AS b
LIMIT 1

--ex8:
WITH a AS
(SELECT DISTINCT product_id,
FIRST_VALUE(new_price) OVER (PARTITION BY product_id ORDER BY change_date DESC) AS price
FROM Products
WHERE change_date<='2019-08-16'),
b AS
(SELECT DISTINCT product_id,
CASE WHEN change_date>'2019-08-16' THEN '10'
END AS price
FROM products),
c AS
(SELECT product_id, price, 1 AS tab_or FROM a
UNION ALL
SELECT product_id, price, 2 AS tab_or FROM b),
d AS
(SELECT *,
ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY tab_or) AS rn
FROM c)
SELECT product_id, price FROM d
WHERE rn=1
