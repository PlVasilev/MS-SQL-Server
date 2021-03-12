CREATE TABLE Cities(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL,
CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
EmployeeCount INT NOT NULL,
BaseRate DECIMAL (15,2)
)

CREATE TABLE Rooms(
Id INT PRIMARY KEY IDENTITY,
Price DECIMAL (15,2) NOT NULL,
[Type] NVARCHAR (20) NOT NULL,
Beds INT NOT NULL,
HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL,
)

CREATE TABLE Trips(
Id INT PRIMARY KEY IDENTITY,
RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
BookDate DATE NOT NULL,
ArrivalDate DATE NOT NULL,
ReturnDate DATE NOT NULL,
CancelDate DATE,
CHECK (ArrivalDate > BookDate),
CHECK (ReturnDate > ArrivalDate),

)

CREATE TABLE Accounts(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(20),
LastName NVARCHAR(50) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
BirthDate DATE NOT NULL,
Email NVARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE AccountsTrips(
AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
Luggage INT CHECK (Luggage >= 0),
PRIMARY KEY (AccountId,TripId)
)

DROP TABLE AccountsTrips


INSERT INTO Accounts(FirstName,	MiddleName,	LastName,	CityId,	BirthDate,	Email)
VALUES
('John',	  'Smith',	'Smith'	,34,	'1975-07-21',	'j_smith@gmail.com'					),
('Gosho',	NULL, 'Petrov'	,11	,'1978-05-16',	'g_petrov@gmail.com'						),
('Ivan',	    'Petrovich',	'Pavlov'	,59,	'1849-09-26',	'i_pavlov@softuni.bg'	),
('Friedrich',	'Wilhelm',	'Nietzsche'	,2,	'1844-10-15',	'f_nietzsche@softuni.bg'		)
INSERT INTO Trips(RoomId,	BookDate,	ArrivalDate,	ReturnDate,	CancelDate)
VALUES 
(101,	'2015-04-12',	'2015-04-14',	'2015-04-20',	'2015-02-02'),
(102,	'2015-07-07',	'2015-07-15',	'2015-07-22',	'2015-04-29'),
(103,	'2013-07-17',	'2013-07-23',	'2013-07-24',	NULL		),
(104,	'2012-03-17',	'2012-03-31',	'2012-04-01',	'2012-01-10'),
(109,	'2017-08-07',	'2017-08-28',	'2017-08-29',	NULL		)

UPDATE Rooms SET Price *= 1.14 WHERE HotelId IN (5,7,9)

DELETE FROM AccountsTrips WHERE AccountId = 47

SELECT Id,[Name] FROM Cities WHERE CountryCode = 'BG' ORDER BY [Name]

SELECT CONCAT(FirstName + ' ', ISNULL(MiddleName + ' ', ''), LastName) AS [Full Name]
, DATEPART(YEAR,BirthDate) AS BirthYear	
FROM Accounts WHERE DATEPART(YEAR,BirthDate) > 1991
ORDER BY BirthYear DESC, FirstName ASC

SELECT FirstName,LastName,FORMAT(BirthDate,'MM-dd-yyyy'),c.Name, Email FROM Accounts AS a
JOIN Cities AS c ON c.Id = a.CityId
WHERE Email LIKE 'e%'
ORDER BY c.Name DESC

SELECT c.Name, COUNT(h.Id) FROM Cities AS c
LEFT JOIN Hotels AS h ON c.Id = h.CityId
GROUP BY  c.Name
ORDER BY  COUNT(h.Id) DESC, c.Name ASC

SELECT r.Id,r.Price,h.Name,c.Name FROM Rooms AS r
JOIN Hotels as h ON r.HotelId = h.Id
JOIN Cities as c ON h.CityId = c.Id
WHERE Type = 'First Class'
ORDER BY r.Price DESC, r.Id ASC

SELECT a.Id
, FirstName + ' ' + LastName AS FullName
,MAX(DATEDIFF(DAY,t.ArrivalDate,t.ReturnDate)) AS LongestTrip
,MIN(DATEDIFF(DAY,t.ArrivalDate,t.ReturnDate)) AS ShortestTrip
 FROM Accounts AS a 
JOIN AccountsTrips AS atr ON atr.AccountId = a.Id
JOIN Trips as t ON atr.TripId = t.Id
WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
GROUP BY a.Id,FirstName,LastName
ORDER BY LongestTrip DESC, a.Id ASC

SELECT TOP(5) c.Id, c.Name , c.CountryCode, COUNT(a.Id) AS Accounts FROM Cities AS c
JOIN Accounts AS a ON c.Id = a.CityId
GROUP BY  c.Id, c.Name , c.CountryCode
ORDER BY Accounts DESC

SELECT a.Id,a.Email,c.Name, COUNT(t.Id) AS Trips FROM Accounts AS a
JOIN AccountsTrips AS atr ON a.Id = atr.AccountId
JOIN Trips AS t on atr.TripId = t.Id
JOIN Rooms AS r ON t.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
JOIN Cities AS c ON h.CityId = c.Id
WHERE a.CityId = h.CityId
GROUP BY a.Id,a.Email,c.Name
ORDER BY Trips DESC, a.Id ASC

SELECT TOP(10) c.Id,c.Name
,SUM(h.BaseRate + r.Price) AS [Total Revenue] 
,COUNT(t.Id) AS Trips
FROM Cities AS c
JOIN Hotels as h ON c.Id = h.CityId
JOIN Rooms as r ON h.Id = r.HotelId
JOIN Trips as t ON r.Id = t.RoomId
WHERE DATEPART(YEAR,t.BookDate) = 2016
GROUP BY c.Id,c.Name
ORDER BY [Total Revenue] DESC, Trips DESC

SELECT  t.Id, h.Name,r.Type
,CASE 
WHEN t.CancelDate IS NOT NULL THEN 0
ELSE SUM(h.BaseRate + r.Price )
END AS Revenue
FROM Trips AS t
JOIN Rooms AS r ON t.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
JOIN AccountsTrips AS atr ON t.Id = atr.TripId
GROUP BY t.Id, h.Name,r.Type, t.CancelDate
ORDER BY r.Type ASC , t.Id ASC

--15
SELECT r.Id,r.Email,r.CountryCode,r.Trips FROM (
SELECT a.Id,a.Email,c.CountryCode, COUNT(t.Id) AS Trips 
, ROW_NUMBER() OVER (PARTITION BY c.CountryCode ORDER BY COUNT(t.Id) DESC) AS Number
FROM Accounts AS a
JOIN AccountsTrips AS atr ON a.Id = atr.AccountId
JOIN Trips as T on atr.TripId = T.Id
JOIN Rooms AS r on T.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
JOIN Cities AS c ON h.CityId = c.Id
GROUP BY a.Id,a.Email,c.CountryCode) AS r
WHERE Number = 1
ORDER BY Trips DESC, Id ASC

--16
SELECT TripId, SUM(Luggage)
,CASE 
WHEN SUM(Luggage) <= 5 THEN '$0'
ELSE CONCAT('$', SUM(Luggage) * 5)
END AS Fee
FROM AccountsTrips
WHERE Luggage > 0
GROUP BY TripId
ORDER BY SUM(Luggage) DESC

--17
SELECT t.Id
,CONCAT(a.FirstName + ' ', ISNULL(a.MiddleName + ' ', ''), LastName) AS [Full Name] 
, ac.Name
, c.Name
, CASE 
WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
ELSE CONCAT(DATEDIFF(DAY,t.ArrivalDate,t.ReturnDate),' days')
END AS Duration
FROM Trips AS t
JOIN AccountsTrips AS atr ON t.Id = atr.TripId
JOIN Accounts AS a ON atr.AccountId = a.Id
JOIN Cities AS ac ON a.CityId = ac.Id
JOIN Rooms AS r ON t.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
JOIN Cities AS c ON h.CityId = c.Id
ORDER BY [Full Name] ASC, t.Id ASC

--18
CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT , @Date DATE, @People INT)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @desiredRoomId TABLE 
	(RoomId INT, RoomType NVARCHAR(20), Beds Int, TotalPrice DECIMAL(15,2))	

	INSERT INTO @desiredRoomId(RoomId, RoomType, Beds, TotalPrice)
	SELECT TOP(1) r.Id,r.Type,r.Beds, (h.BaseRate + r.Price) * 2 
	FROM Hotels AS h
	JOIN Rooms as r ON h.Id = r.HotelId
	JOIN Trips as t ON r.Id = t.RoomId
	WHERE @Date NOT BETWEEN t.ArrivalDate AND t.ReturnDate 
	AND t.CancelDate IS NULL 
	AND h.Id = @HotelId
	AND r.Beds > @People	
	IF((SELECT RoomId FROM @desiredRoomId) IS NULL)
	BEGIN 
		RETURN 'No rooms available'
	END		
	RETURN CONCAT('Room ',(SELECT RoomId FROM @desiredRoomId),': ',
		(SELECT RoomType FROM @desiredRoomId),' (',
		(SELECT Beds FROM @desiredRoomId),' beds) - $',
		(SELECT TotalPrice FROM @desiredRoomId))
