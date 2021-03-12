--Grouping
--Aggregate functions usually ignore NULL values.
-- GET SYMBOL FROM ASKII -- CHAR(number of symbol) CHAR(13)

SELECT e.DepartmentID , e.LastName  FROM Employees AS e GROUP BY e.DepartmentID, e.LastName
SELECT DISTINCT e.DepartmentID FROM Employees AS e

SELECT e.DepartmentID, 
  SUM(e.Salary) AS TotalSalary -- MIN, MAX, AVG, COUNT, etc.
FROM Employees AS e GROUP BY e.DepartmentID ORDER BY e.DepartmentID

SELECT AVG(Salary) FROM Employees -- works on the all table
SELECT DepartmentID,ManagerID, AVG(Salary) FROM Employees WHERE DepartmentID IN (1,7,16) GROUP BY DepartmentID,ManagerID

SELECT DepartmentID, 
COUNT(*) AS EmploeesNumber, -- we should avoid * takes too much resourses
COUNT(MiddleName) AS NotNull 
FROM Employees GROUP BY DepartmentID
--COUNT ignores any employee with NULL salary
--If any department has no salaries, it returns NULL.

--STRING_AGG - Concatenates the values of string expressions and places separator values 
--between them. The separator is not added at the end of string
--	Expressions are converted to NVARCHAR or VARCHAR types during concatenation. Non-string types are converted to NVARCHAR type
--		STRING_AGG ( expression, separator ) [WITHIN GROUP ( ORDER BY expression [ ASC | DESC ] )]

SELECT 
	DepartmentID,
	ManagerID, 
	AVG(Salary) AS AvgSal,
	MAX(Salary) AS MaxSal,
	MIN(Salary) AS MinSal,
	STRING_AGG(Salary, CHAR(13)) WITHIN GROUP(ORDER BY Salary DESC)  AS AllSalaries -- OR ', '
FROM 
	Employees 
GROUP BY 
	DepartmentID,ManagerID

--Having Clause
--The HAVING clause is used to filter data based on aggregate values 
--We cannot use it without grouping first
--Aggregate functions (MIN, MAX, SUM etc.) are executed only once
--Unlike HAVING, WHERE filters rows before aggregation
SELECT e.DepartmentID,
	SUM(e.Salary) AS TotalSalary
    FROM Employees AS e
	WHERE DepartmentID IN(1,2,3) -- Before GROUPING
GROUP BY e.DepartmentID
	HAVING SUM(e.Salary) >= 150000 -- After GROUPING
	ORDER BY TotalSalary DESC

--Pivot Tables
	--PIVOT rotates a table-valued expression by turning the unique values from one column 
		--in the expression into multiple columns in the output, and performs aggregations where 
		--they are required on any remaining column values that are wanted in the final output
	--UNPIVOT performs the opposite operation to PIVOT by rotating columns of a table-valued expression into column values

SELECT * FROM DailyIncome

SELECT * FROM DailyIncome
PIVOT (
	AVG (IncomeAmount) FOR IncomeDay 
		IN ([MON],[TUE],[WED],[THU],[FRI],[SAT],[SUN])
	  ) 
	 AS AvgIncomePerDay

SELECT 'AverageCost' AS Cost_Sorted_By_Production_Days, --Row lable
 [0], [1], [2], [3], [4]  -- coloms lables
FROM (SELECT DaysToManufacture, StandardCost FROM Production.Product) AS SourceTable  
PIVOT  ( AVG(StandardCost) FOR DaysToManufacture IN ([0], [1], [2], [3], [4])) AS PivotTable


SELECT 'Avarage Salary' AS Department,
	[1] AS FirstDep,
	[7]	AS SeventDep ,
	[16] AS Sixteened-- Dep IDs
FROM
(SELECT 
	DepartmentID, Salary -- we get the data
FROM Employees) AS dt
PIVOT (
AVG(Salary)
FOR DepartmentID IN ([1],[7],[16])
) AS PivotTable

SELECT 
	d.[Name], AVG(Salary) AS Sal
FROM Employees AS e 
	JOIN Departments AS d 
	ON e.DepartmentID = d.DepartmentID -- conection between 2 tables
GROUP BY d.[Name]