-- Create and switch to the library database
-- This database holds all tables related to library management
CREATE DATABASE IF NOT EXISTS library_ms;
USE library_ms;

-- -----------------------------------------------------------------------------------
-- 1. Authors Table: stores basic author information (names, biography)
-- -----------------------------------------------------------------------------------
CREATE TABLE Authors (
    AuthorID    INT AUTO_INCREMENT PRIMARY KEY,         -- Unique identifier for each author
    FirstName   VARCHAR(100) NOT NULL,                  -- Author's given name
    LastName    VARCHAR(100) NOT NULL,                  -- Author's family name
    Biography   TEXT                                    -- Short bio or description of the author
);

-- -----------------------------------------------------------------------------------
-- 2. Publishers Table: stores publishing company details
-- -----------------------------------------------------------------------------------
CREATE TABLE Publishers (
    PublisherID INT AUTO_INCREMENT PRIMARY KEY,         -- Unique identifier for each publisher
    Name        VARCHAR(255) NOT NULL UNIQUE,           -- Publisher name, enforced unique
    Address     VARCHAR(255),                           -- Physical or mailing address
    ContactInfo VARCHAR(255)                            -- Phone, email or other contact details
);

-- -----------------------------------------------------------------------------------
-- 3. Categories Table: stores book categories or genres
-- -----------------------------------------------------------------------------------
CREATE TABLE Categories (
    CategoryID   INT AUTO_INCREMENT PRIMARY KEY,        -- Unique identifier for each category
    Name         VARCHAR(100) NOT NULL UNIQUE,          -- Category name, enforced unique
    Description  VARCHAR(255)                            -- Brief description of the category
);

-- -----------------------------------------------------------------------------------
-- 4. Books Table: stores each book's core information
-- -----------------------------------------------------------------------------------
CREATE TABLE Books (
    BookID          INT AUTO_INCREMENT PRIMARY KEY,    -- Unique book record ID
    ISBN            VARCHAR(20) NOT NULL UNIQUE,       -- International Standard Book Number
    Title           VARCHAR(255) NOT NULL,             -- Book title
    PublisherID     INT,                                -- Reference to Publishers(PublisherID)
    PublicationYear INT,                                -- Year the book was published
    TotalCopies     INT NOT NULL DEFAULT 1,             -- Total copies owned by library
    AvailableCopies INT NOT NULL DEFAULT 1,             -- Currently available copies
    ShelfLocation   VARCHAR(50),                        -- Physical shelf location code
    
    -- Foreign key: links each book to its publisher
    CONSTRAINT fk_books_publisher FOREIGN KEY (PublisherID)
        REFERENCES Publishers(PublisherID)
        ON DELETE SET NULL      -- If publisher removed, leave PublisherID NULL
        ON UPDATE CASCADE        -- If PublisherID changes, update Books accordingly
);

-- -----------------------------------------------------------------------------------
-- 5. BookAuthors Table: many-to-many relationship between books and authors
-- -----------------------------------------------------------------------------------
CREATE TABLE BookAuthors (
    BookID   INT NOT NULL,                             -- FK to Books.BookID
    AuthorID INT NOT NULL,                             -- FK to Authors.AuthorID
    PRIMARY KEY (BookID, AuthorID),                    -- Composite PK prevents duplicate pairs

    CONSTRAINT fk_bookauthors_book FOREIGN KEY (BookID)
        REFERENCES Books(BookID)
        ON DELETE CASCADE      -- Remove link if book is deleted
        ON UPDATE CASCADE,
    CONSTRAINT fk_bookauthors_author FOREIGN KEY (AuthorID)
        REFERENCES Authors(AuthorID)
        ON DELETE CASCADE      -- Remove link if author is deleted
        ON UPDATE CASCADE
);

