
# Library Management System Database

A comprehensive MySQL database solution for managing library operations including book inventory, member management, staff administration, and loan tracking.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Database Schema](#database-schema)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Database Structure](#database-structure)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Sample Queries](#sample-queries)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Overview

This Library Management System provides a complete database solution for libraries of all sizes. The system handles book cataloging, member registration, staff management, loan processing, and fine calculation with proper data integrity and business logic enforcement.

## Features

- **Complete Book Management**: ISBN tracking, multiple copies, author relationships
- **Member Management**: Multiple membership types with status tracking
- **Staff Administration**: Employee profiles with hierarchical relationships
- **Loan Processing**: Automated due date calculation and fine management
- **Data Integrity**: Foreign key constraints and business rule validation
- **Reporting Views**: Pre-built queries for common operations
- **Stored Procedures**: Automated book issue/return processing
- **Audit Trails**: Created/updated timestamps on all records

## Database Schema

### Core Entities
- **Publishers**: Publishing company information
- **Categories**: Book genres and classifications
- **Authors**: Author biographical information
- **Books**: Complete book catalog with inventory tracking
- **Members**: Library patron management
- **Staff**: Employee information and profiles
- **Loans**: Book borrowing transactions

### Relationships
- **Many-to-Many**: Books ↔ Authors (through `book_authors`)
- **One-to-Many**: Publishers → Books, Categories → Books
- **One-to-Many**: Members → Loans, Books → Loans
- **One-to-One**: Staff ↔ Staff Profiles

## Prerequisites

- MySQL Server 8.0 or higher
- MySQL Workbench (recommended) or command-line client
- Minimum 50MB database storage space
- User account with CREATE, INSERT, UPDATE, DELETE privileges

## Installation

### Step 1: Database Setup

1. Open MySQL Workbench or connect via command line
2. Execute the provided SQL script:
   ```sql
   -- Run the complete library_management_system.sql script
   ```

### Step 2: Verification

Run the verification queries included in the script to ensure proper installation:

```sql
-- Check table creation
SELECT TABLE_NAME, TABLE_ROWS 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'library_management_system'
ORDER BY TABLE_NAME;

-- Verify sample data
SELECT 'Publishers' AS table_name, COUNT(*) AS row_count FROM publishers
UNION ALL SELECT 'Categories', COUNT(*) FROM categories
UNION ALL SELECT 'Authors', COUNT(*) FROM authors  
UNION ALL SELECT 'Books', COUNT(*) FROM books
UNION ALL SELECT 'Members', COUNT(*) FROM members
UNION ALL SELECT 'Staff', COUNT(*) FROM staff
UNION ALL SELECT 'Loans', COUNT(*) FROM loans;
```

Expected Results:
- 8 tables created successfully
- Sample data: 4 publishers, 10 categories, 5 authors, 6 books, 4 members, 3 staff, 5 loans

## Database Structure

### Tables

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `publishers` | Publishing companies | `publisher_id`, `publisher_name` |
| `categories` | Book genres | `category_id`, `category_name` |
| `authors` | Author information | `author_id`, `first_name`, `last_name` |
| `books` | Book catalog | `book_id`, `isbn`, `title`, `copies_available` |
| `book_authors` | Book-Author relationships | `book_id`, `author_id`, `author_role` |
| `members` | Library patrons | `member_id`, `membership_number`, `membership_type` |
| `staff` | Employee records | `staff_id`, `employee_id`, `position` |
| `staff_profiles` | Extended staff info | `profile_id`, `staff_id`, `department` |
| `loans` | Borrowing transactions | `loan_id`, `book_id`, `member_id`, `status` |

### Views

#### `available_books_view`
Shows all books currently available for loan with complete details including authors and publishers.

```sql
SELECT * FROM available_books_view;
```

#### `active_loans_view`
Displays all current active and overdue loans with member and book information.

```sql
SELECT * FROM active_loans_view;
```

## Usage

### Basic Operations

#### Issue a Book
```sql
CALL IssueBook(book_id, member_id, loan_days);

-- Example: Issue book ID 1 to member ID 2 for 14 days
CALL IssueBook(1, 2, 14);
```

#### Return a Book
```sql
CALL ReturnBook(loan_id);

-- Example: Return loan ID 3
CALL ReturnBook(3);
```

#### Add New Books
```sql
INSERT INTO books (isbn, title, publication_year, pages, copies_available, total_copies, price, publisher_id, category_id)
VALUES ('978-1-234-56789-0', 'New Book Title', 2024, 300, 3, 3, 19.99, 1, 1);
```

#### Register New Members
```sql
INSERT INTO members (membership_number, first_name, last_name, email, membership_type)
VALUES ('LIB005', 'Jane', 'Doe', 'jane.doe@email.com', 'Public');
```

## API Reference

### Stored Procedures

#### `IssueBook(book_id, member_id, loan_days)`
Issues a book to a member for the specified number of days.

**Parameters:**
- `book_id` (INT): ID of the book to issue
- `member_id` (INT): ID of the member borrowing the book  
- `loan_days` (INT): Number of days for the loan period

**Returns:**
- Success message and loan ID, or error message if book unavailable

#### `ReturnBook(loan_id)`
Processes the return of a borrowed book and calculates any applicable fines.

**Parameters:**
- `loan_id` (INT): ID of the loan being returned

**Returns:**
- Success message and fine amount (if any)

**Fine Calculation:**
- $1.00 per day for overdue returns

## Sample Queries

### Find Available Books by Category
```sql
SELECT b.title, b.isbn, a.first_name, a.last_name, b.copies_available
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
JOIN categories c ON b.category_id = c.category_id
WHERE c.category_name = 'Fiction' AND b.copies_available > 0;
```

### View Overdue Books
```sql
SELECT 
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    b.title,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) AS days_overdue
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.status = 'Active' AND l.due_date < CURDATE();
```

### Member Loan History
```sql
SELECT 
    b.title,
    l.loan_date,
    l.due_date,
    l.return_date,
    l.status,
    l.fine_amount
FROM loans l
JOIN books b ON l.book_id = b.book_id
WHERE l.member_id = 1
ORDER BY l.loan_date DESC;
```

### Popular Books Report
```sql
SELECT 
    b.title,
    COUNT(l.loan_id) as times_borrowed,
    b.copies_available,
    b.total_copies
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id
GROUP BY b.book_id, b.title, b.copies_available, b.total_copies
ORDER BY times_borrowed DESC
LIMIT 10;
```

## Troubleshooting

### Common Issues

#### "Table already exists" Warning
This is normal when running the script multiple times. The `IF NOT EXISTS` clause prevents errors.

#### Foreign Key Constraint Errors
Ensure parent records exist before inserting child records:
1. Publishers before Books
2. Categories before Books  
3. Authors before Book-Authors relationships
4. Members and Books before Loans

#### Check Constraint Errors
The system removes function-based CHECK constraints to avoid MySQL compatibility issues. Business logic validation is handled through stored procedures.

### Performance Optimization

#### Recommended Indexes
The script includes optimized indexes for common queries:
- Book titles and ISBNs
- Member names and membership numbers
- Loan dates and status
- Author names

#### Query Optimization Tips
- Use the provided views for complex joins
- Index frequently searched columns
- Limit result sets with appropriate WHERE clauses
- Use stored procedures for business logic

## Database Maintenance

### Regular Tasks

#### Update Overdue Status
```sql
UPDATE loans 
SET status = 'Overdue' 
WHERE status = 'Active' AND due_date < CURDATE();
```

#### Archive Old Loans
```sql
-- Create archive table for loans older than 2 years
CREATE TABLE loans_archive AS 
SELECT * FROM loans 
WHERE return_date < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);

-- Remove archived loans from main table
DELETE FROM loans 
WHERE return_date < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
```

### Backup Strategy
- Regular full database backups (weekly)
- Daily incremental backups
- Transaction log backups (hourly)
- Test restore procedures monthly

## Security Considerations

### User Access Control
Create specific database users with limited privileges:

```sql
-- Create application user
CREATE USER 'library_app'@'localhost' IDENTIFIED BY 'secure_password';
GRANT SELECT, INSERT, UPDATE ON library_management_system.* TO 'library_app'@'localhost';

-- Create read-only user for reports
CREATE USER 'library_reports'@'localhost' IDENTIFIED BY 'report_password';
GRANT SELECT ON library_management_system.* TO 'library_reports'@'localhost';
```

### Data Protection
- Hash sensitive member information
- Implement audit logging
- Regular security updates
- Secure database connections (SSL)

## Future Enhancements

### Potential Features
- Digital resource management
- Online catalog search
- Automated notifications
- Barcode integration
- Multi-branch support
- Fine payment processing
- Book reservation queue
- Reading history analytics

### Scalability Considerations
- Table partitioning for large datasets
- Read replicas for reporting
- Caching frequently accessed data
- Database sharding for multi-location libraries

## Contributing

### Development Guidelines
- Follow consistent naming conventions
- Document all schema changes
- Include migration scripts
- Test all modifications
- Update this README for significant changes

### Schema Modifications
When modifying the database structure:
1. Create migration scripts
2. Update stored procedures if affected
3. Modify views as needed
4. Update sample queries
5. Test thoroughly before deployment

## License

This project is released under the MIT License. See LICENSE file for details.

## Support

For technical support or questions:
- Review this documentation
- Check the troubleshooting section
- Examine the sample queries
- Verify your MySQL version compatibility

## Version History

- **v1.0.0**: Initial release with core functionality
- **v1.1.0**: Added error handling and improved constraints
- **v1.2.0**: Enhanced stored procedures and views
