SELECT DepositGroup,
 SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits AS s
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(s.DepositAmount) < 150000
ORDER BY TotalSum DESC

SELECT  
	DepositGroup,
	MagicWandCreator,
	MIN(DepositCharge) AS MinDepositCharge
FROM WizzardDeposits
	GROUP BY MagicWandCreator,DepositGroup
	ORDER BY MagicWandCreator ASC, DepositGroup ASC

SELECT grouped.AgeGroups,
       COUNT(*) AS WizzardsCount
FROM
(    SELECT CASE
               WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
               WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
               WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
               WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
               WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
               WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
               WHEN Age >= 61 THEN '[61+]'
               ELSE 'N\A'
           END AS AgeGroups
    FROM WizzardDeposits
) AS grouped
GROUP BY grouped.AgeGroups;

--All unique first letters
SELECT LEFT(FirstName, 1) AS FirstLetter
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName,1)
ORDER BY FirstLetter

SELECT 
	DepositGroup,
	IsDepositExpired,
	AVG(DepositInterest) as AverageInterest
FROM WizzardDeposits
WHERE DepositStartDate > '1985-01-01'
GROUP By DepositGroup,IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired

--Difference between Lines same Collumn
SELECT SUM(ws.Difference) AS SumDifference
FROM
(
    SELECT DepositAmount -
    (
        SELECT DepositAmount
        FROM WizzardDeposits AS wsd
        WHERE wsd.Id = wd.Id + 1
    ) AS Difference
    FROM WizzardDeposits AS wd
) AS ws; 

SELECT DepartmentID 
, MIN(Salary) AS TotalSalary
 FROM Employees 
 WHERE DepartmentID IN(2,5,7)
 AND DATEPART(YEAR, HireDate) >= 2000
 GROUP BY DepartmentID
 ORDER BY DepartmentID

 SELECT DepartmentID 
, MIN(Salary) AS TotalSalary
 FROM Employees 
 WHERE DepartmentID IN(2,5,7)
 AND DATEPART(YEAR, HireDate) >= 2000
 GROUP BY DepartmentID
 ORDER BY DepartmentID

 -- CREATE NEW TABLE UPDATE IT AND AGREFATE IT
SELECT * INTO NewTable FROM Employees WHERE Salary > 30000
DELETE FROM NewTable WHERE ManagerID = 42
UPDATE NewTable SET Salary = Salary + 5000 WHERE DepartmentID = 1
SELECT DepartmentID, AVG(Salary) FROM NewTable GROUP BY DepartmentID

SELECT 
	COUNT(Salary) AS [Count]	
FROM Employees 
WHERE ManagerID IS NULL

--3rd hiest salary
SELECT salaries.DepartmentID,
       salaries.Salary
FROM
(
    SELECT DepartmentID,
           Salary, 
		 --DENSE_RANK() OVER(ORDER BY Salary DESC) AS Rank
           DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC) AS RankNAME
    FROM Employees
    GROUP BY DepartmentID,
             Salary
) AS salaries
WHERE RankNAME = 3
GROUP BY salaries.DepartmentID,
         salaries.Salary;

-- Select all employees who have salary higher than the average salary of their respective departments. 
-- Select only the first 10 rows. Order by DepartmentID.
SELECT TOP 10 FirstName,
              LastName,
              DepartmentID
FROM Employees AS e
WHERE Salary >
(
    SELECT AVG(Salary)
    FROM Employees AS em
    WHERE e.DepartmentID = em.DepartmentID
);

