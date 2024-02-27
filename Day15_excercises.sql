--ex1:
SELECT EXTRACT(year from transaction_date) AS year,
product_ID,
spend AS curr_year_spend,
LAG(spend) OVER (PARTITION BY product_id ORDER BY transaction_date),
ROUND(((spend-LAG(spend) OVER (PARTITION BY product_id ORDER BY transaction_date))/
LAG(spend) OVER (PARTITION BY product_id ORDER BY transaction_date))*100,2) AS yoy_rate
FROM user_transactions
ORDER BY product_id,year

--ex2:
SELECT DISTINCT card_name,
FIRST_VALUE(issued_amount) OVER (PARTITION BY card_name ORDER BY issue_year,issue_month)
AS issued_amount
FROM monthly_cards_issued
ORDER BY issued_amount DESC

--ex3:
SELECT user_id, spend, transaction_date
FROM
(SELECT user_id, spend, transaction_date,
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date) AS stt
FROM transactions) AS a
WHERE stt=3

--ex4:
SELECT transaction_date,user_id, purchase_count
FROM
(SELECT transaction_date,user_id,
COUNT(product_id) OVER (PARTITION BY user_id ORDER BY transaction_date DESC) 
AS purchase_count,
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date DESC)
AS stt
FROM user_transactions) AS a
WHERE stt=1
ORDER BY transaction_date

--ex5:
WITH cte as 
(SELECT user_id, tweet_date, tweet_count,
COALESCE(LAG(tweet_count) OVER (PARTITION BY user_id ORDER BY tweet_date),0) AS lag2D,
COALESCE(LAG(tweet_count,2) OVER (PARTITION BY user_id ORDER BY tweet_date),0) AS lag3D
FROM tweets)
SELECT user_id, tweet_date, 
ROUND(CAST((tweet_count+lag2D+laG3D)as decimal)/(1 + 
(CASE 
  WHEN lag2D!=0 then 1 
  ELSE 0 
END) + 
(CASE 
  WHEN lag3D!=0 then 1 
  ELSE 0 
END)),2) AS rolling_avg_3d
FROM cte

--ex6:
SELECT
COUNT(*) FROM
(SELECT merchant_id, credit_card_id, amount,
EXTRACT(EPOCH FROM transaction_timestamp)- 
EXTRACT(EPOCH FROM time2) AS time
FROM 
(SELECT merchant_id, credit_card_id, transaction_timestamp, amount,
LAG(transaction_timestamp) 
OVER (PARTITION BY merchant_id,credit_card_id,amount 
ORDER BY transaction_timestamp)
AS time2
FROM transactions) AS b1
WHERE EXTRACT(EPOCH FROM transaction_timestamp-time2)<=10*60) AS b2

--ex7:
SELECT category, product, total_spend
FROM
(SELECT *, 
ROW_NUMBER() OVER (PARTITION BY category 
ORDER BY total_spend DESC) AS rank
FROM (
SELECT category, product,
SUM(spend) AS total_spend
FROM product_spend
WHERE EXTRACT(year from transaction_date) = '2022'
GROUP BY product, category) AS t1
) AS t2
WHERE rank=1 or rank=2

--ex8:
SELECT *
FROM (SELECT a.artist_name, 
DENSE_RANK() OVER (ORDER BY COUNT(s.song_id) desc) AS artist_rank 
FROM artists AS a
JOIN songs AS s ON a.artist_id=s.artist_id
JOIN global_song_rank AS g ON s.song_id=g.song_id
WHERE g.rank<=10
GROUP BY a.artist_name
ORDER BY artist_rank) AS t1
WHERE artist_rank <=5
