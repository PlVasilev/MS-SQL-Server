USE SoftUni -- DB we use
GO
CREATE PROC usp_EmployeesBySalaryLevel(@SalaryLevel NVARCHAR(50))
AS
  SELECT FirstName AS [First Name]
		,LastName AS [Last Name]
  FROM Employees 
  WHERE dbo.ufn_GetSalaryLevel(Salary) = @SalaryLevel
GO
--Func in ProC
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
END

USE Bank -- DB we use
GO
CREATE PROC usp_GetHoldersWithBalanceHigherThan(@Sum DECIMAL(18,4))
AS
  SELECT FirstName AS [First Name]
		 ,LastName AS [Last Name]
  FROM AccountHolders AS ah
  JOIN Accounts AS a ON a.AccountHolderId =	ah.Id
  GROUP BY FirstName,LastName
  HAVING @Sum < SUM(a.Balance)
  ORDER BY [First Name] ASC,[Last Name] ASC
GO

--FIND LETTERS IN SET OF LETTERS
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(MAX), @word NVARCHAR(MAX)) 
RETURNS BIT 
BEGIN
	DECLARE @CharIndex INT = 1
	WHILE (@CharIndex <= LEN(@word))
		BEGIN
			DECLARE @CurrentLetter CHAR(1) = SUBSTRING(@word,@CharIndex,1)
			IF(CHARINDEX(@CurrentLetter, @setOfLetters) <= 0)
			BEGIN
			 RETURN 0
			 END
			 SET @CharIndex += 1
		END
		RETURN 1
END

--DELETE FROM EMPLOYEES
CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT) 
AS BEGIN TRANSACTION
--Altering tables
ALTER TABLE Employees ALTER COLUMN ManagerID INT
ALTER TABLE Employees ALTER COLUMN DepartmentID INT
UPDATE Employees SET DepartmentID = NULL WHERE EmployeeID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)
UPDATE Employees SET ManagerID = NULL WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)
ALTER TABLE Departments ALTER COLUMN ManagerId INT
UPDATE Departments SET ManagerID = NULL WHERE DepartmentID = @departmentId
-- DELETEING FROM TABLES
DELETE FROM EmployeesProjects WHERE EmployeeID IN (SELECT EmployeeID from Employees WHERE DepartmentID = @departmentId)
DELETE FROM Employees WHERE DepartmentID = @departmentId
DELETE FROM Departments WHERE DepartmentID = @departmentId
SELECT COUNT(*) FROM Employees WHERE DepartmentID = @departmentId
COMMIT

EXEC usp_DeleteEmployeesFromDepartment 2

---
CREATE FUNCTION ufn_CalculateFutureValue 
   (@Sum DECIMAL(15,2), 
	@YearlyInterestRate FLOAT,
    @Years INT) 
RETURNS DECIMAL(15,4) 
AS
BEGIN
  DECLARE @result DECIMAL(15,4)
	SET @result = @Sum * (POWER((1 + @YearlyInterestRate),@Years))
	RETURN @result
END

SELECT dbo.ufn_CalculateFutureValue (1000, 0.1, 5)

--- USING upper function
CREATE PROC usp_CalculateFutureValueForAccount (@AccountID INT,@IntrestRate FLOAT)
AS
SELECT a.Id AS [Account Id]
	,ah.FirstName AS [First Name]
	,ah.LastName AS [Last Name]
	,a.Balance AS [Current Balance]
	, dbo.ufn_CalculateFutureValue (a.Balance, @IntrestRate, 5) AS [Balance in 5 years]
 FROM Accounts AS a
	JOIN AccountHolders AS ah ON a.AccountHolderId = ah.Id
	WHERE a.Id = @AccountID

---ODD RowNUmber
CREATE FUNCTION ufn_CashInUsersGames(@GameName VARCHAR(MAX))
RETURNS TABLE AS
RETURN(
SELECT SUM(t.Cash) AS [SumCash]
FROM (
SELECT g.Name,ug.Cash,
	ROW_NUMBER() OVER(PARTITION BY g.[Name] ORDER BY ug.Cash DESC) AS RowNumber
 FROM UsersGames AS ug
JOIN Games AS g ON ug.GameId = g.Id
WHERE g.Name = @GameName
) AS t
WHERE RowNumber%2 <> 0)

SELECT * FROM dbo.ufn_CashInUsersGames('Mimosa')

----CREATE TRIGGRE FOR Log TABLE
CREATE TABLE Logs (
	LogId INT PRIMARY KEY IDENTITY
	,AccountId INT
	,OldSum DECIMAL(15,2)	
	,NewSum DECIMAL(15,2))

CREATE OR ALTER TRIGGER tr_AccountSumChange
ON Accounts
AFTER UPDATE
AS
	INSERT INTO Logs(AccountId,OldSum,NewSum)
	VALUES (
	(SELECT Id FROM inserted)
	,(SELECT Balance FROM deleted)
	,(SELECT Balance FROM inserted))

---CRATE TRIGGER FRO TRIGGER
CREATE OR ALTER TRIGGER tr_NotificationEmails
ON Logs 
FOR INSERT
AS
BEGIN
	INSERT INTO NotificationEmails
	VALUES (
	(SELECT AccountId FROM inserted)
	,CONCAT('Balance change for account: ',(SELECT AccountId FROM inserted))
	,CONCAT ('On ',GETDATE(),' your balance was changed from ',
	(SELECT TOP(1) OldSum FROM inserted),
	' to ', 
	(SELECT TOP(1) NewSum FROM inserted),
	'.'));
