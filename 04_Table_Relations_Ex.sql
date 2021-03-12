--Steps in the database design process:
	--Identify entities
	--Identify table columns
	--Define a primary key for each table
	--Identify and model relationships
	--Define other constraints
	--Fill tables with test data

	--Primary Key Use IDENTITY to implement auto-increment 

--Normalization
	--Database Normalization is a technique of organizing the data in the database
	--Normalization is a systematic approach of decomposing tables to eliminate data redundancy(repetition) 
		--and undesirable characteristics like Insertion, Update and Deletion anomalies
	--It is a multi-step process that puts data into tabular form, removing duplicated data from the relation tables

	--First Normal Form (1NF)
		--Table should only have single(atomic) valued attributes/columns
		--Values stored in a column should be of the same domain
		--All the columns in a table should have unique names
		--And the order in which data is stored, does not matter
	--Second Normal Form (2NF)
		--The table should be in the First Normal form
		--It should not have Partial Dependency
	--Third Normal Form (3NF)
		--The table is in the Second Normal form
		--It doesn't have Transitive Dependency

--One-to-Many: Tables
CREATE TABLE Mountains(  MountainID INT PRIMARY KEY,  MountainName VARCHAR(50)) -- Parent table

CREATE TABLE Peaks(  PeakId INT PRIMARY KEY,	MountainID INT, -- Child table
  CONSTRAINT FK_Peaks_Mountains   FOREIGN KEY (MountainID)     REFERENCES Mountains(MountainID))

--Many-to-Many: Tables
CREATE TABLE Employees( EmployeeID INT PRIMARY KEY,  EmployeeName VARCHAR(50))
CREATE TABLE Projects(ProjectID INT PRIMARY KEY,  ProjectName VARCHAR(50))

CREATE TABLE EmployeesProjects(  EmployeeID INT,  ProjectID INT,
  CONSTRAINT PK_EmployeesProjects  PRIMARY KEY(EmployeeID, ProjectID),
  CONSTRAINT FK_EmployeesProjects_Employees  FOREIGN KEY(EmployeeID)  REFERENCES Employees(EmployeeID),
  CONSTRAINT FK_EmployeesProjects_Projects  FOREIGN KEY(ProjectID)  REFERENCES Projects(ProjectID))

--One-to-One
CREATE TABLE Drivers(  DriverID INT PRIMARY KEY,  DriverName VARCHAR(50))

CREATE TABLE Cars(  CarID INT PRIMARY KEY,  DriverID INT UNIQUE,
  CONSTRAINT FK_Cars_Drivers FOREIGN KEY  (DriverID) REFERENCES Drivers(DriverID))

 --JOIN Statements - With a JOIN statement, we can get data from two tables simultaneously
 --SELECT * FROM Towns JOIN Countries ON    Countries.Id = Towns.CountryId /* Join Condition */
 -- START FROM THE SMALLER STABLE !!! to work faster
 USE [Geography] 
 SELECT  m.MountainRange, p.PeakName, p.Elevation --,c.CountryName
    FROM Mountains AS m
    JOIN Peaks As p ON p.MountainId = m.Id /* Join Condition */
	--JOIN MountainsCountries AS mc ON m.Id = mc.MountainId -- Many to Many relation 2 Extra Joins
	--JOIN Countries AS c ON mc.CountryCode = c.CountryCode
   WHERE m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC

--Cascading allows when a change is made to certain entity, this change to apply to all related entities
	--Cascade Update: Example
CREATE TABLE Products(  BarcodeId INT PRIMARY KEY,  Name VARCHAR(50)) --
CREATE TABLE Stock(  Id INT PRIMARY KEY,
  CONSTRAINT FK_Stock_Products FOREIGN KEY(BarcodeId)  REFERENCES Products(BarcodeId) ON UPDATE CASCADE)

	--Cascade Delete: Example
CREATE TABLE Drivers(  DriverID INT PRIMARY KEY,  DriverName VARCHAR(50)) --
CREATE TABLE Cars(  CarID INT PRIMARY KEY,  DriverID INT,
  CONSTRAINT FK_Car_Driver FOREIGN KEY(DriverID)  REFERENCES Drivers(DriverID) ON DELETE CASCADE)
CREATE TABLE Cars(  CarID INT PRIMARY KEY,  DriverID INT,
  CONSTRAINT FK_Car_Driver FOREIGN KEY(DriverID)  
  REFERENCES Drivers(DriverID) ON DELETE SET NULL) -- if nullable when DEL will be set to null
CREATE TABLE Cars(  CarID INT PRIMARY KEY,  DriverID INT,
  CONSTRAINT FK_Car_Driver FOREIGN KEY(DriverID)
    REFERENCES Drivers(DriverID) ON DELETE SET DEFAULT)  -- if nullable when DEL will be set to default

	--EX
	--1
CREATE TABLE Passports(  
			PassportID  INT IDENTITY(101, 1) NOT NULL,
             PassportNumber CHAR(8) NOT NULL,
             CONSTRAINT PK_Passports PRIMARY KEY(PassportID))

INSERT INTO Passports(PassportNumber )
VALUES('N34FG21B'),('K65LO4R7'),('ZE657QP2')

CREATE TABLE Persons(  
PersonId INT IDENTITY NOT NULL,  
FirstName NVARCHAR(30)NOT NULL,
Salary MONEY NOT NULL,
PassportID INT UNIQUE NOT NULL,
CONSTRAINT PK_Persons PRIMARY KEY(PersonId),
CONSTRAINT FK_Persons_Passports FOREIGN KEY (PassportID) REFERENCES Passports(PassportID) )

INSERT INTO Persons(FirstName,Salary,PassportID )
VALUES('Roberto',43300.00,102),('Tom',56100.00,103),('Yana', 60200.00,101)