-- -----------------------------------------------------------------------------------
-- 6. BookCategories Table: many-to-many relationship between books and categories
-- -----------------------------------------------------------------------------------
CREATE TABLE BookCategories (
    BookID     INT NOT NULL,                           -- FK to Books.BookID
    CategoryID INT NOT NULL,                           -- FK to Categories.CategoryID
    PRIMARY KEY (BookID, CategoryID),                  -- Composite PK prevents duplicates

    CONSTRAINT fk_bookcategories_book FOREIGN KEY (BookID)
        REFERENCES Books(BookID)
        ON DELETE CASCADE      -- Remove link if book is deleted
        ON UPDATE CASCADE,
    CONSTRAINT fk_bookcategories_category FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID)
        ON DELETE CASCADE      -- Remove link if category is deleted
        ON UPDATE CASCADE
);

-- -----------------------------------------------------------------------------------
-- 7. Members Table: stores library members and their account details
-- -----------------------------------------------------------------------------------
CREATE TABLE Members (
    MemberID           INT AUTO_INCREMENT PRIMARY KEY,   -- Unique member identifier
    LibraryCardNumber  VARCHAR(50) NOT NULL UNIQUE,      -- Unique card number
    FirstName          VARCHAR(100) NOT NULL,            -- Member's given name
    LastName           VARCHAR(100) NOT NULL,            -- Member's family name
    Address            VARCHAR(255),                     -- Residential or mailing address
    Email              VARCHAR(255) NOT NULL UNIQUE,     -- Member's email, enforced unique
    PhoneNumber        VARCHAR(50),                      -- Contact phone number
    RegistrationDate   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Date joined
    ExpiryDate         TIMESTAMP,                        -- Membership expiration
    IsActive           BOOLEAN NOT NULL DEFAULT TRUE,    -- Active flag for membership status
    PasswordHash       VARCHAR(255),                    -- Stored password hash
    PasswordSalt       VARCHAR(100)                     -- Stored password salt for hashing
);

-- -----------------------------------------------------------------------------------
-- 8. Users Table: library staff accounts (librarians, admins)
-- -----------------------------------------------------------------------------------
CREATE TABLE Users (
    UserID        INT AUTO_INCREMENT PRIMARY KEY,       -- Unique user identifier
    Username      VARCHAR(50) NOT NULL UNIQUE,          -- Login username
    PasswordHash  VARCHAR(255) NOT NULL,                -- Stored password hash
    PasswordSalt  VARCHAR(100) NOT NULL,                -- Stored salt for hashing
    FirstName     VARCHAR(100) NOT NULL,                -- Staff member's given name
    LastName      VARCHAR(100) NOT NULL,                -- Staff member's family name
    Email         VARCHAR(255) NOT NULL UNIQUE,         -- Staff email address
    Role          VARCHAR(50) NOT NULL,                 -- Role: 'Admin', 'Librarian', etc.
    IsActive      BOOLEAN NOT NULL DEFAULT TRUE,        -- Active flag for staff account
    LastLogin     TIMESTAMP NULL                        -- Timestamp of last login
);

-- -----------------------------------------------------------------------------------
-- 9. Loans Table: tracks book checkouts and returns
-- -----------------------------------------------------------------------------------
CREATE TABLE Loans (
    LoanID           INT AUTO_INCREMENT PRIMARY KEY,    -- Unique loan record ID
    BookID           INT NOT NULL,                      -- FK to Books.BookID
    MemberID         INT NOT NULL,                      -- FK to Members.MemberID
    LoanDate         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- When loan was issued
    DueDate          TIMESTAMP NOT NULL,                -- When book is due back
    ReturnDate       TIMESTAMP,                         -- NULL if not yet returned
    IssuedByUserID   INT,                               -- FK to Users.UserID (issuer)
    ReceivedByUserID INT,                               -- FK to Users.UserID (receiver)
    
    -- Foreign keys enforce valid references and define cascade behavior
    CONSTRAINT fk_loans_book FOREIGN KEY (BookID)
        REFERENCES Books(BookID)
        ON DELETE RESTRICT     -- Prevent deletion of book with active loans
        ON UPDATE CASCADE,
    CONSTRAINT fk_loans_member FOREIGN KEY (MemberID)
        REFERENCES Members(MemberID)
        ON DELETE RESTRICT     -- Prevent deletion of member with active loans
        ON UPDATE CASCADE,
    CONSTRAINT fk_loans_issuedby FOREIGN KEY (IssuedByUserID)
        REFERENCES Users(UserID)
        ON DELETE SET NULL     -- Allow user removal without orphaned loans
        ON UPDATE CASCADE,
    CONSTRAINT fk_loans_receivedby FOREIGN KEY (ReceivedByUserID)
        REFERENCES Users(UserID)
        ON DELETE SET NULL     -- Allow user removal without orphaned loans
        ON UPDATE CASCADE,

    CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate) -- Ensure return dates are after loan dates
);

