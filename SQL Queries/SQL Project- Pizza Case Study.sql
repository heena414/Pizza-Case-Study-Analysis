
/*SQL PROJECT - PIZZA CASE STUDY ANALYSIS*/



create database PizzaData;

use PizzaData

select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;




--ANALYSIS AND DATA EXPLORATION--



--1. Total number of Orders Placed

select count(*) as total_orders 
from orders;

--distinct count
select count(distinct order_id) as total_orders
from orders;

--2. Total Revenue generated from pizzas sales

select cast(sum(p.price * od.quantity) as decimal(10,2)) as total_revenue
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id;

--3. Highest priced pizza

select top 1 name, max(price) as highest_price
from pizzas as p
join pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
group by name
order by highest_price desc;

/*
Alternate way (using window function) - without using TOP function

with cte as (
select pizza_types.name as 'Pizza Name', cast(pizzas.price as decimal(10,2)) as 'Price',
rank() over (order by price desc) as rnk
from pizzas
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
)
select [Pizza Name], 'Price' from cte where rnk = 1 
*/

--4. Most common pizza size ordered

select top 1 size, count(distinct order_id) as 'No of Orders', sum(quantity) as 'Total Quantity'
from order_details as od 
join pizzas as p on od.pizza_id = p.pizza_id
group by size
order by count(distinct order_id) desc;

--5. Top 5 most ordered Pizza Types

select top 5 pt.name, sum(od.quantity) as total_quantity
from order_details as od 
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_types as pt on p. pizza_type_id = pt.pizza_type_id
group by pt.name
order by total_quantity desc;

--6. Total Number of each Pizza type sold 

select pt.name, sum(od.quantity) as total_sold
from order_details as od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name;

--7. Total orders per day of the week

select datename(weekday, date) as day_of_week, count(*) as total_orders
from orders
group by datename(weekday, date)
order by total_orders desc;

--8. Average order value

select avg(order_value) as avg_order_value
from (
select o.order_id, SUM(p.price * od.quantity) as order_value
from orders as o
join order_details as od on o.order_id = od.order_id
join pizzas as p on od.pizza_id = p.pizza_id
group by o.order_id
) as order_values;

--9. Total Revenue by pizza size

select p.size, sum(p.price * od.quantity) as total_revenue
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
group by p.size;

--10. Total Quantity of each pizza category ordered

select top 5 pt.category, sum(od.quantity) as total_quantity
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category
order by sum(quantity) desc;

--11. Distribution of orders by hour of the day (which hour is the peak hour)

select datepart(hour, time) as hour, count(*) as total_orders
from orders
group by datepart(hour, time)
order by total_orders desc;

--12. Category-Wise distribution of Pizzas

select category, count(distinct pizza_type_id) as 'No of pizzas'
from pizza_types
group by category
order by 'No of pizzas';

/*
select pt.category, count(*) as total_orders
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category;
*/

--13. Average number of Pizzas order per day

with cte as(
select date as 'Date', sum(quantity) as 'Total Pizza Ordered that day'
from order_details as od
join orders as o on od.order_id = o.order_id
group by date
)
select avg([Total Pizza Ordered that day]) as [Avg Number of pizzas ordered per day]
from cte;

/*
alternate way using sub query

select avg([Total Pizza Ordered that day]) as [Avg Number of pizzas ordered per day] from 
(
	select orders.date as 'Date', sum(order_details.quantity) as 'Total Pizza Ordered that day'
	from order_details
	join orders on order_details.order_id = orders.order_id
	group by orders.date
) as pizzas_ordered
*/

--14. Top 3 most ordered Pizza types based on revenue

select top 3 pt.name, sum(p.price * od.quantity) as total_revenue
from order_details od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by total_revenue desc;

--15. Peak order days

select datename(weekday, date) as weekday, count(distinct order_id) as order_count
from orders
group by datename(weekday, date)
order by order_count desc;

--16. Average number of Pizza per Order

select avg(total_pizzas) as avg_pizzas_per_order
from(
select order_id, sum(quantity) as total_pizzas
from order_details
group by order_id
) as order_totals;

--17. Revenue by Day of the week

select datename(weekday, date) as day_of_week, sum(p.price * od.quantity) as total_revenue
from orders as o
join order_details as od on o.order_id = od.order_id
join pizzas as p on od.pizza_id = p.pizza_id
group by datename(weekday, date)
order by total_revenue desc;

--18. Most Popular pizza ingredient

select top 1 ingredient, count(*) as frequency
from(
select pt.ingredients, value as ingredient
from pizza_types as pt
    cross apply string_split(pt.ingredients, ',')
) as ingredients
group by ingredient
order by frequency desc;

--19. Average revenue per pizza type

select pt.name, avg(p.price * od.quantity) as avg_revenue
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name;

--20. Percentage contribution of each pizza type to Total Revenue

select pt.category, 
concat(cast(sum(p.price * od.quantity) / 
(select sum(p.price * od.quantity) 
from order_details od
join pizzas p on od.pizza_id = p.pizza_id
)* 100.0 as decimal(10,2)), '%')
as percentage_contribution
from order_details as od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category;

--21. Revenue contribution from each pizza by pizza name

select pt.name, 
concat(cast(sum(p.price * od.quantity) / 
(select sum(p.price * od.quantity) 
from order_details od
join pizzas p on od.pizza_id = p.pizza_id
)* 100.0 as decimal(10,2)), '%')
as revenue_contribution
from order_details as od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by revenue_contribution desc;

--22. Commulative Revenue generated over time (commulatice Revenue of everyday)

with cte as (
select date, cast(sum(p.price * od.quantity) as decimal (10,2)) as revenue 
from orders as o
join order_details as od on o.order_id = od.order_id
join pizzas as p on od.pizza_id = p.pizza_id
group by date
--order by revenue desc
)
select Date, Revenue, sum(Revenue) over (order by date) as cumulative_sum
from cte 
group by date, Revenue;

--23. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with cte as (
select category, name, cast(sum(p.price * od.quantity) as decimal(10,2)) as revenue
from order_details as od
join pizzas as p on p.pizza_id = od.pizza_id
join pizza_types as pt on pt.pizza_type_id = p.pizza_type_id
group by category, name
-- order by category, name, Revenue desc
)
, cte1 as (
select category, name, revenue,
rank() over (partition by category order by revenue desc) as rnk
from cte 
)
select category, name, revenue
from cte1 
where rnk in (1,2,3)
order by category, name, revenue;

--24. Monthly revenue trend

select datepart(year, date) as year, datepart(month, date) as month, 
sum(p.price * od.quantity) as monthly_revenue
from orders as o
join order_details as od on o.order_id = od.order_id
join pizzas as p on od.pizza_id = p.pizza_id
group by datepart(year, date), datepart(month, date)
order by year, month;














