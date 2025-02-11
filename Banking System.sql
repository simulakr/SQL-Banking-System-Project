CREATE DATABASE banking_system_project 
USE banking_system_project 

--CREATING TABLES
--1. account_opening_form table
CREATE TABLE account_opening_form(
  [date] date default getdate(),
  AccountType varchar(20) default 'saving',
  Account_HolderName varchar(50),
  DOB date,
  AadharNumber varchar(12),
  MobileNumber varchar(15),
  Account_opening_balance decimal(10,2),
  FullAddress varchar(100),
  KYC_Status varchar(20) default 'pending'
  )
  
--2. bank table 
CREATE TABLE bank(
  AccountNumber bigint identity(1000000000,1),
  AccountType varchar(20),
  AccountOpeningDate date default getdate(),
  CurrentBalance decimal(10,2)
  )
  
--3. Account_holder_detail table
CREATE TABLE Account_holder_detail(
  AccountNumber bigint identity(1000000000,1),
  Account_HolderName varchar(50),
  DOB date,
  AadharNumber varchar(12),
  MobileNumber varchar(15),
  FullAddress varchar(100)
  )
  
--4. TransactionDetail table 
CREATE TABLE TransactionDetail(
  AccountNumber bigint,
  PaymentType varchar(20),
  TransactionAmount decimal(10,2),
  DateofTransaction date default getdate()
  )
  
--Data Inserting 
INSERT INTO  account_opening_form(
AccountType, Account_HolderName, DOB, AadharNumber, MobileNumber, Account_opening_balance, FullAddress)
VALUES ('saving','kanhaiya','1999-08-24','545854562845','9875645565', 1000, 'patna')
  
SELECT * FROM account_opening_form 
  
-- Creating Trigger of insert data both of two tables  
 CREATE TRIGGER dbo.insertdata 
 on account_opening_form 
 AFTER UPDATE 
 as 
 		DECLARE @status varchar(20),
 				@AccountType varchar(20),
                @Account_HolderName varchar(50),
                @DOB date,
                @AadharNumber varchar(12),
                @MobileNumber varchar(15),
                @Account_opening_balance decimal(10,2),
                @FullAddress varchar(100)
  
SELECT  @status = kyc_status , @AccountType=AccountType, @Account_HolderName=Account_HolderName,
		@DOB=DOB, @AadharNumber=AadharNumber, @MobileNumber=MobileNumber , @Account_opening_balance=Account_opening_balance,
        @FullAddress=FullAddress 
        FROM inserted

if @status = 'Approved'
BEGIN
INSERT into bank (AccountType, currentbalance) VALUES (@AccountType, @Account_opening_balance)
  
insert into Account_holder_detail(Account_HolderName,DOB,AadharNumber,MobileNumber,FullAddress)values
(@Account_HolderName,@DOB,@AadharNumber,@MobileNumber,@FullAddress)  
  
end 
  
--Update Status Approved 
UPDATE account_opening_form 
SET kyc_status = 'Approved' 
WHERE aadharnumber ='545854562845' 

SELECT * FROM  account_opening_form
SELECT * FROM Account_holder_detail
  
--Checking for Rejected Account Status 
Insert into account_opening_form 
(accounttype,Account_HolderName, DOB,AadharNumber,MobileNumber,Account_opening_balance,FullAddress)
values('saving','Ali','1999-08-20','545854562887','9875645545',1000,'Ankara')
  
SELECT * FROM account_opening_form  
  
--Update Status Rejected 
UPDATE account_opening_form 
set kyc_status='Rejected'
WHERE aadharnumber='545854562845'

--Create Trigger on TransactionDetail table for update current balance into main table 
CREATE TRIGGER dbo.insertbalance  
on TransactionDetail 
AFTER INSERT 
AS 
DECLARE @paymenttype varchar(20),
		@Amount decimal(10,2),
 		@accountnumber bigint
    
SELECT @paymenttype=paymenttype, @Amount= transactionamount, @accountnumber=accountnumber FROM inserted 

if @paymenttype='Credit' 
BEGIN 
UPDATE bank
set currentbalance= currentbalance + @Amount 
WHERE accountnumber = @accountnumber 
END

if @paymenttype ='Debit' 
BEGIN 
UPDATE bank 
SET currentbalance = currentbalance - @Amount 
WHERE accountnumber = @accountnumber 
END

--Trigger Control 
SELECT * FROM bank --Currentbalance=1000
SELECT * FROM TransactionDetail

insert INTO TransactionDetail 
(AccountNumber, PaymentType, TransactionAmount) values (1000000003,'credit',5000)

insert into TransactionDetail (AccountNumber,PaymentType,TransactionAmount) values
(1000000003,'debit',3000)

SELECT * FROM bank ---1000+5000-3000=3000 

--Transactions last 1 month
select * from TransactionDetail 
where DateofTransaction>= dateadd(month,-1,getdate()) and AccountNumber='1000000003'

--A month ago
select dateadd(month,-1,getdate())






  
  