END

SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)

--19
CREATE PROCEDURE usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN
	DECLARE @DesiredHotelId INT = (	SELECT TOP(1) r.HotelId FROM Trips  AS t	JOIN Rooms AS r ON t.RoomId = r.Id	WHERE r.Id = @TargetRoomId)
	DECLARE @currentHotelId INT = (	SELECT TOP(1) r.HotelId FROM Trips  AS t	JOIN Rooms AS r ON t.RoomId = r.Id	WHERE t.Id = @TripId)
	IF(@DesiredHotelId <> @currentHotelId)
	BEGIN
	RAISERROR ('Target room is in another hotel!',16,1)	 RETURN
	END
	DECLARE @NeededBeds INT = (SELECT TOP(1) COUNT(AccountId) FROM AccountsTrips WHERE TripId = @TripId)
	DECLARE @RoomBeds INT = (SELECT  TOP(1) Beds FROM Rooms WHERE id = @TargetRoomId)
	IF(@RoomBeds < @NeededBeds)
	BEGIN
	RAISERROR ('Not enough beds in target room!',16,1) RETURN
	END
	--DECLARE @cuurentRoomID INT = (SELECT RoomId FROM Trips WHERE Id = @TripId)
	UPDATE Trips SET RoomId = @TargetRoomId WHERE id = @TripId
END

EXEC usp_SwitchRoom 10, 7
EXEC usp_SwitchRoom 10, 8
EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10

--20
CREATE TRIGGER tr_CancelTrip ON Trips
INSTEAD OF DELETE
AS
UPDATE Trips
SET CancelDate = GETDATE()
WHERE Id IN (SELECT Id FROM deleted WHERE CancelDate IS NULL)

	DELETE FROM Trips
WHERE Id IN (48, 49, 50)