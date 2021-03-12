CREATE TABLE Planets(
	Id INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports(
	Id INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(50) NOT NULL
	,PlanetId INT FOREIGN KEY REFERENCES Planets(Id) NOT NULL
)

CREATE TABLE Spaceships(
	Id INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(50) NOT NULL
	,Manufacturer NVARCHAR(30) NOT NULL
	,LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists(
	Id INT PRIMARY KEY IDENTITY
	,FirstName NVARCHAR(20) NOT NULL
	,LastName NVARCHAR(30) NOT NULL
	,Ucn NVARCHAR(10) UNIQUE NOT NULL 
	,BirthDate DATE NOT NULL 
)

CREATE TABLE Journeys(
	Id INT PRIMARY KEY IDENTITY
	,JourneyStart DATETIME NOT NULL
	,JourneyEnd DATETIME NOT NULL
	,Purpose NVARCHAR(11) NOT NULL
	,DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id) NOT NULL
	,SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id) NOT NULL
)

CREATE TABLE TravelCards(
	Id INT PRIMARY KEY IDENTITY
	,CardNumber NCHAR(10) UNIQUE NOT NULL
	,JobDuringJourney NVARCHAR(8) NOT NULL
	,ColonistId INT FOREIGN KEY REFERENCES Colonists(Id) NOT NULL
	,JourneyId INT FOREIGN KEY REFERENCES Journeys(Id) NOT NULL
)


ALTER TABLE Journeys 
ADD CONSTRAINT CHK_Purpose CHECK(Purpose = 'Medical' 
								OR Purpose = 'Technical' 
								OR Purpose = 'Educational'
								OR Purpose = 'Military')

ALTER TABLE TravelCards 
ADD CONSTRAINT CHK_JobDuringJourney CHECK(JobDuringJourney = 'Pilot' 
								OR JobDuringJourney = 'Engineer' 
								OR JobDuringJourney = 'Trooper'
								OR JobDuringJourney = 'Cleaner'
								OR JobDuringJourney = 'Cook')

INSERT INTO Planets([Name])
VALUES ('Mars')
,('Earth')
,('Jupiter')
,('Saturn')
INSERT INTO Spaceships([Name],Manufacturer,LightSpeedRate)
VALUES
('Golf',	'VW',	3)
,('WakaWaka',	'Wakanda',	4)
,('Falcon9',	'SpaceX',	1)
,('Bed',	'Vidolov',	6)

DELETE FROM TravelCards WHERE JourneyId IN(1,2,3)
DELETE FROM Journeys WHERE Id IN (1,2,3)

SELECT CardNumber,JobDuringJourney FROM TravelCards ORDER BY CardNumber ASC

SELECT id
	, FirstName + ' ' + LastName AS FullName
	, Ucn FROM Colonists ORDER BY FirstName ASC, LastName ASC, Id ASC

SELECT id,FORMAT(JourneyStart, 'dd/MM/yyyy') as JourneyStart,
	FORMAT(JourneyEnd, 'dd/MM/yyyy') as JourneyEnd FROM Journeys as j
		WHERE Purpose = 'Military'
 ORDER BY JourneyStart ASC

SELECT c.Id,c.FirstName + ' ' + c.LastName AS full_name FROM TravelCards AS t
JOIN Colonists AS c ON t.ColonistId = c.Id
WHERE JobDuringJourney = 'Pilot'
ORDER BY Id ASC

SELECT COUNT(j.Id) AS [count] FROM TravelCards AS tr
JOIN Colonists AS c ON tr.ColonistId = c.Id
JOIN Journeys AS j ON j.Id = tr.JourneyId
WHERE j.Purpose = 'Technical'

SELECT TOP(1) sh.[Name] AS SpaceshipName
,sp.Name AS SpaceportName FROM Journeys AS j
JOIN Spaceships AS sh ON j.SpaceshipId = sh.Id
JOIN Spaceports AS sp ON j.DestinationSpaceportId = sp.Id
ORDER BY LightSpeedRate DESC

SELECT  sh.[Name], sh.Manufacturer  
FROM TravelCards AS tr
	JOIN Journeys AS j ON j.Id = tr.JourneyId
	JOIN Spaceships AS sh ON j.SpaceshipId = sh.Id
	JOIN Colonists AS c ON tr.ColonistId = c.Id
	WHERE tr.JobDuringJourney = 'Pilot' AND DATEDIFF(YEAR, c.BirthDate, '2019-01-01') < 30
	ORDER BY sh.Name ASC

