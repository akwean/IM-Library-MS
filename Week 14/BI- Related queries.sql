-- **************************************************************************
-- Global setting: Limit SELECTs to 110,000 rows.
-- This ensures that even if a query omits an explicit LIMIT,
-- it will return at most 110,000 rows.
-- **************************************************************************
SET @@global.sql_select_limit = 110000;

-- **************************************************************************
-- Query 1: Top 5 Most Borrowed Books
-- **************************************************************************
-- EXPLAIN version:
EXPLAIN
SELECT 
    B.Title,
    COUNT(L.BookID) AS TimesBorrowed
FROM Loans L
JOIN Books B ON L.BookID = B.BookID
GROUP BY L.BookID
ORDER BY TimesBorrowed DESC
LIMIT 5;

-- Actual Query:
SELECT 
    B.Title,
    COUNT(L.BookID) AS TimesBorrowed
FROM Loans L
JOIN Books B ON L.BookID = B.BookID
GROUP BY L.BookID
ORDER BY TimesBorrowed DESC
LIMIT 5;

-- **************************************************************************
-- Query 2: How Many Books Are Borrowed Each Month?
-- **************************************************************************
-- EXPLAIN version:
EXPLAIN
SELECT 
  YEAR(LoanDate) AS LoanYear,
  MONTH(LoanDate) AS LoanMonth,
  COUNT(*) AS TotalBorrowed
FROM Loans
GROUP BY LoanYear, LoanMonth;

-- Actual Query:
SELECT 
  YEAR(LoanDate) AS LoanYear,
  MONTH(LoanDate) AS LoanMonth,
  COUNT(*) AS TotalBorrowed
FROM Loans
GROUP BY LoanYear, LoanMonth;

-- **************************************************************************
-- Query 3: Most Active Members
-- **************************************************************************
-- EXPLAIN version:
EXPLAIN
SELECT 
    M.MemberID,
    CONCAT(M.FirstName, ' ', M.LastName) AS FullName,
    M.Email,
    COUNT(L.LoanID) AS TotalBooksBorrowed,
    MIN(L.LoanDate) AS FirstLoanDate,
    MAX(L.LoanDate) AS LastLoanDate
FROM Loans L
JOIN Members M ON L.MemberID = M.MemberID
GROUP BY M.MemberID, FullName, M.Email
ORDER BY TotalBooksBorrowed DESC
LIMIT 100000;

-- Actual Query:
SELECT 
    M.MemberID,
    CONCAT(M.FirstName, ' ', M.LastName) AS FullName,
    M.Email,
    COUNT(L.LoanID) AS TotalBooksBorrowed,
    MIN(L.LoanDate) AS FirstLoanDate,
    MAX(L.LoanDate) AS LastLoanDate
FROM Loans L
JOIN Members M ON L.MemberID = M.MemberID
GROUP BY M.MemberID, FullName, M.Email
ORDER BY TotalBooksBorrowed DESC
LIMIT 100000;

-- **************************************************************************
-- Query 4: Average Loan Duration Per Member
-- **************************************************************************
-- EXPLAIN version:
EXPLAIN
SELECT 
    M.MemberID,
    CONCAT(M.FirstName, ' ', M.LastName) AS MemberName,
    AVG(DATEDIFF(IFNULL(L.ReturnDate, CURDATE()), L.LoanDate)) AS AvgLoanDurationDays
FROM Loans L
JOIN Members M ON L.MemberID = M.MemberID
GROUP BY M.MemberID;

-- Actual Query:
SELECT 
    M.MemberID,
    CONCAT(M.FirstName, ' ', M.LastName) AS MemberName,
    AVG(DATEDIFF(IFNULL(L.ReturnDate, CURDATE()), L.LoanDate)) AS AvgLoanDurationDays
FROM Loans L
JOIN Members M ON L.MemberID = M.MemberID
GROUP BY M.MemberID;

-- **************************************************************************
-- Query 5: Total Books Available by Category
-- **************************************************************************
-- EXPLAIN version:
EXPLAIN
SELECT 
    c.Name AS CategoryName,
    SUM(b.AvailableCopies) AS TotalAvailableBooks
FROM Categories c
JOIN BookCategories bc ON c.CategoryID = bc.CategoryID
JOIN Books b ON bc.BookID = b.BookID
GROUP BY c.CategoryID
ORDER BY TotalAvailableBooks DESC;

-- Actual Query:
SELECT 
    c.Name AS CategoryName,
    SUM(b.AvailableCopies) AS TotalAvailableBooks
FROM Categories c
JOIN BookCategories bc ON c.CategoryID = bc.CategoryID
JOIN Books b ON bc.BookID = b.BookID
GROUP BY c.CategoryID
ORDER BY TotalAvailableBooks DESC;

-- **************************************************************************
-- Query 6: Most Borrowed Book Categories
-- **************************************************************************
-- EXPLAIN version:
EXPLAIN
SELECT 
    C.Name AS Category,
    COUNT(L.LoanID) AS TotalLoans
FROM Loans L
JOIN Books B ON L.BookID = B.BookID
JOIN BookCategories BC ON B.BookID = BC.BookID
JOIN Categories C ON BC.CategoryID = C.CategoryID
GROUP BY C.CategoryID, C.Name
ORDER BY TotalLoans DESC;

-- Actual Query:
SELECT 
    C.Name AS Category,
    COUNT(L.LoanID) AS TotalLoans
FROM Loans L
JOIN Books B ON L.BookID = B.BookID
JOIN BookCategories BC ON B.BookID = BC.BookID
JOIN Categories C ON BC.CategoryID = C.CategoryID
GROUP BY C.CategoryID, C.Name
ORDER BY TotalLoans DESC;









-- Index on Loans.LoanDate
-- Purpose: Improves performance for queries that aggregate or filter by LoanDate,
-- such as Query 2 (How Many Books Are Borrowed Each Month). 
-- Note: Since YEAR() and MONTH() functions are used, consider a functional index 
-- or storing computed values if needed (MySQL 8.0+ supports functional indexes).
-- -------------------------------------------------------------------
 CREATE INDEX idx_loans_loandate ON Loans(LoanDate);

-- Composite index on Loans(MemberID, LoanDate)
-- Purpose: Speeds up Query 3 by allowing the engine to efficiently locate and aggregate all loan records for each member,
--          using the composite index to obtain both the grouping column (MemberID) and the LoanDate for MIN/MAX calculations.
CREATE INDEX idx_loans_memberid_loandate ON Loans(MemberID, LoanDate);

-- Composite index on BookCategories(CategoryID, BookID)
-- Purpose: Improves join performance for Query 5 and Query 6 by optimizing lookups on CategoryID.
--          Since the join starts with the CategoryID, having it as the first column in the index
--          can reduce the number of rows scanned when joining with Categories.
CREATE INDEX idx_bc_category_book ON BookCategories(CategoryID, BookID);

SHOW INDEX FROM Loans;
SHOW INDEX FROM BookCategories;

