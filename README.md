# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis   
**Database**: `sql_project_sales_analysis`

This project showcases essential SQL skills and techniques commonly used by data analysts to explore, clean, and analyze retail sales data. It involves setting up a retail sales database, conducting exploratory data analysis (EDA), and using SQL queries to answer key business questions. 

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `sql_project_sales_analysis`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
sql_project_sales_analysis;

CREATE TABLE retail_sales
(
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id	INT,
	gender VARCHAR(15),
	age	INT,
	category VARCHAR(15),	
	quantity	INT,
	price_per_unit	FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Understand the table and columns name. Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.
- **Null Value Count**: Count total number of NULL values in the table.
- **Deleting records consist of NULL Values**

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;
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


DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL OR sale_date IS NULL
	OR sale_time IS NULL OR customer_id IS NULL
	OR gender IS NULL OR age IS NULL OR category IS NULL
	OR quantity IS NULL OR price_per_unit IS NULL
	OR cogs IS NULL OR total_sale IS NULL;
```
- **How many sales we have?**
- **How many customers we have?**

```sql
 SELECT COUNT(*) as total_sales FROM retail_sales;

SELECT COUNT(DISTINCT customer_id) as total_customers FROM retail_sales;

SELECT DISTINCT category FROM retail_sales;

```
### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05.**:
```sql
SELECT 
	* 
FROM 
	retail_sales
WHERE
	sale_date = '2022-11-05';

```

2. **Write a SQL query to retrieve all columns for sales from 2020-03-29 to 2020-03-31.**:
```sql
SELECT 
	*
FROM 
	retail_sales
WHERE 
	sale_date BETWEEN '2022-03-29' AND '2022-03-31';
```

3. **Write a SQL query to retrieve all transcations where the category is 'Clothing' and the quantity sold is more than 3 in the month of NOV-2022.**:
```sql
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
```

4. **Write a SQL query to calculate the total sales (total_sales) for each category.**:
```sql
SELECT
	category,
	COUNT(*) AS total_orders,
	SUM(total_sale) AS net_sale,
	ROUND(AVG(total_sale)::NUMERIC,2) AS avg_sale
FROM
	retail_sales
GROUP BY 
	category;
```

5. **Write a SQL query to find the average age of customers who purphased items from the 'Beauty' category more than once.**:
```sql
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
```

6. **Write a SQL query to find all customers who made more than two purchases where each transaction had a total sale greater than 100**:
```sql
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
```

7. **Write a SQL query to find top 10 customers who made the most orders.**:
```sql

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
```

8. **Write a SQL query to find all transaction where the total_sale is greater than 1000.**:
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000
ORDER BY total_sale DESC;
```

9. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT category, gender, count(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY 1;
```

10. **Write a SQL query to calulate the average sale for each month. Find out best selling month in each year.**:
```sql
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
```


11. **Write a SQL query to find the top 5 cutomers based on the highest total sales.**:
```sql
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
```

12. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT 
	category,
	COUNT( DISTINCT customer_id) AS num_of_unique_customers
FROM
	retail_sales
GROUP BY 
	category;
```

13. **Write a SQL query to find the number of unique customers who have purchased from each category only once.**:
```sql
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
```


14. **Write a SQL query to create on each timeframe of number of orders ( Morning before 12, Afternoon before 5 and night before mid-night)**:
```sql

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
```


## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and order time.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `analysis_queries.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - Bibek Parajuli

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions or feedback, feel free to get in touch!

### Socials

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media:

- **Email**: [Contact me on Email](bibekparajuli48@gmail.com)
- **Linkedln**: [Catch me on Linkedln](https://www.linkedin.com/in/bibek-parajuli-b61373186/)
- **Twitter | X**: [Connect with on X](https://x.com/bibekparajuli48)
- **Web Protfolio**: [Explore my projects on Github pages(Web protfolio](https://cod-bibek.github.io/Cod_Bibek.github.io/)

Thank you for exploring my project.
