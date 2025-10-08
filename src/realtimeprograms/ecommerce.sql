CREATE DATABASE ecommerce_db; 

-- Customers 
CREATE TABLE ecommerce_db.Customers ( 
    CustomerID INT PRIMARY KEY AUTO_INCREMENT, 
    FullName VARCHAR(100) NOT NULL, 
    Email VARCHAR(100) UNIQUE NOT NULL, 
    Phone VARCHAR(20), 
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP 
);
INSERT INTO Customers (FullName, Email, Phone)
VALUES
('Ravi Kumar', 'ravi.kumar@example.com', '9876543210'),
('Priya Sharma', 'priya.sharma@example.com', '9123456780'),
('Arjun Mehta', 'arjun.mehta@example.com', '9812345678'),
('Sneha Reddy', 'sneha.reddy@example.com', '9001234567'),
('Vikram Singh', 'vikram.singh@example.com', '9887766554');

-- Categories 
CREATE TABLE ecommerce_db.Categories ( 
    CategoryID INT PRIMARY KEY AUTO_INCREMENT, 
    CategoryName VARCHAR(50) UNIQUE NOT NULL 
); 
INSERT INTO Categories (CategoryName)
VALUES
('Electronics'),
('Clothing'),
('Books'),
('Home Appliances');

 -- Products 
CREATE TABLE ecommerce_db.Products ( 
    ProductID INT PRIMARY KEY AUTO_INCREMENT, 
    ProductName VARCHAR(100) NOT NULL, 
    Price DECIMAL(10,2) NOT NULL, 
    Stock INT NOT NULL, 
    CategoryID INT, 
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) 
); 
INSERT INTO Products (ProductName, Price, Stock, CategoryID)
VALUES
('Smartphone', 25000.00, 50, 1),
('Laptop', 60000.00, 20, 1),
('Headphones', 2000.00, 100, 1),
('T-Shirt', 800.00, 200, 2),
('Jeans', 1500.00, 150, 2),
('Novel - The Alchemist', 400.00, 80, 3),
('Textbook - Data Structures', 1200.00, 60, 3),
('Microwave Oven', 7000.00, 30, 4),
('Refrigerator', 45000.00, 10, 4),
('Washing Machine', 30000.00, 15, 4);
 -- Orders 
CREATE TABLE ecommerce_db.Orders ( 
    OrderID INT PRIMARY KEY AUTO_INCREMENT, 
    CustomerID INT, 
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP, 
    PaymentMethod VARCHAR(50), 
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) 
); 
INSERT INTO Orders (CustomerID, OrderDate, PaymentMethod)
VALUES
(1, '2025-07-01 10:30:00', 'Credit Card'),
(2, '2025-07-05 15:00:00', 'UPI'),
(3, '2025-08-10 18:45:00', 'Debit Card'),
(1, '2025-08-20 12:20:00', 'Net Banking'),
(4, '2025-09-01 09:15:00', 'Cash on Delivery'),
(5, '2025-09-05 20:10:00', 'Credit Card');
 -- Order Details (many-to-many between Orders and Products) 
CREATE TABLE ecommerce_db.OrderDetails ( 
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT, 
    OrderID INT, 
    ProductID INT, 
    Quantity INT NOT NULL, 
    Price DECIMAL(10,2) NOT NULL, -- store price at time of order 
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID), 
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) 
); 
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price)
VALUES
(1, 1, 1, 25000.00), -- Ravi buys Smartphone
(1, 4, 2, 800.00),   -- Ravi buys 2 T-Shirts
(2, 2, 1, 60000.00), -- Priya buys Laptop
(3, 5, 2, 1500.00),  -- Arjun buys 2 Jeans
(3, 6, 1, 400.00),   -- Arjun buys Novel
(4, 7, 1, 1200.00),  -- Ravi buys Textbook
(4, 3, 2, 2000.00),  -- Ravi buys 2 Headphones
(5, 8, 1, 7000.00),  -- Sneha buys Microwave
(5, 9, 1, 45000.00), -- Sneha buys Refrigerator
(6, 10, 1, 30000.00); -- Vikram buys Washing Machine
 -- Audit Table 
CREATE TABLE OrderAudit ( 
    AuditID INT PRIMARY KEY AUTO_INCREMENT, 
    OrderID INT, 
    CustomerID INT, 
    OrderDate DATETIME, 
    ActionType VARCHAR(20), 
    LoggedAt DATETIME DEFAULT CURRENT_TIMESTAMP 
); 
INSERT INTO OrderAudit (OrderID, CustomerID, OrderDate, ActionType)
VALUES
(1, 1, '2025-07-01 10:30:00', 'INSERT'),
(2, 2, '2025-07-05 15:00:00', 'INSERT'),
(3, 3, '2025-08-10 18:45:00', 'INSERT'),
(4, 1, '2025-08-20 12:20:00', 'INSERT'),
(5, 4, '2025-09-01 09:15:00', 'INSERT'),
(6, 5, '2025-09-05 20:10:00', 'INSERT');

 -- High Value Orders 
