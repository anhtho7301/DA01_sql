--ex1:
WITH new_table
AS
(SELECT company_id,
title,
description,
COUNT(job_id) AS job_count
FROM job_listings
GROUP BY company_id,
title,
description)
SELECT COUNT(job_count)
FROM new_table
WHERE job_count>=2

--ex2:
WITH app
AS (SELECT 
category,
product,
SUM(spend) AS total_spend
FROM product_spend
WHERE EXTRACT(year from transaction_date) = '2022'
AND category='appliance'
GROUP BY product, category
ORDER BY total_spend DESC
LIMIT 2),
elec AS (SELECT 
category,
product,
SUM(spend) AS total_spend
FROM product_spend
WHERE EXTRACT(year from transaction_date) = '2022'
AND category='electronics'
GROUP BY product, category
ORDER BY total_spend DESC
LIMIT 2)
SELECT * FROM app
UNION
SELECT * FROM elec
ORDER BY category, total_spend DESC

--ex3:
WITH new_table
AS (SELECT
policy_holder_id,
COUNT(case_id) AS count_call
FROM callers
GROUP BY policy_holder_id
HAVING COUNT(case_id)>=3)
SELECT COUNT(policy_holder_id)
FROM new_table

--ex4:
SELECT pages.page_id
FROM pages
LEFT JOIN page_likes AS likes
ON pages.page_id=likes.page_id
WHERE likes.page_id IS NULL
ORDER BY page_id

--ex5:
WITH a AS
(SELECT user_id,
COUNT(event_type) AS count_event,
EXTRACT (month from event_date) AS month
FROM user_actions
WHERE EXTRACT (month from event_date) IN ('6','7')
GROUP BY user_id, month)
SELECT 7 AS month,
COUNT(DISTINCT user_id) AS monthly_active_users
FROM a
WHERE month <> 7

--ex6:
SELECT
CONCAT(LEFT(EXTRACT(year_month from trans_date),4),'-',RIGHT(EXTRACT(year_month from trans_date),2)) AS month,
country,
COUNT(state) AS trans_count,
SUM(amount) AS trans_total_amount,
SUM(CASE
    WHEN state='approved' THEN 1
    ELSE 0
END) AS approved_count,
SUM(CASE
    WHEN state='approved' THEN amount
    ELSE 0
END) AS approved_total_amount
FROM Transactions
GROUP BY month, country

--ex7:
SELECT DISTINCT product_id,
year AS first_year,
quantity,
price
FROM Sales
WHERE (product_id, year) IN
(SELECT product_id, MIN(year)
FROM Sales 
GROUP BY product_id)

--ex8:
SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(DISTINCT product_key) FROM Product)

--ex9:
SELECT employee_id
FROM Employees
WHERE NOT manager_id IN 
(SELECT employee_id FROM Employees)
AND salary<30000
ORDER BY employee_id

--ex10: same ex1
  
--ex11:
WITH a AS
(SELECT
u.name AS results
FROM MovieRating AS r
JOIN Users AS u
ON r.user_id=u.user_id
GROUP BY u.name
ORDER BY COUNT(r.rating) DESC, name
LIMIT 1),
b AS
(SELECT
m.title AS results
FROM MovieRating AS r
JOIN Movies AS m
ON r.movie_id=m.movie_id
WHERE EXTRACT(year_month from created_at)=202002
GROUP BY m.title
ORDER BY AVG(r.rating) DESC, title
LIMIT 1)
SELECT results FROM a
UNION ALL
SELECT results FROM b

--ex12:
WITH a AS
(SELECT requester_id AS id
    FROM RequestAccepted
    UNION ALL
    SELECT accepter_id AS id
    FROM RequestAccepted)
SELECT id, COUNT(id) AS num
FROM a
GROUP BY id
ORDER BY COUNT(id) DESC
LIMIT 1
