-- Q 1 Find the different payment method and number of transactions, number of qty sold 

select  * from walmart;

select SUM(quantity) as QUANT, COUNT(invoice_id) AS TRANS,  payment_method
from walmart
group by  payment_method;

-- Q 2 Identify the highest- rated cateory in each branch, displaying the branch, category.
-- AVG RATING 

select *
from
(
  select
      Branch,
      category,
	  avg(rating) As avg_rating ,
      rank() OVER(partition by Branch order by avg(rating) Desc) as Ranking
  from walmart
  group by Branch,category
)AS ranked_data
where ranking = 1;

-- Q 3 Identify the bussiest day for each branch, based on the number of transactions 
select  * from walmart;

select *
from
(
SELECT
    Branch,
    DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS Day_Name,
    COUNT(*) AS no_transactions,
    Rank() OVER(partition by Branch order by COUNT(*)desc) as Ranking
FROM walmart
GROUP BY Branch, DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W')
)as sort
where Ranking = 1;

-- Q 4 calculate the total quantity of items sold per payment method. List payment_method and total_quality.

select SUM(quantity)as Total_quantity,payment_method
from walmart
group by payment_method;

-- Q 5 Determine the average,minimum, and maximum rating of products for each city.
-- List the city, average_rating, min_rating and max_rating.

select * from walmart;

select City, category, AVG(rating),Min(rating),MAX(rating)
from walmart
group by City,category
order by City asc;

-- Q 6 calculate the total profit for each category by considering total_profit as 
-- (unit_price * quantity * profit_margin). List category and total_profit, ordered from hihest to lowest profit.

select category,
	   SUM( unit_price * quantity * profit_margin) as Profit,
       SUM(unit_price * quantity) as Total_Revenue
from walmart
group by category
order by Profit Desc;

-- Q 7 Determine the most common payment method for each brach.
-- Determine branch and the preferred_payment_method.
select *
from
(
   select 
      Branch,
      count(*),
      payment_method,
      rank() over(partition by Branch order by count(*) desc) as Ranking
from walmart
group by Branch,payment_method
order by Branch Asc
)as Preffered_method
where ranking = 1 ;

-- Q 8 categorize sales into 3 groups MORNING, AFTERNOON, EVENING
--  Find out each of the shift and number of invoices.

SELECT 
    Branch,
    CASE
        WHEN HOUR(TIME(time)) < 12 THEN 'MORNING'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 16 THEN 'AFTERNOON'
        ELSE 'EVENING'
    END AS Day_time,
    COUNT(*) AS total_transactions
FROM walmart
GROUP BY Day_time,Branch
order by Branch,total_transactions DESC;

-- Q 9 Identify 5 branch with highest decrease ratio in evevenue compare to last year(current year 2022 and last year 2022
-- REVENUE_DESC_RATIO = LAST_REV - CURRENT_REV/LAST_REV*100

WITH rev_2022 AS (
    SELECT 
        Branch,
        SUM(quantity * unit_price) AS Revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY Branch
),
rev_2023 AS (
    SELECT 
        Branch,
        SUM(quantity * unit_price) AS Revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY Branch
)
SELECT 
    cy.Branch,
    ly.Revenue AS Last_Year_Revenue,
    cy.Revenue AS Current_Year_Revenue,
    ROUND(((ly.Revenue - cy.Revenue) / ly.Revenue) * 100, 2) AS Revenue_Decline_Ratio
FROM rev_2023 AS cy
LEFT JOIN rev_2022 AS ly ON cy.Branch = ly.Branch
ORDER BY Revenue_Decline_Ratio DESC
LIMIT 5;
