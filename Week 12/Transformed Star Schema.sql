
-- DENORMALIZED LIBRARY MANAGEMENT SYSTEM STAR SCHEMA

-- 1. Date Dimension
CREATE TABLE DimDate (
    DateID INT PRIMARY KEY AUTO_INCREMENT,
    FullDate DATE NOT NULL,
    Year INT,
    Month INT,
    Day INT,
    WeekdayName VARCHAR(20)
);

-- 2. Book Dimension
CREATE TABLE DimBook (
    BookID INT PRIMARY KEY,
    Title VARCHAR(255),
    ISBN VARCHAR(20),
    PublicationYear INT,
    PublisherName VARCHAR(255),
    Categories TEXT,
    Authors TEXT,
    TotalCopies INT,
    AvailableCopies INT,
    ShelfLocation VARCHAR(50)
);

-- 3. Member Dimension
CREATE TABLE DimMember (
    MemberID INT PRIMARY KEY,
    LibraryCardNumber VARCHAR(50),
    FullName VARCHAR(200),
    Email VARCHAR(255),
    IsActive BOOLEAN,
    RegistrationDate TIMESTAMP,
    ExpiryDate TIMESTAMP
);

-- 4. User Dimension (Library Staff)
CREATE TABLE DimUser (
    UserID INT PRIMARY KEY,
    Username VARCHAR(50),
    FullName VARCHAR(200),
    Email VARCHAR(255),
    Role VARCHAR(50),
    IsActive BOOLEAN
);

-- 5. Fact Table: Book Loans
CREATE TABLE FactLoans (
    LoanID INT PRIMARY KEY,
    BookID INT,
    BookTitle VARCHAR(255),
    ISBN VARCHAR(20),
    PublicationYear INT,
    PublisherName VARCHAR(255),
    Categories TEXT,
    Authors TEXT,
    MemberID INT,
    MemberFullName VARCHAR(200),
    MemberEmail VARCHAR(255),
    IsMemberActive BOOLEAN,
    RegistrationDate TIMESTAMP,
    ExpiryDate TIMESTAMP,
    IssuedByUserID INT,
    IssuerName VARCHAR(200),
    ReceiverName VARCHAR(200),
    LoanDate TIMESTAMP,
    DueDate TIMESTAMP,
    ReturnDate TIMESTAMP,
    LoanDurationDays INT,
    FineAmount DECIMAL(10,2),
    FineReason VARCHAR(255)
);
