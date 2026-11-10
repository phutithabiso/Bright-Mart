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


SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
