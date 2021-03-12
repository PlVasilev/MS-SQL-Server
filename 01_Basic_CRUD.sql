CREATE DATABASE Movies

USE Movies


CREATE TABLE Directors(
Id INT PRIMARY KEY IDENTITY,
DirectorName NVARCHAR(50) NOT NULL,
Notes NTEXT
)

SET IDENTITY_INSERT Directors ON

INSERT INTO Directors(Id,DirectorName )
VALUES
(1,'Director One'),
(2,'Director Two'),
(3,'Director Three'),
(4,'Director Four'),
(5,'Director Five');

SET IDENTITY_INSERT Directors OFF

CREATE TABLE Genres(
Id INT PRIMARY KEY IDENTITY,
GenreName NVARCHAR(20) NOT NULL,
Notes NTEXT
)

SET IDENTITY_INSERT Genres ON

INSERT INTO Genres(Id,GenreName)VALUES
(1,'Genre One'),
(2,'Genre Two'),
(3,'Genre Three'),
(4,'Genre Four'),
(5,'Genre Five');

SET IDENTITY_INSERT Genres OFF

CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY,
CategoryName NVARCHAR(20) NOT NULL,
Notes NTEXT
)

SET IDENTITY_INSERT Categories ON

INSERT INTO Categories(Id,CategoryName)VALUES
(1,'Category One'),
(2,'Category Two'),
(3,'Category Three'),
(4,'Category Four'),
(5,'Category Five');

SET IDENTITY_INSERT Categories OFF

CREATE TABLE Movies(
Id INT PRIMARY KEY IDENTITY,
Title NVARCHAR(30) NOT NULL,
DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
CopyrightYear NVARCHAR(4),
[Length] NVARCHAR(4),
GenreId INT FOREIGN KEY REFERENCES Genres(Id),
CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
Rating TINYINT,
Notes NTEXT,
)

SET IDENTITY_INSERT Movies ON

INSERT INTO Movies(Id,Title,DirectorId,GenreId,CategoryId)
VALUES
(1,'Title One',2,3,4),
(2,'Title Two',3,4,5),
(3,'Title Three',1,2,3),
(4,'Title Four',5,1,3),
(5,'Title Five',3,5,2);


CREATE DATABASE CarRental
GO

USE CarRental

CREATE TABLE Categories (
Id INT PRIMARY KEY IDENTiTY,
CategoryName NVARCHAR(20) NOT NULL,
DailyRate MONEY DEFAULT (0),
WeeklyRate MONEY DEFAULT (0),
MonthlyRate MONEY DEFAULT (0),
WeekendRate MONEY DEFAULT (0)
)

INSERT INTO Categories(CategoryName,DailyRate,WeeklyRate,MonthlyRate,WeekendRate)
VALUES ('SUV', 35,85,240, 65),
 ('Van',45,95,280, 75),
 ('FamilyCar',25,65,190, 55
)

CREATE TABLE Cars (
Id INT PRIMARY KEY IDENTiTY,
PlateName NCHAR(8) NOT NULL,
Manufacturer NVARCHAR(20) NOT NULL,
Model NVARCHAR(20) NOT NULL,
CarYear NCHAR(4) NOT NULL,
Doors SMALLINT NOT NULL,
[Picture] VARBINARY(MAX),
Condition NVARCHAR(100) NOT NULL,
Available BIT NOT NULL,
)

ALTER TABLE Cars
ADD CategoryId INT CONSTRAINT FK_CategoryId_Categories FOREIGN KEY REFERENCES Categories(Id)

INSERT INTO Cars(PlateName,Manufacturer,Model,CarYear,Doors,Picture,Condition,Available,CategoryId)
VALUES ('CA1085HB', 'DAF','XF','2007', 2, Null, 'FAIR',1,1),
 ('CA1157HB', 'Mercedes','Actros','2007', 2, Null, 'EXCELENT',0,2),
 ('CA7763HB', 'MAN','TX','2008', 2, Null, 'GOOD',1,3
)

CREATE TABLE Employees (
Id INT PRIMARY KEY IDENTiTY,
FirstName NVARCHAR(20) NOT NULL,
LastName NVARCHAR(20) NOT NULL,
Title NVARCHAR(20) NOT NULL,
Notes NTEXT NULL
)

INSERT INTO Employees(FirstName,LastName,Title,Notes)
VALUES ('Pesho','Peshov', 'Junior Seller' , 'Hi how are ya!')
		,('Gosho','Goshov', 'Seller' , NULL)
		,('Misho','Mishov', 'Senior Seller' , 'Not null')
		
CREATE TABLE Customers  (
Id INT PRIMARY KEY IDENTiTY,
DriverLicenceNumber NCHAR(10) NOT NULL,
FullName NVARCHAR(60) NOT NULL,
[Address] NVARCHAR(20) NOT NULL,
City NVARCHAR(20) NOT NULL,
ZIPCode NCHAR(4) NOT NULL,
Notes NTEXT NULL,
)

