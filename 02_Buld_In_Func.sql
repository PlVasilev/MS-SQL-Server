
--INDEX START FROM 1 !!!
SELECT CAST('25' as INT)

--USE SoftUni

		----STRING FUNCTIONS
	--CONCAT replaces NULL values with empty string
SELECT CONCAT(FirstName, ' ', LastName)
    AS [Full Name]
	FROM Employees
	--CONCAT_WS ( separator, argument1, argument2 [, argumentN]... )
	--CONCAT_WS ignores null values during concatenation, and does not add the 
	--separator between null values. Therefore, CONCAT_WS can cleanly handle 
	-- concatenation of strings that might have "blank" values
SELECT CONCAT_WS(' ', FirstName, LastName)
    AS [Full Name]
  FROM Employees
SELECT CONCAT_WS(',','1 Microsoft Way', NULL, NULL, 'Redmond', 'WA', 98052) AS Address;
SELECT CONCAT_WS('. ', SUBSTRING(FirstName, 1,1) , SUBSTRING(LastName, 1,1), '') FROM Employees
SELECT REPLACE(MiddleName, 'P', ' Peshov') FROM Employees

	--SUBSTRING – extracts a part of a string
--SUBSTRING(String, StartIndex, Length)
SELECT ArticleId, Author, Content,
       SUBSTRING(Content, 1, 200) + '...' AS Summary
  FROM Articles

	--REPLACE – replaces a specific string with another
--REPLACE(String, Pattern, Replacement)
SELECT REPLACE(Title, 'blood', '*****')
    AS Title
  FROM Album

	--LTRIM & RTRIM – remove spaces from either side of stringLTRIM(String) RTRIM(String)
LTRIM(String) RTRIM(String) TRIM(String)

	--LEN – counts the number of characters
LEN(String)

	--DATALENGTH – gets the number of used bytes
SELECT DATALENGTH('String')
SELECT DATALENGTH(N'ÈÂÀÍ') -- 8 ñëàãà ãè â ÀÑÊÈÈ çà òîâà ïîëçà 2õ áàéòà
SELECT DATALENGTH('ÈÂÀÍ') -- 4

	--LEFT & RIGHT – get characters from the beginning or the end of a string
--LEFT(String, Count) RIGHT(String, Count)
SELECT Id, Start,
       LEFT(Name, 3) AS Shortened
  FROM Games

	--LOWER & UPPER – change letter casing
LOWER(String) UPPER(String)

	--REVERSE – reverses order of all characters in a string
REVERSE(String)

	--REPLICATE – repeats a string
REPLICATE(String, Count)
	
	--CHARINDEX – locates a specific pattern (substring) in a string
CHARINDEX(Pattern, String, [StartIndex])

	--STUFF – inserts a substring at a specific position
STUFF(String, StartIndex, Length, Substring)
SELECT STUFF('This is a bad idea', 11 , 0 ,'very ')
SELECT STUFF('This is a bad idea', 11 , 3 ,'good')

	--FORMAT – returns a value formatted with the specified format and optional culture in SQL Server 2017. Use the 
--FORMAT function for locale-aware formatting of date/time and number values as strings
FORMAT ( value, format [, culture ] ) 
--The format argument must contain a valid .NET Framework format string, either as a standard format string (for example, "C" or "D"), 
--or as a pattern of custom characters for dates and numeric values (for example, "MMMM DD, yyyy (dddd)")
SELECT FORMAT(67.2342,'C', 'en-US')
SELECT FORMAT(67.23452151,'C', 'bg-BG')
SELECT FORMAT(0.23452151,'P', 'bg-BG')
SELECT FORMAT(CAST('2019-01-19' as date),'dd.MM.yyyy ã.', 'bg-BG')
SELECT FORMAT(CAST('2019-01-19' as date),N'dd.MM.yyyy ã.', 'bg-BG')

	--TRANSLATE – returns the string provided as a first argument after some characters specified in the second 
--argument are translated into a destination set of characters specified in the third argument
TRANSLATE ( inputString, characters, translations)
SELECT TRANSLATE('2*[3+4]/{7-2}', '[]{}', '()()') -- ÐÀÁÎÒÈ 2*(3+4)/(7-2)
	
USE DEMO
GO
CREATE VIEW v_PublicPaymentInfo AS 
SELECT CustomerID,
       FirstName,
       LastName,
       LEFT(PaymentNumber, 6) + '**********' as c
  FROM Customers

SELECT * FROM v_PublicPaymentInfo

		----MATH FUNCTIONS
