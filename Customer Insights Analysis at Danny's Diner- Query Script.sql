USE dannys_diner;

SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;

#1. What is the total amount each customer spent at the restaurant?
SELECT
    s.customer_id,
    SUM(m.price) AS total_amount_spent
FROM
    sales s
JOIN
    menu m ON s.product_id = m.product_id
GROUP BY
    s.customer_id
ORDER BY 
	s.customer_id;


 #2. How many days has each customer visited the restaurant?
  SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS visit_days
FROM
    sales
GROUP BY
    customer_id;
    
    
#3. What was the first item from the menu purchased by each customer?
  WITH cte_order AS (
	SELECT 
		s.customer_id,
        m.product_name AS first_item,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS item_order
	FROM
        sales s
     JOIN
        menu m ON s.product_id = m.product_id
  )
SELECT customer_id,
       first_item 
FROM cte_order
WHERE item_order = 1;
    
    
#4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
    m.product_name,
    COUNT(*) AS purchase_count
FROM
    sales s
JOIN
    menu m ON s.product_id = m.product_id
GROUP BY
    m.product_name
ORDER BY
    purchase_count DESC
LIMIT 1;


#5. Which item was the most popular for each customer?
WITH cte_order_count AS(
	SELECT
        s.customer_id,
        m.product_name,
        COUNT(*) AS order_count,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS Pop_rank
     FROM
        sales s
     JOIN
        menu m ON s.product_id = m.product_id
     GROUP BY
        s.customer_id, m.product_name
)
SELECT
    customer_id,
    product_name,
    MAX(order_count) AS max_purchase
FROM 
	 cte_order_count
WHERE 
	Pop_rank = 1
GROUP BY 
	customer_id,
    product_name;
    
    
# 6. Which item was purchased first by the customer after they became a member?
WITH orders_by_customer AS(
SELECT
	s.customer_id, 
    s.product_id, 
    m.product_name,
    mb.join_date,
    s.order_date,
    ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ) AS row_num
FROM 
	sales s
JOIN 
	menu m ON s.product_id = m.product_id
JOIN
	members mb ON s.customer_id = mb.customer_id
WHERE 
	s.order_date > mb.join_date)

SELECT customer_id, product_name
FROM orders_by_customer
WHERE row_num = 1;


#7. Which item was purchased just before the customer became a member?
WITH orders_by_customer AS(
SELECT
	s.customer_id, 
    s.product_id, 
    m.product_name,
    s.order_date,
    mb.join_date,
    RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC ) AS rank_num
FROM 
	sales s
JOIN 
	menu m ON s.product_id = m.product_id
JOIN
	members mb ON s.customer_id = mb.customer_id
WHERE 
	s.order_date < mb.join_date)

SELECT customer_id, product_name
FROM orders_by_customer
WHERE rank_num = 1;


#8. What is the total items and amount spent for each member before they became a member?
SELECT
    s.customer_id,
    COUNT(s.product_id) AS total_items,
    SUM(m.price) AS total_amount_spent
FROM
    sales s
JOIN
    menu m ON s.product_id = m.product_id
JOIN
    members mb ON s.customer_id = mb.customer_id
WHERE
    s.order_date < mb.join_date
GROUP BY
    s.customer_id
ORDER BY 
	s.customer_id;


#9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier—how many points would each customer have?
SELECT
	s.customer_id,
    SUM(CASE 
		WHEN m.product_name = 'sushi' THEN m.price*20
        ELSE m.price*10
	END) AS Total_Points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;


#10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi—how many points do customer A and B have at the end of January?
SELECT 
	s.customer_id,
	SUM(CASE 
		WHEN m.product_name = 'sushi' THEN m.price * 20
        WHEN s.order_date BETWEEN mb.join_date AND mb.join_date + '6 day' THEN m.price * 20
        ELSE m.price * 10
	END) AS Total_Points
FROM
    sales s
JOIN
    menu m ON s.product_id = m.product_id
JOIN
    members mb ON s.customer_id = mb.customer_id
WHERE 
	s.order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY s.customer_id;

