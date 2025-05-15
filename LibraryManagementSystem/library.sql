create database Library;
use Library;

RENAME TABLE `book copies` TO bookcopies;
RENAME TABLE `book loans` TO bookloans;
RENAME TABLE `library branch` TO librarybranch;
-- changed the table names
select * from authors;
select * from bookcopies;
select * from bookloans;
select * from books;
select * from borrower;
select * from librarybranch;
select * from publisher;

-- change column names
alter table authors change column ï»¿book_authors_BookID book_authors_BookID int; 
alter table bookcopies change column ï»¿book_copies_BookID book_copies_BookID int;
alter table bookloans change column ï»¿book_loans_BookID book_loans_BookID int;
alter table books change column ï»¿book_BookID book_BookID int;

# adding foreign key

ALTER TABLE books 
MODIFY book_BookID INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE authors
ADD CONSTRAINT book_authors_BookID
foreign KEY (book_authors_BookID) references books(book_BookID) on update cascade;

-- text can't be used as a primary key so here we are also changing data type into char/varchar
ALTER TABLE publisher 
MODIFY publisher_PublisherName VARCHAR(255) primary key;
ALTER TABLE books 
MODIFY book_PublisherName VARCHAR(255);
ALTER TABLE books
ADD CONSTRAINT book_PublisherName
foreign KEY (book_PublisherName) references publisher(publisher_PublisherName) on update cascade;

ALTER TABLE borrower
ADD PRIMARY KEY (borrower_CardNo);
ALTER TABLE borrower 
MODIFY borrower_CardNo INT NOT NULL AUTO_INCREMENT;
ALTER TABLE bookloans
ADD CONSTRAINT book_loans_CardNo
foreign KEY (book_loans_CardNo) references borrower(borrower_CardNo) on update cascade;

-- create a new column called library_branch_BranchID with auto-increment and primary key
ALTER TABLE librarybranch 
ADD COLUMN library_branch_BranchID INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE bookcopies
ADD CONSTRAINT book_copies_BranchID
foreign KEY (book_copies_BranchID) references librarybranch(library_branch_BranchID) on update cascade;

ALTER TABLE bookloans
ADD CONSTRAINT book_loans_BranchID
foreign KEY (book_loans_BranchID) references librarybranch(library_branch_BranchID) on update cascade;

ALTER TABLE bookcopies
ADD CONSTRAINT book_copies_BookID
foreign KEY (book_copies_BookID) references books(book_BookID) on update cascade;

ALTER TABLE bookloans
ADD CONSTRAINT book_loans_BookID
foreign KEY (book_loans_BookID) references books(book_BookID) on update cascade;

# also creating new columns as primary keys (authors,copies,loans)

ALTER TABLE authors 
ADD COLUMN book_authors_AuthorID INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE bookcopies 
ADD COLUMN book_copies_CopiesID INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE bookloans 
ADD COLUMN book_loans_LoansID INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

# TASK QUESTIONS
# 1.How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
select bc.book_copies_No_Of_Copies from bookcopies as bc 
where bc.book_copies_BookID = (select b.book_BookID from books as b where b.book_Title = 'The Lost Tribe')
and bc.book_copies_BranchID = (select lb.library_branch_BranchID from librarybranch as lb where lb.library_branch_BranchName='Sharpstown');
-- or
select bc.book_copies_No_Of_Copies from bookcopies as bc 
left join books as b on bc.book_copies_BookID = b.book_BookID 
left join librarybranch as lb on bc.book_copies_BranchID = lb.library_branch_BranchID
where b.book_Title = 'The Lost Tribe' and lb.library_branch_BranchName='Sharpstown';

# 2. How many copies of the book titled "The Lost Tribe" are owned by each library branch?
select lb.library_branch_BranchName,bc.book_copies_No_Of_Copies from bookcopies as bc 
left join books as b on bc.book_copies_BookID = b.book_BookID 
left join librarybranch as lb on bc.book_copies_BranchID = lb.library_branch_BranchID
where b.book_Title = 'The Lost Tribe';

#3. Retrieve the names of all borrowers who do not have any books checked out.(incomplete)
select borrower_BorrowerName from borrower where borrower_CardNo NOT IN (select book_loans_CardNo from bookloans);
-- or
select bo.borrower_BorrowerName from borrower as bo left join bookloans as lb on bo.borrower_CardNo = lb.book_loans_CardNo
where lb.book_loans_BookID is null;

# 4.For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, 
# retrieve the book title, the borrower's name, and the borrower's address.
select b.book_Title,bo.borrower_BorrowerName,bo.borrower_BorrowerAddress from bookloans as bl
left join librarybranch as lb on bl.book_loans_BranchID=lb.library_branch_BranchID
left join borrower as bo on bl.book_loans_CardNo = bo.borrower_CardNo 
left join books as b on bl.book_loans_BookID = b.book_BookID
where lb.library_branch_BranchName = 'Sharpstown' and bl.book_loans_DueDate='2/3/18';

# 5.For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
select lb.library_branch_BranchName,count(*) as no_of_books_loanedOut from librarybranch as lb 
left join bookloans as bl on bl.book_loans_BranchID = lb.library_branch_BranchID 
group by lb.library_branch_BranchName;

# 6.Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
select bo.borrower_BorrowerName,bo.borrower_BorrowerAddress,count(*) as no_of_book_CheckedOut from bookloans as bl 
left join borrower as bo on bl.book_loans_CardNo = bo.borrower_CardNo 
group by bl.book_loans_CardNo
having count(*)>5; 

# 7.For each book authored by "Stephen King", 
# retrieve the title and the number of copies owned by the library branch whose name is "Central".
select b.book_Title,bc.book_copies_No_Of_Copies from authors as a 
left join bookcopies as bc on a.book_authors_BookID = bc.book_copies_BookID
left join librarybranch as lb on bc.book_copies_BranchID = lb.library_branch_BranchID
left join books as b on b.book_BookID = a.book_authors_BookID
where a.book_authors_AuthorName = "Stephen King" and lb.library_branch_BranchName = "Central";