--2
CREATE TABLE Manufacturers(
ManufacturerID INT PRIMARY KEY IDENTITY NOT NULL,
[Name] NVARCHAR(30) NOT NULL,
EstablishedOn DATE DEFAULT GETDATE())

INSERT INTO Manufacturers
VALUES ('BMW','07/03/1916'),('Tesla','01/01/2003'),('Lada','01/05/1966')

CREATE TABLE Models(  ModelID INT PRIMARY KEY  IDENTITY(101, 1) NOT NULL,
					  [Name] NVARCHAR(30) NOT NULL,
					  ManufacturerID INT NOT NULL
  CONSTRAINT FK_Models_Manufacturers   FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID))

INSERT INTO Models VALUES
('X1',1),('i6',1),('Model S',2),('Model X',2),('Model 3',2),('Nova',3)

--3 
CREATE TABLE Students(StudentID INT PRIMARY KEY IDENTITY NOT NULL,[Name] NVARCHAR(30) NOT NULL)
INSERT INTO Students VALUES('Mila'),('Toni'),('Ron')
CREATE TABLE Exams(ExamID INT PRIMARY KEY  IDENTITY(101, 1) NOT NULL,[Name] NVARCHAR(30) NOT NULL)
INSERT INTO Exams VALUES('SpringMVC'),('Neo4j'),('Oracle 11g')
CREATE TABLE StudentsExams(
	StudentID INT,  ExamID INT,
  CONSTRAINT PK_StudentsExams  PRIMARY KEY(StudentID, ExamID),
  CONSTRAINT FK_EmployeesProjects_Students  FOREIGN KEY(StudentID)  REFERENCES Students(StudentID),
  CONSTRAINT FK_EmployeesProjects_Exams  FOREIGN KEY(ExamID)  REFERENCES Exams(ExamID))
INSERT INTO StudentsExams VALUES(1,101),(1,102),(2,101),(3,103),(2,102),(2,103)

--4 Self-Referencing 
CREATE TABLE Teachers(
TeacherID INT PRIMARY KEY  IDENTITY(101, 1) NOT NULL,
[Name] NVARCHAR(30) NOT NULL,
ManagerID INT,
CONSTRAINT FK_Teachers_TeacherID FOREIGN KEY(ManagerID) REFERENCES Teachers(TeacherID))

INSERT INTO Teachers VALUES
('John',NULL),('Maya',106),('Silvia',106),('Ted',105),('Mark',101),('Greta',101)

--5
CREATE TABLE ItemTypes(ItemTypeID INT PRIMARY KEY  IDENTITY NOT NULL,[Name] VARCHAR(50) NOT NULL);
CREATE TABLE Items(ItemID INT PRIMARY KEY  IDENTITY NOT NULL,[Name] VARCHAR(50) NOT NULL, ItemTypeID INT NOT NULL,
					CONSTRAINT FK_Items_ItemTypes FOREIGN KEY(ItemTypeID) REFERENCES ItemTypes(ItemTypeID));
CREATE TABLE Cities(CityID INT PRIMARY KEY  IDENTITY NOT NULL,[Name] VARCHAR(50) NOT NULL);
CREATE TABLE Customers(CustomerID INT PRIMARY KEY  IDENTITY NOT NULL,[Name] VARCHAR(50) NOT NULL,
						BirthDay SMALLDATETIME NOT NULL, CityID INT NOT NULL,
						CONSTRAINT FK_Customers_Cities FOREIGN KEY(CityID) REFERENCES Cities(CityID));
CREATE TABLE Orders(OrderID INT PRIMARY KEY  IDENTITY NOT NULL,CustomerID INT NOT NULL,
						CONSTRAINT FK_Orders_Customers FOREIGN KEY(CustomerID) REFERENCES Customers(CustomerID));
CREATE TABLE OrderItems(OrderID INT, ItemID INT,
					CONSTRAINT PK_OrderItems  PRIMARY KEY(OrderID, ItemID),
					CONSTRAINT FK_OrderItems_Orders FOREIGN KEY(OrderID) REFERENCES Orders(OrderID),
					CONSTRAINT FK_OrderItems_Items FOREIGN KEY(ItemID) REFERENCES Items(ItemID))
--6
CREATE TABLE Majors(MajorID INT PRIMARY KEY  IDENTITY NOT NULL,[Name] NVARCHAR(50) NOT NULL);
CREATE TABLE Students (StudentID INT PRIMARY KEY  IDENTITY NOT NULL,
						StudentNumber BIGINT NOT NULL,
						StudentName NVARCHAR(50) NOT NULL,
						MajorID INT,
						CONSTRAINT FK_Students_Majors FOREIGN KEY(MajorID) REFERENCES Majors(MajorID))
CREATE TABLE Payments (PaymentID INT PRIMARY KEY  IDENTITY NOT NULL,
						PaymentDate SMALLDATETIME NOT NULL,
						PaymentAmount MONEY NOT NULL,
						StudentID INT,
						CONSTRAINT FK_Payments_Students FOREIGN KEY(StudentID) REFERENCES Students(StudentID))
CREATE TABLE Subjects(SubjectID INT PRIMARY KEY  IDENTITY NOT NULL,SubjectName NVARCHAR(50) NOT NULL);
CREATE TABLE Agenda(StudentID INT , SubjectID INT,
					CONSTRAINT PK_Agenda  PRIMARY KEY(StudentID, SubjectID),
					CONSTRAINT FK_Agenda_Students FOREIGN KEY(StudentID) REFERENCES Students(StudentID),
					CONSTRAINT FK_Agenda_Subjects FOREIGN KEY(SubjectID) REFERENCES Subjects(SubjectID));