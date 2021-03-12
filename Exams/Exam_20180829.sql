CREATE DATABASE Supermarket;

USE Supermarket

CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(30) NOT NULL
	
);

CREATE TABLE Items (
	Id INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(30) NOT NULL
	,Price DECIMAL (15,2) NOT NULL
	,CategoryId INT FOREIGN KEY REFERENCES Categories(Id)
);

--ALTER TABLE Items ADD CategoryId INT CONSTRAINT FK_ItemId_Items FOREIGN KEY REFERENCES Categories(Id)

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY
	,FirstName NVARCHAR(50) NOT NULL
	,LastName NVARCHAR(50) NOT NULL
	,Phone CHAR(12) NOT NULL
	,Salary DECIMAL (15,2) NOT NUll
);

CREATE TABLE Shifts (
	Id INT IDENTITY NOT NULL
	,EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
	,CheckIn DATETIME NOT NULL
	,CheckOut DATETIME NOT NULL
	CONSTRAINT PK_Shifts PRIMARY KEY (Id, EmployeeId)
);

--ALTER TABLE Shifts ADD CONSTRAINT C1 CHECK (CheckOut > CheckIn)

CREATE TABLE Orders (
	Id INT PRIMARY KEY IDENTITY
	,[DateTime] DATE NOT NULL
	,EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
);

CREATE TABLE OrderItems (
	OrderId INT FOREIGN KEY REFERENCES Orders(Id)
	,ItemId INT FOREIGN KEY REFERENCES Items(Id)
	,Quantity INT CHECK (Quantity >= 1)
	--CONSTRAINT PK_OrderItems PRIMARY KEY (OrderId, ItemId)
	PRIMARY KEY (OrderId, ItemId) -- works
)
INSERT INTO Employees 
VALUES 
('Stoyan','Petrov','888-785-8573',500.25)
,('Stamat','Nikolov','789-613-1122',999995.25)
,('Evgeni','Petkov','645-369-9517',1234.51)
,('Krasimir','Vidolov','321-471-9982',50.25)

INSERT INTO Items (Name, Price,CategoryId) -- Name of Coloums
VALUES 
('Tesla battery',154.25,8)
,('Chess',30.25,8)
,('Juice',5.32,1)
,('Glasses',10,8)
,('Bottle of water',1,1)

UPDATE Items
   SET Price = Price * 1.27
 WHERE CategoryId IN ( 1,2,3)

 DELETE FROM OrderItems WHERE OrderId = 48
 DELETE FROM Orders WHERE Id = 48

 SELECT Id, FirstName FROM Employees WHERE Salary > 6500 ORDER BY FirstName ASC, Id ASC

  SELECT 
  FirstName + ' ' + LastName AS [Full Name]
  ,Phone AS [Phone Number] 
  FROM Employees 
  WHERE Phone LIKE '3%' 
  ORDER BY FirstName ASC, Phone ASC

  SELECT e.FirstName, e.LastName, COUNT(EmployeeId) AS [Count] FROM Employees AS e
  JOIN Orders AS o ON e.Id = o.EmployeeId
  GROUP BY e.FirstName, e.LastName
  ORDER BY COUNT(EmployeeId) DESC, e.FirstName ASC

  SELECT e.FirstName,e.LastName, AVG(DATEDIFF(HOUR,CheckIn,CheckOut)) AS [Work hours] FROM Employees AS e
  JOIN Shifts AS s ON e.Id = s.EmployeeId
  GROUP BY e.FirstName,e.LastName, s.EmployeeId
  HAVING AVG(DATEDIFF(HOUR,CheckIn,CheckOut)) > 7
  ORDER BY AVG(DATEDIFF(HOUR,CheckIn,CheckOut)) DESC, EmployeeId ASC
  
  SELECT TOP (1) o.Id AS [OrderId] , SUM(i.Price * oi.Quantity) AS [TotalPrice] FROM Orders AS o
  JOIN OrderItems AS oi ON o.Id = oi.OrderId
  JOIN Items AS i ON oi.ItemId = i.Id
  GROUP BY o.Id
  ORDER BY SUM(i.Price * oi.Quantity) DESC

    SELECT TOP (10) o.Id AS [OrderId] , MAX(i.Price), MIN(i.Price) AS [TotalPrice] FROM Orders AS o
  JOIN OrderItems AS oi ON o.Id = oi.OrderId
  JOIN Items AS i ON oi.ItemId = i.Id
  GROUP BY o.Id
  ORDER BY MAX(i.Price) DESC, o.Id ASC

  SELECT DISTINCT e.Id, e.FirstName, e.LastName FROM  Employees AS e
  JOIN Orders AS o ON e.Id = o.EmployeeId
  ORDER BY e.Id

  SELECT DISTINCT e.Id, e.FirstName + ' ' + e.LastName FROM Employees AS e
  JOIN Shifts AS s ON e.Id = s.EmployeeId
  WHERE DATEDIFF(HOUR,s.CheckIn,s.CheckOut) < 4
  ORDER BY e.Id

  SELECT TOP (10) r.[Full Name], SUM(r.[Total Price]),SUM(r.Quantity) FROM (
  SELECT e.FirstName + ' ' + e.LastName AS [Full Name],
  SUM(oi.Quantity * i.Price) AS [Total Price],
  SUM(oi.Quantity) AS Quantity
   FROM Employees AS e
  JOIN Orders AS o ON o.EmployeeId = e.Id
  JOIN OrderItems AS oi ON o.Id = oi.OrderId
  JOIN Items AS i ON i.Id = oi.ItemId
  WHERE o.DateTime < '2018-06-15'
  GROUP BY e.FirstName,e.LastName, oi.Quantity) AS r
  GROUP BY r.[Full Name] ORDER BY SUM(r.[Total Price]) DESC

