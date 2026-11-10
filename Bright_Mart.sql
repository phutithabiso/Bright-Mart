CREATE DATABASE brightmart;
--Create customers table
CREATE TABLE customers (
    customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
--Create products table
CREATE TABLE products(
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
--Create orders table
 create Table orders(
    order_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_order_customer
    FOREIGN KEY(customer_id)
    REFERENCES customers(customer_id),
    Constraint fk_order_status
    Check (status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'))
 );
 --Create order_items table
  CREATE TABLE order_items(
    order_item_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    --foreign key constraints and unique constraint
    CONSTRAINT fk_order_items_order
    FOREIGN KEY(order_id)
    REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_product
    FOREIGN KEY(product_id) 
    REFERENCES products(product_id),
    CONSTRAINT  uq_order_product UNIQUE(order_id, product_id)
  );
INSERT INTO customers (first_name, last_name, email, phone)
VALUES
    ('Aisha', 'Khumalo', 'aisha@example.com', '0710000001'),INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES
    (1, 1, 2, 249.99),
    (1, 3, 1, 99.50),
    (2, 2, 1, 899.00);
    ('Daniel', 'Mokoena', 'daniel@example.com', '0720000002'),
    ('Lerato', 'Dlamini', 'lerato@example.com', '0730000003'),
    ('Sipho', 'Nkosi', 'sipho@example.com', '0740000004'),
    ('Thabo', 'Mabena', 'thabo@example.com', '0750000005'),
    ('Zanele', 'Mthembu', 'zanele@example.com', '0760000006'),
    ('Nokuthula', 'Mkhize', 'nokuthula@example.com', '0770000007')
ON CONFLICT DO NOTHING;
INSERT INTO products (product_name, description, price, stock_quantity)
VALUES
    ('Wireless Mouse', 'Wireless computer mouse', 249.99, 30),
    ('Mechanical Keyboard', 'USB mechanical keyboard', 899.00, 15),
    ('USB-C Cable', 'One metre USB-C cable', 99.50, 50),
    ('HD Webcam', '1080p HD webcam with built-in microphone', 499.99, 20),
    ('External Hard Drive', '1TB external hard drive', 1299.00, 10),
    ('Bluetooth Speaker', 'Portable Bluetooth speaker with 10-hour battery life', 699.00, 25);

--create a view to display customer information
SELECT customer_id, first_name, last_name
FROM customers
ORDER BY customer_id;

--insert sample orders into the orders table
INSERT INTO orders (customer_id, status)
VALUES
    (1, 'Processing'),
    (2, 'Pending'),
    (3, 'Cancelled'),
    (4, 'Pending'),
    (5, 'Shipped'),
    (6, 'Delivered'),
    (7, 'Processing');

    SELECT order_id, customer_id, status FROM orders;
SELECT product_id, product_name, price FROM products;

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES
    (12, 1, 2, 249.99),
    (13, 2, 1, 899.00);

--display all customers, products, orders, and order items
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

--Retrieve only names and email addresses
SELECT first_name, last_name, email
FROM customers;

--Retrieve product names and prices 
SELECT product_name AS product, 
         price AS unit_price
FROM products

-- see products with a price greater than 200.00 
Select product_name, price
FROM products
WHERE price > 200.00;

--The manager wants products costing more than R100 and with at least 20 units in stock.
SELECT product_name, price, stock_quantity
FROM products
Where price >100
and stock_quantity >= 20;

--A manager may want to find product names containing the word “USB
SELECT product_name
FROM products
WHERE product_name LIKE '%USB%';

SELECT product_name
FROM products
WHERE product_name ILIKE '%keyboard%';

---The manager wants to see all orders that have been delivered or shipped.
SELECT order_id, status
FROM orders
WHERE status IN ('Delivered', 'Shipped');

---The manager wants to d products priced between R100 and R1000
SELECT product_name, price
FROM products
WHERE price BETWEEN 100 AND 500;

-- the manager wants to see all products sorted by price in descending order.
SELECT product_name, price
FROM products
ORDER BY price DESC;

-- the manager wants to see all products sorted by name in ascending order.
SELECT product_name, price
FROM products
ORDER BY product_name ASC;
--- the manager wants to see all products sorted by stock quantity in ascending order and then by price in descending order.
SELECT product_name, stock_quantity, price
FROM products
ORDER BY stock_quantity ASC, price DESC;

--inner join to display order details along with customer names
Select 
    orders.order_id,
    customers.first_name,
    customers.last_name,
    orders.status
From orders
INNER JOIN customers 
ON orders.customer_id = customers.customer_id;  

---inner join to display order details along with customer names
Select 
    o.order_id,
    c.first_name,
    c.last_name,
    o.status
FROM orders AS o
INNER JOIN customers AS c
ON o.customer_id = c.customer_id;

---inner join to display order details along with customer names and product details
SELECT 
    o.order_id,
    c.first_name,
    p.product_name,
    oi.quantity,
    oi.unit_price
From orders as o
INNER JOIN customers AS c 
ON o.customer_id  = c.customer_id
INNER JOIN order_items AS oi
ON o.order_id = oi.order_id
INNER JOIN products AS p
ON oi.product_id = p.product_id;

---left join to display all customers and their orders, including those without orders
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

--right join to display all orders and their customers, including those without customers
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- the current  value of the stock quantity for a specific product, such as the "USB-C Cable."
SELECT product_id, product_name, price
FROM products
WHERE product_name = 'USB-C Cable';

-- update the price of the "USB-C Cable" to a new value, such as 109.50.
UPDATE products
SET price = 109.50
WHERE product_name = 'USB-C Cable';

-- verify that the price has been updated by retrieving the product name and price again.
SELECT product_name, price
FROM products
WHERE product_name = 'USB-C Cable';

--correct the stock quantity for the "USB-C Cable" to a new value, such as 45.
UPDATE products
SET
    stock_quantity = 45,
    description = 'One metre USB-C charging and data cable'
WHERE product_name = 'USB-C Cable';

--alter the customer table to add a new column for storing the city of each customer.
Alter TABLE customers
ADD COLUMN citys VARCHAR(100);
--change the name of the column "phone" to "phone_number" in the customers table.
ALTER TABLE customers
RENAME COLUMN phone TO phone_number;

---alter the data type of the "city" column to allow for longer city names, such as VARCHAR(100).
Alter TABLE customers
ALTER COLUMN citys TYPE VARCHAR(100);

--alter the "city" column to allow NULL values, as not all customers may have a city specified.
ALTER TABLE customers
DROP COLUMN citys;

-- we identify a specific customer by their email address, such as "daniel@example.com"
SELECT customer_id, first_name, last_name, email
FROM customers
WHERE  email = 'test@example.com';

-- we want to remove this customer from the database, we can use the DELETE statement to delete their record from the customers table.
DELETE FROM customers
WHERE email = 'sipho@example.com';

--begin a transaction to update the price of the "USB-C Cable" and ensure that the change is atomic and can be rolled back if needed.
BEGIN;
---update the price of the "USB-C Cable" to a new value, such as 119.50.
UPDATE products
SET price = 119.50
WHERE product_name = 'USB-C Cable';
--If the update is successful, we can commit the transaction to make the changes permanent.
COMMIT;
---If we want to undo the changes made in the transaction, we can use the ROLLBACK statement to revert the database to its previous state.
ROLLBACK;

--sum of all sales made by multiplying the quantity of each order item by its unit price and summing the results.
SELECT SUM(oi.quantity * oi.unit_price) AS total_sales
FROM order_items AS oi

--average price of all products in the products table.
SELECT AVG(price) AS average_price
FROM products;

---average price of all products in the products table rounded to two decimal places.
SELECT ROUND(AVG(price), 2) AS average_price
FROM products;

---total number of customers in the customers table.
SELECT COUNT(*) ASC total_customers
FROM customers;

---total number of products in the products table.
SELECT COUNT(*) AS total_products
FROM products;


SELECT MIN(price) AS lowest_price,
 MAX(price) AS highest_price
FROM products;

-- group by order_id to calculate the total amount for each order by multiplying the quantity of each order item by its unit price and summing the results for each order.
SELECT order_id,
 SUM (oi.quantity * oi.unit_price) AS order_total
FROM order_items AS oi
GROUP BY order_id
ORDER BY order_total DESC;

