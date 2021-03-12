--Select From Smaller table
--Inner Join Syntax - Ignor Null in condition
SELECT * FROM Employees AS e
  INNER JOIN Departments AS d
  ON e.DepartmentID = d.DepartmentID

--Left Outer Join Syntax - Nulls on the right in condition
--Get all rows from left table 'e' and joins all that maches from the right'd'(After JOIN) not mached are Null
SELECT * FROM Employees AS e
 RIGHT OUTER JOIN Departments AS d
 ON e.DepartmentID = d.DepartmentID

 --Right Outer Join Syntax Nulls on the left in condition
 --Get all rows from right table 'e' and joins all that maches from the left'd'(After JOIN) not mached are Null
 SELECT * FROM Employees AS e
 RIGHT OUTER JOIN Departments AS d
 ON e.DepartmentID = d.DepartmentID

 --Full Join Syntax
 --Get all rows from one table 'e' and joins all that maches from the other'd' and
 -- Nulls are on the left and on the right depending of the table they are in
 SELECT * FROM Employees AS e
  FULL JOIN Departments AS d
  ON e.DepartmentID = d.DepartmentID

--Cartesian Product (1)
--Get All from Employees and put All from Departmest on the right with NO CONDITION DO NOT USE 
SELECT LastName, Name AS DepartmentName
FROM Employees, Departments -- we can have ON Condition -- rows A times rows B

--Cross Join
-- For Each row from Employees copies it and puts all departments rows next to it 
-- Copies Departments table to a row in Employees
SELECT * FROM Employees AS e
 CROSS JOIN Departments AS d

 --Solution: Addresses with Towns
 SELECT TOP 50 e.FirstName, e.LastName,
  t.Name as Town, a.AddressText
FROM Employees e
  JOIN Addresses a ON e.AddressID = a.AddressID
  JOIN Towns t ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName

--Solution: Sales Employees
SELECT e.EmployeeID, e.FirstName, e.LastName, 
  d.Name AS DepartmentName
FROM Employees e 
  INNER JOIN Departments d 
    ON e.DepartmentID = d.DepartmentID AND d.Name = 'Sales' -- Extra condition like WHERE on the result SET (FASTER)
--WHERE d.Name = 'Sales'
ORDER BY e.EmployeeID

--Solution: Employees Hired After
SELECT e.FirstName, e.LastName, e.HireDate,  d.Name as DeptName
FROM Employees e
  INNER JOIN Departments d
  ON (e.DepartmentId = d.DepartmentId
  AND e.HireDate > '1/1/1999' -- '1999-01-01' works the same
  AND d.Name IN ('Sales', 'Finance'))
ORDER BY e.HireDate ASC

--Solution: Employee Summary
SELECT TOP 50 
  e.EmployeeID, 
  e.FirstName + ' ' + e.LastName AS EmployeeName, 
  m.FirstName + ' ' + m. LastName AS ManagerName,
  d.Name AS DepartmentName
FROM Employees AS e
  LEFT JOIN Employees AS m ON m.EmployeeID = e.ManagerID -- Self join
  LEFT JOIN Departments AS d ON d.DepartmentID =       e.DepartmentID -- Table Departments
  ORDER BY e.EmployeeID ASC

 -- Subqueries
 SELECT * FROM Employees AS e
 WHERE e.DepartmentID IN  -- SELECT in SELECT = SubQue
  (   SELECT d.DepartmentID -- we dont have join so we dont have Depart Name but we filter by it :)
        FROM Departments AS d
    WHERE d.Name = 'Finance'  )

--Solution: Min Average Salary
SELECT   
MIN(a.AverageSalary) AS MinAverageSalary
  FROM 
  (     SELECT e.DepartmentID, 
            AVG(e.Salary) AS AverageSalary
       FROM Employees AS e
   GROUP BY e.DepartmentID ) AS a

 --Common Table Expressions (CTE) can be considered as "named subqueries"
--They could be used to improve code readability and code reu
--Usually they are positioned in the beginning of the query
--WITH CTE_Name (ColumnA, ColumnB…)
--AS
--(-- Insert subquery here.)
--CTE Syntax
WITH Employees_CTE (FirstName, LastName, DepartmentName)
AS
(  SELECT e.FirstName, e.LastName, d.Name
  FROM Employees AS e 
  LEFT JOIN Departments AS d ON 
    d.DepartmentID = e.DepartmentID)

SELECT FirstName, LastName, DepartmentName FROM Employees_CTE

--Temporary Tables
--Temporary tables are stored in tempdb
--Automatically deleted when they are no longer used
--CREATE TABLE #TempTable(	-- Add columns here.	) # before name is a MUST
--SELECT * FROM #TempTable
CREATE TABLE #Employees(
	Id INT PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50),
	Address VARCHAR(50))

SELECT * FROM #Employees

--INSERT FROM TABLE !!!!
INSERT INTO #Employees SELECT e.EmployeeID,e.FirstName, e.LastName, d.Name 
FROM Employees AS e 
JOIN Departments AS d 
ON d.[DepartmentID] = e.DepartmentID

--Indices Syntax
--Indices speed up the searching of values in a certain column or group of columns
--Usually implemented as B-trees
--Indices can be built-in the table (clustered) or stored externally (non-clustered)
--Adding and deleting records in indexed tables is slower!
--Indices should be used for big tables only (e.g. 50 000 rows).

CREATE NONCLUSTERED INDEX -- Index Type
IX_Employees_FirstName_LastName
ON Employees(FirstName, LastName) --TableName (Colomns)
