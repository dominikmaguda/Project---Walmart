--Business problems
-- 1. Find payment methods,numer of transactions, number of quantity sold
SELECT * FROM walmart
LIMIT 10;

SELECT 
    payment_method,
    COUNT(*),
    SUM(quantity)
FROM walmart
GROUP BY payment_method;

-- 2. Identify the highest-rated category in each branch displaying branch and category


WITH a as
(
SELECT
    branch,
    category,
    AVG(rating) as avg_rating,
    RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
FROM walmart
GROUP BY branch, category) 

SELECT * 
FROM a
WHERE rank = 1;


-- 3. Identify the busiest day of the week for each branch based on the number of transactions

SELECT 
    branch,
    day,
    transactions
FROM 
(
SELECT
    branch,
    TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'DAY') as day,
    COUNT(*) as transactions,
    RANK() OVER(PARTITION BY branch ORDER BY SUM(quantity) DESC) as rank
FROM walmart
GROUP BY branch, day
ORDER BY branch
)
WHERE rank = 1;

-- 4. Calculate the total quantity of items sold per payment method. 
-- List payment_method and total quantity

SELECT 
    payment_method,
    SUM(quantity) as total_quantity
FROM walmart
GROUP BY payment_method;

-- 5. Determine the average, minimum and maximum rating of category for each city.
-- List the city, average_rating, min_rating and max_rating

SELECT 
    city,
    category,
    ROUND(AVG(rating)::numeric, 2) as average_rating,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating
FROM walmart
GROUP BY city, category;

--Calculate the total profit for each category by considering total_profit as 
--(unit_price * quantity * profit_margin). List category, total_profit (ordered from higest to lowest)

SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) as total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit

-- 7. Determine the most common payment method for each branch
-- Display branch and the preffered_payment_method

WITH b AS
(
SELECT 
    branch,
    payment_method,
    COUNT(*),
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC)
FROM walmart
GROUP BY branch, payment_method
ORDER BY branch
)

SELECT
branch,
payment_method as preffered_payment_method
FROM b
WHERE RANK = 1; 

-- 8. Categorize sales into 3 groups: morning, afternoon, evening
-- Find number of transactions in each group

SELECT 
    CASE
        WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM(time::time))  BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END day_part,
    COUNT(*)
FROM walmart
GROUP BY day_part;

-- 9. Identify 5 branches with highest decrese in revenue compared to previous year 
-- Current year 2023, previous year 2022


--2022
WITH revenue_2022 AS
(
SELECT 
    branch,
    SUM(total) as revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
GROUP BY branch
),
revenue_2023 AS
(
SELECT 
    branch,
    SUM(total) as revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
GROUP BY branch
)
SELECT 
    r22.branch,
    r22.revenue as last_year_revenue,
    r23.revenue as current_revenue,
    ROUND
        ((r22.revenue - r23.revenue)::numeric/r22.revenue::numeric * 100, 2) as revenue_decrese
FROM revenue_2022 AS r22
JOIN revenue_2023 AS r23
ON r22.branch = r23.branch
WHERE
    r22.revenue > r23.revenue
ORDER BY revenue_decrese DESC 
LIMIT 5;