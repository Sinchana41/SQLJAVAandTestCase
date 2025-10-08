CREATE DATABASE onlineordersystem;

CREATE TABLE Customer (
    cust_id INT PRIMARY KEY AUTO_INCREMENT,
    cust_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    last_order_date DATETIME
);

INSERT INTO Customer (cust_name, email) VALUES
('Ravi Kumar', 'ravi@example.com'),
('Priya Sharma', 'priya@example.com'),
('Arjun Mehta', 'arjun@example.com'),
('Sneha Reddy', 'sneha@example.com'),
('Vikram Singh', 'vikram@example.com');

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    cust_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2),
    FOREIGN KEY (cust_id) REFERENCES Customer(cust_id)
);

INSERT INTO Orders (cust_id, order_date, amount) VALUES
(1, '2025-08-01 10:00:00', 2000),
(1, '2025-08-10 12:00:00', 1500),
(2, '2025-08-05 15:30:00', 5000),
(2, '2025-09-01 09:15:00', 2500),
(3, '2025-08-07 18:45:00', 3500),
(3, '2025-09-02 14:10:00', 4000),
(4, '2025-08-15 11:20:00', 6000),
(5, '2025-08-18 16:00:00', 4500),
(5, '2025-09-03 10:30:00', 2000),
(1, '2025-09-05 19:45:00', 3000);


SELECT o.order_id, o.order_date, o.amount
FROM Orders o
JOIN Customer c ON o.cust_id = c.cust_id
WHERE c.cust_name = 'Ravi Kumar';

SELECT c.cust_id, c.cust_name, SUM(o.amount) AS total_spent
FROM Customer c
JOIN Orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.cust_name
ORDER BY total_spent DESC
LIMIT 1;

SELECT c.cust_id, c.cust_name, c.email
FROM Customer c
LEFT JOIN Orders o ON c.cust_id = o.cust_id
WHERE o.order_id IS NULL;

SELECT AVG(amount) AS avg_order_value
FROM Orders;
