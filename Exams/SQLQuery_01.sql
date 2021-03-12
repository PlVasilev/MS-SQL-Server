SELECT f.[Teacher Full Name],f.[Subject Name],f.[Student Full Name],f.Grade FROM
(
SELECT
r.FirstName + ' ' + r.LastName AS [Teacher Full Name] ,
r.Name AS [Subject Name],
r.StFN + ' ' + r.StLN AS [Student Full Name],
CAST(r.Grade AS decimal(15,2)) Grade,
ROW_NUMBER() OVER(PARTITION BY r.id ORDER BY r.Grade DESC) AS fRN
 FROM (
SELECT t.Id,t.FirstName,t.LastName,sub.id AS subID, sub.Name,ss.StudentId,s.id AS StID,s.FirstName AS StFN,s.LastName AS StLN, 
AVG(ss.Grade) AS Grade,
ROW_NUMBER() OVER (PARTITION BY s.id ORDER BY AVG(ss.Grade) DESC) AS RowNUMBER
FROM Teachers AS t
JOIN Subjects AS sub ON t.SubjectId = sub.Id
JOIN StudentsSubjects AS ss ON sub.Id = ss.SubjectId
JOIN Students AS s ON ss.StudentId = s.Id
GROUP BY t.Id,t.FirstName,sub.Name,ss.StudentId,s.FirstName,t.LastName,s.LastName,s.id,sub.id
) AS r
WHERE r.RowNUMBER = 1
) AS f
WHERE f.fRN = 1
ORDER BY f.[Subject Name] ASC, f.[Teacher Full Name] ASC, f.Grade DESC

