CREATE DATABASE employee_d_b;

CREATE TABLE Department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL
);
INSERT INTO Department (dept_name)
VALUES
('HR'),
('IT'),
('Finance');

CREATE TABLE Employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    designation VARCHAR(50),
    salary DECIMAL(10,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

INSERT INTO Employee (name, designation, salary, dept_id)
VALUES
('Ravi Kumar', 'Manager', 80000, 1),
('Priya Sharma', 'Executive', 40000, 1),
('Arjun Mehta', 'Manager', 90000, 2),
('Sneha Reddy', 'Developer', 50000, 2),
('Vikram Singh', 'Developer', 45000, 2),
('Ananya Rao', 'Executive', 35000, 3),
('Karan Jain', 'Manager', 95000, 3),
('Neha Gupta', 'Executive', 32000, 3),
('Suresh Patil', 'Developer', 42000, 2),
('Pooja Das', 'Executive', 30000, 1);

-- Replace 'IT' with any department name
SELECT e.emp_id, e.name, e.designation, e.salary
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'IT';

SELECT d.dept_name, e.name, e.salary
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
WHERE (e.dept_id, e.salary) IN (
    SELECT dept_id, MAX(salary)
    FROM Employee
    GROUP BY dept_id
);

UPDATE Employee
SET salary = salary * 1.10
WHERE designation = 'Manager';

DELETE FROM Employee
WHERE salary < 30000;
