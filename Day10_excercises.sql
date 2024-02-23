--ex1:
SELECT COUNTRY.Continent,
FLOOR(AVG(CITY.Population))
FROM COUNTRY
JOIN CITY
ON CITY.CountryCode=COUNTRY.Code
GROUP BY COUNTRY.Continent

--ex2:
SELECT
ROUND((CAST((SUM(CASE
  WHEN texts.signup_action='Confirmed' THEN 1
  ELSE 0
END)) AS DECIMAL)/COUNT(emails.email_id)),2) AS confirm_rate
FROM emails
JOIN texts
ON emails.email_id=texts.email_id

--ex3:
SELECT age.age_bucket,
ROUND((SUM(CASE
  WHEN act.activity_type = 'open' THEN act.time_spent
  ELSE 0
END)/
SUM(CASE
  WHEN act.activity_type IN ('open','send') THEN act.time_spent
  ELSE 0
END))*100.0,2) AS open_perc,
ROUND((SUM(CASE
  WHEN act.activity_type = 'send' THEN act.time_spent
  ELSE 0
END)/
SUM(CASE
  WHEN act.activity_type IN ('open','send') THEN act.time_spent
  ELSE 0
END))*100.0,2) AS send_perc
FROM age_breakdown AS age
JOIN activities AS act
ON age.user_id=act.user_id
GROUP BY age.age_bucket

--ex4:
SELECT cus.customer_id
FROM customer_contracts AS cus
JOIN products AS prd
ON cus.product_id=prd.product_id
GROUP BY cus.customer_id
HAVING COUNT(DISTINCT prd.product_category)=3

--ex5:
SELECT mng.employee_id, 
mng.name AS name, 
COUNT(emp.reports_to) AS reports_count, 
ROUND(AVG(emp.age),0) AS average_age
FROM Employees AS emp
JOIN Employees AS mng
ON emp.reports_to=mng.employee_id

--ex6:
SELECT prd.product_name,
SUM(ord.unit) AS unit
FROM Products AS prd
JOIN Orders AS ord
ON prd.product_id=ord.product_id
WHERE EXTRACT(month from ord.order_date)='02'
GROUP BY prd.product_name
HAVING SUM(ord.unit)>=100

--ex7:
SELECT pages.page_id
FROM pages
LEFT JOIN page_likes AS likes
ON pages.page_id=likes.page_id
WHERE likes.page_id IS NULL

/* Mid term*/
--q1:
SELECT DISTINCT replacement_cost
FROM film
ORDER BY replacement_cost
  
--q2:
SELECT
SUM(CASE
	WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 1
	ELSE 0
END)
FROM film

--q3:
SELECT f.title,
f.length,
c.name
FROM film AS f
JOIN film_category AS fc
ON f.film_id=fc.film_id
JOIN category AS c
ON fc.category_id=c.category_id
WHERE c.name IN ('Drama','Sports')
ORDER BY length DESC

--q4:
SELECT COUNT(f.title),
c.name
FROM film AS f
JOIN film_category AS fc
ON f.film_id=fc.film_id
JOIN category AS c
ON fc.category_id=c.category_id
GROUP BY c.name
ORDER BY COUNT(f.title) DESC

--q5:
SELECT a.first_name,
a.last_name,
COUNT(a.actor_id)
FROM actor AS a
JOIN film_actor AS fa
ON a.actor_id=fa.actor_id
GROUP BY a.first_name, a.last_name
ORDER BY COUNT(a.actor_id) DESC

--q6:
SELECT COUNT(a.address)
FROM address as a
LEFT JOIN customer AS c
ON a.address_id=c.address_id
WHERE c.address_id IS NULL

--q7:
SELECT c.city,
SUM(p.amount)
FROM city AS c
JOIN address AS a
ON c.city_id=a.city_id
JOIN customer AS cus
ON a.address_id=cus.address_id
JOIN payment AS p
ON cus.customer_id=p.customer_id
GROUP BY c.city
ORDER BY SUM(p.amount) DESC

--q8:
SELECT c.city,
coun.country,
SUM(p.amount)
FROM country AS coun
JOIN city AS c
ON coun.country_id=c.country_id
JOIN address AS a
ON c.city_id=a.city_id
JOIN customer AS cus
ON a.address_id=cus.address_id
JOIN payment AS p
ON cus.customer_id=p.customer_id
GROUP BY c.city, coun.country
ORDER BY SUM(p.amount) DESC
