-- retrieve the total number of orders placed
select count(order_id) as total_orders from orders;

-- calculate the total revenue generated from pizza sales 

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- identify the highest priced pizza,second highest priced pizza 

with my_cte as (select pizza_types.name,pizzas.price,dense_rank() over(order by pizzas.price desc) as rnk from pizza_types join pizzas on 
                 pizza_types.pizza_type_id=pizzas.pizza_type_id )

select name,price from my_cte
where rnk=1; -- for second highest priced pizza rnk=2




-- identify the most common pizza size ordered 

SELECT 
    quantity, COUNT(order_details_id)
FROM
    order_details
GROUP BY quantity;-- it shows that most of the time only single pizza was ordered 

SELECT 
    pizzas.size, COUNT(order_details.order_details_id)
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY COUNT(order_details.order_details_id) DESC; -- most ordered pizza size is L size then its M


-- LIST THE TOP 5 MOST ORDERED PIZZA TYPE ALONG WITH THEIR QUANTITY

SELECT 
    pizza_types.name, SUM(order_details.quantity)
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY SUM(order_details.quantity) DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category, SUM(order_details.quantity)
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY SUM(order_details.quantity) DESC;
 
 
 
-- Determine the distribution of orders by hour of the day.


SELECT 
    HOUR(time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(time)
ORDER BY HOUR(time);

SELECT 
    DAY(date), COUNT(order_id)
FROM
    orders
GROUP BY DAY(date)
ORDER BY COUNT(order_id) DESC;


-- Join relevant tables to find the category-wise distribution of pizzas.


SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;



-- Group the orders by date and calculate the average number of pizzas ordered per day.



SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_quantity;
    
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    CONCAT(ROUND(((SUM(pizzas.price * order_details.quantity)) / (SELECT 
                            SUM(order_details.quantity * pizzas.price)
                        FROM
                            order_details
                                JOIN
                            pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100,
                    2),
            '%') AS precent_conti
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;




-- Analyze the cumulative revenue generated over time.


select date,sum(revenue) over(order by date) as cum_revenue from
(select orders.date, sum(order_details.quantity * pizzas.price) as revenue from order_details 
join pizzas on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by orders.date) as sales;




-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name,revenue,rnk from (select category,name,revenue,dense_rank() over(partition by category order by revenue desc) as rnk from 
(select pizza_types.category,pizza_types.name,sum(order_details.quantity*pizzas.price) as revenue from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category,pizza_types.name) as result) as result1
where rnk<=3