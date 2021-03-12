SELECT top 50 e.FirstName, e.LastName, t.[Name] AS Town, a.AddressText
 FROM Employees AS e
  JOIN Addresses AS a  ON e.AddressID = a.AddressID
  JOIN Towns AS t ON t.TownID = a.TownID
  ORDER BY e.FirstName ASC, e.LastName ASC

  --IS NULL
SELECT top 3 e.EmployeeID, e.FirstName
 FROM Employees AS e
   LEFT JOIN EmployeesProjects AS ep  ON e.EmployeeID = ep.EmployeeID 
   WHERE ep.EmployeeID IS NULL
  ORDER BY e.EmployeeID ASC

  --ADD CONDITION
SELECT e.FirstName,e.LastName, e.HireDate, d.Name AS DeptName
 FROM Employees AS e
  JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
  AND e.HireDate > ('1999-01-01')
  AND d.[Name] IN ('Sales', 'Finance') 
  ORDER BY e.HireDate ASC

-- IF ELSE CASE
SELECT e.EmployeeID,
       e.FirstName,
       CASE
           WHEN p.StartDate > '2005'
           THEN NULL
           ELSE p.Name
       END AS ProjectName
FROM Employees AS e
     JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
     JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24; 

--SELF JOIN
SELECT e.EmployeeID,
       e.FirstName,
       e.ManagerID,
       m.FirstName AS ManagerName
FROM Employees AS e
     JOIN Employees AS m ON e.ManagerID = m.EmployeeID
WHERE e.ManagerID IN(3, 7)
ORDER BY e.EmployeeID;
	
 SELECT TOP 50 e.EmployeeID,
       e.FirstName + ' ' + e.LastName AS 'EmployeeName',
		m.FirstName + ' ' + m.LastName AS 'ManagerName',
	   d.[Name] AS 'DepartmentName'
FROM Employees AS e
     JOIN Employees AS m ON e.ManagerID = m.EmployeeID
	 JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID;

--SUBQUE
SELECT MIN(d.averageSalary) AS MinAverageSalary FROM 
(
	SELECT
	AVG(Salary) AS averageSalary 
	 FROM Employees
	 GROUP BY DepartmentID
) as d

-- 2 CONDITIONS IN 2 TABLES
SELECT mc.CountryCode,m.MountainRange,p.PeakName, p.Elevation FROM 
	Peaks AS p 
	JOIN Mountains AS m ON p.MountainId = m.Id AND p.Elevation > 2835
	JOIN MountainsCountries AS mc ON m.Id = mc.MountainId AND mc.CountryCode = 'BG'
	ORDER BY Elevation DESC

SELECT mc.CountryCode, 
		COUNT (m.MountainRange) AS MountainRanges
 FROM Mountains AS m
	JOIN MountainsCountries AS mc ON m.Id = mc.MountainId AND mc.CountryCode IN ('BG','RU', 'US')
	GROUP BY mc.CountryCode

SELECT TOP 5 c.CountryName, r.RiverName
 FROM Countries AS c
	LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode 
	LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
	WHERE c.ContinentCode = 'AF'
	ORDER BY c.CountryName
	
SELECT COUNT(c.CountryCode) AS CountryCode 
	FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
	WHERE MountainId IS NULL

--	Problem 17.	Highest Peak and Longest River by Country

SELECT TOP (5) peaks.CountryName,
               peaks.Elevation AS HighestPeakElevation,
               rivers.Length AS LongestRiverLength
