-- NexusMart Schema Creation Script
DROP DATABASE IF EXISTS nexusmart;
CREATE DATABASE nexusmart;
USE nexusmart;

-- 1. Independent Tables
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT NULL,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100)
);

CREATE TABLE promotions (
    promotion_id INT AUTO_INCREMENT PRIMARY KEY,
    promo_code VARCHAR(20) UNIQUE NOT NULL,
    discount_percent DECIMAL(5,2) CHECK (discount_percent BETWEEN 0 AND 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

-- 2. Dependent Tables with Foreign Keys
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_line1 VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postcode VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    weight_kg DECIMAL(10, 2),
    category_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Processing',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 3. Junction Tables for M:M Relationships
CREATE TABLE product_suppliers (
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    cost_price DECIMAL(10, 2) NOT NULL CHECK (cost_price >= 0),
    PRIMARY KEY (product_id, supplier_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE wishlist (
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id, product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE promotion_products (
    promotion_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (promotion_id, product_id),
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- 4. Subsequent Tables
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    carrier VARCHAR(50) NOT NULL,
    tracking_number VARCHAR(100),
    shipped_date DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE shipment_items (
    shipment_id INT NOT NULL,
    order_item_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (shipment_id, order_item_id),
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id) ON DELETE CASCADE
);

CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 5. Performance Optimization: Indexes
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_shipments_order ON shipments(order_id);

-- --------------------------------------------------------
-- SAMPLE DATA INSERTION

-- 1. Insert into independent tables
INSERT INTO customers (first_name, last_name, email, date_of_birth) VALUES
('Alice', 'Smith', 'alice.smith@email.com', '1985-07-22'),
('Bob', 'Jones', 'bob.jones@email.com', '1992-11-03'),
('Charlie', 'Brown', 'charlie.brown@email.com', '1978-03-15'),
('Diana', 'Prince', 'diana.prince@email.com', '1990-12-01'),
('Evan', 'Davis', 'evan.davis@email.com', '1988-05-19');

INSERT INTO categories (category_name, parent_category_id) VALUES
('Electronics', NULL),
('Home & Kitchen', NULL),
('Computers', 1), -- parent is Electronics
('Smartphones', 1), -- parent is Electronics
('Furniture', 2); -- parent is Home & Kitchen

INSERT INTO suppliers (supplier_name, contact_email) VALUES
('TechCorp Inc.', 'procurement@techcorp.com'),
('HomeGoods Ltd.', 'orders@homegoods.ltd'),
('Global Parts', 'contact@globalparts.com');

INSERT INTO promotions (promo_code, discount_percent, start_date, end_date) VALUES
('WELCOME10', 10.00, '2025-01-01', '2025-12-31'),
('SUMMER25', 25.00, '2025-06-01', '2025-08-31');

-- 2. Insert into dependent tables
INSERT INTO addresses (customer_id, address_line1, city, postcode, country, is_primary) VALUES
(1, '123 Maple Street', 'London', 'W1A 1AA', 'United Kingdom', TRUE),
(2, '456 Oak Avenue', 'Manchester', 'M1 1AB', 'United Kingdom', TRUE),
(3, '789 Pine Road', 'Glasgow', 'G1 1AC', 'United Kingdom', TRUE),
(1, '321 Birch Lane', 'Brighton', 'BN1 1AD', 'United Kingdom', FALSE); -- Alice's secondary address

INSERT INTO products (product_name, description, weight_kg, category_id) VALUES
('UltraBook Pro', '13-inch laptop, 16GB RAM, 512GB SSD', 1.30, 3),
('Phoenix Smartphone', '6.7-inch display, 128GB storage', 0.20, 4),
('ErgoChair Deluxe', 'Adjustable office chair with lumbar support', 18.50, 5),
('Stainless Steel Kettle', '1.7L, fast-boiling, cordless', 1.10, 2);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2025-09-10 10:34:09', 'Delivered'),
(2, '2025-09-15 14:23:01', 'Shipped'),
(3, '2025-09-17 09:11:45', 'Processing'),
(1, '2025-09-18 16:45:22', 'Processing'); -- Alice's second order

-- 3. Insert into junction tables
INSERT INTO product_suppliers (product_id, supplier_id, cost_price) VALUES
(1, 1, 799.99), -- UltraBook supplied by TechCorp
(2, 1, 350.50), -- Phone supplied by TechCorp
(2, 3, 345.00), -- Phone ALSO supplied by Global Parts (M:M example)
(3, 2, 89.99), -- Chair supplied by HomeGoods
(4, 2, 24.50); -- Kettle supplied by HomeGoods

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 999.99), -- Order #1: 1 x UltraBook
(1, 2, 1, 499.99), -- Order #1: 1 x Phone
(2, 3, 2, 129.99), -- Order #2: 2 x Chairs
(3, 4, 1, 39.99), -- Order #3: 1 x Kettle
(4, 2, 1, 479.99); -- Order #4: 1 x Phone (on sale)

INSERT INTO wishlist (customer_id, product_id) VALUES
(2, 1), -- Bob wishes for an UltraBook
(4, 3), -- Diana wishes for a Chair
(4, 4); -- Diana also wishes for a Kettle

INSERT INTO promotion_products (promotion_id, product_id) VALUES
(2, 2); -- The SUMMER25 promotion applies to the Phoenix Smartphone

-- 4. Insert into subsequent tables
INSERT INTO payments (order_id, payment_method, amount, status, payment_date) VALUES
(1, 'Credit Card', 1499.98, 'Completed', '2025-09-10 10:35:01'), -- Pays for full order #1
(2, 'PayPal', 259.98, 'Completed', '2025-09-15 14:24:05'), -- Pays for full order #2
(3, 'Debit Card', 39.99, 'Completed', '2025-09-17 09:13:20'), -- Pays for full order #3
(4, 'Credit Card', 479.99, 'Pending', '2025-09-18 16:46:10'); -- Payment pending for order #4

INSERT INTO shipments (order_id, carrier, tracking_number, shipped_date) VALUES
(1, 'Royal Mail', 'RM123456789GB', '2025-09-11 08:00:00'),
(2, 'DPD', 'DPD987654321', '2025-09-16 12:30:00');

INSERT INTO shipment_items (shipment_id, order_item_id, quantity) VALUES
(1, 1, 1), -- Shipment #1 contains the UltraBook from order #1
(1, 2, 1), -- Shipment #1 ALSO contains the Phone from order #1
(2, 3, 2); -- Shipment #2 contains the 2 Chairs from order #2

INSERT INTO reviews (product_id, customer_id, rating, comment) VALUES
(1, 1, 5, 'Incredible performance and battery life!'),
(2, 1, 4, 'Great phone, but the camera could be better.');

-- --------------------------------------------------------
-- VIEW CREATION
-- --------------------------------------------------------

-- View 1: A summary view for customer analytics
CREATE VIEW customer_order_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS number_of_orders,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_lifetime_value,
    MAX(o.order_date) AS most_recent_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, customer_name;

-- View 2: A performance/trend view for sales analysis
CREATE VIEW monthly_sales_performance AS
SELECT
    YEAR(o.order_date) AS year_num,
    MONTHNAME(o.order_date) AS month_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(oi.order_item_id) AS total_items_sold,
    SUM(oi.quantity * oi.unit_price) AS total_sales_value,
    AVG(oi.quantity * oi.unit_price) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status != 'Cancelled' -- Exclude cancelled orders
GROUP BY YEAR(o.order_date), MONTH(o.order_date), MONTHNAME(o.order_date)
ORDER BY year_num, MONTH(o.order_date);

-- --------------------------------------------------------
-- ADVANCED SQL QUERIES FOR ANALYTICS
-- --------------------------------------------------------
-- Query 1: Multi-Table JOINs and Aggregation with GROUP BY
-- Business Question: What is the total sales value and number of units sold for each product category?
SELECT
    c.category_name,
    COUNT(oi.order_item_id) AS total_units_sold,
    CONCAT('£', FORMAT(SUM(oi.quantity * oi.unit_price), 2)) AS total_revenue
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status != 'Cancelled' -- Filter out cancelled orders
GROUP BY c.category_name
ORDER BY total_revenue DESC;




-- Query 2: Conditional Logic with CASE
-- Business Question: How are our products performing based on sales, and how can we classify them?
SELECT
    p.product_name,
    COUNT(oi.order_item_id) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue,
    CASE
        WHEN SUM(oi.quantity * oi.unit_price) > 1000 THEN 'High Performer'
        WHEN SUM(oi.quantity * oi.unit_price) BETWEEN 500 AND 1000 THEN 'Medium Performer'
        WHEN SUM(oi.quantity * oi.unit_price) > 0 THEN 'Low Performer'
        ELSE 'Not Sold'
    END AS performance_category
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status != 'Cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;




-- Query 3: Correlated Subquery
-- Business Question: Which customers have not placed any orders, making them targets for re-engagement?
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    email
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id -- Correlates with the outer query
);




-- Query 4: Window Function for Ranking
-- Business Question: Who are our top-spending customers each month, and what is their ranking?
SELECT
    customer_name,
    year_num,
    month_name,
    total_monthly_spend,
    RANK() OVER (PARTITION BY year_num, month_name ORDER BY total_monthly_spend DESC) AS monthly_rank
FROM (
    SELECT
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        YEAR(o.order_date) AS year_num,
        MONTHNAME(o.order_date) AS month_name,
        SUM(oi.quantity * oi.unit_price) AS total_monthly_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'Cancelled'
    GROUP BY c.customer_id, customer_name, year_num, month_name
) AS monthly_customer_spend;




-- Query 5: Complex JOIN with HAVING Clause
-- Business Question: Find products that are frequently bought together to inform bundle offers and recommendations.
SELECT
    p1.product_name AS first_product,
    p2.product_name AS second_product,
    COUNT(*) AS times_bought_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id 
JOIN products p1 ON oi1.product_id = p1.product_id
JOIN products p2 ON oi2.product_id = p2.product_id
GROUP BY oi1.product_id, oi2.product_id, p1.product_name, p2.product_name
HAVING times_bought_together >= 1 -- In a larger dataset, you would set a higher threshold
ORDER BY times_bought_together DESC;

-- Query Optimization
-- Optimized Query: Total revenue per product for delivered orders
SELECT p.product_name, SUM(oi.quantity * oi.unit_price) AS revenue 
FROM products p 
JOIN order_items oi ON p.product_id = oi.product_id 
JOIN orders o ON oi.order_id = o.order_id 
WHERE o.status = 'Delivered' 
GROUP BY p.product_name 
HAVING revenue > 100 
ORDER BY revenue DESC;