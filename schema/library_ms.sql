CREATE DATABASE library_ms;
USE library_ms;


-- 1. Authors Table
CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Biography TEXT
);

-- 2. Publishers Table
CREATE TABLE Publishers (
    PublisherID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE,
    Address VARCHAR(255),
    ContactInfo VARCHAR(255)
);

-- 3. Categories Table
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

-- 4. Books Table
CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    ISBN VARCHAR(13) NOT NULL UNIQUE,
    Title VARCHAR(255) NOT NULL,
    PublisherID INT,
    PublicationYear INT,  -- Changed to INT to avoid range issues (MySQL YEAR datatype is limited)
    TotalCopies INT NOT NULL DEFAULT 1,
    AvailableCopies INT NOT NULL DEFAULT 1,
    ShelfLocation VARCHAR(50),
    CONSTRAINT fk_books_publisher FOREIGN KEY (PublisherID)
        REFERENCES Publishers(PublisherID)
        ON DELETE SET NULL   -- If a Publisher is deleted, set PublisherID in Books to NULL.
        ON UPDATE CASCADE    -- If PublisherID changes, update Books accordingly.
);

ALTER table Books 
MODIFY ISBN VARCHAR(20); -- had to alter the VARCHAR(13) cause you additional ' - ' in ISBN



-- 5. BookAuthors Table (Many-to-Many Relationship)
CREATE TABLE BookAuthors (
    BookID INT NOT NULL,
    AuthorID INT NOT NULL,
    PRIMARY KEY (BookID, AuthorID),
    CONSTRAINT fk_bookauthors_book FOREIGN KEY (BookID)
        REFERENCES Books(BookID)
        ON DELETE CASCADE  -- Delete associated BookAuthors record if a Book is removed.
        ON UPDATE CASCADE, -- If BookID is updated, cascade changes.
    CONSTRAINT fk_bookauthors_author FOREIGN KEY (AuthorID)
        REFERENCES Authors(AuthorID)
        ON DELETE CASCADE  -- Delete associated record if an Author is removed.
        ON UPDATE CASCADE   -- If AuthorID is updated, cascade changes.
);

-- 6. BookCategories Table (Many-to-Many Relationship)
CREATE TABLE BookCategories (
    BookID INT NOT NULL,
    CategoryID INT NOT NULL,
    PRIMARY KEY (BookID, CategoryID),
    CONSTRAINT fk_bookcategories_book FOREIGN KEY (BookID)
        REFERENCES Books(BookID)
        ON DELETE CASCADE  -- Delete association if a Book is removed.
        ON UPDATE CASCADE, -- If BookID is updated, cascade changes.
    CONSTRAINT fk_bookcategories_category FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID)
        ON DELETE CASCADE  -- Delete association if a Category is removed.
        ON UPDATE CASCADE   -- If CategoryID is updated, cascade changes.
);

-- 7. Members Table
CREATE TABLE Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    LibraryCardNumber VARCHAR(50) NOT NULL UNIQUE,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Address VARCHAR(255),
    Email VARCHAR(255) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(50), -- alteed this becuase the random for 100k  data 
    RegistrationDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ExpiryDate TIMESTAMP,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    PasswordHash VARCHAR(255),
    PasswordSalt VARCHAR(100)
);

-- 8. Users Table (Librarians/Staff)
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    PasswordSalt VARCHAR(100) NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Role VARCHAR(50) NOT NULL,          -- Example roles: 'Admin', 'Librarian', etc.
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    LastLogin TIMESTAMP NULL
);

-- 9. Loans Table
CREATE TABLE Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    LoanDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DueDate TIMESTAMP NOT NULL,
    ReturnDate TIMESTAMP,  -- NULL indicates the book is still checked out
    IssuedByUserID INT,    -- Librarian issuing the loan
    ReceivedByUserID INT,  -- Librarian processing the return
    CONSTRAINT fk_loans_book FOREIGN KEY (BookID)
        REFERENCES Books(BookID)
        ON DELETE RESTRICT  -- Prevent deletion of a Book if a loan record exists.
        ON UPDATE CASCADE,  -- Cascade update of BookID to Loans.
    CONSTRAINT fk_loans_member FOREIGN KEY (MemberID)
        REFERENCES Members(MemberID)
        ON DELETE RESTRICT  -- Prevent deletion of a Member if a loan record exists.
        ON UPDATE CASCADE,  -- Cascade update of MemberID to Loans.
    CONSTRAINT fk_loans_issuedby FOREIGN KEY (IssuedByUserID)
        REFERENCES Users(UserID)
        ON DELETE SET NULL  -- If the issuing user is removed, set IssuedByUserID to NULL.
        ON UPDATE CASCADE,  -- Cascade update of UserID to Loans.
    CONSTRAINT fk_loans_receivedby FOREIGN KEY (ReceivedByUserID)
        REFERENCES Users(UserID)
        ON DELETE SET NULL  -- If the receiving user is removed, set ReceivedByUserID to NULL.
        ON UPDATE CASCADE,  -- Cascade update of UserID to Loans.
    CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate)
);

-- 10. Fines Table (Optional for Tracking Overdue Fines)
CREATE TABLE Fines (
    FineID INT AUTO_INCREMENT PRIMARY KEY,
    LoanID INT NOT NULL UNIQUE,  -- One fine record per overdue loan
    MemberID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    DateIssued TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DatePaid TIMESTAMP,
    Reason VARCHAR(255),
    CONSTRAINT fk_fines_loan FOREIGN KEY (LoanID)
        REFERENCES Loans(LoanID)
        ON DELETE CASCADE  -- Delete fine record if the associated loan is removed.
        ON UPDATE CASCADE, -- Cascade update of LoanID to Fines.
    CONSTRAINT fk_fines_member FOREIGN KEY (MemberID)
        REFERENCES Members(MemberID)
        ON DELETE RESTRICT  -- Prevent deletion of a Member if a fine record exists.
        ON UPDATE CASCADE   -- Cascade update of MemberID to Fines.
);



