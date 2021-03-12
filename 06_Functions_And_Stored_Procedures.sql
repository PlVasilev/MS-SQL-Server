-- CAN NOT CHAGE DB, only returns one result or result set (table), can not call procedures
-- CAN NOT USE tempt table and Dynamic SQL(),
-- CAN USE table variables(it is valid in the functions where is defined)
-- EACH STATEMENT start with BEGGIND and ands with END
--Create Functions (scalar) returns one result
--OR 1 = 1;--
CREATE FUNCTION udf_ProjectDurationWeeks -- Function Name
 (@StartDate DATETIME, -- @(parameter name) parameter TYPE,
 @EndDate DATETIME) -- Parameters start with A capital letter
RETURNS INT -- Return Type
AS
BEGIN
  DECLARE @projectWeeks INT; --we declare variable ,start with a small letter
  IF(@EndDate IS NULL) -- if statement
  BEGIN
    SET @EndDate = GETDATE()
  END
  SET @projectWeeks = DATEDIFF(WEEK, @StartDate, @EndDate)
  RETURN @projectWeeks; -- return value
END
--Execute Functions we CALL WITH dbo.udf_.... (write all name)
SELECT [ProjectID], [StartDate], [EndDate],
       dbo.udf_ProjectDurationWeeks([StartDate],[EndDate])
    AS ProjectWeeks
  FROM [SoftUni].[dbo].[Projects]

--Create Functions (TVF) -- returns colletions(tables) like select
CREATE OR ALTER FUNCTION udf_AverageSalaryByDepartment(@DepartmentName NVARCHAR(50)) -- create or change
RETURNS TABLE AS
RETURN 
(
	SELECT d.[Name] AS Department, AVG(e.Salary) AS AverageSalary 
	FROM Departments AS d 
	JOIN Employees AS e ON d.DepartmentID = e.DepartmentID
	WHERE d.[Name] = @DepartmentName
	GROUP BY d.DepartmentID, d.[Name])

SELECT * FROM dbo.udf_AverageSalaryByDepartment('Sales')

--Create Functions (MSTVF) 
CREATE FUNCTION udf_EmployeeListByDepartment(@depName nvarchar(20))
RETURNS @result TABLE( -- name of table @result (table variable)
    FirstName nvarchar(50) NOT NULL,  
    LastName nvarchar(50) NOT NULL,  
    DepartmentName nvarchar(20) NOT NULL) AS
BEGIN
-- DECLARE we can declare the table here
    WITH Employees_CTE (FirstName, LastName, DepartmentName)
    AS(
        SELECT e.FirstName, e.LastName, d.DepartmentName
        FROM Employees AS e 
        LEFT JOIN Departments AS d ON d.DepartmentID = e.DepartmentID)
    INSERT INTO @result SELECT FirstName, LastName, DepartmentName 
      FROM Employees_CTE WHERE DepartmentName = @depName
    RETURN
END

--Problem: Salary Level Function
--Write a function ufn_GetSalaryLevel(@salary MONEY) that receives salary of an employee and returns the level of the salary.
--If salary is < 30000 return “Low”
--If salary is between 30000 and 50000 (inclusive) returns“Average”
--If salary is > 50000 return “High”
CREATE FUNCTION ufn_GetSalaryLevel(@salary MONEY)
RETURNS NVARCHAR(10)
AS
BEGIN
DECLARE @salaryLevel VARCHAR(10)
IF (@salary < 30000)
  SET @salaryLevel = 'Low'
ELSE IF(@salary >= 30000 AND @salary <= 50000)
  SET @salaryLevel = 'Average'
ELSE
  SET @salaryLevel = 'High'
RETURN @salaryLevel
END;

--STORED PROCEDURES -- THEY CAN ALTERER THE DB
--Very usefull whe we need multiple calls from DB to perform a task and less traffic,
-- cuz we gat all the data one and then work with it
--Creating Stored Procedures
USE SoftUni -- DB we use
GO
CREATE PROC dbo.usp_SelectEmployeesBySeniority -- procdure name
AS
  SELECT * -- it is the result of SP we can have multiple SELECTS so that means multiple results
  FROM Employees
  WHERE DATEDIFF(Year, HireDate, GETDATE()) > 18 -- procedure logic
GO

--Executing Stored Procedures
EXEC usp_SelectEmployeesBySeniority

INSERT INTO Customers -- in custemers we insert the result of usp_SelectEmployeesBySeniority
EXEC usp_SelectEmployeesBySeniority

--Altering Stored Procedures
USE SoftUni GO
ALTER PROC usp_SelectEmployeesBySeniority
AS
  SELECT FirstName, LastName, HireDate, 
    DATEDIFF(Year, HireDate, GETDATE()) as Years
  FROM Employees
  WHERE DATEDIFF(Year, HireDate, GETDATE()) > 5
  ORDER BY HireDate
GO

--Dropping Stored Procedures
DROP PROC usp_SelectEmployeesBySeniority

