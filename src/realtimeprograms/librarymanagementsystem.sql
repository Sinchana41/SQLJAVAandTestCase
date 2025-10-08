CREATE DATABASE librarymanagementsystem;

CREATE TABLE librarymanagementsystem.Book (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100) NOT NULL,
    available_copies INT NOT NULL
);

INSERT INTO Book (title, author, available_copies) VALUES
('Database Systems', 'Navathe', 5),
('Operating System Concepts', 'Silberschatz', 3),
('Java Programming', 'Herbert Schildt', 4),
('Computer Networks', 'Tanenbaum', 2),
('C Programming', 'Kernighan & Ritchie', 6);

CREATE TABLE Student (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    branch VARCHAR(50)
);
INSERT INTO Student (name, branch) VALUES
('Ravi Kumar', 'CSE'),
('Priya Sharma', 'ECE'),
('Arjun Mehta', 'MECH'),
('Sneha Reddy', 'CSE'),
('Vikram Singh', 'CIVIL');

CREATE TABLE Issue (
    issue_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    book_id INT,
    issue_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    return_date DATETIME,
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (book_id) REFERENCES Book(book_id)
);

INSERT INTO Issue (student_id, book_id, issue_date) VALUES
(1, 1, '2025-09-01 10:00:00'),
(1, 3, '2025-09-02 11:30:00'),
(2, 2, '2025-09-03 14:15:00'),
(3, 3, '2025-09-04 16:00:00'),
(4, 1, '2025-09-05 09:45:00');

SELECT b.title, b.author, i.issue_date, i.return_date
FROM Issue i
JOIN Book b ON i.book_id = b.book_id
JOIN Student s ON i.student_id = s.student_id
WHERE s.name = 'Ravi Kumar';

SELECT b.title, COUNT(i.issue_id) AS issue_count
FROM Issue i
JOIN Book b ON i.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY issue_count DESC
LIMIT 1;

SELECT title, available_copies
FROM Book
WHERE title = 'Java Programming';

SELECT s.branch, COUNT(i.issue_id) AS books_issued
FROM Issue i
JOIN Student s ON i.student_id = s.student_id
WHERE i.return_date IS NULL
GROUP BY s.branch;

