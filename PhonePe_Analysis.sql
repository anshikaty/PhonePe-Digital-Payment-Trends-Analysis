create database Phonepe;
use phonepe;
select * from phonepe.agg_trans;
-- change the datatype of transaction_amount as int
SET SQL_SAFE_UPDATES=0;
update phonepe.agg_trans
set Transaction_amount= Floor(Transaction_amount);

describe phonepe.agg_trans;
-- Total transaction amount and  count for each state in particular year and quarter
select state,year,quarter, sum(Transaction_amount) as total_transaction_amount, sum(Transaction_count) as total_trans_count
from agg_trans 
group by state,year,quarter
order by total_transaction_amount desc;
-- top 5 states for each year
with cte as (
select year, state,sum(transaction_amount)as total_trans_amount, dense_rank() over (partition by year order by sum(transaction_amount) desc) as rnk
from agg_trans
group by year,state
)
select year,state, total_trans_amount,rnk
from cte
where rnk <=5;

select * from phonepe.map_user;
-- which districts have the highest number of registered users and app opens for in 2022 year
select district ,sum(Registered_users) as total_users ,sum(App_opens) as total_app_open
from map_user
where year =2022
group by district
order by total_users desc; 
-- Total registered user for each year
select year , sum(registered_users) as total_users
from map_user
group by year
order by total_users;
-- Quarterly analysis of app opens - find the top quarter in every year
with cte1 as (
select year,quarter,sum(app_opens) as total_app_opens,dense_rank() over (partition by year order by sum(app_opens) desc) as rnk
from map_user
group by year,quarter
)
select year,quarter ,total_app_opens
from cte1
where rnk=1
order by total_app_opens desc;
--  Total Registered users by region 
select region , sum(Registered_users) as total_registered_users
from map_user 
group by region
order by total_registered_users desc;
-- total transaction amount by region and quarter
select * from top_trans_pin;
select region,quarter, sum(Transaction_amount) as total_trans_amount
from top_trans_pin
group by region,quarter
order by total_trans_amount desc;
-- year on year growth for each year in terms of transaction amount 
select year,sum(Transaction_amount) as total_amount,(sum(transaction_amount) -lag(sum(transaction_amount)) over (order by year ))as y_y_growth
from top_trans_pin
group by year
order by year;
-- year on year growth for each year in terms of registered users
select year, sum(Registered_users) as total_registered_users , 
(sum(registered_users) -lag(sum(registered_users)) over ( order by year)) as y_y_user_growth,
(sum(registered_users) -lag(sum(registered_users)) over ( order by year))/lag(sum(registered_users)) over(order by year)*100 as y_y_user_growth_percnt
from map_user
group by year
order by year;
-- which region is leading in terms of  transaction count
select region,sum(transaction_count) as total_transaction_count
from top_trans_pin
group by region
order by total_transaction_count desc;
-- transaction type trend
select transaction_type,sum(Transaction_count) as total_trans_count
from agg_trans
group by transaction_type
order by total_trans_count desc;