-- -----------------------------------------------------------------------------------
-- 10. Fines Table: automatically generated via triggers for overdue loans
-- -----------------------------------------------------------------------------------
CREATE TABLE Fines (
    FineID      INT AUTO_INCREMENT PRIMARY KEY,          -- Unique fine record ID
    LoanID      INT NOT NULL UNIQUE,                     -- FK to Loans.LoanID (one fine per loan)
    MemberID    INT NOT NULL,                            -- FK to Members.MemberID (owner of fine)
    Amount      DECIMAL(10,2) NOT NULL,                  -- Total fine amount calculated
    DateIssued  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- When fine was generated
    DatePaid    TIMESTAMP NULL,                          -- When fine was paid (NULL if unpaid)
    Reason      VARCHAR(255),                           -- Description of why fine was applied

    CONSTRAINT fk_fines_loan FOREIGN KEY (LoanID)
        REFERENCES Loans(LoanID)
        ON DELETE CASCADE    -- Remove fine if associated loan is deleted
        ON UPDATE CASCADE,
    CONSTRAINT fk_fines_member FOREIGN KEY (MemberID)
        REFERENCES Members(MemberID)
        ON DELETE RESTRICT   -- Prevent member deletion if unpaid fine exists
        ON UPDATE CASCADE
);

-- -----------------------------------------------------------------------------------
-- 11. Triggers: automatic fine generation on Loans INSERT/UPDATE
-- -----------------------------------------------------------------------------------

-- AFTER INSERT: generate fine immediately for overdue loans loaded or inserted
-- Uses DATEDIFF on ReturnDate vs DueDate and rate of 10 units/day
DELIMITER $$
CREATE TRIGGER trg_after_insert_loan
AFTER INSERT ON Loans
FOR EACH ROW
BEGIN
  DECLARE days_overdue INT;
  DECLARE fine_amt    DECIMAL(10,2);

  -- Calculate overdue days (zero if not yet returned or not overdue)
  SET days_overdue = GREATEST(DATEDIFF(NEW.ReturnDate, NEW.DueDate), 0);

  IF days_overdue > 0 THEN
    -- Rate: 10 units per overdue day
    SET fine_amt = days_overdue * 10;

    INSERT INTO Fines (
      LoanID, MemberID, Amount, DateIssued, Reason
    ) VALUES (
      NEW.LoanID,
      NEW.MemberID,
      fine_amt,
      NOW(),
      CONCAT('Overdue by ', days_overdue, ' days')
    );
  END IF;
END$$
DELIMITER ;


-- AFTER UPDATE: generate fine when ReturnDate is set after due date
-- Ensures fines are created on manual or bulk updates to ReturnDate
DELIMITER $$
CREATE TRIGGER trg_after_update_loan
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
  DECLARE days_overdue INT;
  DECLARE fine_amt    DECIMAL(10,2);

  -- Only trigger when ReturnDate transitions from NULL to non-NULL
  IF OLD.ReturnDate IS NULL AND NEW.ReturnDate IS NOT NULL THEN
    SET days_overdue = GREATEST(DATEDIFF(NEW.ReturnDate, NEW.DueDate), 0);

    IF days_overdue > 0 THEN
      SET fine_amt = days_overdue * 10; -- change this to change the amounnt of fines per day

      INSERT INTO Fines (
        LoanID, MemberID, Amount, DateIssued, Reason
      ) VALUES (
        NEW.LoanID,
        NEW.MemberID,
        fine_amt,
        NOW(),
        CONCAT('Overdue by ', days_overdue, ' days')
      );
    END IF;
  END IF;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------------
-- End of schema 
-- -----------------------------------------------------------------------------------
