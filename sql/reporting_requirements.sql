-- Queries for reporting requirement using source tables

-- the total amount spent and the country for the Pending delivery status for each country.

with d_shipping_status as (
WITH customer_shipping_status AS (
  SELECT
    Customer_ID,
    CASE
      WHEN SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) > 0 THEN 'Pending'
      WHEN SUM(CASE WHEN Status = 'Delivered' THEN 1 ELSE 0 END) > 0 THEN 'Delivered'
      ELSE 'NoRecord'  
    END AS status
  FROM shipping
  GROUP BY Customer_ID
)
SELECT
  c.Customer_ID,
  COALESCE(s.status, 'NoRecord') AS current_status
FROM customer c
LEFT JOIN customer_shipping_status s ON s.Customer_ID = c.Customer_ID
)
SELECT c.Country,
       SUM(o.Amount) AS total_amount_spent
FROM orders o
JOIN customer c ON c.Customer_ID = o.Customer_ID
JOIN d_shipping_status p ON p.Customer_ID = o.Customer_ID and p.current_status='Pending'
GROUP BY c.Country
ORDER BY total_amount_spent DESC;


-- the total number of transactions, total quantity sold, and total amount spent for each customer, along with the product details.

with f_order as (
select o.Order_ID,c.Customer_ID,o.Item,o.Amount,c.Country,1 as quantity
from orders o
left join Customer c on o.Customer_ID=c.customer_id
)
select c.Customer_ID,concat(c.First,' ',c.Last) name,item,
count(Order_ID) as total_transactions,
sum(quantity) as total_quantity,
sum(amount) as total_amount
from f_order f
join Customer c on f.Customer_ID = c.Customer_ID
group by 1,2,3;


-- the maximum product purchased for each country.

WITH f_order AS (
  SELECT o.Order_ID, c.Customer_ID, o.Item, o.Amount, c.Country, 1 AS quantity
  FROM orders o
  LEFT JOIN Customer c ON o.Customer_ID = c.Customer_ID
),
agg AS (
  SELECT Country, Item, SUM(quantity) AS qty
  FROM f_order
  GROUP BY Country, Item
),
ranked AS (
  SELECT Country, Item, qty,
         ROW_NUMBER() OVER (PARTITION BY Country ORDER BY qty DESC, Item ASC) AS rn
  FROM agg
)
SELECT Country,
       Item  AS max_product,
       qty   AS max_quantity
FROM ranked
WHERE rn = 1
ORDER BY Country;


-- the most purchased product based on the age category less than 30 and above 30.

WITH f_order AS (
  SELECT o.Order_ID,
         c.Customer_ID,
         o.Item,
         o.Amount,
         c.Age,
         1 AS quantity
  FROM orders o
  LEFT JOIN Customer c ON o.Customer_ID = c.Customer_ID
),
agg AS (
  SELECT
    CASE WHEN Age < 30 THEN '<30' ELSE '>=30' END AS age_category,
    Item,
    SUM(quantity) AS qty
  FROM f_order
  GROUP BY age_category, Item
),
ranked AS (
  SELECT
    age_category, Item, qty,
    ROW_NUMBER() OVER (PARTITION BY age_category ORDER BY qty DESC, Item ASC) AS rn
  FROM agg
)
SELECT age_category,
       Item  AS most_purchased_product,
       qty   AS total_quantity
FROM ranked
WHERE rn = 1
ORDER BY age_category;


-- the country that had minimum transactions and sales amount.

WITH f_order AS (
  SELECT o.Order_ID,
         c.Country,
         o.Amount,
         1 AS quantity
  FROM orders o
  JOIN Customer c ON c.Customer_ID = o.Customer_ID
),
agg AS (
  SELECT
    Country,
    COUNT(*)            AS transactions,   
    SUM(Amount)         AS sales_amount
  FROM f_order
  GROUP BY Country
)
SELECT Country, transactions, sales_amount
FROM agg
ORDER BY transactions ASC, sales_amount ASC
LIMIT 1; 