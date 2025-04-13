USE library_ms;

-- To turn on the local_infile
SET GLOBAL local_infile = 1;

-- To see if it is ON
SHOW VARIABLES LIKE 'local_infile';

SHOW GRANTS FOR 'root'@'localhost';

-- This is to the dataset for the Author
LOAD DATA LOCAL INFILE 'C:/Users/akwean/Downloads/csv data for database/authors.csv' -- change this according to where your csv file is 
INTO TABLE Authors
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(FirstName, LastName, Biography);

-- This is for loading data into the Publishers table.
LOAD DATA LOCAL INFILE 'C:/Users/akwean/Downloads/csv data for database/publishers.csv'
INTO TABLE Publishers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Name, Address, ContactInfo);



-- This is for loading data into the Categories table.
LOAD DATA LOCAL INFILE 'C:/Users/akwean/Downloads/csv data for database/categories.csv'
INTO TABLE Categories
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Name, Description);


-- This is for loading data into the Books table.
LOAD DATA LOCAL INFILE 'C:/Users/akwean/Downloads/csv data for database/books.csv'
INTO TABLE Books
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ISBN, Title, PublisherID, PublicationYear, TotalCopies, AvailableCopies, ShelfLocation);

-- This is for loading data into the Members table.
LOAD DATA LOCAL INFILE 'C:/Users/akwean/Downloads/csv data for database/members.csv'
INTO TABLE Members
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(LibraryCardNumber, FirstName, LastName, Address, Email, PhoneNumber, RegistrationDate, ExpiryDate, IsActive, PasswordHash, PasswordSalt);


-- This is for loading data into the Users table.
LOAD DATA LOCAL INFILE 'C:/Users/akwean/Downloads/csv data for database/users.csv'
INTO TABLE Users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Username, PasswordHash, PasswordSalt, FirstName, LastName, Email, Role, IsActive, LastLogin);

-- This is for loading data into the BookAuthors table.
LOAD DATA LOCAL INFILE 'C:/Users/akwean/Downloads/csv data for database/bookauthors.csv'
INTO TABLE BookAuthors
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(BookID, AuthorID);

-- This is for loading data into the BookCategories table.
LOAD DATA LOCAL INFILE 'C:/Users/akwean/Downloads/csv data for database/bookcategories.csv'
INTO TABLE BookCategories
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(BookID, CategoryID);

