-- SQL Retail Sales Analysis
CREATE DATABASE sql_project_sales_analysis;


-- Create TABLE
CREATE TABLE retail_sales
(
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id	INT,
	gender VARCHAR(15),
	age	INT,
	category VARCHAR(15),	
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);

-- DATA CLEANING
SELECT * FROM retail_sales
LIMIT 10;
SELECT COUNT(*) FROM retail_sales

SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

SELECT DISTINCT category FROM retail_sales;

SELECT COUNT(*) FROM retail_sales
WHERE transactions_id IS NULL;

SELECT COUNT(*) FROM retail_sales
WHERE sale_date IS NULL;

SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR 
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR 
	total_sale IS NULL;

-- Deleting records consist of NULL VALUES.

DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL OR sale_date IS NULL
	OR sale_time IS NULL OR customer_id IS NULL
	OR gender IS NULL OR age IS NULL OR category IS NULL
	OR quantity IS NULL OR price_per_unit IS NULL
	OR cogs IS NULL OR total_sale IS NULL;

SELECT COUNT(*) FROM retail_sales;
	
-- DATA EXPLORATION

--How many sales we have?
SELECT COUNT(*) as total_sales FROM retail_sales;


-- How many customers we have?

SELECT COUNT(DISTINCT customer_id) as total_customers FROM retail_sales;

SELECT DISTINCT category FROM retail_sales;


-- Data Analysis & Business Key Problems @ Answers

-- Q1. write a SQL query to retrieve all columns for sales on 2022-11-05

SELECT 
	* 
FROM 
	retail_sales
WHERE
	sale_date = '2022-11-05';

	

-- Q2. Write a SQL query to retrieve all columns for sales from 2020-03-29 to 2020-03-31

SELECT 
	*
FROM 
	retail_sales
WHERE 
	sale_date BETWEEN '2022-03-29' AND '2022-03-31';


-- Q3. Write a SQL query to retrieve all transcations where the category is 'Clothing' and the quantity sold is more than 3 in the month of NOV-2022


SELECT * 
FROM 
	retail_sales
WHERE 
	category = 'Clothing'
	AND quantity > 3
	AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';
	

-- Alternate method

SELECT *
FROM
	retail_sales
WHERE
	category = 'Clothing'
	AND TO_CHAR(sale_date,'YYYY-MM') = '2022-11'
	AND quantity > 3;


-- Q4. Write a SQL query to calculate the total sales (total_sales) for each category.

SELECT
	category,
	COUNT(*) AS total_orders,
	SUM(total_sale) AS net_sale,
	ROUND(AVG(total_sale)::NUMERIC,2) AS avg_sale
FROM
	retail_sales
GROUP BY 
	category;


-- Q5. Write a SQL query to find the average age of customers who purphased items from the 'Beauty' category more than once.

SELECT 
	ROUND(AVG(age),2) as average_age
FROM retail_sales
WHERE customer_id IN (
	SELECT customer_id 
	FROM retail_sales
	WHERE category = 'Beauty'
	GROUP BY customer_id
	HAVING COUNT(customer_id) > 1
	);


-- Q6. Write a SQL query to find all customers who made more than two purchases where each transaction had a total sale greater than 100.

SELECT 
	customer_id,
	SUM(total_sale) AS net_sale,
	ROUND(AVG(total_sale)::NUMERIC, 2) AS avg_sale
FROM retail_sales
WHERE customer_id IN (
	SELECT customer_id
	FROM retail_sales
	WHERE total_sale > 100
	GROUP BY customer_id
	HAVING COUNT(customer_id)>2
)
GROUP BY customer_id
ORDER BY avg_sale DESC;

-- Q7. Write a SQL query to find top 10 customers who made the most orders


		SELECT 
			customer_id,
			COUNT(customer_id) as total_orders
		FROM 
			retail_sales
		GROUP BY 
			customer_id
		ORDER BY 
			total_orders DESC
		LIMIT 10
	);

-- Q8. Write a SQL query to find all transaction where the total_sale is greater than 1000.

SELECT * FROM retail_sales
WHERE total_sale > 1000
ORDER BY total_sale DESC;


-- 	Q9. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT category, gender, count(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY 1;


-- Q10. Write a SQL query to calulate the average sale for each month. Find out best selling month in each year
SELECT 
	year,
	month,
	avg_sale
FROM 
	(
		SELECT 
			EXTRACT(YEAR FROM sale_date) as year, 
			EXTRACT(MONTH FROM sale_date) as month,
			ROUND(AVG(total_sale) :: NUMERIC, 2)  as avg_sale,
			RANK()OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(TOTAL_SALE)DESC) as rank
		FROM retail_sales
		GROUP BY 1 , 2
	) AS sub_query 
WHERE rank = 1;


-- Q11. Write a SQL query to find the top 5 cutomers based on the highest total sales

SELECT
	customer_id,
	SUM(total_sale) AS net_sale
FROM 
	retail_sales
GROUP BY 
	customer_id
ORDER BY 2 DESC
LIMIT 5;

-- Alternate method

SELECT
	customer_id,
	net_sale
FROM 
     (
		SELECT 
			customer_id,
			SUM(total_sale) AS net_sale,
			RANK() OVER (ORDER BY SUM(total_sale)DESC) AS rank
		FROM retail_sales
		GROUP BY customer_id

) AS sub_query
WHERE rank < 6;



-- 	Q.12 Write a SQL query to find the number of unique customers who purchased items from each category.


SELECT 
	category,
	COUNT( DISTINCT customer_id) AS num_of_unique_customers
FROM
	retail_sales
GROUP BY 
	category;



-- Q.13 Write a SQL query to find the number of unique customers who have purchased from each category only once.
SELECT 
	category,
	count(category) as unique_customers
FROM 
	(
		SELECT 
			customer_id,
			category,
			count(*) AS purchases
		FROM 
			retail_sales
		GROUP BY 
			customer_id, category
	)
WHERE purchases = 1
GROUP BY category;


-- Q.14 Write a SQL query to create on each timeframe of number of orders ( Morning before 12, Afternoon before 5 and night before mid-night)


SELECT * FROM retail_sales
LIMIT 3; -- Analysing Table Format

SELECT 
	order_time, 
	count(transactions_id)
FROM 
	 (
		SELECT 
			transactions_id,
			CASE 
					WHEN sale_time < '12:00:00' THEN 'Morning'
					WHEN sale_time < '17:00:00' THEN 'Afternoon'
					ELSE 'Night'
					END  AS order_time
		FROM 
			retail_sales
	)
GROUP BY order_time

-- Alternate Method

WITH hourly_sale
AS 
(
SELECT sale_time ,
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 16 THEN 'Afternoon'
		ELSE 'Evening'
	END AS order_time
FROM retail_sales
)

SELECT 
	order_time,
	COUNT(*) as total_orders

FROM 
	hourly_sale
GROUP BY
	order_time;

--- END OF PROJECT

	
