-- =====================================================
-- Library Management System Database - ALL ERRORS FIXED
-- Database Design & Programming with SQL Final Project
-- =====================================================

-- Create the database (this warning is normal and can be ignored)
CREATE DATABASE IF NOT EXISTS library_management_system;
USE library_management_system;

-- =====================================================
-- FIXED TABLES - Removed problematic CHECK constraints
-- =====================================================

-- Table: publishers
CREATE TABLE IF NOT EXISTS publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL UNIQUE,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    website VARCHAR(100),
    established_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: categories
CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: authors - FIXED: Removed CURDATE() from CHECK constraint
CREATE TABLE IF NOT EXISTS authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes (removed problematic CHECK constraint)
    INDEX idx_author_name (last_name, first_name)
);

-- Table: books - FIXED: Removed problematic CHECK constraints with functions
CREATE TABLE IF NOT EXISTS books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(17) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    publication_year YEAR,
    pages INT,
    language VARCHAR(30) DEFAULT 'English',
    edition INT DEFAULT 1,
    copies_available INT NOT NULL DEFAULT 1,
    total_copies INT NOT NULL DEFAULT 1,
    price DECIMAL(10,2),
    
    -- Foreign Keys
    publisher_id INT,
    category_id INT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_books_publisher FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    CONSTRAINT fk_books_category FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    
    -- Simple CHECK constraints (without functions)
    CONSTRAINT chk_pages CHECK (pages > 0),
    CONSTRAINT chk_copies_positive CHECK (copies_available >= 0),
    CONSTRAINT chk_total_copies CHECK (total_copies > 0),
    CONSTRAINT chk_edition CHECK (edition > 0),
    CONSTRAINT chk_price CHECK (price >= 0),
    
    -- Indexes
    INDEX idx_book_title (title),
    INDEX idx_book_isbn (isbn),
    INDEX idx_publication_year (publication_year)
);

-- Table: book_authors
CREATE TABLE IF NOT EXISTS book_authors (
    book_id INT,
    author_id INT,
    author_role ENUM('Primary Author', 'Co-Author', 'Editor', 'Translator') DEFAULT 'Primary Author',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Composite Primary Key
    PRIMARY KEY (book_id, author_id),
    
    -- Foreign Keys
    CONSTRAINT fk_book_authors_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_book_authors_author FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Table: members - FIXED: Removed CURDATE() from CHECK constraints
CREATE TABLE IF NOT EXISTS members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    membership_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    membership_date DATE NOT NULL DEFAULT (CURDATE()),
    membership_type ENUM('Student', 'Faculty', 'Public', 'Senior') NOT NULL DEFAULT 'Public',
    status ENUM('Active', 'Suspended', 'Expired') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes (removed problematic CHECK constraints)
    INDEX idx_member_name (last_name, first_name),
    INDEX idx_membership_number (membership_number),
    INDEX idx_member_email (email)
);

-- Table: loans - FIXED: Simplified CHECK constraints
CREATE TABLE IF NOT EXISTS loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT (CURDATE()),
    due_date DATE NOT NULL,
    return_date DATE NULL,
    fine_amount DECIMAL(8,2) DEFAULT 0.00,
    status ENUM('Active', 'Returned', 'Overdue', 'Lost') NOT NULL DEFAULT 'Active',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_loans_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    CONSTRAINT fk_loans_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT,
    
    -- Simple CHECK constraint
    CONSTRAINT chk_fine_amount CHECK (fine_amount >= 0),
    
    -- Indexes
    INDEX idx_loan_date (loan_date),
    INDEX idx_due_date (due_date),
    INDEX idx_loan_status (status),
    INDEX idx_book_member (book_id, member_id)
);

-- Table: staff - FIXED: Removed CURDATE() from CHECK constraints
CREATE TABLE IF NOT EXISTS staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    position ENUM('Librarian', 'Assistant Librarian', 'Manager', 'IT Support', 'Security') NOT NULL,
    hire_date DATE NOT NULL DEFAULT (CURDATE()),
    salary DECIMAL(10,2),
    status ENUM('Active', 'Inactive', 'Terminated') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Simple CHECK constraint
    CONSTRAINT chk_salary CHECK (salary > 0),
    
    -- Indexes
    INDEX idx_staff_name (last_name, first_name),
    INDEX idx_employee_id (employee_id)
);