--PI – gets the value of Pi as a float (15 –digit precision)
SELECT PI() --3.14159265358979
--ABS – absolute value
ABS(Value)
--SQRT – square root (the result will be float)
SQRT(Value)
--SQUARE – raise to power of two
SQUARE(Value)
--POWER – raises value to the desired exponent
POWER(Value, Exponent)
--ROUND – obtains the desired precision
ROUND(Value, Precision)
SELECT ROUND(18.345, 2)
SELECT ROUND(18.345, -1)
--FLOOR & CEILING – return the nearest integer
FLOOR(Value)
CEILING(Value)
--SIGN – returns 1, -1 or 0, depending on the value of the sign
SIGN(Value)
--RAND – gets a random float value in the range [0, 1] If Seed is not specified, it will be assigned randomly
SELECT RAND()
RAND(Seed)

SELECT Id,
       SQRT(SQUARE(X1-X2) + SQUARE(Y1-Y2))
    AS Length
  FROM Lines

		----DATE FUNCTIONS
--Use DATEPART to get the relevant parts of the dateFor a full list, take a look at the official documentation
SELECT InvoiceId, Total,
       DATEPART(QUARTER, InvoiceDate) AS Quarter,
       DATEPART(MONTH, InvoiceDate) AS Month,
       DATEPART(YEAR, InvoiceDate) AS Year,       
	   DATEPART(WEEK, InvoiceDate)
  FROM Invoice

USE SoftUni
SELECT * FROM Projects Where DATEPART(QUARTER, StartDate) = 3

--DATEDIFF – finds the difference between two dates Part can be any part and format of date or time
DATEDIFF(Part, FirstDate, SecondDate)
SELECT EmployeeID, FirstName, LastName,
       DATEDIFF(YEAR, HireDate, '2017/01/25')
    AS [Years In Service]
  FROM Employees

--DATENAME – gets a string representation of a date's part 
DATENAME(Part, Date)
SELECT DATENAME(weekday, '2017/01/27')

--DATEADD – performs date arithmetic Part can be any part and format of date or time
DATEADD(Part, Number, Date)

--GETDATE – obtains the current date and time
SELECT GETDATE()

--EOMONTH – this function returns the last day of the month containing a specified date, with an optional offset.
EOMONTH ( start_date [, month_to_add ] )
SELECT EOMONTH('2017/01/27') -- 2017-01-31
--If the month_to_add argument has a value, then EOMONTH adds the specified number of months to start_date, 
--and then returns the last day of the month for the resulting date

		--OTHER FUNCIONS
--CAST & CONVERT – conversion between data types
CAST(Data AS NewType)
CONVERT(NewType, Data)

--ISNULL – swaps NULL values with a specified default value
ISNULL(Data, DefaultValue)
SELECT ProjectID, Name,
       ISNULL(CAST(EndDate AS varchar), 'Not Finished')
  FROM Projects

--COALESCE – evaluates the arguments in order and returns the current value of the first 
--expression that initially does not evaluate to NULL
SELECT COALESCE(NULL, NULL, 'third_value', 'fourth_value');  -- third_value

--OFFSET & FETCH – get only specific rows from the result set (skip & take)
SELECT EmployeeID, FirstName, LastName
    FROM Employees
ORDER BY EmployeeID
  OFFSET 10 ROWS
   FETCH NEXT 5 ROWS ONLY

--ROW_NUMBER – always generate unique values without any   gaps, even if there are ties
--RANK – can have gaps in its sequence and when values are the same, they get the same rank
--DENSE_RANK – returns the same rank for ties, but it doesn’t have any gaps in the sequence

		--Using WHERE … LIKE (REGEX simmular)
--Wildcards are used with WHERE for partial filtration
--Similar to Regular Expressions, but less capable
--Example: Find all employees who's first name starts with "Ro"
SELECT EmployeeID, FirstName, LastName
  FROM Employees
 WHERE FirstName LIKE 'Ro%'
	-- %    -- any string, including zero-length
	--_    -- any single character
	--[…]  -- any character within range
	--[^…] -- any character not in the range

--ESCAPE – specify a prefix to treat special characters as normal
SELECT ID, Name
  FROM Tracks
 WHERE Name LIKE '%max!%' ESCAPE '!'


--IF
DECLARE @a int = 45, @b int = 40;  
SELECT IIF ( @a > @b, 'TRUE', 'FALSE' ) AS Result;

--Examples
SELECT Id, SQRT(SQUARE(X1-X2) + SQUARE(Y1-Y2)) AS Length FROM Lines
SELECT
  CEILING(
    CEILING(
      CAST(Quantity AS float) / 
      BoxCapacity) / PalletCapacity)
    AS [Number of pallets]
  FROM Products