SELECT p.Name AS PlanetName, sp.Name AS SpaceportName
FROM Planets AS p
LEFT JOIN Spaceports AS sp ON sp.PlanetId = p.Id
LEFT JOIN Journeys AS j ON j.DestinationSpaceportId = sp.Id
WHERE j.Purpose = 'Educational'
ORDER BY sp.Name DESC

SELECT p.Name AS 'PlanetName', COUNT(p.Id) AS JourneysCount FROM Planets AS p
JOIN Spaceports AS sp ON sp.PlanetId = p.Id
JOIN Journeys AS j ON j.DestinationSpaceportId = sp.Id
GROUP BY p.Name
ORDER BY COUNT(p.Id) DESC, p.Name ASC


SELECT TOP (1) r.Id , r.JobDuringJourney FROM
(SELECT  j.Id,tc.JobDuringJourney
		,DATEDIFF(SECOND ,j.JourneyEnd, j.JourneyStart) AS dd
		,DENSE_RANK() OVER(PARTITION BY j.Id ORDER BY COUNT(tc.JobDuringJourney) ASC)  AS dr
		FROM Journeys AS j
	JOIN TravelCards AS tc ON j.Id = tc.JourneyId
	JOIN Colonists AS c ON c.Id = tc.ColonistId
	JOIN Spaceports AS sp ON sp.Id = j.DestinationSpaceportId
	JOIN Planets AS p ON p.Id = sp.PlanetId
	GROUP BY j.Id, tc.JobDuringJourney,j.JourneyEnd,j.JourneyStart
	) AS r
	WHERE r.dr = 1
	ORDER BY r.dd ASC

SELECT r.JobDuringJourney
,r.FirstName + ' ' + r.LastName AS FullName 
,r.Rank AS JobRank
FROM (
SELECT c.FirstName,c.LastName, tc.JourneyId, tc.JobDuringJourney,DENSE_RANK() OVER (PARTITION BY tc.JobDuringJourney ORDER BY c.BirthDate) AS [Rank]
FROM Colonists as c
JOIN TravelCards as tc ON tc.ColonistId = c.Id) AS r
WHERE r.Rank = 2

SELECT p.Name, COUNT(s.PlanetId) AS Count FROM Planets AS p
LEFT JOIN Spaceports AS s ON p.Id = s.PlanetId
GROUP BY p.Name
ORDER BY COUNT(s.PlanetId) DESC, p.Name ASC

USE ColonialJourney
GO
CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR (30))
RETURNS INT
AS
BEGIN
	DECLARE @result INT
	SELECT @result = COUNT(*) FROM (
	SELECT p.Name AS Count FROM Planets AS p
	JOIN Spaceports as sp ON p.Id = sp.PlanetId
	JOIN Journeys AS j ON j.DestinationSpaceportId = sp.Id
	JOIN TravelCards AS tc ON tc.JourneyId = j.Id
	WHERE p.Name = @PlanetName
	) as r
	RETURN(@result)
END

SELECT dbo.udf_GetColonistsCount('Otroyphus')

USE ColonialJourney
GO
CREATE PROCEDURE usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose NVARCHAR(11))
AS
BEGIN
    DECLARE @currentJurneID INT = (SELECT Id FROM Journeys WHERE Id = @JourneyId)
	DECLARE @currentPurpouse NVARCHAR(11) = (SELECT Purpose FROM Journeys WHERE Id = @currentJurneID)
	IF(@currentJurneID IS NULL)
	BEGIN 
		RAISERROR ('The journey does not exist!',16,1)
		RETURN
	END
	ELSE
	BEGIN
		IF(@currentPurpouse = @NewPurpose)
		BEGIN
			RAISERROR ('You cannot change the purpose!',16,2)
			RETURN
		END
		ELSE
		BEGIN
			UPDATE Journeys SET Purpose = @NewPurpose WHERE id = @JourneyId
		END
	END 
END

CREATE TABLE DeletedJourneys
(
	Id INT NOT NULL
	,JourneyStart DATETIME NOT NULL
	,JourneyEnd DATETIME NOT NULL
	,Purpose NVARCHAR(11) NOT NULL
	,DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id) NOT NULL
	,SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id) NOT NULL
)

CREATE TRIGGER t_DeletedJourneys
    ON Journeys AFTER DELETE
    AS
    BEGIN
	  INSERT INTO DeletedJourneys (Id, JourneyStart, JourneyEnd,Purpose,DestinationSpaceportId,SpaceshipId)
	  SELECT d.Id, d.JourneyStart, d.JourneyEnd,d.Purpose,d.DestinationSpaceportId,d.SpaceshipId
	    FROM deleted AS d
    END