CREATE TABLE ecommerce_db.HighValueOrders ( 
    HVOrderID INT PRIMARY KEY AUTO_INCREMENT, 
    OrderID INT, 
    CustomerID INT, 
    TotalAmount DECIMAL(12,2), 
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP 
);
INSERT INTO HighValueOrders (OrderID, CustomerID, TotalAmount)
VALUES
(2, 2, 60000.00),   -- Priya’s Laptop
(5, 4, 52000.00),   -- Sneha’s Microwave + Refrigerator
(6, 5, 30000.00);   -- Vikram’s Washing Machine (just below 50k, included for testing)

SELECT
    c.CustomerID,
    c.FullName,
    c.Email,
    COUNT(DISTINCT p.CategoryID) AS distinct_categories,
    SUM(od.Price * od.Quantity) AS total_spent
FROM Orders o
JOIN OrderDetails od ON od.OrderID = o.OrderID
JOIN Products p      ON p.ProductID = od.ProductID
JOIN Customers c     ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
GROUP BY c.CustomerID, c.FullName, c.Email
HAVING COUNT(DISTINCT p.CategoryID) >= 3
ORDER BY total_spent DESC
LIMIT 3;

CREATE INDEX idx_orders_orderdate ON Orders(OrderDate);
CREATE INDEX idx_orders_customerid_orderdate ON Orders(CustomerID, OrderDate);
CREATE UNIQUE INDEX ux_customers_email ON Customers(Email);
CREATE INDEX idx_products_categoryid ON Products(CategoryID);
CREATE INDEX idx_products_categoryid_price ON Products(CategoryID, Price);
CREATE INDEX idx_orderdetails_orderid ON OrderDetails(OrderID);
CREATE INDEX idx_orderdetails_productid ON OrderDetails(ProductID);
CREATE INDEX idx_orderdetails_orderid_productid ON OrderDetails(OrderID, ProductID);

DROP PROCEDURE IF EXISTS PlaceOrder;

DELIMITER $$

CREATE PROCEDURE PlaceOrder (
    IN p_CustomerID INT,
    IN p_ProductID INT,
    IN p_Quantity INT,
    IN p_PaymentMethod VARCHAR(50),
    OUT p_OrderID INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_orderid INT;

    -- start transaction
    START TRANSACTION;

    -- Lock the product row
    SELECT Stock, Price INTO v_stock, v_price
    FROM Products
    WHERE ProductID = p_ProductID
    FOR UPDATE;

    IF v_stock IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid ProductID';
    END IF;

    IF v_stock < p_Quantity THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    -- Insert Order
    INSERT INTO Orders (CustomerID, OrderDate, PaymentMethod)
    VALUES (p_CustomerID, NOW(), p_PaymentMethod);

    SET v_orderid = LAST_INSERT_ID();

    -- Insert OrderDetails
    INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price)
    VALUES (v_orderid, p_ProductID, p_Quantity, v_price);

    -- Decrease stock
    UPDATE Products
    SET Stock = Stock - p_Quantity
    WHERE ProductID = p_ProductID;

    COMMIT;

    SET p_OrderID = v_orderid;
END$$

DELIMITER ;


DELIMITER $$
DROP TRIGGER IF EXISTS trg_orders_after_insert$$
CREATE TRIGGER trg_orders_after_insert
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    INSERT INTO OrderAudit (OrderID, CustomerID, OrderDate, ActionType, LoggedAt)
    VALUES (NEW.OrderID, NEW.CustomerID, NEW.OrderDate, 'INSERT', NOW());
END$$
DELIMITER ;

DELIMITER $$
DROP TRIGGER IF EXISTS trg_orderdetails_after_insert$$
CREATE TRIGGER trg_orderdetails_after_insert
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(12,2);

    SELECT IFNULL(SUM(Price * Quantity), 0)
    INTO v_total
    FROM OrderDetails
    WHERE OrderID = NEW.OrderID;

    IF v_total > 50000.00 THEN
        -- avoid duplicates
        IF NOT EXISTS (
            SELECT 1 FROM HighValueOrders WHERE OrderID = NEW.OrderID
        ) THEN
            INSERT INTO HighValueOrders (OrderID, CustomerID, TotalAmount, CreatedAt)
            SELECT o.OrderID, o.CustomerID, v_total, NOW()
            FROM Orders o
            WHERE o.OrderID = NEW.OrderID;
        END IF;
    END IF;
END$$
DELIMITER ;


