--ex1:
SELECT Name
FROM STUDENTS
WHERE Marks >75
ORDER BY RIGHT(Name, 3), ID

--ex2:
SELECT user_id,
CONCAT(UPPER(LEFT(name,1)),LOWER(RIGHT(name,LENGTH(name)-1))) AS name
FROM Users

--ex3:
SELECT manufacturer,
CONCAT('$',ROUND(SUM(total_sales)/1000000,0),' million')
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY ROUND(SUM(total_sales),0) DESC, manufacturer

--ex4:
SELECT 
EXTRACT(month from submit_date) AS mth,
product_id AS product,
ROUND(AVG(stars),2) AS avg_stars
FROM reviews
GROUP BY mth, product
ORDER BY mth, product

--ex5:
SELECT
sender_id,
COUNT(message_id) AS message_count
FROM messages
WHERE sent_date BETWEEN '2022-08-01' AND '2022-09-01'
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2

--ex6:
SELECT tweet_id
FROM Tweets
WHERE LENGTH(content)>15

--ex7:
SELECT
activity_date AS day,
COUNT(DISTINCT user_id) AS active_users
FROM Activity
WHERE activity_date BETWEEN '2019-06-28' AND '2019-07-27'
GROUP BY day

--ex8:
SELECT 
COUNT(DISTINCT id)
FROM employees
WHERE EXTRACT(month from joining_date) between 1 and 7
AND EXTRACT(year from joining_date)=2022

--ex9:
SELECT POSITION('a' in first_name)
FROM worker
WHERE first_name='Amitah'

--ex10:
SELECT title,
SUBSTRING(title FROM LENGTH(winery)+2 FOR 4)
FROM winemag_p2
WHERE country='Macedonia'