-- Table: staff_profiles
CREATE TABLE IF NOT EXISTS staff_profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT NOT NULL UNIQUE,
    address TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    qualifications TEXT,
    department VARCHAR(50),
    supervisor_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_staff_profiles_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE,
    CONSTRAINT fk_staff_profiles_supervisor FOREIGN KEY (supervisor_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- =====================================================
-- SAFE DATA INSERTION - Using INSERT IGNORE
-- =====================================================

-- Insert Publishers
INSERT IGNORE INTO publishers (publisher_name, address, phone, email, website, established_year) VALUES
('Penguin Random House', '1745 Broadway, New York, NY 10019', '+1-212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com', 1927),
('HarperCollins', '195 Broadway, New York, NY 10007', '+1-212-207-7000', 'info@harpercollins.com', 'www.harpercollins.com', 1989),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', '+1-212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com', 1924),
('Macmillan Publishers', '120 Broadway, New York, NY 10271', '+1-646-307-5151', 'info@macmillan.com', 'www.macmillan.com', 1843);

-- Insert Categories
INSERT IGNORE INTO categories (category_name, description) VALUES
('Fiction', 'Imaginative literature including novels and short stories'),
('Non-Fiction', 'Factual books including biographies, history, and self-help'),
('Science Fiction', 'Speculative fiction dealing with futuristic concepts'),
('Mystery', 'Fiction dealing with puzzling crimes and their solutions'),
('Romance', 'Fiction focusing on romantic relationships'),
('Biography', 'Life stories of real people'),
('History', 'Books about past events and civilizations'),
('Technology', 'Books about computers, programming, and modern technology'),
('Philosophy', 'Books exploring fundamental questions about existence'),
('Children', 'Books specifically written for young readers');

-- Insert Authors
INSERT IGNORE INTO authors (first_name, last_name, birth_date, nationality, biography, email) VALUES
('George', 'Orwell', '1903-06-25', 'British', 'English novelist and journalist known for Animal Farm and 1984', 'george.orwell@classic.com'),
('Jane', 'Austen', '1775-12-16', 'British', 'English novelist known for Pride and Prejudice and Sense and Sensibility', 'jane.austen@classic.com'),
('Mark', 'Twain', '1835-11-30', 'American', 'American writer known for The Adventures of Tom Sawyer and Adventures of Huckleberry Finn', 'mark.twain@classic.com'),
('Agatha', 'Christie', '1890-09-15', 'British', 'English writer known for detective novels featuring Hercule Poirot and Miss Marple', 'agatha.christie@mystery.com'),
('Isaac', 'Asimov', '1920-01-02', 'American', 'American writer and professor of biochemistry, known for science fiction works', 'isaac.asimov@scifi.com');

-- Insert Books
INSERT IGNORE INTO books (isbn, title, publication_year, pages, language, edition, copies_available, total_copies, price, publisher_id, category_id) VALUES
('978-0-452-28423-4', '1984', 1949, 328, 'English', 1, 5, 5, 12.99, 1, 1),
('978-0-14-143951-8', 'Animal Farm', 1945, 112, 'English', 1, 3, 3, 9.99, 1, 1),
('978-0-14-143957-0', 'Pride and Prejudice', 1813, 432, 'English', 1, 4, 4, 11.99, 1, 1),
('978-0-06-112008-4', 'The Adventures of Tom Sawyer', 1876, 274, 'English', 1, 2, 2, 10.99, 2, 1),
('978-0-06-440055-8', 'Murder on the Orient Express', 1934, 256, 'English', 1, 3, 3, 13.99, 2, 4),
('978-0-553-29337-0', 'Foundation', 1951, 244, 'English', 1, 2, 2, 14.99, 1, 3);

-- Insert Book-Author relationships
INSERT IGNORE INTO book_authors (book_id, author_id, author_role) VALUES
(1, 1, 'Primary Author'),
(2, 1, 'Primary Author'),
(3, 2, 'Primary Author'),
(4, 3, 'Primary Author'),
(5, 4, 'Primary Author'),
(6, 5, 'Primary Author');

-- Insert Members
INSERT IGNORE INTO members (membership_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, status) VALUES
('LIB001', 'John', 'Smith', 'john.smith@email.com', '+1-555-0101', '123 Main St, Anytown, ST 12345', '1985-03-15', 'Public', 'Active'),
('LIB002', 'Emily', 'Johnson', 'emily.johnson@email.com', '+1-555-0102', '456 Oak Ave, Anytown, ST 12345', '1992-07-22', 'Student', 'Active'),
('LIB003', 'Michael', 'Brown', 'michael.brown@email.com', '+1-555-0103', '789 Pine Rd, Anytown, ST 12345', '1978-11-08', 'Faculty', 'Active'),
('LIB004', 'Sarah', 'Davis', 'sarah.davis@email.com', '+1-555-0104', '321 Elm St, Anytown, ST 12345', '1965-05-30', 'Senior', 'Active');

-- Insert Staff
INSERT IGNORE INTO staff (employee_id, first_name, last_name, email, phone, position, hire_date, salary, status) VALUES
('EMP001', 'Alice', 'Wilson', 'alice.wilson@library.com', '+1-555-0201', 'Manager', '2015-01-15', 65000.00, 'Active'),
('EMP002', 'Bob', 'Martinez', 'bob.martinez@library.com', '+1-555-0202', 'Librarian', '2018-03-20', 45000.00, 'Active'),
('EMP003', 'Carol', 'Anderson', 'carol.anderson@library.com', '+1-555-0203', 'Assistant Librarian', '2020-06-10', 35000.00, 'Active');

-- Insert Staff Profiles
INSERT IGNORE INTO staff_profiles (staff_id, address, emergency_contact_name, emergency_contact_phone, qualifications, department, supervisor_id) VALUES
(1, '100 Library Lane, Anytown, ST 12345', 'Tom Wilson', '+1-555-0301', 'MLS - Master of Library Science, MBA', 'Administration', NULL),
(2, '200 Book Street, Anytown, ST 12345', 'Maria Martinez', '+1-555-0302', 'MLS - Master of Library Science', 'Circulation', 1),
(3, '300 Reading Road, Anytown, ST 12345', 'David Anderson', '+1-555-0303', 'Bachelor in Library Science', 'Reference', 2);

-- Insert Sample Loans
INSERT IGNORE INTO loans (book_id, member_id, loan_date, due_date, return_date, fine_amount, status, notes) VALUES
(1, 1, '2024-01-15', '2024-02-15', '2024-02-10', 0.00, 'Returned', 'Book returned in good condition'),
(2, 2, '2024-01-20', '2024-02-20', NULL, 0.00, 'Active', 'Currently on loan'),
(3, 3, '2024-01-10', '2024-02-10', '2024-02-18', 5.00, 'Returned', 'Returned 8 days late'),
(4, 1, '2024-02-01', '2024-03-01', NULL, 0.00, 'Active', 'Second book for this member'),
(5, 4, '2024-01-25', '2024-02-25', NULL, 0.00, 'Overdue', 'Book is overdue, member contacted');

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- Drop and recreate views
DROP VIEW IF EXISTS available_books_view;
CREATE VIEW available_books_view AS
SELECT 
    b.book_id,
    b.isbn,
    b.title,
    b.publication_year,
    b.copies_available,
    b.total_copies,
    b.price,
    p.publisher_name,
    c.category_name,
    GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors
FROM books b
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN categories c ON b.category_id = c.category_id
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
WHERE b.copies_available > 0
GROUP BY b.book_id, b.isbn, b.title, b.publication_year, b.copies_available, b.total_copies, b.price, p.publisher_name, c.category_name;

DROP VIEW IF EXISTS active_loans_view;
CREATE VIEW active_loans_view AS
SELECT 
    l.loan_id,
    l.loan_date,
    l.due_date,
    l.fine_amount,
    l.status,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    m.membership_number,
    m.email AS member_email,
    b.title AS book_title,
    b.isbn,
    CONCAT(a.first_name, ' ', a.last_name) AS author_name
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
LEFT JOIN book_authors ba ON b.book_id = ba.book_id AND ba.author_role = 'Primary Author'
LEFT JOIN authors a ON ba.author_id = a.author_id
WHERE l.status IN ('Active', 'Overdue');

-- =====================================================
-- STORED PROCEDURES FOR LIBRARY OPERATIONS
-- =====================================================

DELIMITER //

-- Procedure to issue a book
CREATE PROCEDURE IF NOT EXISTS IssueBook(
    IN p_book_id INT,
    IN p_member_id INT,
    IN p_loan_days INT
)
BEGIN
    DECLARE v_available_copies INT DEFAULT 0;
    DECLARE v_due_date DATE;
    
    -- Check available copies
    SELECT copies_available INTO v_available_copies 
    FROM books 
    WHERE book_id = p_book_id;
    
    IF v_available_copies > 0 THEN
        -- Calculate due date
        SET v_due_date = DATE_ADD(CURDATE(), INTERVAL p_loan_days DAY);
        
        -- Insert loan record
        INSERT INTO loans (book_id, member_id, loan_date, due_date, status)
        VALUES (p_book_id, p_member_id, CURDATE(), v_due_date, 'Active');
        
        -- Update available copies
        UPDATE books 
        SET copies_available = copies_available - 1 
        WHERE book_id = p_book_id;
        
        SELECT 'Book issued successfully' AS message, LAST_INSERT_ID() AS loan_id;
    ELSE
        SELECT 'Book not available' AS message, 0 AS loan_id;
    END IF;
END //

-- Procedure to return a book
CREATE PROCEDURE IF NOT EXISTS ReturnBook(
    IN p_loan_id INT
)
BEGIN
    DECLARE v_book_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_fine DECIMAL(8,2) DEFAULT 0.00;
    DECLARE v_days_late INT DEFAULT 0;
    
    -- Get loan details
    SELECT book_id, due_date 
    INTO v_book_id, v_due_date
    FROM loans 
    WHERE loan_id = p_loan_id AND status = 'Active';
    
    IF v_book_id IS NOT NULL THEN
        -- Calculate fine if overdue
        IF CURDATE() > v_due_date THEN
            SET v_days_late = DATEDIFF(CURDATE(), v_due_date);
            SET v_fine = v_days_late * 1.00; -- $1 per day
        END IF;
        
        -- Update loan record
        UPDATE loans 
        SET return_date = CURDATE(), 
            status = 'Returned', 
            fine_amount = v_fine
        WHERE loan_id = p_loan_id;
        
        -- Update available copies
        UPDATE books 
        SET copies_available = copies_available + 1 
        WHERE book_id = v_book_id;
        
        SELECT 'Book returned successfully' AS message, v_fine AS fine_amount;
    ELSE
        SELECT 'Invalid loan ID or book already returned' AS message, 0.00 AS fine_amount;
    END IF;
END //

DELIMITER ;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Show all tables
SELECT TABLE_NAME, TABLE_ROWS 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'library_management_system'
ORDER BY TABLE_NAME;

-- Show row counts
SELECT 'Publishers' AS table_name, COUNT(*) AS row_count FROM publishers
UNION ALL SELECT 'Categories', COUNT(*) FROM categories
UNION ALL SELECT 'Authors', COUNT(*) FROM authors  
UNION ALL SELECT 'Books', COUNT(*) FROM books
UNION ALL SELECT 'Members', COUNT(*) FROM members
UNION ALL SELECT 'Staff', COUNT(*) FROM staff
UNION ALL SELECT 'Loans', COUNT(*) FROM loans;

-- Test queries
SELECT * FROM available_books_view LIMIT 5;
SELECT * FROM active_loans_view;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
SELECT 'Library Management System created successfully!' AS Status;