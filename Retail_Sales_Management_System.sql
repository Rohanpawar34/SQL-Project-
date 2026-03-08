-- ---------------------------------------------------------
-- DATABASE: retail_sales_management
-- ---------------------------------------------------------
CREATE DATABASE IF NOT EXISTS retail_sales_management;
Drop database retail_sales_management;
USE retail_sales_management;
-- ---------------------------------------------------------
-- TABLE: stores
-- ---------------------------------------------------------
 CREATE TABLE stores (
    store_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(150)
);
-- ---------------------------------------------------------
-- TABLE: customers
-- ---------------------------------------------------------
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- ---------------------------------------------------------
-- TABLE: products
-- ---------------------------------------------------------
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- ---------------------------------------------------------
-- TABLE: orders
-- ---------------------------------------------------------
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    store_id INT,
    total_amount DECIMAL(15,2) DEFAULT 0.00,
    payment_method ENUM('Cash', 'Card', 'UPI', 'Wallet') DEFAULT 'Cash',
    order_status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);
-- ---------------------------------------------------------
-- TABLE: order_items
-- ---------------------------------------------------------
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price_each DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(15,2) GENERATED ALWAYS AS (quantity * price_each) STORED,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- ---------------------------------------------------------
-- TABLE: audit_logs
-- ---------------------------------------------------------
CREATE TABLE audit_logs (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    actor VARCHAR(100),
    action VARCHAR(100),
    details TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- ---------------------------------------------------------
-- INSERTING VALUES INTO TABLES 
-- ---------------------------------------------------------
-- Stores
INSERT INTO stores (name, location) VALUES
('Downtown Store', 'MG Road, Bengaluru'),
('TechPark Store', 'Electronic City, Bengaluru'),
('Airport Store', 'Devanahalli, Bengaluru');

-- Customers
INSERT INTO customers (full_name, email, phone) VALUES
('Ravi Kumar', 'ravi.k@example.com', '9876543210'),
('Priya Shah', 'priya.s@example.com', '9876501234'),
('Anil Verma', 'anil.v@example.com', '9898123456'),
('Sneha Rao', 'sneha.r@example.com', '9998887776');

-- Products
INSERT INTO products (name, category, price, stock) VALUES
('Laptop', 'Electronics', 55000.00, 20),
('Wireless Mouse', 'Electronics', 800.00, 100),
('Office Chair', 'Furniture', 4500.00, 15),
('Standing Desk', 'Furniture', 12000.00, 10),
('Coffee Mug', 'Accessories', 250.00, 200),
('Notebook', 'Stationery', 80.00, 500);

-- Orders
INSERT INTO orders (customer_id, store_id, total_amount, payment_method, order_status)
VALUES
(1, 1, 56650.00, 'Card', 'Completed'),
(2, 2, 12800.00, 'UPI', 'Completed'),
(3, 3, 255.00, 'Cash', 'Completed'),
(4, 1, 4800.00, 'Wallet', 'Pending');

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, price_each)
VALUES
(1, 1, 1, 55000.00),
(1, 2, 2, 800.00),
(2, 4, 1, 12000.00),
(2, 5, 3, 250.00),
(3, 5, 1, 250.00),
(4, 3, 1, 4500.00),
(4, 6, 3, 100.00);

-- Audit Logs
INSERT INTO audit_logs (actor, action, details)
VALUES
('Admin', 'Order Created', 'Order #1 created for Ravi Kumar'),
('Admin', 'Order Completed', 'Order #2 completed for Priya Shah'),
('System', 'Stock Update', 'Reduced stock for product Laptop by 1'),
('Admin', 'Order Pending', 'Order #4 created for Sneha Rao');

-- ---------------------------------------------------------

-- Problem Statement 1 Display all store names and their locations.
SELECT store_id,name,location
FROM stores
WHERE location IS NOT NULL
ORDER BY store_id;

-- Problem Statement 2 List customers with formatted names and emails
SELECT 
    UPPER(full_name) AS customer_name,
    LOWER(email) AS email_lowercase,
    phone
FROM customers;

-- Problem Statement 3 Electronics products sorted by price rank
SELECT name, price,
    RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products
WHERE category = 'Electronics';

-- Problem Statement 4 Total customers grouped by the year they joined
SELECT 
    YEAR(created_at) AS joining_year,
    COUNT(*) AS total_customers
FROM customers
GROUP BY joining_year;

-- Problem Statement 5  Completed orders in last 30 days using date functions
SELECT order_id,customer_id,total_amount,created_at
FROM orders
WHERE order_status = 'Completed'
AND created_at >= NOW() - INTERVAL 30 DAY;

-- Problem Statement 6  Orders with customer & store 
SELECT 
    o.order_id,
    c.full_name AS customer,
    s.name AS store,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN stores s ON o.store_id = s.store_id;

-- Problem Statement 7  Total sales per store 
SELECT 
    s.name AS store,
    SUM(o.total_amount) AS total_sales
FROM stores s
JOIN orders o ON s.store_id = o.store_id
GROUP BY s.store_id
HAVING total_sales > 0;

-- Problem Statement 8 Number of orders per customer using LEFT JOIN
SELECT 
    c.full_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- Problem Statement 9 Total quantity sold per product using subquery
SELECT 
    p.name,
    (SELECT SUM(quantity) 
     FROM order_items oi 
     WHERE oi.product_id = p.product_id) AS total_qty
FROM products p;

-- Problem Statement 10 Revenue by product category using CASE
SELECT 
    CASE 
       WHEN category = 'Electronics' THEN 'Tech Products'
       ELSE 'Other Products'
    END AS product_group,
    SUM(oi.quantity * oi.price_each) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY product_group;

-- Problem Statement 11 Customers who spent more than 50,000
SELECT 
    c.full_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING total_spent > 50000;

-- Problem Statement 12 Orders paid via UPI with LIMIT
SELECT order_id,total_amount,payment_method
FROM orders
WHERE payment_method = 'UPI'
LIMIT 5;

-- Problem Statement 13 Completed & pending orders per store using UNION
SELECT 
    s.name AS store,
    o.order_status,
    COUNT(*) AS total_orders
FROM stores s
JOIN orders o ON s.store_id = o.store_id
WHERE o.order_status = 'Completed'
GROUP BY s.store_id
UNION
SELECT 
    s.name,
    o.order_status,
    COUNT(*)
FROM stores s
JOIN orders o ON s.store_id = o.store_id
WHERE o.order_status = 'Pending'
GROUP BY s.store_id;

-- Problem Statement 14 Top 5 best-selling products using ORDER BY + LIMIT
SELECT p.name,
    SUM(oi.quantity) AS total_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_sold DESC
LIMIT 5;
