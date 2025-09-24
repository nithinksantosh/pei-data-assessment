
https://sqliteonline.com/

-- PK duplicate checks
SELECT Customer_ID, COUNT(*) c FROM customer GROUP BY 1 HAVING c > 1;      
SELECT Order_ID, COUNT(*) c    FROM orders    GROUP BY 1 HAVING c > 1; 
SELECT Shipping_ID, COUNT(*) c FROM shipping  GROUP BY 1 HAVING c > 1; 




-- null check
SELECT
  SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN First IS NULL THEN 1 ELSE 0 END) AS null_first,
  SUM(CASE WHEN Last IS NULL THEN 1 ELSE 0 END) AS null_last,
  SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS null_age,
  SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) AS null_country
FROM customer;



-- Referential integrity? are there Pkeys in the foreign key, no orphan keys
SELECT o.* FROM orders o
LEFT JOIN customer c ON o.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL; 

SELECT s.* FROM shipping s
LEFT JOIN customer c ON s.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL; 



-- Business rules
SELECT COUNT(*) FROM orders WHERE Amount <= 0;
SELECT COUNT(*) FROM shipping WHERE Status NOT IN ('Pending','Delivered'); 



-- checking for anomalies in the data, updating them. checking for double spaces, dangling spaces.

SELECT Customer_ID, First
FROM customer
WHERE First GLOB '*[0-9]*' or First GLOB '*[]!@#$%^&*()_+=\[{};:"''|,./<>?\\]*';

SELECT Customer_ID, last
FROM customer
WHERE Last GLOB '*[0-9]*' or last GLOB '*[]!@#$%^&*()_+=\[{};:"''|,./<>?\\]*';



UPDATE customer
SET first = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Last,
          '0','o'),'1','i'),'3','e'),'4','a'),'5','s'),'7','t'),'@','a'),'!','i')
WHERE first GLOB '*[0-9]*' or First GLOB '*[]!@#$%^&*()_+=\[{};:"''|,./<>?\\]*';

UPDATE customer
SET Last = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Last,
          '0','o'),'1','i'),'3','e'),'4','a'),'5','s'),'7','t'),'@','a'),'!','i')
WHERE Last GLOB '*[0-9]*' or last GLOB '*[]!@#$%^&*()_+=\[{};:"''|,./<>?\\]*';


SELECT COUNT(*) AS double_spaces
FROM customer
WHERE First LIKE '%  %' OR Last LIKE '%  %';


SELECT COUNT(*) AS needs_trim
FROM customer
WHERE TRIM(First) <> First OR TRIM(Last) <> Last;