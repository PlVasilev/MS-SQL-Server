--Transactions Syntax
CREATE PROC usp_Withdraw  @withdrawAmount DECIMAL(18,2), @accountId INT
ASBEGIN TRANSACTION -- Start Transaction
UPDATE Accounts SET Balance = Balance - @withdrawAmount -- Withdraw Money
WHERE Id = @accountId
IF @@ROWCOUNT <> 1 -- Didn’t affect exactly one row Undo Changes
BEGIN -- {
  ROLLBACK
  RAISERROR('Invalid account!', 16, 1) -- if we have 2nd ERROR it will be suvir 16 , state 2 (...,16,2)
  RETURN -- it is a must to stop
END -- }
COMMIT -- Save Changes
---------------------
--Trigres
--Triggers are very much like stored procedures
--Called in case of a specific event
--We do not call triggers explicitly
--Triggers are attached to a table
--Triggers are fired when a certain SQL statement is executed against the contents of the table
--Syntax:
--AFTER INSERT/UPDATE/DELETE
--INSTEAD OF INSERT/UPDATE/DELETE

--After Triggers 
CREATE TRIGGER tr_TownsUpdate -- name
ON Towns --table
FOR UPDATE --what evenent - insert update or del
AS
  IF (EXISTS(
        SELECT * FROM inserted
        WHERE Name IS NULL OR LEN(Name) = 0))
  BEGIN
    RAISERROR('Town name cannot be empty.', 16, 1)
    ROLLBACK
    RETURN
  END
					--Causes an error
UPDATE Towns SET Name='' WHERE TownId=1 -- Query to start the trigger
---------------------------

--Instead Of Triggers - Defined by using INSTEAD OF
CREATE TABLE Accounts(
  Username varchar(10) NOT NULL PRIMARY KEY,
  [Password] varchar(20) NOT NULL,
  Active char(1) NOT NULL DEFAULT 'Y'
)
CREATE TRIGGER tr_AccountsDelete ON Accounts
INSTEAD OF DELETE
AS
UPDATE a SET Active = 'N'
  FROM Accounts AS a JOIN DELETED d 
    ON d.Username = a.Username
 WHERE a.Active = 'Y'  

