------------------ Creating tables----------------------
CREATE TABLE customers(
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50),
    region VARCHAR(50),
    signup_date DATE
);

CREATE TABLE products(
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(100),
    sub_category VARCHAR(50),
    cost_price NUMERIC(10,2)
);

CREATE TABLE orders(
    order_id VARCHAR(20) PRIMARY KEY,
    order_date DATE,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    quantity INT,
    selling_price NUMERIC(10,2),
    discount_percent NUMERIC(5,2)
);
--printing tables
select * from customers;
select * from orders;
select * from products;

------------------------------Cleaning--------------------
-- Checking for no.of rows
select count(*) from customers;
select count(*) from orders;
select count(*) from products;

-- Checking for nulls
SELECT * FROM customers
WHERE customer_id isnull;

SELECT * FROM orders
WHERE order_id ISNULL;

SELECT * FROM products
WHERE product_id ISNULL;

-- Orders with missing customers
SELECT COUNT(*) 
FROM orders o
LEFT JOIN customers c 
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Orders with missing customers
SELECT COUNT(*) 
FROM orders o
LEFT JOIN customers c 
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

----Joining orders and products tables and creating revenue and profit column------------------

SELECT o.order_id,
--net revenue
round((o.quantity * o.selling_price)
- (o.quantity * o.selling_price * o.discount_percent/100),2) AS revenue,
--profit
ROUND(
((o.quantity * o.selling_price)
- (o.quantity * o.selling_price * o.discount_percent/100)) - (o.quantity * p.cost_price),2) AS profit
FROM orders o
JOIN products p
ON o.product_id = p.product_id;

-------------Checking for loss making orders-------------------
SELECT o.order_id,o.selling_price,p.cost_price,
o.discount_percent,o.quantity,
ROUND((o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent / 100),2)
AS revenue,

ROUND(
((o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent / 100))- (o.quantity * p.cost_price),2)
AS profit

FROM orders o
JOIN products p
ON o.product_id = p.product_id

WHERE 
((o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent / 100))
<
(o.quantity * p.cost_price);

---------average discount for loss-making orders and profitable orders----
SELECT 
CASE 
WHEN ( (o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent / 100) )
- (o.quantity * p.cost_price) < 0 
THEN 'Loss'
ELSE 'Profit'
END AS order_status,

AVG(o.discount_percent) AS avg_discount

FROM orders o
JOIN products p
ON o.product_id = p.product_id

GROUP BY order_status;

-- Category performance analysis----------
SELECT p.category,
ROUND( SUM (
( (o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent / 100) )
- (o.quantity * p.cost_price) ),2) 
AS total_profit,

ROUND( SUM (
(o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent / 100) ),2)
AS total_revenue,

COUNT(o.order_id) AS total_orders

FROM orders o
JOIN products p
ON o.product_id = p.product_id

GROUP BY p.category
ORDER BY total_profit DESC;

-- Calculating profit margin(Profit/Net revenue)-----------------
SELECT p.category,
ROUND( SUM(
((o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent / 100) )
- (o.quantity * p.cost_price) )
/
SUM( (o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent / 100) ), 4)
AS profit_margin
FROM orders o
JOIN products p
ON o.product_id = p.product_id

GROUP BY p.category
ORDER BY profit_margin DESC;

-- Discount Analysis(Which category has more discount)------------
SELECT p.category,
ROUND(AVG(o.discount_percent),2) AS avg_discount
FROM orders o
JOIN products p
ON o.product_id = p.product_id

GROUP BY p.category
ORDER BY avg_discount DESC;

-- Top 10 customers by total_revenue-------------------
SELECT c.customer_id,c.customer_name,
ROUND(sum((o.quantity * o.selling_price)-(o.quantity * o.selling_price * o.discount_percent/100)),2)
AS total_revenue

FROM orders o
JOIN customers c
ON o.customer_id=c.customer_id

GROUP BY c.customer_id,c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 customers by total_profit--------------
SELECT c.customer_id,c.customer_name,
ROUND(SUM(
( (o.quantity * o.selling_price)-(o.quantity * o.selling_price * o.discount_percent/100) )
-(o.quantity * p.cost_price) ),2) 
AS total_profit

FROM orders o
JOIN customers c 
ON o.customer_id=c.customer_id
JOIN products p
ON o.product_id=p.product_id

