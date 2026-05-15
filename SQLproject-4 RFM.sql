select count(*)
from products1

select *
from orders

SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END)                  AS null_orderid,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END)                   AS null_userid,
    SUM(CASE WHEN order_number IS NULL THEN 1 ELSE 0 END)              AS null_ordernumber,
    SUM(CASE WHEN days_since_prior_order IS NULL THEN 1 ELSE 0 END)    AS null_days
FROM orders

SELECT
    MIN(order_number)  AS min_orders,
    MAX(order_number)  AS max_orders,
    round( AVG(CAST(order_number AS FLOAT)),2) AS avg_orders
FROM orders

SELECT
    MIN(days_since_prior_order)   AS min_days,
    MAX(days_since_prior_order)   AS max_days,
    AVG(cast(days_since_prior_order as float))   AS avg_days
FROM orders

SELECT DISTINCT days_since_prior_order
FROM orders
order by days_since_prior_order desc

SELECT
    MIN(CAST(days_since_prior_order AS FLOAT)) AS min_days,
    MAX(CAST(days_since_prior_order AS FLOAT)) AS max_days,
    AVG(CAST(days_since_prior_order AS FLOAT)) AS avg_days
FROM orders
WHERE days_since_prior_order IS NOT NULL

ALTER TABLE orders
ALTER COLUMN order_number INT;

ALTER TABLE orders
ALTER COLUMN days_since_prior_order FLOAT;

SELECT DISTINCT order_dow, COUNT(*) AS cnt
FROM orders
GROUP BY order_dow
ORDER BY order_dow

SELECT
    MIN(order_number)  AS min_orders,
    MAX(order_number)  AS max_orders,
    AVG(order_number)  AS avg_orders
FROM orders

SELECT
    MIN(order_hour_of_day) AS min_hour,
    MAX(order_hour_of_day) AS max_hour
FROM orders

SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1

alter table orders add is_first_order int

update orders
set is_first_order = case when days_since_prior_order is null then 1 else 0 end

alter table orders add days_since_prior_clean float

update orders
set days_since_prior_clean = case
                                when days_since_prior_order is null then 0
                                else days_since_prior_order
                                end

alter table orders add order_day_name varchar(50)

update orders
set order_day_name = case order_dow
                        WHEN 0 THEN 'Saturday'
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
    END

alter table orders add hour_bucket varchar(50)

update orders
set hour_bucket = case WHEN order_hour_of_day BETWEEN 6  AND 11 THEN 'Morning (6-11)'
        WHEN order_hour_of_day BETWEEN 12 AND 17 THEN 'Afternoon (12-17)'
        WHEN order_hour_of_day BETWEEN 18 AND 21 THEN 'Evening (18-21)'
        ELSE 'Off-Peak'
        end

SELECT TOP 5
    order_id, user_id, order_number, order_day_name,
    hour_bucket, is_first_order, days_since_prior_clean
FROM orders

-----RFM Caluculation--------

WITH user_orders AS (
    SELECT
        user_id,
        order_id,
        CAST(order_number AS INT) AS order_number,
        CAST(days_since_prior_clean AS FLOAT) AS days_since_prior_clean,
        is_first_order,

        -- Get last order per user
        MAX(CAST(order_number AS INT)) OVER (PARTITION BY user_id) AS max_order_number

    FROM orders
)

SELECT
    user_id,
    COUNT(order_id) AS frequency,
    MAX(order_number) AS total_orders,

    -- Recency: days from last order
    MAX(CASE 
        WHEN order_number = max_order_number 
        THEN days_since_prior_clean 
    END) AS recency_days,

    round(AVG(days_since_prior_clean),2) AS avg_days_between_orders,
    SUM(is_first_order) AS first_order_flag

INTO customer_summary

FROM user_orders
GROUP BY user_id

SELECT * FROM customer_summary

WITH rfm_base AS (
    SELECT
        user_id,
        frequency,
        recency_days,
        avg_days_between_orders,

        -- Recency score (lower = better → flip)
        (5 - NTILE(4) OVER (ORDER BY recency_days ASC)) AS r_score,

        -- Frequency score (higher = better)
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score

    FROM customer_summary
    WHERE recency_days IS NOT NULL
)

SELECT
    user_id,
    frequency,
    recency_days,
    avg_days_between_orders,
    r_score,
    f_score,
    CONCAT(r_score, f_score) AS rf_score,
    ROUND((r_score + f_score) / 2.0, 1) AS rfm_score

INTO rfm_scores  

FROM rfm_base

select COUNT(*)
from rfm_scores

select *
from rfm_scores

alter table rfm_scores add customer_segment varchar(50)

UPDATE rfm_scores
SET customer_segment =
    CASE
        WHEN r_score = 4 AND f_score = 4 THEN 'Champion'
        WHEN r_score = 4 AND f_score IN (3,4) THEN 'Loyal'
        WHEN r_score = 4 AND f_score <= 2 THEN 'New Customer'
        WHEN r_score = 3 AND f_score = 3 THEN 'Potential Loyal'
        WHEN r_score = 3 AND f_score <= 2 THEN 'Promising'
        WHEN r_score = 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score = 2 AND f_score <= 2 THEN 'Needs Attention'
        WHEN r_score = 1 AND f_score >= 3 THEN 'Cannot Lose Them'
        WHEN r_score = 1 AND f_score <= 2 THEN 'Lost'
        ELSE 'Other'
    END