SELECT e.FirstName + ' ' + e.LastName AS [Full Name],
DATENAME(WEEKDAY,CheckIn) AS [Day of week]
FROM Employees AS e
JOIN Shifts AS s ON e.Id = s.EmployeeId
LEFT JOIN Orders AS o ON e.Id = o.EmployeeId
WHERE o.Id IS NULL AND DATEDIFF(HOUR,CheckIn, CheckOut) > 12
ORDER BY e.Id

--15
SELECT r.[Full Name], 
		DATEDIFF(HOUR,CheckIn,CheckOut) AS [WorkHours],
		r.TotalPrice FROM (
		SELECT  o.Id AS OrderId, 
				e.Id AS EmployeeId,
				o.DateTime,
				e.FirstName + ' ' + e.LastName AS [Full Name],
				SUM (oi.Quantity * i.Price) AS [TotalPrice],
				ROW_NUMBER() OVER (PARTITION BY e.Id ORDER BY SUM (oi.Quantity * i.Price) DESC) AS RowNumber
				FROM Employees AS e
		JOIN Orders AS o ON o.EmployeeId = e.Id
		JOIN OrderItems AS oi ON oi.OrderId = o.Id
		JOIN Items AS i ON i.Id = oi.ItemId
		GROUP BY o.Id,e.FirstName,e.LastName,e.Id,o.DateTime) AS r
JOIN Shifts AS s ON s.EmployeeId = r.EmployeeId
WHERE r.RowNumber = 1 AND r.DateTime BETWEEN s.CheckIn AND s.CheckOut
ORDER BY r.[Full Name], WorkHours DESC, TotalPrice DESC

SELECT DATEPART(DAY, o.DateTime)  AS [DayOfMonth]
,CAST(AVG(oi.Quantity * i.Price) AS decimal(15,2))
FROM Orders AS o
JOIN OrderItems AS oi ON oi.OrderId = o.Id
JOIN Items AS i ON i.Id = oi.ItemId
GROUP BY DATEPART(DAY, o.DateTime)
ORDER BY [DayOfMonth] ASC

SELECT i.Name,c.Name,SUM(oi.Quantity) AS [Count],SUM(oi.Quantity * i.Price) AS TotalPrice FROM Items AS i
LEFT JOIN OrderItems AS oi ON i.Id = oi.ItemId
JOIN Categories AS c ON c.Id = i.CategoryId
GROUP BY i.Name,c.Name
ORDER BY TotalPrice DESC, Count DESC

----
CREATE FUNCTION udf_GetPromotedProducts(@CurrentDate DATE, @StartDate DATE, @EndDate DATE, 
						@Discount INT, @FirstItemId INT, @SecondItemId INT, @ThirdItemId INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @fItem NVARCHAR(MAX) = (SELECT Name FROM Items WHERE Id = @FirstItemId)
	DECLARE @fItemPrice DECIMAL(15,2) = (SELECT Price FROM Items WHERE Id = @FirstItemId)
	DECLARE @sItem NVARCHAR(MAX) = (SELECT Name FROM Items WHERE Id = @SecondItemId)
	DECLARE @sItemPrice DECIMAL(15,2) = (SELECT Price FROM Items WHERE Id = @SecondItemId)
	DECLARE @tItem NVARCHAR(MAX) = (SELECT Name FROM Items WHERE Id = @ThirdItemId)
	DECLARE @tItemPrice DECIMAL(15,2) = (SELECT Price FROM Items WHERE Id = @ThirdItemId)
	IF(@fItem IS NULL OR @sItem IS NULL OR @tItem is NULL)
	BEGIN
		RETURN 'One of the items does not exists!'
	END
	IF(@CurrentDate NOT BETWEEN @StartDate AND @EndDate)
	BEGIN
		RETURN 'The current date is not within the promotion dates!'
	END
	RETURN CONCAT(@fItem,' price: ',CAST(@fItemPrice - @fItemPrice*@Discount/100 AS decimal(15,2)),' <-> '
	,@sItem,' price: ',CAST(@sItemPrice - @sItemPrice*@Discount/100 AS decimal(15,2)),' <-> '
	,@tItem,' price: ',CAST(@tItemPrice - @tItemPrice*@Discount/100 AS decimal(15,2)))
END

SELECT dbo.udf_GetPromotedProducts('2018-08-02', '2018-08-01', '2018-08-03',13, 3,4,5)

----
CREATE PROCEDURE usp_CancelOrder(@OrderId INT, @CancelDate DATE)
AS
BEGIN
	DECLARE @orderToDel INT = (SELECT id FROM Orders WHERE id = @OrderId)
	IF (@orderToDel IS NULL)
	BEGIN
		RAISERROR ('The order does not exist!',16,1)
		ROLLBACK
		RETURN
	END
	DECLARE @orderDate DATE = (SELECT [DateTime] FROM Orders WHERE id = @OrderId)
	IF(DATEDIFF(DAY,@orderDate,@CancelDate) >= 3)
	BEGIN
		RAISERROR ('You cannot cancel the order!',16,2)
		ROLLBACK
		RETURN
	END
	DELETE FROM OrderItems WHERE OrderId = @orderToDel
	DELETE FROM Orders WHERE Id = @orderToDel
END

EXEC usp_CancelOrder 1, '2018-06-02'
SELECT COUNT(*) FROM Orders
SELECT COUNT(*) FROM OrderItems

----
CREATE TRIGGER t_DeletedOrders
    ON OrderItems AFTER DELETE
    AS
    BEGIN
	  INSERT INTO DeletedOrders (OrderId,ItemId,ItemQuantity)
	  SELECT d.OrderId,d.ItemId,d.Quantity
	    FROM deleted AS d
    END