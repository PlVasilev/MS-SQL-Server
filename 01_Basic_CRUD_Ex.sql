use SoftUni

SELECT FirstName + '.' + LastName + '@softuni.bg' AS [Full Email Address]
  FROM Employees

SELECT DISTINCT Salary
  FROM Employees

SELECT *
  FROM Employees
  WHERE JobTitle = 'Sales Representative'

SELECT FirstName,LastName, Salary 
  FROM Employees
  WHERE Salary > 50000
  ORDER BY Salary DESC

SELECT TOP(5) FirstName,LastName
  FROM Employees
  ORDER BY Salary DESC

SELECT FirstName,LastName 
  FROM Employees
  WHERE DepartmentID <> 4

SELECT *
  FROM Employees
  ORDER BY Salary DESC, FirstName ASC,LastName DESC, MiddleName ASC

CREATE VIEW V_EmployeesSalaries AS
SELECT FirstName,  LastName , Salary
  FROM Employees

DROP VIEW IF EXISTS dbo.V_EmployeesSalaries ;  

 SELECT DISTINCT JobTitle
  FROM Employees

SELECT TOP(7) FirstName,LastName,HireDate
  FROM Employees
ORDER BY HireDate DESC

UPDATE Employees
   SET Salary = Salary * 1.12
 WHERE DepartmentID IN ( 1,2,4,11)

 SELECT Salary FROM Employees

 USE [Geography]

 SELECT * FROM Countries

SELECT TOP(30) CountryName,[Population] 
  FROM Countries
  WHERE ContinentCode = 'EU' 
  ORDER BY [Population] DESC, CountryName

  USE Diablo

SELECT [Name] from Characters ORDER BY [Name]

USE [Geography]

--44

SELECT CountryName,
       CountryCode,
       CASE CurrencyCode
           WHEN 'EUR'
           THEN 'Euro'
           ELSE 'Not Euro'
       END AS 'Currency'
FROM Countries
ORDER BY CountryName;