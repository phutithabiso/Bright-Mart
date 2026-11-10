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

    CONSTRAINT fk_order_items_order
    FOREIGN KEY(order_id)
    REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_product
    FOREIGN KEY(product_id) 
    REFERENCES products(product_id),
    CONSTRAINT  uq_order_product UNIQUE(order_id, product_id)
  );


select * from customers;

