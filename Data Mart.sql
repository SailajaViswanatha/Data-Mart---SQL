use case_1;
drop table clean_weekly_sales;
drop table cleaned_weekly_sales;
###Data cleansing
create table clean_weekly_sales as
select week_date, extract(week from week_date) as week_number, extract(month from week_date) as month_number,
extract(year from week_date) as calender_year,region,platform,
case
when segment='null' then 'unknown'
else segment
end as 'segment',
case
when segment regexp '1$'
then 'Young Adults'
when segment regexp '2$'
then 'Middle Aged'
when segment regexp '3$' 
then 'Retirees'
when segment regexp '4$' 
then 'Retirees'
else 'unknown'
end as 'age_band' ,
case
when segment regexp '^C'
then 'Couples'
when segment regexp '^F'
then 'Families'
else 'unknown'
end as 'demographic',
customer_type,transactions,sales,round(sales/transactions) as avg_transactions
 from weekly_sales;
 
 select * from clean_weekly_sales;
 
 ###Data Exploration
 
 create table seq100(x int not null auto_increment primary key);
 
 insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 select x + 50 from seq100;
select * from seq100;
create table seq52 as (select x from seq100 limit 52);
select * from seq52;

## 1. Which week numbers are missing from the dataset?

select x from seq52
where x not in (select distinct week_number from clean_weekly_sales);                              
select distinct week_number from clean_weekly_sales;

## 2.How many total transactions were there for each year in the dataset?

select calender_year,sum(transactions) as total_transactions from clean_weekly_sales
group by calender_year;

## 3. What are the total sales for each region for each month?
 select region,month_number,sum(sales) as 'Total Sales' from clean_weekly_sales
 group by region,month_number;
 
## 4. What is the total count of transactions for each platform?
select platform,count(transactions) as count from clean_weekly_sales
group by platform;

##5. What is the percentage of sales for Retail vs Shopify for each month?
with cte_monthly_platform_sales as (
select month_number,calender_year,platform,sum(sales) as monthly_sales from clean_weekly_sales
group by month_number,calender_year,platform
)
SELECT
  month_number,calender_year,
  ROUND(
    100 * max(CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) /
      SUM(monthly_sales),
    2
  ) AS retail_percentage,
  ROUND(
    100 * max(CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END) /
      SUM(monthly_sales),
    2
  ) AS shopify_percentage
FROM cte_monthly_platform_sales
GROUP BY month_number,calender_year
ORDER BY month_number,calender_year;

## 6.What is the percentage of sales by demographic for each year in the dataset?

SELECT calender_year,demographic,SUM(SALES) AS yearly_sales,
  ROUND(100 * SUM(sales)/ SUM(SUM(SALES)) OVER (PARTITION BY demographic),2) AS percentage
FROM clean_weekly_sales
GROUP BY calender_year,demographic
ORDER BY calender_year,demographic;

## 7. Which age_band and demographic values contribute the most to Retail sales?
select age_band,demographic,sum(sales) from clean_weekly_sales
where platform='Retail'
group by age_band,demographic
order by sum(sales) desc;


