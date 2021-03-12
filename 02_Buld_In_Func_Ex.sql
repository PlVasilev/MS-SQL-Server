SELECT FirstName FROM Employees WHERE DepartmentID IN (3,10) AND DATEPART(YEAR, HireDate) BETWEEN 1995 AND 2005

SELECT FirstName, LastName FROM Employees WHERE NOT JobTitle LIKE '%engineer%'

SELECT [Name] FROM Towns WHERE LEN([Name]) IN (5,6) ORDER BY [Name] ASC

SELECT TownID, [Name] 
FROM Towns 
WHERE LEFT ([Name],1) <> 'R' AND
	 LEFT ([Name],1) <> 'B' AND
	 LEFT ([Name],1) <> 'D' 
ORDER BY [Name] ASC

--CREATE VIEW V_EmployeesHiredAfter2000
--AS
    SELECT FirstName , LastName 	
    FROM Employees
	WHERE DATEPART(YEAR, HireDate) > 2000 

SELECT FirstName, LastName FROM Employees WHERE LEN(LastName) = 5

SELECT EmployeeID, FirstName, LastName, Salary, 
	DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS Rank
 FROM Employees 
 WHERE Salary BETWEEN 10000 AND 50000
 ORDER BY Salary DESC

 --GET Something from TheResult of SELECT
 SELECT * FROM
 (
 SELECT EmployeeID, FirstName, LastName, Salary, 
	DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS Rank
 FROM Employees 
 WHERE Salary BETWEEN 10000 AND 50000
 ) 
 AS MySpecialTable
 WHERE MySpecialTable.Rank = 2
 ORDER BY MySpecialTable.Salary DESC

 SELECT CountryName AS 'Country Name', IsoCode AS 'ISO Code'
 FROM Countries 
 WHERE CountryName LIKE '%a%a%a%'
 ORDER BY IsoCode

 --2 TABLES
SELECT Peaks.PeakName,
Rivers.RiverName,
		LOWER(CONCAT(LEFT(Peaks.PeakName, LEN(Peaks.PeakName) - 1), Rivers.RiverName)) AS Mix
	FROM Peaks , Rivers
	WHERE RIGHT(PeakName, 1) = LEFT(RiverName,1)
	ORDER BY Mix

SELECT 
TOP(50) [Name], FORMAT(CAST([Start] AS DATE),'yyyy-MM-dd') as [Start]
FROM Games 
WHERE DATEPART(YEAR,Start) BETWEEN 2011 AND 2012
ORDER BY [Start] 

-- GET the end of the string starting from index
SELECT 
Username, RIGHT(Email, LEN(Email)-CHARINDEX('@',Email))  AS [Email Provider]
FROM Users
ORDER BY [Email Provider] ASC, Username ASC

SELECT 
Username,
IpAddress AS [IP Address]
FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username ASC

--SWICH
SELECT Name AS [Game],
			CASE
			WHEN  DATEPART(HOUR,Start) BETWEEN 0 AND 11
			THEN 'Morning'
			WHEN  DATEPART(HOUR,Start) BETWEEN 12 AND 17
			THEN 'Afternoon'
			WHEN  DATEPART(HOUR,Start) BETWEEN 18 AND 23
			THEN 'Evening'
			ELSE 'N\A'
			END			
			AS [Part of the Day],
		   	CASE
			WHEN  Duration <= 3
			THEN 'Extra Short'
			WHEN  Duration BETWEEN 4 AND 6
			THEN 'Short'
			WHEN  Duration > 6
			THEN 'Long'
			WHEN  Duration IS NULL
			THEN 'Extra Long'
			ELSE 'Error - must be unreachable case'
			END
			AS [Duration]
FROM Games
ORDER BY 
Name, 
Duration, 
[Part of the Day] 

SELECT 
ProductName,
OrderDate, 
DATEADD(DAY,3,OrderDate) AS [Pay Due],
DATEADD(MONTH,1,OrderDate) AS [Deliver Due] 
FROM Orders