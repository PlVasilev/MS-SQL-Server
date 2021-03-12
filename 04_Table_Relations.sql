--CTR SHIFT R

CREATE DATABASE Minions

USE Minions

CREATE TABLE Minions(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL,
Age INT
)

CREATE TABLE Towns(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL
--,TownId INT NOT NULL FOREIGN KEY REFERENCES Towns(Id),
)

SET IDENTITY_INSERT Towns ON

ALTER TABLE Minions
ADD TownId INT CONSTRAINT FK_TownId_Towns FOREIGN KEY REFERENCES Towns(Id)

INSERT INTO Towns(Id, [Name])
VALUES (1,'Sofia'),
 (2,'Plovdiv'),
 (3,'Varna')

 SET IDENTITY_INSERT Towns OFF

 SET IDENTITY_INSERT Minions ON


 INSERT INTO Minions(Id,[Name],Age,TownId)
 VALUES (1,'Kevin',22,1),
		(2,'Bob',15,3),
		(3,'Steward', NULL,2)


TRUNCATE TABLE Minions

SELECT *
FROM sys.foreign_keys
WHERE referenced_object_id = object_id('dbo.Towns')

ALTER TABLE Minions DROP CONSTRAINT FK_TownId_Towns

TRUNCATE TABLE Towns

DROP TABLE Towns

DROP TABLE Minions

CREATE TABLE People
(
 [Id] INT PRIMARY KEY Identity,
 [Name] NVARCHAR(200) NOT NULL,
 [Picture] VARBINARY(MAX),
 [Height] DECIMAL(5,2),
 [Weight] DECIMAL(5,2),
 [Gender] char(1) Not null CHECK(Gender='m' OR Gender='f'),
 Birthdate DATE Not Null,
 Biography NVARCHAR(MAX)
)
INSERT INTO People(Name,Picture,Height,Weight,Gender,Birthdate,Biography) Values
('Stela',Null,1.65,44.55,'f','2000-09-22',Null),
('Ivan',Null,2.15,95.55,'m','1989-11-02',Null),
('Qvor',Null,1.55,33.00,'m','2010-04-11',Null),
('Karolina',Null,2.15,55.55,'f','2001-11-11',Null),
('Pesho',Null,1.85,90.00,'m','1983-07-22',Null)

CREATE TABLE Users
(
 [Id] BIGINT PRIMARY KEY IDENTITY,
 [Username] VARCHAR(30) NOT NULL,
 [Password] VARCHAR(26) NOT NULL,
 ProfilePicture VARBINARY(900),
 LastLoginTime SMALLDATETIME DEFAULT GETDATE(),
 IsDeleted BINARY,
)

INSERT INTO Users (Username,Password,ProfilePicture,LastLoginTime,IsDeleted) VALUES
('U1','P1',NULL,'2007-05-08 12:35:29',0),
('U2','P2',NULL,NULL,0),
('U3','P3',NULL,NULL,0),
('U4','P4',NULL,NULL,0),
('U5','P5',NULL,NULL,0)

ALTER TABLE Users
ADD CONSTRAINT CH_ProfilePicture CHECK(DATALENGTH(ProfilePicture) <= 900 * 1024);

--Problem 9 Change Primary Key

ALTER TABLE Users DROP CONSTRAINT PK_Users;

ALTER TABLE Users
ADD CONSTRAINT PK_Users PRIMARY KEY(Id, Username);

--Problem 10.	Add Check Constraint

TRUNCATE TABLE Users

ALTER TABLE Users
ADD CONSTRAINT [Password] CHECK (LEN([Password]) >= 5)

--Problem 11.	Set Default Value of a Field

ALTER TABLE Users
ADD CONSTRAINT DF_Users DEFAULT GETDATE() FOR LastLoginTime;

--Problem 12.	Set Unique Field
ALTER TABLE Users
DROP CONSTRAINT PK_Users;

ALTER TABLE Users
ADD CONSTRAINT PK_Users PRIMARY KEY(Id);

ALTER TABLE Users
ADD UNIQUE (Username);

ALTER TABLE Users
ADD CONSTRAINT Username CHECK (LEN(Username) >= 3)


INSERT INTO Users (Username,Password,ProfilePicture,IsDeleted) VALUES
('U16','P0006',NULL,0)

SELECT
	Name + ' ' + Gender AS 'Name Gender',
	Height
FROM People 

SELECT DISTINCT Gender
  FROM People

SELECT Name
	FROM People 
WHERE Name = 'Stela'

SELECT Height FROM People
 WHERE Height <= 2

 -- <> = ! in C# != works too
 SELECT Height FROM People
 WHERE Height <> 1.65

	--SELET
-- SELECT LastName FROM Employees
--WHERE NOT (ManagerID = 3 OR ManagerID = 4)

-- SELECT LastName, Salary FROM Employees
--WHERE Salary BETWEEN 20000 AND 22000

-- SELECT FirstName, LastName, ManagerID FROM Employees
--WHERE ManagerID IN (109, 3, 16)  --  true if ManagerID is 109 or 3 or 16

--SELECT LastName, ManagerId FROM Employees
--WHERE ManagerId IS NULL  --  IS NOT NULL

-- SELECT LastName, HireDate -- order by LastName.ThenBy(HireDate)
--    FROM Employees
--ORDER BY LastName, HireDate DESC

	--INSERT
--INSERT INTO Towns VALUES (33, 'Paris')

--INSERT INTO Projects (Name, StartDate)
--     VALUES ('Reflective Jacket', GETDATE())

--INSERT INTO EmployeesProjects
--     VALUES (229, 1),
--            (229, 2),
--            (229, 3)

	--Inserting rows into existing table
--INSERT INTO Projects (Name, StartDate)
--     SELECT Name + ' Restructuring', GETDATE()
--       FROM Departments
 
	--Using existing records to create a new table
--SELECT CustomerID, FirstName, Email, Phone
--  INTO CustomerContacts
--  FROM Customers

	-- Deleting
--DELETE FROM Employees WHERE EmployeeID = 1
--Note: Don’t forget the WHERE clause!

--TRUNCATE TABLE Users

	--Updating
--Note: Don’t forget the WHERE clause!
--UPDATE Employees
--   SET LastName = 'Brown'
-- WHERE EmployeeID = 1

--UPDATE Employees
--   SET Salary = Salary * 1.10,
--       JobTitle = 'Senior ' + JobTitle
-- WHERE DepartmentID = 3


	--CREATE VIEW
--CREATE VIEW v_EmployeesByDepartment AS
--SELECT FirstName + ' ' + LastName AS [Full Name],
--       Salary
--  FROM Employees

--CREATE VIEW V_EmployeeNameJobTitle -- + IF STATEMENT
--AS
--     SELECT FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + LastName AS 'Full Naeme',
--            JobTitle AS 'Job Title'
--     FROM Employees;

--DROP VIEW IF EXISTS dbo.V_EmployeeNameJobTitle ;   

	--Sequences
--Returns an incrementing value every time it’s used

--CREATE SEQUENCE seq_Customers_CustomerID              
--           AS INT
--     START WITH 1
--   INCREMENT BY 1

--SELECT NEXT VALUE FOR seq_Customers_CustomerID

	--CASE
SELECT CountryName,
       CountryCode,
       CASE CurrencyCode
           WHEN 'EUR'
           THEN 'Euro'
           ELSE 'Not Euro'
       END AS 'Currency'
FROM Countries
ORDER BY CountryName;