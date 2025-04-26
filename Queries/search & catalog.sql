-- Search books by title (partial match)
SELECT 
    b.BookID,
    b.Title,
    b.ISBN,
    b.PublicationYear,
    b.TotalCopies,
    b.AvailableCopies,
    b.ShelfLocation,
    GROUP_CONCAT(DISTINCT CONCAT(a.FirstName, ' ', a.LastName) SEPARATOR ', ') AS Authors,
    GROUP_CONCAT(DISTINCT c.Name SEPARATOR ', ') AS Categories
FROM Books b
LEFT JOIN BookAuthors ba ON b.BookID = ba.BookID
LEFT JOIN Authors a ON ba.AuthorID = a.AuthorID
LEFT JOIN BookCategories bc ON b.BookID = bc.BookID
LEFT JOIN Categories c ON bc.CategoryID = c.CategoryID
WHERE b.Title LIKE CONCAT('%', 'The', '%')
GROUP BY b.BookID;

-- Search books by author name (partial match)
SELECT 
    b.BookID,
    b.Title,
    b.ISBN,
    b.PublicationYear,
    b.TotalCopies,
    b.AvailableCopies,
    b.ShelfLocation,
    GROUP_CONCAT(DISTINCT CONCAT(a.FirstName, ' ', a.LastName) SEPARATOR ', ') AS Authors,
    GROUP_CONCAT(DISTINCT c.Name SEPARATOR ', ') AS Categories
FROM Books b
LEFT JOIN BookAuthors ba ON b.BookID = ba.BookID
LEFT JOIN Authors a ON ba.AuthorID = a.AuthorID
LEFT JOIN BookCategories bc ON b.BookID = bc.BookID
LEFT JOIN Categories c ON bc.CategoryID = c.CategoryID
WHERE CONCAT(a.FirstName, ' ', a.LastName) LIKE CONCAT('%', 'Moon', '%')
GROUP BY b.BookID;

-- Search books by category name (partial match)
SELECT 
    b.BookID,
    b.Title,
    b.ISBN,
    b.PublicationYear,
    b.TotalCopies,
    b.AvailableCopies,
    b.ShelfLocation,
    GROUP_CONCAT(DISTINCT CONCAT(a.FirstName, ' ', a.LastName) SEPARATOR ', ') AS Authors,
    GROUP_CONCAT(DISTINCT c.Name SEPARATOR ', ') AS Categories
FROM Books b
LEFT JOIN BookAuthors ba ON b.BookID = ba.BookID
LEFT JOIN Authors a ON ba.AuthorID = a.AuthorID
LEFT JOIN BookCategories bc ON b.BookID = bc.BookID
LEFT JOIN Categories c ON bc.CategoryID = c.CategoryID
WHERE c.Name LIKE CONCAT('%', 'politics', '%')
GROUP BY b.BookID;

-- Search books by availability status
-- Replace 'available' with 'unavailable' to find books that are not available
SELECT 
    b.BookID,
    b.Title,
    b.ISBN,
    b.PublicationYear,
    b.TotalCopies,
    b.AvailableCopies,
    b.ShelfLocation,
    GROUP_CONCAT(DISTINCT CONCAT(a.FirstName, ' ', a.LastName) SEPARATOR ', ') AS Authors,
    GROUP_CONCAT(DISTINCT c.Name SEPARATOR ', ') AS Categories
FROM Books b
LEFT JOIN BookAuthors ba ON b.BookID = ba.BookID
LEFT JOIN Authors a ON ba.AuthorID = a.AuthorID
LEFT JOIN BookCategories bc ON b.BookID = bc.BookID
LEFT JOIN Categories c ON bc.CategoryID = c.CategoryID
WHERE b.AvailableCopies > 0
GROUP BY b.BookID;

SELECT 
    b.BookID,
    b.Title,
    GROUP_CONCAT(DISTINCT CONCAT(a.FirstName, ' ', a.LastName)) AS Authors,
    GROUP_CONCAT(DISTINCT c.Name) AS Categories
FROM Books b
LEFT JOIN BookAuthors ba ON b.BookID = ba.BookID
LEFT JOIN Authors a ON ba.AuthorID = a.AuthorID
LEFT JOIN BookCategories bc ON b.BookID = bc.BookID
LEFT JOIN Categories c ON bc.CategoryID = c.CategoryID
GROUP BY b.BookID
LIMIT 10;



