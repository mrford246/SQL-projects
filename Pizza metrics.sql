-- Pizza Metrics
-- How many pizzas were ordered?
SELECT count(order_id) AS pizza_ordered
FROM customer_orders;

-- How many unique customer orders were made?
SELECT DISTINCT (pizza_id AND exclusions AND extras) AS unique_orders, customer_id
FROM customer_orders
WHERE pizza_id AND exclusions AND extras  > 0;

-- How many vegetarian and meatlovers were ordered by each customer  
SELECT  DISTINCT a.customer_id,
SUM(CASE WHEN c.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS Number_of_MeatLovers_Ordered, 
SUM(CASE WHEN c.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS Number_of_Vegetarians_Ordered
FROM customer_orders a
INNER JOIN pizza_names c
ON a.pizza_id = c.pizza_id  
GROUP BY a.customer_id
ORDER BY a.customer_id;


-- What was the maximum number of pizzas delivered in a single order?
SELECT order_id, COUNT(pizza_id) as Number_Of_Pizzas_Ordered
FROM customer_orders
GROUP BY order_id
ORDER BY Number_Of_Pizzas_Ordered DESC
LIMIT 1;

-- What was the average time in minutes it took each runner to arrive at the Pizza Runner HQ to pickup the order - come back to 

SELECT 
    b.runner_id,
    AVG(TIMESTAMPDIFF(
        MINUTE, 
        a.order_time, 
        STR_TO_DATE(b.pickup_time, '%Y-%m-%d %H:%i:%s')
    )) AS Average_pick_up_time
FROM customer_orders a
LEFT JOIN runner_orders b
ON a.order_id = b.order_id  
WHERE b.pickup_time IS NOT NULL 
  AND STR_TO_DATE(b.pickup_time, '%Y-%m-%d %H:%i:%s') IS NOT NULL
GROUP BY b.runner_id;

-- What are the standard ingredients for each pizza? 
SELECT p.pizza_id, a.topping, b.topping_name
FROM pizza_recipes p
JOIN JSON_TABLE(
     CONCAT('["', REPLACE(p.toppings, ',', '","'), '"]'), 
     "$[*]" COLUMNS (topping VARCHAR(4) PATH "$")
) AS a
JOIN pizza_toppings b
ON a.topping = b.topping_id
WHERE pizza_id = '2' or '1'
ORDER BY pizza_id;

-- what was the most commonly added extra?

SELECT jt.extra_number , b.topping_name, COUNT(topping_name) as times_topping_chosen
FROM customer_orders a
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(a.extras, ',', '","'), '"]'), 
    "$[*]" COLUMNS (extra_number VARCHAR(4) PATH "$")
) AS jt
LEFT JOIN pizza_toppings b 
ON jt.extra_number  = b.topping_id
WHERE topping_name IS NOT NULL
GROUP BY jt.extra_number, b.topping_name
ORDER BY times_topping_chosen DESC
LIMIT 1;


-- If a Meat Lovers Pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees    
SELECT 
	SUM(CASE WHEN pizza_name = 'MeatLovers' THEN 12 ELSE 0 END) AS Income_MeatLovers,
	SUM(CASE WHEN pizza_name = 'Vegetarian' THEN 10 ELSE 0 END) AS Income_Vegetarian,
   SUM(CASE WHEN pizza_name = 'MeatLovers' THEN 12 ELSE 0 END) +
   SUM(CASE WHEN pizza_name = 'Vegetarian' THEN 10 ELSE 0 END) AS Total_Income
FROM pizza_names a
LEFT JOIN customer_orders b 
ON a.pizza_id = b.pizza_id;