--You could check if any objects depend on the stored procedure by executing the system stored procedure sp_depends
EXEC sp_depends 'usp_SelectEmployeesBySeniority' -- FOR ALL OBJECTS IN TSQL

--Defining Parameterized Procedures To define a parameterized procedure use the syntax:
CREATE PROCEDURE usp_ProcedureName 
(@parameter1Name parameterType,
  @parameter2Name parameterType,…) AS

--Choose the parameter types carefully and provide an appropriate default values
CREATE PROC usp_SelectEmployeesBySeniority(
  @minYearsAtWork int = 5) AS …

--Parameterized Stored Procedures – Example
CREATE PROC usp_SelectEmployeesBySeniority(@minYearsAtWork int = 5) -- procedure name default = 5 if nothing entered
AS
  SELECT FirstName, LastName, HireDate,
         DATEDIFF(Year, HireDate, GETDATE()) as Years
    FROM Employees
   WHERE DATEDIFF(Year, HireDate, GETDATE()) > @minYearsAtWork -- procedure logic
   ORDER BY HireDate	GO

EXEC usp_SelectEmployeesBySeniority 10 -- Usage

--Passing values by parameter name
EXEC usp_AddCustomer 
  @customerID = 'ALFKI',
  @companyName = 'Alfreds Futterkiste',
  @address = 'Obere Str. 57',
  @city = 'Berlin',
  @phone = '030-0074321' 

--Passing values by position
EXEC usp_AddCustomer 'ALFKI2', 'Alfreds Futterkiste', 'Obere Str. 57', 'Berlin', '030-0074321'

--Returning Values Using OUTPUT Parameters
CREATE PROCEDURE dbo.usp_AddNumbers -- create procedure
   @firstNumber SMALLINT,
   @secondNumber SMALLINT,
   @result INT OUTPUT
AS   SET @result = @firstNumber + @secondNumber		GO

DECLARE @answer smallint -- execute procedure
EXECUTE usp_AddNumbers 5, 6, @answer OUTPUT
SELECT 'The result is: ', @answer -- answer -- The result is: 11

--Returning Multiple Results
CREATE OR ALTER PROC usp_MultipleResults -- Checks if procedure exists and then Creates or Alters it 
AS
SELECT FirstName, LastName FROM Employees -- Multiple SELECT statements
SELECT FirstName, LastName, d.[Name] AS Department 
FROM Employees AS e 
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID;	GO

EXEC usp_MultipleResults

--Error Handling
--@@ERROR global variable we cann call it anytime
--Returns 0 if the previous Transact-SQL statement encountered no errors
--Returns an error number if the previous statement encountered an error
--@@ERROR is cleared and reset on each statement executed, check it immediately 
--following the statement being verified, or save it to a local variable that can be checked later
--Error Handling try catch
BEGIN TRY  
    -- Generate a divide-by-zero error.  
    SELECT 1/0
END TRY  
BEGIN CATCH  
    SELECT  
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_LINE() AS ErrorLine  
        ,ERROR_MESSAGE() AS ErrorMessage;  -- only usable in Catch BLock
END CATCH  
GO
SELECT @@ERROR

--Solution: Employees with Three Projects (1) -- Raise error
--Create a procedure that assigns projects to an employee
--If the employee has more than 3 projects, throw an exception and rollback the changes
CREATE PROCEDURE udp_AssignProject -- procedure name
(@EmployeeID INT, @ProjectID INT) -- Parameters
AS
BEGIN
DECLARE @maxEmployeeProjectsCount INT = 3 -- declare variables
DECLARE @employeeProjectsCount INT
SET @employeeProjectsCount = 
(SELECT COUNT(*) 
   FROM [dbo].[EmployeesProjects] AS ep
   WHERE ep.EmployeeId = @EmployeeID)
	BEGIN TRAN
	INSERT INTO [dbo].[EmployeesProjects]  (EmployeeID, ProjectID)VALUES (@EmployeeID, @ProjectID)
	
	IF(@employeeProjectsCount >= @maxEmployeeProjectsCount)
	BEGIN
	  RAISERROR('The employee has too many projects!', 16, 1) -- throw exeception
	  ROLLBACK -- undo changes
	END
	ELSE
	   COMMIT -- save changes
END

--Problem: Withdraw Money
--Create a stored procedure usp_WithdrawMoney (AccountId, moneyAmount) that operate in transactions
--Validate only if the account exists and if not, throw an exception
CREATE PROCEDURE usp_WithdrawMoney
  @account INT , @moneyAmount MONEY -- we can do it without ()
AS
BEGIN
	  BEGIN TRANSACTION
	UPDATE Accounts SET Balance = Balance - @moneyAmount -- Update Balance
	
	WHERE Id = @account
	IF @@ROWCOUNT <> 1
	BEGIN
	  ROLLBACK; -- Rollback
	  RAISERROR('Invalid account!', 16, 1)
	  RETURN
END
COMMIT -- Save changes
END