FROM
(
    SELECT c.CountryName,
           c.CountryCode,
           DENSE_RANK() OVER(PARTITION BY c.CountryName ORDER BY p.Elevation DESC) AS DescendingElevationRank,
           p.Elevation
    FROM Countries AS c
         FULL OUTER JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
         FULL OUTER JOIN Mountains AS m ON mc.MountainId = m.Id
         FULL OUTER JOIN Peaks AS p ON m.Id = p.MountainId
) AS peaks
FULL OUTER JOIN
(
    SELECT c.CountryName,
           c.CountryCode,
           DENSE_RANK() OVER(PARTITION BY c.CountryCode ORDER BY r.Length DESC) AS DescendingRiversLenghRank,
           r.Length
    FROM Countries AS c
         FULL OUTER JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
         FULL OUTER JOIN Rivers AS r ON cr.RiverId = r.Id
) AS rivers ON peaks.CountryCode = rivers.CountryCode
WHERE peaks.DescendingElevationRank = 1
      AND rivers.DescendingRiversLenghRank = 1
      AND (peaks.Elevation IS NOT NULL
           OR rivers.Length IS NOT NULL)
ORDER BY HighestPeakElevation DESC,
         LongestRiverLength DESC,
         CountryName; 

SELECT cou.ContinentCode, cou.CurrencyCode, COUNT(cou.CurrencyCode) AS countOfCur
	FROM Currencies as cur
	JOIN Countries AS cou ON cur.CurrencyCode = cou.CurrencyCode
	GROUP BY cou.ContinentCode, cou.CurrencyCode
	ORDER BY countOfCur DESC

	-- Continents and Currencies TOP 1 of curuncees of continets
SELECT ranked.ContinentCode,
       ranked.CurrencyCode,
       ranked.CurrencyUsage
FROM
(
    SELECT gbc.ContinentCode,
           gbc.CurrencyCode,
           gbc.CurrencyUsage,
           DENSE_RANK() OVER(PARTITION BY gbc.ContinentCode ORDER BY gbc.CurrencyUsage DESC) AS UsageRank
    FROM
    (
        SELECT ContinentCode,
               CurrencyCode,
               COUNT(CurrencyCode) AS CurrencyUsage
        FROM Countries
        GROUP BY ContinentCode,
                 CurrencyCode
        HAVING COUNT(CurrencyCode) > 1
    ) AS gbc
) AS ranked
WHERE ranked.UsageRank = 1
ORDER BY ranked.ContinentCode; 


--Highest Peak Name and Elevation by Country
SELECT TOP (5) jt.CountryName AS Country,
               ISNULL(jt.PeakName, '(no highest peak)') AS HighestPeakName,
               ISNULL(jt.Elevation, 0) AS HighestPeakElevation,
               ISNULL(jt.MountainRange, '(no mountain)') AS Mountain
FROM
(
    SELECT c.CountryName,
           DENSE_RANK() OVER(PARTITION BY c.CountryName ORDER BY p.Elevation DESC) AS PeakRank,
           p.PeakName,
           p.Elevation,
           m.MountainRange
    FROM Countries AS c
         LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
         LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
         LEFT JOIN Peaks AS p ON m.Id = p.MountainId
) AS jt
WHERE jt.PeakRank = 1
ORDER BY jt.CountryName,
         jt.PeakName;

-- CASE solution

SELECT TOP (5) jt.CountryName AS Country,
               CASE
                   WHEN jt.PeakName IS NULL
                   THEN '(no highest peak)'
                   ELSE jt.PeakName
               END AS HighestPeakName,
               CASE
                   WHEN jt.Elevation IS NULL
                   THEN 0
                   ELSE jt.Elevation
               END AS HighestPeakElevation,
               CASE
                   WHEN jt.MountainRange IS NULL
                   THEN '(no mountain)'
                   ELSE jt.MountainRange
               END AS Mountain
FROM
(
    SELECT c.CountryName,
           DENSE_RANK() OVER(PARTITION BY c.CountryName ORDER BY p.Elevation DESC) AS PeakRank,
           p.PeakName,
           p.Elevation,
           m.MountainRange
    FROM Countries AS c
         LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
         LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
         LEFT JOIN Peaks AS p ON m.Id = p.MountainId
) AS jt
WHERE jt.PeakRank = 1
ORDER BY jt.CountryName,
         jt.PeakName;