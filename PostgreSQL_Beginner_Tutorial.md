# PostgreSQL Tutorial: Build a Small Shop Database

**Duration:** 5 hours (300 minutes)  
**Level:** Beginner  
**Tools:** PostgreSQL, `psql` or pgAdmin, a terminal, and Git  
**Scenario:** Build a database for a small shop that sells products to customers.

---

## What you will learn

By the end of this guided tutorial, you should be able to:

- Create and connect to a PostgreSQL database.
- Design related tables using primary keys and foreign keys.
- Insert, retrieve, filter, sort and update records.
- Join data from multiple tables.
- Use aggregate functions such as `SUM()` and `AVG()`.
- Limit the number of returned rows.
- Alter and delete data safely.
- Drop a table when it is no longer needed.
- Track your work with meaningful Git commits.

This is a hands-on tutorial, not a script to paste and run without thinking. Read each explanation, predict what a query will do, write it yourself, run it, inspect the result, and answer the checkpoint questions.

## Mandatory data-entry requirement

**Every table must contain at least 6 records (more than 5) by the end of Tutorial 4.** This applies to all four tables:

- `customers`: at least 6 customers.
- `products`: at least 6 products.
- `orders`: at least 6 orders.
- `order_items`: at least 6 order-item records.

The small sample inserts in the lessons are teaching examples, not the final required dataset. After practising those examples, add enough additional records to reach the minimum in every table. Use realistic, varied data rather than inserting the same values repeatedly.

Make sure that:
- Every customer has a different email address.
- Every order references a real `customer_id`.
- Every order item references a real `order_id` and `product_id`.
- Quantities and prices satisfy the table constraints.
- Your records include a useful mix of order statuses and product prices so that filtering, sorting, joins and aggregate queries return meaningful results.

At the end of Tutorial 4, verify the number of records in each table:

```sql
SELECT 'customers' AS table_name, COUNT(*) AS record_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
```

**Do not continue to Tutorial 5 until every table shows a `record_count` of at least 6.** If a table has fewer than 6 records, insert additional valid records and run the count query again.

## The five-hour schedule

| Tutorial | Topic | Time |
|---|---|---:|
| 1 | Setup, create a database and connect | 20 min |
| 2 | Plan the database and create tables | 40 min |
| 3 | Primary keys, foreign keys and relationships | 25 min |
| 4 | Insert data | 30 min |
| 5 | SELECT, filtering and sorting | 35 min |
| 6 | JOIN queries | 40 min |
| 7 | UPDATE, ALTER and DELETE | 35 min |
| 8 | SUM, AVG and other aggregate queries | 35 min |
| 9 | LIMIT, DROP TABLE and safe cleanup | 20 min |
| 10 | Review challenge and Git hand-in | 20 min |
| **Total** | | **300 min / 5 hours** |

> **Working rule:** Do not move to the next tutorial until you have run the current queries, checked the results and completed the checkpoint.

---

# Before you begin

## Required software

Install or make sure you have access to:

1. **PostgreSQL** – the database server.
2. **pgAdmin** or **psql** – a tool for running SQL.
3. **Git** – to track your progress.
4. **A code editor** – for example, IntelliJ IDEA or another editor.

You can use pgAdmin's Query Tool or the `psql` terminal throughout this tutorial. The SQL is the same.

## Create a Git repository

Create a folder for the tutorial and initialise Git inside it.

```bash
mkdir postgres-shop-tutorial
cd postgres-shop-tutorial
git init
```

Create a file named `README.md`. Add your name, the date you started, the PostgreSQL version you are using, and a short description of the project.

Check your repository:

```bash
git status
```

### Why use Git?

Git records changes to your work. If a query or database design changes later, your commit history helps you understand what you changed and when. A commit message should describe the work completed, not simply say “updates”.

**Git checkpoint**

```bash
git add README.md
git commit -m "docs: add PostgreSQL tutorial project README"
```

If Git asks you to configure your identity, set your name and email using the instructions Git displays. Use the email associated with your Git account if you want your commits linked to that account.

---

# Tutorial 1 – Create a database and connect

**Time: 20 minutes**

## 1.1 Understand what a database is

Imagine a small shop called **BrightMart**. The shop needs to keep track of:

- Customers who buy from the shop.
- Products the shop sells.
- Orders customers place.
- The products included in each order.

A database is an organised place to store and manage this information. PostgreSQL is a relational database management system. It stores information in tables and lets related tables refer to one another.

A database is not the same thing as a table:

- A **database** is the overall container for related data.
- A **table** stores one type of information.
- A **row** represents one record.
- A **column** represents one attribute of a record.

## 1.2 Open PostgreSQL

Using pgAdmin:

1. Open pgAdmin.
2. Connect to your local PostgreSQL server.
3. Open the Query Tool from the server or an existing database.
4. You may initially be connected to a default database such as `postgres`.