GROUP BY c.customer_id,c.customer_name
ORDER BY total_profit DESC
LIMIT 10;

-- Profit margin per customer----------------------------------
SELECT c.customer_id,c.customer_name,
ROUND(SUM(
((o.quantity * o.selling_price)-(o.quantity * o.selling_price * o.discount_percent/100))
-(o.quantity * p.cost_price))
/
SUM(
(o.quantity * o.selling_price)-(o.quantity * o.selling_price * o.discount_percent/100)),4)
AS profit_margin

FROM orders o
JOIN customers c
ON o.customer_id=c.customer_id
JOIN products p
ON o.product_id=p.product_id

GROUP BY c.customer_id,c.customer_name
ORDER BY profit_margin DESC
LIMIT 10;

-- Monthly revenue and profit trend--------------------------------------
SELECT DATE_TRUNC('month', o.order_date) AS month,
ROUND(SUM(
(o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent/100)),2)
AS monthly_revenue,

ROUND(SUM(
((o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent/100))
- (o.quantity * p.cost_price)),2)
AS monthly_profit

FROM orders o
JOIN products p 
ON o.product_id = p.product_id

GROUP BY month
ORDER BY month;

-- Seasonality of months-------------------------------
SELECT EXTRACT(month from order_date) AS month_number,
ROUND(SUM((o.quantity * o.selling_price)
-(o.quantity * o.selling_price *o.discount_percent/100)),2)
AS total_revenue

FROM orders o
GROUP BY month_number
ORDER BY month_number;

SELECT 
    EXTRACT(MONTH FROM order_date) AS month_number,
    
    ROUND(SUM(
        (quantity * selling_price) 
        - (quantity * selling_price * discount_percent/100)
    ),2) AS total_revenue

FROM orders
GROUP BY month_number
ORDER BY month_number;

-- Which region generates highest revenue-----------------------------------
SELECT c.region,
ROUND(SUM( (o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent/100) ),2)
AS total_revenue,

ROUND(SUM((
(o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent/100) )
- (o.quantity * p.cost_price)),2)
AS total_profit

FROM orders o
JOIN customers c 
ON o.customer_id = c.customer_id
JOIN products p 
ON o.product_id = p.product_id

GROUP BY c.region
ORDER BY total_revenue DESC;

-- Checking regions with revenue,profit,profit margin,average discount--------------------
SELECT c.region,
ROUND(SUM(
(o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent/100)),2) 
AS total_revenue,

ROUND(SUM( (
(o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent/100) )
- (o.quantity * p.cost_price)),2)
AS total_profit,

ROUND(SUM( (
(o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent/100) )
- (o.quantity * p.cost_price) )
/
SUM(
(o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent/100)),4)
AS profit_margin,

ROUND(AVG(o.discount_percent),2) AS avg_discount

FROM orders o
JOIN customers c 
ON o.customer_id = c.customer_id
JOIN products p 
ON o.product_id = p.product_id

GROUP BY c.region
ORDER BY total_revenue DESC;

-- Customer segmentation table----------------------------------
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        COUNT(o.order_id) AS order_count,
		MAX(o.order_date) AS last_order_date,
        ROUND(SUM(
            (o.quantity * o.selling_price) 
            - (o.quantity * o.selling_price * o.discount_percent/100)
        ),3) AS total_revenue,
        ROUND(SUM(
            (
                (o.quantity * o.selling_price) 
                - (o.quantity * o.selling_price * o.discount_percent/100)
            )
            - (o.quantity * p.cost_price)
        ),3) AS total_profit
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN products p ON o.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
),

avg_values AS (
    SELECT 
        AVG(total_revenue) AS avg_revenue,
        AVG(total_profit/NULLIF(total_revenue,0)) AS avg_margin,
        AVG(order_count) AS avg_orders
    FROM customer_metrics
),

segmented AS(
SELECT 
    cm.*,
    ROUND(cm.total_profit/cm.total_revenue,4) AS profit_margin,

    CASE
        WHEN cm.total_revenue >= av.avg_revenue 
             AND (cm.total_profit/cm.total_revenue) >= av.avg_margin
             AND cm.order_count >= av.avg_orders
        THEN 'VIP - High Value Loyal'

        WHEN cm.total_revenue >= av.avg_revenue 
             AND (cm.total_profit/cm.total_revenue) < av.avg_margin
        THEN 'High Revenue - Discount Dependent'

        WHEN cm.total_revenue < av.avg_revenue 
             AND (cm.total_profit/cm.total_revenue) >= av.avg_margin
        THEN 'Efficient but Low Volume'

        ELSE 'Low Value Customer'
    END AS customer_segment

FROM customer_metrics cm, avg_values av
)
SELECT 
    customer_segment,
    COUNT(customer_id) AS number_of_customers