END

UPDATE Accounts SET Balance = 530 WHERE Id = 2

---
CREATE OR ALTER  PROC usp_DepositMoney (@AccountId INT, @MoneyAmount DECIMAL(13,4))
AS
BEGIN 
IF @MoneyAmount < 0
	BEGIN	RAISERROR('Money Can NOT be Negative.', 16, 1)	END
ELSE	
	BEGIN		
		IF(@AccountId IS NULL or @MoneyAmount IS NULL) 
			BEGIN		
			RAISERROR('Missing Value', 16, 2)		
			END
	END
	BEGIN TRANSACTION
UPDATE Accounts SET Balance += @MoneyAmount WHERE Id = @AccountId
		IF(@@ROWCOUNT < 1)
             BEGIN   
			 ROLLBACK;  
			 RAISERROR('Account doesn''t exists', 16, 3);         
			 END;
	COMMIT
END

EXEC usp_DepositMoney 1, 50

---
CREATE PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount DECIMAL(13,4))
AS
BEGIN 
IF @MoneyAmount < 0
	BEGIN	RAISERROR('Money Can NOT be Negative.', 16, 1)	END
ELSE	
	BEGIN		
		IF(@AccountId IS NULL or @MoneyAmount IS NULL) 
			BEGIN		
			RAISERROR('Missing Value', 16, 2)		
			END
	END
	BEGIN TRANSACTION
UPDATE Accounts SET Balance -= @MoneyAmount WHERE Id = @AccountId
		IF(@@ROWCOUNT < 1)
             BEGIN   
			 ROLLBACK;  
			 RAISERROR('Account doesn''t exists', 16, 3);         
			 END;
	COMMIT
END

---
CREATE PROC usp_TransferMoney(@SenderId INT,@ReceiverId INT, @Amount DECIMAL(13,4)) 
AS
BEGIN TRANSACTION
	EXEC dbo.usp_DepositMoney @ReceiverId,@Amount
	EXEC dbo.usp_WithdrawMoney @SenderId,@Amount
	COMMIT

-------Massive Shopping
DECLARE @gameId INT, @sum1 MONEY, @sum2 MONEY;

SELECT @gameId = usg.[Id]
FROM UsersGames AS usg
     JOIN Games AS g ON usg.[GameId] = g.[Id]
WHERE g.[Name] = 'Safflower';

SET @sum1 =
(
    SELECT SUM(i.Price)
    FROM Items AS i
    WHERE MinLevel BETWEEN 11 AND 12
);

SET @sum2 =
(
    SELECT SUM(i.Price)
    FROM Items AS i
    WHERE MinLevel BETWEEN 19 AND 21
);

BEGIN TRANSACTION;

IF
(
    SELECT Cash
    FROM UsersGames
    WHERE Id = @gameId
) < @sum1
    BEGIN
        ROLLBACK;
END
    ELSE
    BEGIN
        UPDATE UsersGames
          SET
              Cash = Cash - @sum1
        WHERE Id = @gameId;

        INSERT INTO UserGameItems(UserGameId,
                                  ItemId
                                 )
               SELECT @gameId,
                      Id
               FROM Items
               WHERE MinLevel BETWEEN 11 AND 12;
        COMMIT;
END;

BEGIN TRANSACTION;

IF
(
    SELECT Cash
    FROM UsersGames
    WHERE Id = @gameId
) < @sum2
    BEGIN
        ROLLBACK;
END
    ELSE
    BEGIN
        UPDATE UsersGames
          SET
              Cash = Cash - @sum2
        WHERE Id = @gameId;

        INSERT INTO UserGameItems(UserGameId,
                                  ItemId
                                 )
               SELECT @gameId,
                      Id
               FROM Items
               WHERE MinLevel BETWEEN 19 AND 21;
        COMMIT;
END;

SELECT i.Name AS 'Item Name'
FROM UserGameItems AS ugi
     JOIN Items AS i ON ugi.ItemId = i.Id
WHERE ugi.UserGameId = @gameId;

-----
CREATE PROC usp_AssignProject(@emloyeeId INT, @projectID INT) 
AS
BEGIN
	DECLARE @employeeProjects INT = (SELECT COUNT(ep.ProjectID) AS pId FROM Employees AS e
	JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
	GROUP By e.EmployeeID
	HAVING e.EmployeeID = @emloyeeId)
	IF(@employeeProjects >= 3)
	BEGIN
	RAISERROR ('The employee has too many projects!',16,1)
	ROLLBACK
	END
	ELSE
	BEGIN
	INSERT INTO EmployeesProjects
	VALUES(@emloyeeId,@projectID)
	END
END

---
CREATE TABLE Deleted_Employees(
EmployeeId INT PRIMARY KEY IDENTITY, 
FirstName VARCHAR(50), 
LastName VARCHAR(50), 
MiddleName VARCHAR(50), 
JobTitle VARCHAR(50), 
DepartmentId iNT, 
Salary MONEY) 

CREATE TRIGGER t_DeletedEmployees
    ON Employees AFTER DELETE
    AS
    BEGIN
	  INSERT INTO Deleted_Employees ( FirstName, LastName,MiddleName,JobTitle,DepartmentId,Salary)
	  SELECT  d.FirstName, d.LastName,d.MiddleName,d.JobTitle,d.DepartmentId,d.Salary
	    FROM deleted AS d
    END