Using `psql`, connect to your PostgreSQL server with the username and host configured during installation. For example:

```bash
psql -U postgres -h localhost
```

You may be asked for your PostgreSQL password. This is the database password you configured during installation, not your Windows or computer password.

## 1.3 Create the project database

Create a database named `brightmart`:

```sql
CREATE DATABASE brightmart;
```

**What does this do?**

- `CREATE DATABASE` tells PostgreSQL to create a new database.
- `brightmart` is the name chosen for the database.
- The semicolon (`;`) marks the end of the SQL statement.

Database names are commonly written in lowercase to avoid unnecessary quoting in PostgreSQL.

### Connect to the new database

In `psql`, run:

```text
\c brightmart
```

In pgAdmin, refresh the Databases list, select `brightmart`, and open a Query Tool connected to it.

> `\c` is a `psql` meta-command, not standard SQL. In pgAdmin, select the database through the interface instead.

Confirm which database you are connected to:

```sql
SELECT current_database();
```

You should see `brightmart`.

## Checkpoint

Before continuing, answer these questions in your own words:

1. What is the difference between a database and a table?
2. Why did we create a separate `brightmart` database?
3. Which command did you use to connect to it?

**Git checkpoint**

Create a folder named `sql` in your project. Create `sql/01-create-database.sql` and record the database creation statement in it. (Keep connection commands such as `\\c` in your notes if you are using pgAdmin, because they are specific to `psql`.)

```bash
git add README.md sql/01-create-database.sql
git commit -m "feat: create BrightMart database"
```

---

# Tutorial 2 – Plan the database and create tables

**Time: 40 minutes**

## 2.1 Plan before writing SQL

A common beginner mistake is to put all information into one large table. For example, a single shop table might repeat a customer's name and address every time that customer places an order.

That creates problems:

- The same customer information is repeated.
- Updating an address may require changing many rows.
- It becomes easier for records to disagree.
- Deleting one order could accidentally remove information about a customer.

Instead, separate information into tables based on what it represents.

For BrightMart, we will create four tables:

| Table | What it stores |
|---|---|
| `customers` | Customer details |
| `products` | Products available for sale |
| `orders` | Orders placed by customers |
| `order_items` | Products and quantities belonging to an order |

The `order_items` table is important because one order can contain several products, and one product can appear in many orders.

## 2.2 Understand the CREATE TABLE statement

A table is created using `CREATE TABLE`.

General structure:

```sql
CREATE TABLE table_name (
    column_name data_type,
    another_column data_type
);
```

A **data type** tells PostgreSQL what kind of value a column can store.

Common PostgreSQL data types:

| Data type | Purpose | Example |
|---|---|---|
| `INTEGER` | Whole numbers | `25` |
| `BIGINT` | Larger whole numbers | Large identifiers |
| `VARCHAR(100)` | Text up to a chosen length | `'Keyboard'` |
| `TEXT` | Text without a declared length limit | Product description |
| `NUMERIC(10, 2)` | Exact decimal values | `1299.99` |
| `DATE` | Calendar date | `2026-11-10` |
| `TIMESTAMP` | Date and time | `2026-11-10 09:30:00` |
| `BOOLEAN` | True or false | `TRUE` |

For prices and money-like amounts, use `NUMERIC`, not floating-point types. `NUMERIC(10, 2)` stores exact decimal values with up to two digits after the decimal point.

## 2.3 Create the customers table

Think about what the shop needs to know about a customer. At minimum, it needs a name and an email address. It also needs a reliable way to identify each customer.

Before running the query, identify:
- Which column should uniquely identify a customer?
- Which columns should be compulsory?
- Should two customers be allowed to register with the same email address?

Now create the table:

```sql
CREATE TABLE customers (
    customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Understand the important parts

- `customer_id` identifies each customer.
- `GENERATED ALWAYS AS IDENTITY` lets PostgreSQL generate the identifier.
- `PRIMARY KEY` makes the identifier unique and prevents it from being `NULL`.
- `NOT NULL` means a value must be supplied.
- `UNIQUE` prevents duplicate email values.
- `DEFAULT CURRENT_TIMESTAMP` supplies the current date and time when a value is not provided.
- `phone` is optional because it has no `NOT NULL` rule.

A primary key is important because other tables need a dependable way to refer to a specific customer.

## 2.4 Create the products table

A shop needs to store the product name, price and available stock.

First decide why a product's price should use `NUMERIC(10, 2)` instead of `VARCHAR`.

Create the table:

```sql
CREATE TABLE products (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

Notice the `CHECK` constraints:

- `CHECK (price >= 0)` prevents negative prices.
- `CHECK (stock_quantity >= 0)` prevents negative stock.
- `DEFAULT 0` gives a new product zero stock if no quantity is provided.

A constraint is a rule enforced by the database. It protects data even if an application sends incorrect values.

## 2.5 Create the orders table

An order belongs to a customer. Therefore, the orders table needs a column that identifies the customer who placed it.

```sql
CREATE TABLE orders (
    order_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    CONSTRAINT chk_orders_status
        CHECK (status IN ('PENDING', 'PAID', 'SHIPPED', 'CANCELLED'))
);
```

The `customer_id` column in `orders` will refer to a customer in `customers`.

The foreign key ensures that an order cannot refer to a customer that does not exist. This protects the relationship between the tables.

## 2.6 Create the order_items table

An order can contain multiple products. Each row in `order_items` represents one product line within an order.

```sql
CREATE TABLE order_items (
    order_item_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CONSTRAINT uq_order_product
        UNIQUE (order_id, product_id)
);
```

Why store `unit_price` here if the product already has a price?

Because the product's current price may change after an order is placed. The order item should preserve the price that applied when the customer bought it. This is a practical example of storing a historical transaction value.

The `UNIQUE (order_id, product_id)` constraint prevents the same product from appearing twice as separate lines in one order. The quantity can represent multiple units.

## 2.7 Inspect your tables

In `psql`, list the tables:

```text
\dt
```

To inspect a table's columns and constraints in `psql`:

```text
\d customers
```

In pgAdmin, expand `Schemas` → `public` → `Tables`. Right-click a table and inspect its properties.

You can also use this SQL query to list tables in the current schema:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

## Checkpoint

1. Why do we keep customers and orders in separate tables?
2. Why does `orders` contain `customer_id`?
3. What could go wrong if `price` were stored as text?
4. What does the `CHECK (quantity > 0)` rule protect against?
5. Why does `order_items` store `unit_price`?

**Git checkpoint**

Save your table creation statements in `sql/02-create-tables.sql`. Put the parent tables (`customers` and `products`) before the tables that reference them (`orders` and `order_items`).

```bash
git add sql/02-create-tables.sql
git commit -m "feat: create shop tables and constraints"
```

---

# Tutorial 3 – Primary keys, foreign keys and relationships

**Time: 25 minutes**

## 3.1 Primary keys

A primary key uniquely identifies each row in a table.

For example, two customers may both be named “Alex Smith”. Their names are not reliable unique identifiers. Their `customer_id` values are.

A primary key:
- Must be unique.
- Cannot be `NULL`.
- Gives each row a stable identifier.
- Can be referenced by a foreign key in another table.

## 3.2 Foreign keys

A foreign key connects a row in one table to a valid row in another table.

In BrightMart:

- `orders.customer_id` references `customers.customer_id`.
- `order_items.order_id` references `orders.order_id`.
- `order_items.product_id` references `products.product_id`.

This is called **referential integrity**. It prevents records from referring to missing parent records.

## 3.3 Understand the relationships

- One customer can place many orders: **one-to-many**.
- One order can have many order items: **one-to-many**.
- One product can appear in many order items: **one-to-many**.
- Orders and products have a many-to-many relationship, implemented through the `order_items` linking table.

<details>
<summary>Relationship diagram in text</summary>

```text
CUSTOMERS
---------
customer_id (PK)
       |
       | one customer can place many orders
       |
       v
ORDERS
------
order_id (PK)
customer_id (FK)
       |
       | one order has many order items
       |
       v
ORDER_ITEMS
-----------
order_item_id (PK)
order_id (FK)
product_id (FK)
       ^
       | many order items can refer to one product
       |
PRODUCTS
--------
product_id (PK)
```

`PK` means primary key. `FK` means foreign key.

</details>

## 3.4 Observe referential integrity

After you have inserted the sample data in Tutorial 4, try to insert an order using a customer ID that does not exist.

For example, if your customer IDs are 1 and 2, try an order with `customer_id = 999999`.

PostgreSQL should reject it because the foreign key cannot find that customer.

Do not remove the foreign key just to make the insert work. The error is evidence that the constraint is protecting your data.

## Checkpoint

Explain the difference between a primary key and a foreign key. Give one example of each from BrightMart.

**Git checkpoint**

Add a short explanation of the relationships to `README.md`.

```bash
git add README.md
git commit -m "docs: explain primary and foreign key relationships"
```

---

# Tutorial 4 – Insert data into tables

**Time: 30 minutes**

## 4.1 Why do we insert data?

Creating a table creates its structure, not its records. The shop still needs customers, products and orders.

`INSERT INTO` adds new rows to a table.

General structure:

```sql
INSERT INTO table_name (column_one, column_two)
VALUES (value_one, value_two);
```

It is good practice to list the column names. This makes the query easier to read and reduces the chance of putting values in the wrong columns.

## 4.2 Insert customers

Start by adding two customers.

```sql
INSERT INTO customers (first_name, last_name, email, phone)
VALUES
    ('Aisha', 'Khumalo', 'aisha@example.com', '0710000001'),
    ('Daniel', 'Mokoena', 'daniel@example.com', '0720000002');
```

Notice that we did not supply `customer_id` or `created_at`. PostgreSQL generates the identity value and uses the default timestamp.

Run the query. Then retrieve the records:

```sql
SELECT * FROM customers;
```

Do not assume the IDs will always be a particular number. Identity sequences can advance even when an insert fails or a transaction is rolled back. Inspect the actual values in your database.

## 4.3 Insert products

Add three products:

```sql
INSERT INTO products (product_name, description, price, stock_quantity)
VALUES
    ('Wireless Mouse', 'Wireless computer mouse', 249.99, 30),
    ('Mechanical Keyboard', 'USB mechanical keyboard', 899.00, 15),
    ('USB-C Cable', 'One metre USB-C cable', 99.50, 50);
```

Consider why `price` is numeric and why `stock_quantity` is an integer.

Check what was inserted:

```sql
SELECT * FROM products;
```

## 4.4 Insert orders

Now create an order for each customer.

First, inspect the actual customer IDs:

```sql
SELECT customer_id, first_name, last_name
FROM customers
ORDER BY customer_id;
```

Use the IDs returned by your database in the next query. The example below assumes Aisha has ID `1` and Daniel has ID `2`. If your IDs differ, replace them with the values you actually retrieved.

```sql
INSERT INTO orders (customer_id, status)
VALUES
    (1, 'PAID'),
    (2, 'PENDING');
```

## 4.5 Insert order items

Inspect the actual order and product IDs before inserting the order items:

```sql
SELECT order_id, customer_id, status FROM orders;
SELECT product_id, product_name, price FROM products;
```

The following example assumes the IDs match the values shown above. Adjust them if your database generated different IDs.

```sql
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES
    (1, 1, 2, 249.99),
    (1, 3, 1, 99.50),
    (2, 2, 1, 899.00);
```

This represents:
- Order 1: two wireless mice and one USB-C cable.
- Order 2: one mechanical keyboard.

## 4.6 Verify your data

Run:

```sql
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
```

Compare the results with the records you intended to insert.

### Common INSERT errors

- **Duplicate key:** You tried to insert a value that violates a primary key or unique constraint.
- **Foreign key violation:** You supplied a customer, order or product ID that does not exist.
- **Not-null violation:** You omitted a required value.
- **Check constraint violation:** A value did not satisfy a rule, such as a negative price.

Read the error message. It often identifies the table and constraint that rejected the data.

## Checkpoint exercise

Continue adding realistic records until **each of the four tables has at least 6 records**. The examples above create only a starting dataset. Add enough customers and products, then create at least 6 valid orders and at least 6 valid order-item records in total. Ensure every foreign-key value refers to an existing record. Run the record-count verification query in the Mandatory data-entry requirement section before moving on.

Do not copy an existing customer's email address. The email column is unique.

**Git checkpoint**

Save your sample data statements in `sql/03-insert-sample-data.sql`. Use the IDs and values that make sense for your own database, and add a comment if your inserts depend on existing records.

```bash
git add sql/03-insert-sample-data.sql
git commit -m "feat: add BrightMart sample customers products and orders"
```

---

# Tutorial 5 – SELECT, filtering and sorting

**Time: 35 minutes**

## 5.1 Retrieve records with SELECT

A database is useful because an application can ask questions about stored information.

`SELECT` retrieves data. It does not change the stored rows.

Retrieve every column from the customers table:

```sql
SELECT * FROM customers;
```

The asterisk (`*`) means all columns. It is useful when exploring a table, but in application queries it is often better to select only the columns you need.

Retrieve only names and email addresses:

```sql
SELECT first_name, last_name, email
FROM customers;
```

This makes the result smaller and easier to understand.

## 5.2 Use column aliases

An alias gives a result column a more readable heading.

```sql
SELECT
    product_name AS product,
    price AS selling_price
FROM products;
```

`AS` does not rename the actual table column. It changes the label in the query result.

## 5.3 Filter records with WHERE

Imagine the shop manager wants to see products that cost more than R200.

```sql
SELECT product_name, price
FROM products
WHERE price > 200;
```

`WHERE` filters rows according to a condition.

Useful comparison operators:

| Operator | Meaning |
|---|---|
| `=` | Equal to |
| `<>` | Not equal to |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal to |
| `<=` | Less than or equal to |

Try these questions yourself:

1. Find products costing less than R300.
2. Find products with exactly 15 units in stock.
3. Find orders whose status is `PENDING`.

## 5.4 Combine conditions with AND and OR

The manager wants products costing more than R100 and with at least 20 units in stock.

```sql
SELECT product_name, price, stock_quantity
FROM products
WHERE price > 100
  AND stock_quantity >= 20;
```

`AND` requires both conditions to be true.

`OR` requires at least one condition to be true.

Try finding products that cost less than R150 or have fewer than 20 units in stock.

Use parentheses when combining `AND` and `OR` so the intended logic is clear.

## 5.5 Search text with LIKE

A manager may want to find product names containing the word “USB”.

```sql
SELECT product_name
FROM products
WHERE product_name LIKE '%USB%';
```

In a `LIKE` pattern:
- `%` represents zero or more characters.
- `_` represents exactly one character.

PostgreSQL also supports `ILIKE`, which performs a case-insensitive pattern match:

```sql
SELECT product_name
FROM products
WHERE product_name ILIKE '%keyboard%';
```

## 5.6 Filter using IN and BETWEEN

Find orders that are paid or shipped:

```sql
SELECT order_id, status
FROM orders
WHERE status IN ('PAID', 'SHIPPED');
```

Find products priced between R100 and R500:

```sql
SELECT product_name, price
FROM products
WHERE price BETWEEN 100 AND 500;
```

`BETWEEN` includes both boundary values.

## 5.7 Sort results with ORDER BY

The manager wants to see the most expensive products first.

```sql
SELECT product_name, price
FROM products
ORDER BY price DESC;
```

- `ASC` sorts from low to high (ascending).
- `DESC` sorts from high to low (descending).

If you do not specify a direction, PostgreSQL uses ascending order.

Sort products alphabetically:

```sql
SELECT product_name, price
FROM products
ORDER BY product_name ASC;
```

Sort by stock, then by price:

```sql
SELECT product_name, stock_quantity, price
FROM products
ORDER BY stock_quantity ASC, price DESC;
```

The second column is used to sort rows when the first column has equal values.

## Checkpoint exercise

Write queries to:

1. Display only customer names and emails.
2. Find products costing more than R200.
3. Find orders with a status of `PAID` or `SHIPPED`.
4. Search for product names containing `USB`, regardless of letter case.
5. Display products from most expensive to least expensive.

**Git checkpoint**

Save your retrieval and filtering examples in `sql/04-select-filter-sort.sql`.

```bash
git add sql/04-select-filter-sort.sql
git commit -m "feat: add select filtering and sorting examples"
```

---

# Tutorial 6 – JOIN queries

**Time: 40 minutes**

## 6.1 Why do we need JOIN?

The shop manager wants a report showing:

- The order number.
- The customer's name.
- The order status.
- The product in the order.
- The quantity purchased.

That information is spread across four tables. A `JOIN` combines related rows so the report can show the information together.

A join uses a relationship between tables, commonly a primary key and foreign key.

## 6.2 INNER JOIN

An `INNER JOIN` returns rows where the join condition matches in both tables.

Start by joining orders to customers:

```sql
SELECT
    orders.order_id,
    customers.first_name,
    customers.last_name,
    orders.status
FROM orders
INNER JOIN customers
    ON orders.customer_id = customers.customer_id;
```

Read the query from the `FROM` clause:

1. Start with orders.
2. Find the customer whose ID matches the order's `customer_id`.
3. Return the requested columns.

The `ON` condition is essential. It tells PostgreSQL how the records are related.

## 6.3 Use table aliases

Long table names can make a query harder to read. An alias is a short name for a table within a query.

```sql
SELECT
    o.order_id,
    c.first_name,
    c.last_name,
    o.status
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id;
```

Here:
- `o` represents `orders`.
- `c` represents `customers`.

Aliases make larger joins easier to read.

## 6.4 Join three tables

The manager now wants to see which products were included in each order.

```sql
SELECT
    o.order_id,
    c.first_name,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN products AS p
    ON oi.product_id = p.product_id;
```

Follow the relationships:

- Orders connect to customers through `customer_id`.
- Orders connect to order items through `order_id`.
- Order items connect to products through `product_id`.

The result can contain multiple rows for one order because one order may have several products.

## 6.5 LEFT JOIN

Suppose the manager wants to see every customer, including customers who have not placed an order.

An `INNER JOIN` would exclude customers without matching orders. A `LEFT JOIN` keeps all rows from the left table and includes matching rows from the right table when they exist.

```sql
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
ORDER BY c.customer_id;
```

A customer without an order will still appear, with `NULL` in the order columns.

## 6.6 RIGHT JOIN and FULL OUTER JOIN

A `RIGHT JOIN` keeps all rows from the right-hand table, including those without a match on the left.

A `FULL OUTER JOIN` keeps matching rows and unmatched rows from both sides.

These are useful to recognise, although `LEFT JOIN` and `INNER JOIN` are more common in everyday application queries.

## 6.7 JOIN practice

Try these without looking at the examples first:

1. Show each order with the customer's full name.
2. Show each product included in each order.
3. Show all customers, even those without orders.
4. Show order ID, customer email, product name and quantity.

**Think about it:** What would happen if you joined `orders` to `products` without using `order_items`? Why is the linking table needed?

**Git checkpoint**

Save your join examples in `sql/05-joins.sql`.

```bash
git add sql/05-joins.sql
git commit -m "feat: add inner and outer join examples"
```

---

# Tutorial 7 – UPDATE, ALTER and DELETE

**Time: 35 minutes**

These statements change the database. Be careful: an incorrect condition can affect many records.

## 7.1 UPDATE – change existing data

Imagine the shop increases the price of its USB-C cable.

First, inspect the current value:

```sql
SELECT product_id, product_name, price
FROM products
WHERE product_name = 'USB-C Cable';
```

Now update the price. Use the actual product ID or a sufficiently specific condition from your results.

```sql
UPDATE products
SET price = 109.50
WHERE product_name = 'USB-C Cable';
```

Verify the change:

```sql
SELECT product_name, price
FROM products
WHERE product_name = 'USB-C Cable';
```

### Why is WHERE important?

Without `WHERE`, this statement:

```sql
UPDATE products
SET price = 109.50;
```

would change the price of every product.

**Good habit:** Before an `UPDATE`, run a `SELECT` with the same `WHERE` condition to confirm exactly which rows will be affected.

## 7.2 Update more than one column

The manager corrects the product's stock quantity and description:

```sql
UPDATE products
SET
    stock_quantity = 45,
    description = 'One metre USB-C charging and data cable'
WHERE product_name = 'USB-C Cable';
```

Verify the result before moving on.

## 7.3 ALTER TABLE – change the table structure

`UPDATE` changes stored values. `ALTER TABLE` changes the structure of a table.

For example, the shop now wants to store a customer's city.

```sql
ALTER TABLE customers
ADD COLUMN city VARCHAR(80);
```

The new column will initially contain `NULL` for existing customers because no city has been supplied.

Inspect the table structure using pgAdmin's table properties or, in `psql`:

```text
\d customers
```

You can also rename a column:

```sql
ALTER TABLE customers
RENAME COLUMN phone TO phone_number;
```

Only run this rename if your table still has the original `phone` column and you want the new name. If you rename it, use `phone_number` in later queries.

You can change a column's data type when appropriate:

```sql
ALTER TABLE customers
ALTER COLUMN city TYPE VARCHAR(100);
```

You can remove a column:

```sql
ALTER TABLE customers
DROP COLUMN city;
```

This permanently removes the column and its stored values. Do not run the removal statement if you still need the city field.

## 7.4 DELETE – remove selected rows

Suppose a test customer was inserted by mistake.

First identify the customer:

```sql
SELECT customer_id, first_name, last_name, email
FROM customers
WHERE email = 'test@example.com';
```

If the customer has no related orders, delete the specific row:

```sql
DELETE FROM customers
WHERE email = 'test@example.com';
```

If the customer has related orders, PostgreSQL may reject the deletion because the foreign key protects those related records. That is intentional. Decide how the related records should be handled according to the shop's business rules; do not remove constraints simply to bypass the error.

## 7.5 Use transactions for safer changes

A transaction lets you group changes and either commit them or undo them before they are committed.

Example:

```sql
BEGIN;

UPDATE products
SET price = 119.50
WHERE product_name = 'USB-C Cable';

SELECT product_name, price
FROM products
WHERE product_name = 'USB-C Cable';
```

If the result is correct:

```sql
COMMIT;
```

If the result is not correct and you have not committed:

```sql
ROLLBACK;
```

A `COMMIT` makes the transaction's changes permanent. A `ROLLBACK` undoes changes made in the current uncommitted transaction.

## Checkpoint exercise

1. Increase the price of one product.
2. Add a `city` column to customers.
3. Set a city for one customer.
4. Find that customer using a `WHERE` condition.
5. Practise a transaction and decide whether to commit or roll it back.

**Git checkpoint**

Save your data modification examples in `sql/06-update-alter-delete.sql`. Add comments explaining which statements are destructive and which are safe to practise in a test database.

```bash
git add sql/06-update-alter-delete.sql
git commit -m "feat: add update alter and delete examples"
```

---

# Tutorial 8 – SUM, AVG and other aggregate queries

**Time: 35 minutes**

## 8.1 What are aggregate functions?

An aggregate function calculates a result from multiple rows.

A shop manager may ask:

- How much revenue came from the orders?
- What is the average product price?
- How many products are available?
- What is the lowest or highest product price?

PostgreSQL provides functions for these questions.

| Function | Purpose |
|---|---|
| `SUM()` | Adds numeric values |
| `AVG()` | Calculates an average |
| `COUNT()` | Counts rows or non-null values |
| `MIN()` | Finds the smallest value |
| `MAX()` | Finds the largest value |

## 8.2 SUM – calculate a total

To calculate the value of all order items:

```sql
SELECT
    SUM(quantity * unit_price) AS total_order_value
FROM order_items;
```

Why multiply `quantity` by `unit_price`?

If a customer buys three items at R100 each, the line total is R300. The query calculates each line value and adds the results.

This is a simple order-value calculation. It does not account for discounts, tax, refunds or delivery fees.

## 8.3 AVG – calculate an average

Find the average price of all products:

```sql
SELECT
    AVG(price) AS average_product_price
FROM products;
```

The result may contain decimal places. That is normal.

To display two decimal places:

```sql
SELECT
    ROUND(AVG(price), 2) AS average_product_price
FROM products;
```

## 8.4 COUNT – count records

Count the number of customers:

```sql
SELECT COUNT(*) AS total_customers
FROM customers;
```

Count the number of products:

```sql
SELECT COUNT(*) AS total_products
FROM products;
```

`COUNT(*)` counts rows. `COUNT(column_name)` counts only rows where that column is not `NULL`.

## 8.5 MIN and MAX

Find the cheapest and most expensive products:

```sql
SELECT
    MIN(price) AS cheapest_price,
    MAX(price) AS most_expensive_price
FROM products;
```

## 8.6 GROUP BY – calculate totals per group

The manager wants the total value of each order.

```sql
SELECT
    order_id,
    SUM(quantity * unit_price) AS order_total
FROM order_items
GROUP BY order_id
ORDER BY order_id;
```

`GROUP BY` puts rows with the same `order_id` into a group. `SUM()` then calculates a total for each group.

## 8.7 Combine JOIN and GROUP BY

Show each customer's name and the total value of their orders:

```sql
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;
```

This is a realistic reporting query: it combines customer and order information, groups the results by customer and calculates spending.

This example includes customers who have order items. To include customers with no orders, use `LEFT JOIN` and consider how `COALESCE()` handles missing totals.

## 8.8 HAVING – filter grouped results

`WHERE` filters individual rows before grouping. `HAVING` filters groups after aggregation.

Find orders whose total is greater than R500:

```sql
SELECT
    order_id,
    SUM(quantity * unit_price) AS order_total
FROM order_items
GROUP BY order_id
HAVING SUM(quantity * unit_price) > 500;
```

## Checkpoint exercise

Write queries to:

1. Calculate the total value of all order items.
2. Calculate the average product price.
3. Count all products.
4. Find the cheapest and most expensive product.
5. Calculate the total value of each order.
6. Find orders with a total value greater than R500.

**Git checkpoint**

Save your aggregate queries in `sql/07-aggregate-functions.sql`.

```bash
git add sql/07-aggregate-functions.sql
git commit -m "feat: add aggregate and grouped reporting queries"
```

---

# Tutorial 9 – LIMIT and DROP TABLE

**Time: 20 minutes**

## 9.1 LIMIT – return only a certain number of rows

A shop may have thousands of products. A page in the application may need to show only the first five.

```sql
SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 5;
```

`LIMIT 5` returns at most five rows.

Use `ORDER BY` when you need a predictable selection. Without sorting, the database does not promise which five rows will be returned.

A useful application example is showing the five most expensive products.

## 9.2 OFFSET – skip rows

`OFFSET` skips a number of rows before returning results.

```sql
SELECT product_name, price
FROM products
ORDER BY product_id
LIMIT 5 OFFSET 5;
```

This returns up to five rows after skipping the first five. It is one way to implement basic pagination.

## 9.3 DROP TABLE – remove a table

`DROP TABLE` removes a table's structure and its data.

For a safe demonstration, create a temporary practice table:

```sql
CREATE TABLE practice_notes (
    note_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    note TEXT NOT NULL
);
```

Add a sample row:

```sql
INSERT INTO practice_notes (note)
VALUES ('This table is only for DROP TABLE practice');
```

Check that the table exists:

```sql
SELECT * FROM practice_notes;
```

Now remove the practice table:

```sql
DROP TABLE practice_notes;
```

Check that it has been removed using pgAdmin or the `psql` table listing command.

### DROP versus DELETE

| Command | What it removes |
|---|---|
| `DELETE FROM table_name` | Rows from a table |
| `DROP TABLE table_name` | The entire table structure and its data |

`DELETE` keeps the table. `DROP TABLE` removes it.

You may also see `TRUNCATE TABLE`, which removes all rows while keeping the table structure. It is different from both `DELETE` and `DROP`.

> **Important:** Never practise `DROP TABLE` on a real or shared database unless you have permission, a backup and a clear reason. Do not use `CASCADE` casually: it can remove dependent database objects.

## Checkpoint

Explain why the following two operations are different:

- Removing one customer's row.
- Removing the entire customers table.

**Git checkpoint**

Save the `LIMIT`, `OFFSET` and practice-table example in `sql/08-limit-drop.sql`.

```bash
git add sql/08-limit-drop.sql
git commit -m "feat: add pagination and drop table examples"
```

---

# Tutorial 10 – Final review challenge

**Time: 20 minutes**

You have now created a small relational database for BrightMart. Complete this challenge without copying the earlier queries directly.

## Business request

The shop manager wants a short report about customers, products and orders.

Write SQL queries that answer the following questions:

1. Display all customers, showing their first name, last name and email.
2. Display all products sorted from cheapest to most expensive.
3. Find products with fewer than 20 units in stock.
4. Display each order with the customer's name and order status.
5. Display each order's products, quantities and unit prices.
6. Calculate the total value of each order.
7. Calculate the average price of all products.
8. Find the five most expensive products.
9. Count how many customers are registered.
10. Add a new customer and create an order for that customer.

## Final understanding questions

Answer these in your `README.md`:

1. What is a primary key?
2. What is a foreign key?
3. Why do we use joins?
4. What is the difference between `WHERE` and `HAVING`?
5. What is the difference between `UPDATE` and `ALTER TABLE`?
6. Why should you be careful when using `DELETE`?
7. What is the difference between `DELETE` and `DROP TABLE`?
8. Why is `ORDER BY` useful with `LIMIT`?
9. When would you use `SUM()` instead of `AVG()`?
10. Why is it important to use constraints in a relational database?

## Final Git hand-in

Check your repository:

```bash
git status
```

Review the files you created. Add and commit your final work:

```bash
git add README.md sql/
git commit -m "docs: complete five-hour PostgreSQL shop database tutorial"
```

Check your commit history:

```bash
git log --oneline
```

Your repository should contain a clear history showing your progress through the tutorial.

---

# Suggested project folder structure

When finished, your project should look similar to this:

```text
postgres-shop-tutorial/
│
├── README.md
│
└── sql/
    ├── 01-create-database.sql
    ├── 02-create-tables.sql
    ├── 03-insert-sample-data.sql
    ├── 04-select-filter-sort.sql
    ├── 05-joins.sql
    ├── 06-update-alter-delete.sql
    ├── 07-aggregate-functions.sql
    └── 08-limit-drop.sql
```

You may also add a `notes/` folder for your answers and observations.

# SQL quick reference

| Task | SQL command or clause |
|---|---|
| Create a database | `CREATE DATABASE` |
| Create a table | `CREATE TABLE` |
| Primary key | `PRIMARY KEY` |
| Foreign key | `FOREIGN KEY ... REFERENCES` |
| Insert records | `INSERT INTO ... VALUES` |
| Retrieve records | `SELECT` |
| Choose columns | `SELECT column_name` |
| Filter rows | `WHERE` |
| Match patterns | `LIKE` / `ILIKE` |
| Match a list | `IN` |
| Match a range | `BETWEEN` |
| Sort results | `ORDER BY ASC` / `DESC` |
| Join tables | `INNER JOIN`, `LEFT JOIN` |
| Change row values | `UPDATE ... SET` |
| Change table structure | `ALTER TABLE` |
| Remove selected rows | `DELETE FROM` |
| Add numeric values | `SUM()` |
| Calculate average | `AVG()` |
| Count records | `COUNT()` |
| Find minimum / maximum | `MIN()` / `MAX()` |
| Group records | `GROUP BY` |
| Filter groups | `HAVING` |
| Limit results | `LIMIT` |
| Skip results | `OFFSET` |
| Remove a table | `DROP TABLE` |

# Completion checklist

Use this checklist to assess your progress:

- [ ] I created and connected to the `brightmart` database.
- [ ] I created all four tables.
- [ ] I can explain primary keys and foreign keys.
- [ ] I inserted at least 6 records into each table: `customers`, `products`, `orders` and `order_items`.
- [ ] I can retrieve selected columns using `SELECT`.
- [ ] I can filter records using `WHERE`, `AND`, `OR`, `IN`, `BETWEEN` and `LIKE`.
- [ ] I can sort results using `ORDER BY`.
- [ ] I can join two or more related tables.
- [ ] I can safely update records.
- [ ] I can alter a table's structure.
- [ ] I understand how to delete records safely.
- [ ] I can calculate totals using `SUM()`.
- [ ] I can calculate averages using `AVG()`.
- [ ] I can group records and filter groups.
- [ ] I can limit and paginate query results.
- [ ] I understand the difference between `DELETE`, `TRUNCATE` and `DROP TABLE`.
- [ ] I committed my work to Git with meaningful messages.

**You are finished when you can explain what each query does, why it is needed, and how to adapt it to a different business scenario—not merely when all the SQL statements run successfully.**
