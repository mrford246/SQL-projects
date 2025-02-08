-- Calculate the average order amount for each country 

SELECT ROUND(AVG(priceEach * quantityOrdered),2) AS order_value, customers.country
FROM orderdetails
LEFT JOIN orders ON orderdetails.orderNumber = orders.orderNumber
LEFT JOIN customers ON orders.customerNumber = customers.customerNumber
GROUP BY customers.country;

-- Calculate the total sales amount for each product line 
SELECT products.productline, SUM(quantityOrdered * priceEach) AS total_sales_amount 
FROM orderdetails
INNER JOIN products ON orderdetails.productCode = products.productCode
GROUP BY products.productline;

-- List the top 10 best-selling products based on total quantity sold 
SELECT productName, SUM(quantityOrdered) AS units_sold
FROM products p
INNER JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY productName
ORDER BY units_sold DESC
LIMIT 10;


-- Evaluate the sales peformance of each sales representative 
SELECT salesRepEmployeeNumber, SUM(quantityOrdered) AS products_sold 
FROM customers c
INNER JOIN orders o ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY salesRepEmployeeNumber
ORDER BY products_sold DESC;


-- Calculate the percentage of orders that were shipped on time orders 

SELECT SUM(CASE WHEN shippedDate <= requiredDate THEN 1 ELSE 0 END)/ COUNT(orderNumber) *100 AS Percentage_of_orders_on_time 
FROM Classicmodels.orders;



-- Calculate the average number of orders placed by each customer
SELECT CustomerNumber, avg((COUNT(DISTINCT orderNumber))) as Average_Customer_Order
FROM classicmodels.orders
GROUP BY customerNumber; 

-- calculate the profit margin for each product by subtracting the cost of goods sold (COGS) from the sales revenue 
SELECT productName, SUM((quantityOrdered * priceEach) - (buyPrice * quantityOrdered)) AS profit_margin
FROM classicmodels.products a 
INNER JOIN classicmodels.orderdetails b 
ON a.productCode = b.productCode
GROUP BY productName;

-- segment customers based on their total purchase amount 
SELECT c.*, t2.customer_segment
FROM customers c
LEFT JOIN
(SELECT *,
CASE WHEN TotalPurchaseAmount > 100000 THEN 'High Value'
	 WHEN TotalPurchaseAmount BETWEEN  50000 AND 100000 THEN 'Medium Value'
	 WHEN TotalPurchaseAmount < 50000 THEN 'Low Value'
ELSE 'Other' END AS customer_segment
FROM
	(SELECT customerNumber, SUM(priceEach*quantityOrdered) as TotalPurchaseAmount
	FROM classicmodels.orders a
	INNER JOIN classicmodels.orderdetails b
	ON a.orderNumber = b.orderNumber
	GROUP BY customerNumber) t1
    )t2
ON c.customernumber = t2.customernumber;

-- Identify frequently co-purchased products to understand cross-seeling opportunities 
SELECT a.productCode, b.productName, a2.productCode, b2.productName, COUNT(*) as purchased_together
FROM classicmodels.orderdetails a 
INNER JOIN classicmodels.orderdetails a2
ON a.orderNumber = a2.orderNumber AND a.productCode <> a2.productCode
INNER JOIN products b
ON a.productCode = b.productCode
INNER JOIN	products b2
ON a2.productCode = b2.productCode 
GROUP BY a.productCode, b.productName, a2.productCode, b2.productName
ORDER BY purchased_together DESC;