FROM segmented
GROUP BY customer_segment
ORDER BY number_of_customers DESC;

-- Which segment contributes most revenue percent---------------------
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        COUNT(o.order_id) AS order_count,
		MAX(o.order_date) AS last_order_date,
        ROUND(SUM(
            (o.quantity * o.selling_price) 
            - (o.quantity * o.selling_price * o.discount_percent/100)
        ),3) AS total_revenue,
        ROUND(SUM(
            (
                (o.quantity * o.selling_price) 
                - (o.quantity * o.selling_price * o.discount_percent/100)
            )
            - (o.quantity * p.cost_price)
        ),3) AS total_profit
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN products p ON o.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
),

avg_values AS (
    SELECT 
        AVG(total_revenue) AS avg_revenue,
        AVG(total_profit/NULLIF(total_revenue,0)) AS avg_margin,
        AVG(order_count) AS avg_orders
    FROM customer_metrics
),

segmented AS(
SELECT 
    cm.*,
    ROUND(cm.total_profit/cm.total_revenue,4) AS profit_margin,

    CASE
        WHEN cm.total_revenue >= av.avg_revenue 
             AND (cm.total_profit/cm.total_revenue) >= av.avg_margin
             AND cm.order_count >= av.avg_orders
        THEN 'VIP - High Value Loyal'

        WHEN cm.total_revenue >= av.avg_revenue 
             AND (cm.total_profit/cm.total_revenue) < av.avg_margin
        THEN 'High Revenue - Discount Dependent'

        WHEN cm.total_revenue < av.avg_revenue 
             AND (cm.total_profit/cm.total_revenue) >= av.avg_margin
        THEN 'Efficient but Low Volume'

        ELSE 'Low Value Customer'
    END AS customer_segment

FROM customer_metrics cm, avg_values av
)
SELECT 
    customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(total_revenue),2) AS total_revenue,
    ROUND(SUM(total_profit),2) AS total_profit,
    ROUND(100.0 * SUM(total_revenue) / SUM(SUM(total_revenue)) OVER(),2) AS revenue_percent
FROM segmented
GROUP BY customer_segment
ORDER BY total_revenue DESC;

-- Top 10 profitable products------------------------------------
SELECT p.product_id,p.category,p.sub_category,
ROUND(SUM(
((o.quantity * o.selling_price)-(o.quantity * o.selling_price * o.discount_percent/100))
-(o.quantity * p.cost_price)
),2) AS total_profit

FROM orders o
JOIN products p
ON o.product_id=p.product_id

GROUP BY p.product_id,p.category,p.sub_category
ORDER BY total_profit DESC
LIMIT 20;

-- Revenue and profit according to categories---------------------
SELECT p.category,
ROUND(SUM(
(o.quantity * o.selling_price) 
- (o.quantity * o.selling_price * o.discount_percent/100)),2) 
AS total_revenue,
ROUND(SUM(
((o.quantity * o.selling_price)-(o.quantity * o.selling_price * o.discount_percent/100))
-(o.quantity * p.cost_price)
),2) AS total_profit

FROM orders o
JOIN products p
ON o.product_id=p.product_id

GROUP BY p.category
ORDER BY total_revenue DESC
LIMIT 10;

-- Identifying loss making orders------------------------
SELECT 
    o.order_id,
    o.product_id,
    p.category,
    o.quantity,
    o.selling_price,
    p.cost_price,
    
    ROUND(
        ((o.quantity * o.selling_price) - 
        (o.quantity * o.selling_price * o.discount_percent/100)) 
        - (o.quantity * p.cost_price)
    ,2) AS profit

FROM orders o
JOIN products p
ON o.product_id = p.product_id

WHERE 
(
((o.quantity * o.selling_price) - 
(o.quantity * o.selling_price * o.discount_percent/100)) 
- (o.quantity * p.cost_price)
) < 0

ORDER BY profit;