INSERT INTO Customers(DriverLicenceNumber,FullName,[Address],City,ZIPCode,Notes)
VALUES ('0000000001','Ivan Peshov', 'Lulin 10' , 'Sofia', '1000', 'wow')
		,('0000000002','Misho Peshov', 'Arena 110' , 'Plovdiv', '1200', null)
		,('0000000003','Ivan Ivanov', 'Stochna gara 141' , 'Varna', '1300', 'wow')

CREATE TABLE RentalOrders  (
Id INT PRIMARY KEY IDENTiTY,
EmployeeId INT NOT NULL FOREIGN KEY REFERENCES Employees(Id),
CustomerId INT NOT NULL FOREIGN KEY REFERENCES Customers(Id),
CarId INT NOT NULL FOREIGN KEY REFERENCES Cars(Id),
TankLevel NUMERIC(5,2) NOT NULL,
KilometrageStart INT NOT NULL,
KilometrageEnd INT NOT NULL,
TotalKilometrage INT NOT NULL,
StartDate DATE DEFAULT GETDATE(),
EndDate DATE NOT NULL,
TotalDays INT NOT NULL,
RateApplied MONEY NOT NULL,
TaxRate MONEY NOT NULL,
OrderStatus NVARCHAR (20),
Notes NTEXT NULL
)

INSERT INTO RentalOrders(EmployeeId,CustomerId,CarId,TankLevel,KilometrageStart,
						KilometrageEnd,TotalKilometrage,StartDate,EndDate,
						TotalDays,RateApplied,TaxRate,OrderStatus,Notes)
VALUES (1,3, 2, 0.8 , 251000, 251400, 300, GETDATE(), '2019-01-20', 1, 34,4, 'avaible', 'Note')
		,(2,1, 3, 1 , 351000, 351400, 300, GETDATE(), '2019-01-21', 2, 35,5, 'not avaible',  null)
		,(3,2, 1, 0.4 , 451000, 451400, 300, GETDATE(), '2019-01-22', 3, 36,6, 'in repair', null)

--SoftUni
CREATE DATABASE SoftUni
GO

USE SoftUni

CREATE TABLE Towns(
Id INT PRIMARY KEY IDENTiTY,
[Name] NVARCHAR(20) NOT NULL
)

CREATE TABLE Addresses (
Id INT PRIMARY KEY IDENTiTY,
AddressText NVARCHAR(200) NOT NULL,
TownId INT NOT NULL FOREIGN KEY REFERENCES Towns(Id),
)

CREATE TABLE Departments (
Id INT PRIMARY KEY IDENTiTY,
[Name] NVARCHAR(20) NOT NULL
)

CREATE TABLE Employees (
Id INT PRIMARY KEY IDENTiTY,
FirstName NVARCHAR(20) NOT NULL,
MiddleName NVARCHAR(20) NOT NULL,
LastName NVARCHAR(20) NOT NULL,
JobTitle NVARCHAR(20) NOT NULL,
DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id),
HireDate DATE NOT NULL,
Salary MONEY NOT NULL,
AddressId int NOT NULL FOREIGN KEY REFERENCES Addresses(Id),
)

--	Problem 17. Backup Database

BACKUP DATABASE SoftUni TO DISK = 'C:\Users\user\Documents\SQL Server Management Studio\BakcUps\softuni-backup.bak';

DROP DATABASE SoftUni;

RESTORE DATABASE SoftUni FROM DISK = 'C:\Users\user\Documents\SQL Server Management Studio\BakcUps\softuni-backup.bak';

USE SoftUni

INSERT INTO Towns([Name])
VALUES ('Sofia'), ('Plovdiv'),('Varna'),('Burgas')

DROP TABLE Towns

ALTER TABLE Addresses DROP CONSTRAINT FK__Addresses__TownI__398D8EEE

SELECT *
FROM sys.foreign_keys
WHERE referenced_object_id = object_id('dbo.Towns')

INSERT INTO Addresses (AddressText,TownId)
VALUES ('Lulin', 1),('Tepeta', 2),('Varnenska', 3),('Burgaska', 4)

INSERT INTO Departments([Name])
VALUES ('Engineering'), ('Sales'),('Marketing'),('Software Development'),('Quality Assurance')

INSERT INTO Employees (FirstName,MiddleName,LastName,JobTitle,DepartmentId,HireDate,Salary,AddressId)
VALUES ('Ivan','Ivanov','Ivanov', '.NET Developer', 4, '2013-02-01',3500.00,1)
		,('Petar','Petrov','Petrov', 'Senior Engineer', 1, '2004-03-04',4000.00,1)
		,('Maria','Petrova','Ivanova', 'Intern', 5, '2018-08-28',525.25,1)
		,('Georgi','Teziev','Ivanov', 'CEO', 2, '2007-09-12',3000.00,1)
		,('Peter','Pan','Pan', 'Intern', 3, '2016-08-28',3000.00,1)
		
SELECT * FROM Towns

SELECT * FROM Departments

SELECT * FROM Employees

SELECT [Name] 
    FROM Towns
ORDER BY [Name] ASC		

SELECT [Name] 
    FROM Departments
ORDER BY [Name] ASC			

SELECT FirstName,LastName,JobTitle,Salary
    FROM Employees
ORDER BY Salary DESC		

UPDATE Employees
	SET Salary *= 1.1;

SELECT Salary FROM Employees