SELECT
    customer_segment,
    COUNT(*)                                                AS CustomerCount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1)      AS Pct,
    ROUND(AVG(frequency), 1)                               AS AvgOrders,
    ROUND(AVG(recency_days), 1)                            AS AvgRecencyDays
FROM rfm_scores
GROUP BY customer_segment
ORDER BY CustomerCount DESC

select *
from rfm_scores

------business_analysis------
SELECT
    customer_segment,
    COUNT(*)                                                AS Customers,
    ROUND(AVG(frequency), 1)                               AS AvgOrders,
    ROUND(AVG(recency_days), 1)                            AS AvgDaysSinceOrder,
    ROUND(AVG(avg_days_between_orders), 1)                 AS AvgOrderCadenceDays
FROM rfm_scores
GROUP BY customer_segment
ORDER BY AVG(frequency) DESC

SELECT top 10 
    order_day_name,
    hour_bucket,
    COUNT(*)                                               AS OrderCount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)     AS Pct_of_Total
FROM orders
GROUP BY order_day_name, hour_bucket
ORDER BY OrderCount DESC

WITH freq_buckets AS (
    SELECT
        user_id,
        frequency,
        NTILE(5) OVER (ORDER BY frequency ASC)             AS freq_quintile
    FROM customer_summary
)
SELECT
    freq_quintile,
    COUNT(*)                                               AS Customers,
    MIN(frequency)                                         AS MinOrders,
    MAX(frequency)                                         AS MaxOrders,
    ROUND(AVG(frequency), 1)                               AS AvgOrders
FROM freq_buckets
GROUP BY freq_quintile
ORDER BY freq_quintile


SELECT
    segment_group,
    ROUND(AVG(frequency), 1)                               AS AvgOrderFrequency,
    ROUND(AVG(recency_days), 1)                            AS AvgRecencyDays,
    ROUND(AVG(avg_days_between_orders), 1)                 AS AvgOrderCadence,
    COUNT(*)                                               AS CustomerCount
FROM (
    SELECT
        user_id, frequency, recency_days, avg_days_between_orders,
        CASE
            WHEN customer_segment IN ('Champion', 'Loyal') THEN 'High Value'
            WHEN customer_segment IN ('At Risk', 'Cannot Lose Them') THEN 'At Risk'
            WHEN customer_segment IN ('Lost') THEN 'Lost'
            ELSE 'Mid Value'
        END AS segment_group
    FROM rfm_scores
) AS segmented
GROUP BY segment_group
ORDER BY AvgOrderFrequency DESC


WITH product_stats AS (

    SELECT
        product_id,
        COUNT(*)                                            AS TotalAppearances,
        SUM(reordered)                                      AS TotalReorders,
        COUNT(DISTINCT order_id)                            AS UniqueOrders,

     
        ROUND(
            SUM(reordered) * 100.0 / NULLIF(COUNT(*), 0)
        , 1)                                               AS ReorderRate_Pct

    FROM order_products_prior
    GROUP BY product_id

    HAVING COUNT(*) >= 500
),
ranked AS (
 
    SELECT
        ps.product_id,
        ps.TotalAppearances,
        ps.TotalReorders,
        ps.UniqueOrders,
        ps.ReorderRate_Pct,
        RANK() OVER (ORDER BY ps.ReorderRate_Pct DESC)     AS ReorderRank
    FROM product_stats ps
)

SELECT TOP 10
    r.ReorderRank,
    p.product_name,
    p.department_id,
    r.TotalAppearances,
    r.TotalReorders,
    r.UniqueOrders,
    r.ReorderRate_Pct
FROM ranked r
JOIN products1 p ON r.product_id = p.product_id
WHERE r.ReorderRank <= 10
ORDER BY r.ReorderRank;

SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'rfm_scores'
ORDER BY ORDINAL_POSITION

select *
from order_products__prior

ALTER TABLE orders
ALTER COLUMN user_id INT

ALTER TABLE orders
ALTER COLUMN order_dow INT

ALTER TABLE orders
ALTER COLUMN order_hour_of_day INT

ALTER TABLE products1
ALTER COLUMN product_id INT;


ALTER TABLE products1
ALTER COLUMN aisle_id INT;


ALTER TABLE products1
ALTER COLUMN department_id INT;

select *
from customer_summary

SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'customer_summary'
ORDER BY ORDINAL_POSITION

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'products1'
ORDER BY ORDINAL_POSITION

SELECT TOP 10
    p.product_name,
    p.department_id,
    COUNT(DISTINCT op.order_id)                              AS OrderAppearances,
    RANK() OVER (
        ORDER BY COUNT(DISTINCT op.order_id) DESC
    )                                                        AS PopularityRank
FROM order_products__prior op
JOIN products1 p
    ON op.product_id = p.product_id
GROUP BY
    p.product_name,
    p.department_id
HAVING COUNT(DISTINCT op.order_id) >= 100
ORDER BY OrderAppearances DESC