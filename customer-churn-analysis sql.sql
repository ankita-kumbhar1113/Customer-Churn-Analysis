create database churn_analysis ;
use churn_analysis;

-- check table 
select * from churn_data ;

-- check column names
describe churn_data ;

-- find null values
select * from churn_data
where totalcharges is null;

-- find blank spaces
select * from churn_data
where totalcharges = '';

-- set sql to safe mode off to replace blankspace using null 
set sql_safe_updates = 0;

update churn_data
set totalcharges = null
where totalcharges = '';

set sql_safe_updates = 1;

-- check duplicate values 
select customerid,count(*)
from churn_data
group by customerid
having count(*) > 1;

-- check churn values
select distinct churn
 from churn_data;

-- SQL Basic Queries

-- 1] Total Customers
select count(*) 
from churn_data ;

-- 2] Total Churn Customers
select count(*) from churn_data
where churn = 'yes';

-- 3]Churn Rate
select 
round(
sum( case when churn = 'yes' then 1 else 0 end )*100/count(*), 2)
as churn_rate
from churn_data;

-- 4]Churn rate by Contract Type
select contract,count(*) as customers,
round(sum(
case when churn = 'yes' then 1 else 0 end)*100/count(*),1) as churn_customers
from churn_data
group by Contract;

-- 5]Churn rate by payment Type
select paymentmethod,count(*) as customers,
sum(
case when churn='yes' then 1 else 0 end ) as churn_customers
from churn_data 
group by PaymentMethod ;

-- 6] avg monthly charges
SELECT churn,ROUND(avg(monthlycharges),2)
FROM
churn_data
group by churn;


-- created small table to use join query 
create table contract_info as
select customerid, contract, monthlycharges, churn 
from churn_data;

-- 7] inner join
select c.customerid, c.contract, d.tenure, d.paymentmethod, c.monthlycharges, c.churn
from contract_info c
inner join churn_data d on c.customerID = d.customerID ;

-- 8]High Risk Customers
with high_risk_cust as (
	select customerid, tenure, contract, paymentmethod, monthlycharges, churn
	from churn_data 
	where churn = 'yes' and
	monthlycharges > 70
 )
select * from high_risk_cust ; 

-- 9]Rank Customers by Charges
select customerid, monthlycharges,
rank() over(order by monthlycharges desc) as rank_by_charges
from churn_data
limit 10;

-- 10] Average Charges by Contract
select customerid, contract, monthlycharges, avg(monthlycharges)
over(partition by contract) as avg_contract_charges
from churn_data;

-- 11]creating view
create view churn_view as
select customerid,
tenure,
contract,
paymentmethod,
monthlycharges,
TotalCharges
from churn_data
where Churn = 'yes'; 

select * from churn_view ;

-- 12] Top 5 highest-paying churned customers
with churn_stats as(
select customerid,
tenure,
contract,
monthlycharges,
rank() over(
partition by contract 
order by monthlycharges desc) as contract_rank
from churn_data
where churn= 'yes')
select * from churn_stats
where contract_rank <= 5 ;
      












