--ex1:
SELECT
SUM(CASE
  WHEN device_type='laptop' THEN 1
  ELSE 0
END) AS laptop_views,
SUM(CASE
  WHEN device_type IN ('tablet','phone') THEN 1
  ELSE 0
END) mobile_views
FROM viewership

--ex2:
SELECT x,y,z,
CASE
    WHEN x+y>z AND x+z>y AND z+y>x THEN 'Yes'
    ELSE 'No'
END AS triangle
FROM Triangle

--ex3:
SELECT
ROUND(((SUM(CASE
  WHEN call_category IS NULL OR call_category='n/a' THEN 1
  ELSE 0
END))/COUNT(case_id))*100,1) AS call_percentage
FROM callers

--ex4:
SELECT name 
FROM Customer
WHERE referee_id <> 2 OR referee_id IS NULL

--ex5:
SELECT
CASE
    WHEN survived=1 THEN 'survivors'
    ELSE 'non-survivors'
END AS category,
SUM(CASE
    WHEN pclass=1 THEN 1
    ELSE 0
END) AS first_class,
SUM(CASE
    WHEN pclass=2 THEN 1
    ELSE 0
END) AS second_class,
SUM(CASE
    WHEN pclass=3 THEN 1
    ELSE 0
END) AS third_class
FROM titanic
GROUP BY category
