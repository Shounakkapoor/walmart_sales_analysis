SELECT *
FROM walmart;

-- Business Problems


-- What are the different payment methods, and how many transactions and items were sold with each method?

 SELECT 
 	payment_method,
	COUNT(*) AS no_payments,
	SUM(quantity) AS no_qty_sold
 FROM walmart
 GROUP BY payment_method;

 -- Which category received the highest average rating in each branch?

SELECT 
	category,
	top_avg_rating,
	branch
FROM
(
SELECT 
	category,
	AVG(rating) AS top_avg_rating,
	branch,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
FROM walmart
GROUP BY branch, category
ORDER BY top_avg_rating DESC)
WHERE rank = 1;

-- 3 What is the busiest day of the week for each branch based on transaction volume?

SELECT *
FROM
(
SELECT 
	branch,
	TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
	COUNT(*) AS no_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY branch, day_name)
WHERE rank = 1


-- 4 How many items were sold through each payment method?


 SELECT 
 	payment_method,
	SUM(quantity) AS no_qty_sold
 FROM walmart
 GROUP BY payment_method;


-- 5 What are the average, minimum, and maximum ratings for each category in each city?

SELECT 
	category,
	city,
	AVG(rating) AS avg_rating,
	MIN(rating)AS min_rating,
	Max(rating) AS max_rating
FROM walmart
GROUP BY 1,2
ORDER BY 1,2;

-- 6  What is the total profit for each category, ranked from highest to lowest?

SELECT 
	category,
	ROUND(SUM(total*profit_margin)) as profit
FROM walmart
GROUP BY 1
ORDER BY 2 DESC;

-- 7 What is the most frequently used payment method in each branch?

SELECT *
FROM(
SELECT 
	branch,
	payment_method,
	COUNT(*) AS frequency_of_method_used,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY 1,2)
WHERE rank = 1;


-- 8 How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

SELECT 
	branch,
	CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(TIME::TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*) AS no_of_transactions
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;


-- 9 Which branches experienced the largest decrease in revenue compared to the previous year?

WITH revenue_2022
AS
(
SELECT 
	branch,
	SUM(total) as revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
GROUP BY 1
),
revenue_2023
AS
(
SELECT 
	branch,
	SUM(total) as revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
GROUP BY 1
)

SELECT
 ls.branch,
 ls.revenue as last_year_revenue,
 cs.revenue as current_year_revenue,
 ROUND(
 		(ls.revenue - cs.revenue)::numeric/
 		ls.revenue::numeric *100,
 		2) AS revenue_drop_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON cs.branch = ls.branch
WHERE
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;
