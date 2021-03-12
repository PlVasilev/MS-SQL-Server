

CREATE TABLE Students(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
MiddleName NVARCHAR(25),
LastName NVARCHAR(30) NOT NULL,
Age INT CHECK(Age BETWEEN 5 AND 100) NOT NULL,
[Address] NVARCHAR(50),
Phone NCHAR(10)
)

CREATE TABLE Subjects(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL,
Lessons INT CHECK(Lessons > 0) NOT NULL
)

CREATE TABLE StudentsSubjects(
Id INT PRIMARY KEY IDENTITY,
StudentId  INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
SubjectId  INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
Grade DECIMAL(15,2) CHECK(Grade BETWEEN 2 AND 6) NOT NULL
)

CREATE TABLE Exams(
Id INT PRIMARY KEY IDENTITY,
[Date] DATETIME, 
SubjectId  INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsExams (
StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
ExamId INT FOREIGN KEY REFERENCES Exams(Id) NOT NULL,
Grade DECIMAL(15,2) CHECK(Grade BETWEEN 2 AND 6) NOT NULL
PRIMARY KEY (StudentId,ExamId)
)

CREATE TABLE Teachers(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(20) NOT NULL,
LastName NVARCHAR(20) NOT NULL,
[Address] NVARCHAR(20) NOT NULL,
Phone CHAR(10),
SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsTeachers(
StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
TeacherId INT FOREIGN KEY REFERENCES Teachers(Id) NOT NULL
PRIMARY KEY (StudentId,TeacherId)
)

INSERT INTO Teachers(FirstName,	LastName,	Address,	Phone,	SubjectId)
VALUES
('Ruthanne',	'Bamb',	'84948 Mesta Junction',	3105500146,	6),
('Gerrard',	'Lowin',	'370 Talisman Plaza',	3324874824,	2),
('Merrile',	'Lambdin',	'81 Dahle Plaza',	4373065154,	5),
('Bert',	'Ivie',	'2 Gateway Circle',	4409584510,	4)
INSERT INTO Subjects(Name,	Lessons)
VALUES
('Geometry',	12),
('Health',	10),
('Drama',		7),
('Sports',	9)

UPDATE StudentsSubjects SET Grade = 6.00 WHERE Grade >=5.50 AND SubjectId IN (1,2)


SELECT id FROM Teachers WHERE Phone LIKE '%72%'
DELETE FROM StudentsTeachers WHERE TeacherId IN (7,12,15,18,24,26)	
DELETE FROM Teachers WHERE Phone LIKE '%72%'

SELECT FirstName,LastName, Age FROM Students WHERE Age >=12 ORDER BY FirstName ASC, LastName ASC

--6
SELECT CONCAT(FirstName + ' ', ISNULL(MiddleName + ' ', ' '), LastName) AS [Full Name]
, Address
FROM Students	
WHERE [Address] LIKE '%road%'
ORDER BY FirstName ASC,LastName ASC, Address ASC

--7
SELECT FirstName,Address,Phone FROM Students 
WHERE MiddleName IS NOT NULL AND Phone LIKE '42%'
ORDER BY FirstName ASC

--8
SELECT s.FirstName,s.LastName, COUNT(st.TeacherId) AS TeachersCount FROM Students AS s
JOIN StudentsTeachers AS st ON s.Id = st.StudentId
GROUP BY  s.FirstName,s.LastName

--9
SELECT t.FirstName + ' ' + t.LastName AS FullName
, CONCAT(s.Name, '-', s.Lessons) AS Subjects
, COUNT(st.StudentId) AS Students
FROM Teachers AS t
JOIN Subjects AS s ON t.SubjectId = s.Id
JOIN StudentsTeachers AS st ON t.Id = st.TeacherId
GROUP BY t.FirstName,t.LastName,s.Name,s.Lessons
ORDER BY Students DESC

--10
SELECT FirstName + ' ' + LastName AS [Full Name]
FROM Students AS s
LEFT JOIN StudentsExams AS st ON s.Id =st.StudentId
WHERE st.StudentId IS NULL
ORDER BY FirstName

--11
SELECT TOP(10) t.FirstName,t.LastName, COUNT(st.StudentId) AS StudentsCount FROM Teachers AS t
JOIN StudentsTeachers AS st ON t.Id = st.TeacherId
GROUP BY t.FirstName,t.LastName
ORDER BY StudentsCount DESC, FirstName ASC, LastName ASC

--12
SELECT TOP(10) FirstName,LastName, CAST(AVG(Grade) AS decimal(15,2) ) AS Grade FROM Students AS s
JOIN StudentsExams AS se ON s.Id = se.StudentId
GROUP BY FirstName,LastName
ORDER BY Grade DESC, FirstName ASC, LastName ASC

--13
SELECT r.FirstName,r.LastName,r.Grade FROM(
SELECT s.FirstName,s.LastName
, Grade
,ROW_NUMBER() OVER (PARTITION BY s.Id ORDER BY Grade DESC) AS RowNmber
 FROM Students AS s
 JOIN StudentsSubjects AS se ON s.Id = se.StudentId
) AS r
WHERE r.RowNmber = 2
ORDER BY r.FirstName ASC, LastName ASC

--14
SELECT CONCAT(s.FirstName + ' ',ISNULL(MiddleName + ' ' ,''), LastName) AS [Full Name]
 FROM Students AS s
LEFT JOIN StudentsSubjects AS ss ON s.Id = ss.StudentId
WHERE ss.Id IS NULL
ORDER BY [Full Name]

--15
SELECT * FROM (
SELECT t.FirstName + ' ' + t.LastName AS [Teacher Full Name]
, sub.Name AS [Subject Name]
, s.FirstName + ' ' + s.LastName AS [Student Full Name]
, AVG(ss.Grade) AS [Grade]
, ROW_NUMBER() OVER (PARTITION BY t.id ORDER BY AVG(ss.Grade) DESC) AS RowNumber
FROM Teachers AS t
JOIN Subjects as sub ON t.Id = sub.Id
JOIN StudentsTeachers AS st ON t.Id = st.TeacherId
JOIN Students AS s ON st.StudentId = s.Id
JOIN StudentsSubjects AS ss ON s.Id = ss.StudentId
GROUP BY t.FirstName, t.LastName, sub.Name,s.FirstName,s.LastName,t.Id
) AS r
WHERE r.RowNumber = 1

--16
SELECT s.Name,AVG(ss.Grade) FROM Subjects AS s
JOIN StudentsSubjects AS ss ON s.Id = ss.SubjectId
GROUP BY s.Name, s.Id
ORDER BY s.Id

--17
SELECT
CASE
WHEN r.qurter IS NULL THEN 'TBA'
ELSE CONCAT('Q', r.qurter)
END 'Quarter',
	r.Name,
	 SUM(sCount) AS StudentsCount
	  FROM (
SELECT 
	DATEPART(QUARTER, e.Date) AS qurter
	,s.Name
	, COUNT (se.StudentId) AS sCount
	FROM Exams AS e
JOIN StudentsExams AS se ON e.Id = se.ExamId
JOIN Subjects AS s ON e.SubjectId = s.Id
WHERE se.Grade >= 4.00
GROUP BY Date,s.Name,se.Grade) AS r
GROUP BY r.qurter,r.Name
ORDER BY [Quarter] ASC, r.Name ASC

--18
CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(15,2))
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @currentStudentID INT = (SELECT Id FROM Students WHERE Id = @studentId)
	IF(@currentStudentID IS NULL) 
	BEGIN
	 RETURN 'The student with provided id does not exist in the school!'
	END
	IF(@grade > 6.00)
		BEGIN
	 RETURN 'Grade cannot be above 6.00!'
	END 
	DECLARE @countOfGrades INT = (
	SELECT COUNT(StudentId) FROM StudentsExams 
	WHERE StudentId = @studentId AND Grade BETWEEN @grade AND @grade + 0.50)
	DECLARE @studentFirstName NVARCHAR(30) = (
	SELECT FirstName FROM Students WHERE Id = @studentId
	)
	RETURN CONCAT('You have to update ',@countOfGrades,' grades for the student ',@studentFirstName)
END

SELECT dbo.udf_ExamGradesToUpdate(12, 6.20)
SELECT dbo.udf_ExamGradesToUpdate(121, 5.50)
SELECT dbo.udf_ExamGradesToUpdate(12, 5.50)

--19
CREATE PROCEDURE usp_ExcludeFromSchool(@StudentId INT)
AS
BEGIN
	DECLARE @currentStudentID INT = (SELECT id FROM Students WHERE id = @StudentId) 
	IF (@currentStudentID IS NULL)
	BEGIN
	RAISERROR('This school has no student with the provided id!',16,1)
	RETURN
	END
	DELETE FROM StudentsTeachers WHERE StudentId = @currentStudentID
	DELETE FROM StudentsSubjects WHERE StudentId = @currentStudentID
	DELETE FROM StudentsExams WHERE StudentId = @currentStudentID
	DELETE FROM Students WHERE Id = @currentStudentID
END

EXEC usp_ExcludeFromSchool 1
SELECT COUNT(*) FROM Students

--20
CREATE TRIGGER t_ExcludedStudents
    ON Students AFTER DELETE
    AS
    BEGIN
	  INSERT INTO ExcludedStudents (StudentId, StudentName)
	  SELECT d.Id, d.FirstName+ ' ' + LastName
	    FROM deleted AS d
    END

--15 AS
SELECT
    [Teacher FULL Name], [Subject Name], [Student FULL Name], CAST(Grade AS NUMERIC(10, 2)) AS Grade
    FROM(
SELECT 
	 CONCAT(t.FirstName, ' ', t.LastName) AS [Teacher FULL Name],
	 sb.[Name] AS [Subject Name],
	 CONCAT(s.FirstName, ' ', s.LastName) AS [Student FULL Name],
	 AVG(ss.Grade) AS Grade,
	 ROW_NUMBER() OVER (PARTITION BY t.FirstName, t.LastName ORDER BY AVG(ss.Grade) DESC) AS [Rank]
    FROM Students AS s
    JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id
    JOIN StudentsTeachers AS st ON st.StudentId = s.Id
    JOIN Teachers AS t ON t.Id = st.TeacherId
    JOIN Subjects AS sb ON sb.Id = t.SubjectId
    WHERE t.SubjectId = ss.SubjectId
    GROUP BY s.Id, s.FirstName, s.LastName, t.FirstName, t.LastName, sb.[Name]
    ) AS t
    WHERE [Rank] = 1
ORDER BY [Subject Name], [Teacher FULL Name], Grade DESC