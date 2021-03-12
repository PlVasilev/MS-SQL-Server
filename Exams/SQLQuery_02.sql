SELECT t.FirstName+ ' '+ t.LastName AS [Teacher Full Name],
r.Name AS [Subject Name],
r.FirstName + ' ' + r.LastName AS [Student Full Name],
ROW_NUMBER() OVER (PARTITION BY t.I)
 FROM (
SELECT s.Id,s.FirstName,s.LastName,sub.Name, sub.Id AS SubId,
AVG(Grade) AS Grade,
ROW_NUMBER () OVER (PARTITION BY s.ID ORDER BY AVG(Grade) DESC)  AS RowNumber
FROM StudentsSubjects AS ss
JOIN Subjects AS sub ON ss.SubjectId = sub.Id
JOIN Students AS s ON ss.StudentId = s.Id
GROUP BY s.Id,s.FirstName,s.LastName,sub.Name,sub.Id
) AS r 
JOIN StudentsTeachers AS st ON r.Id = st.StudentId
JOIN Teachers AS t ON st.TeacherId = t.Id
WHERE r.RowNumber = 1
ORDER BY st.TeacherId




