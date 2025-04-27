-- To set the limit to 100k
set @@global.sql_select_limit=110000;


-- Top 5 Most Borrowed Books
SELECT 
    B.Title,
    COUNT(L.BookID) AS TimesBorrowed
FROM Loans L
JOIN Books B ON L.BookID = B.BookID
GROUP BY L.BookID
ORDER BY TimesBorrowed DESC
LIMIT 110000;
explain 

-- How many books are borrowed each month?
SELECT 
  YEAR(LoanDate) AS LoanYear,
  MONTH(LoanDate) AS LoanMonth,
  COUNT(*) AS TotalBorrowed
FROM Loans
GROUP BY LoanYear, LoanMonth;

-- Most Active Members   
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

-- Average Loan Duration Per Member
SELECT 
    M.MemberID,
    CONCAT(M.FirstName, ' ', M.LastName) AS MemberName,
    AVG(DATEDIFF(IFNULL(L.ReturnDate, CURDATE()), L.LoanDate)) AS AvgLoanDurationDays
FROM Loans L
JOIN Members M ON L.MemberID = M.MemberID
GROUP BY M.MemberID; 

-- Total Books Available by Category
SELECT 
    c.Name AS CategoryName,
    SUM(b.AvailableCopies) AS TotalAvailableBooks
FROM Categories c
JOIN BookCategories bc ON c.CategoryID = bc.CategoryID
JOIN Books b ON bc.BookID = b.BookID
GROUP BY c.CategoryID
ORDER BY TotalAvailableBooks DESC;

-- Most Borrowed Book Categories
SELECT 
    C.Name AS Category,
    COUNT(L.LoanID) AS TotalLoans
FROM Loans L
JOIN Books B ON L.BookID = B.BookID
JOIN BookCategories BC ON B.BookID = BC.BookID
JOIN Categories C ON BC.CategoryID = C.CategoryID
GROUP BY C.CategoryID, C.Name
ORDER BY TotalLoans DESC;
