-- Hacker rank Symmetric Pairs
select distinct F1.X, F1.Y --, F2.X, F2.Y , F1.RowNum, F2.RowNum
from (select *, ROW_NUMBER() OVER (order by X) As RowNum from Functions) F1 
inner join (select *, ROW_NUMBER() OVER (order by X) As RowNum from Functions) F2 
on F1.X = F2.Y and F1.Y = F2.X and F1.X <= F1.Y and F1.RowNum <> F2.RowNum order by F1.X


-- Hacker rank INTERVIEWs
select con.Contest_Id, con.Hacker_id, con.Name, x.TSub, x.TASub, x.TV, x.TUV from Contests Con 
	inner join ( select T1.Contest_Id, 
					    isnull(T1.TSub,0) as TSub, 
					    isnull(T1.TASub,0) as TASub, 
					    isnull(T2.TV,0) as TV, 
					    isnull(T2.TUV,0) as TUV 
						from ( select Col.Contest_Id, 
							  TSub = Sum(Ss.Total_Submissions), 
							  TASub = Sum(Ss.Total_Accepted_Submissions) 
								 from Colleges Col 
									inner join Challenges Ch on col.College_Id = ch.College_Id
									left outer join Submission_Stats Ss on ch.Challenge_Id = Ss.Challenge_Id
										group by Col.Contest_Id) T1 --order by 1,2
					inner join (select Col.Contest_Id, 
							  TV = Sum(Vs.Total_Views), 
							  TUV=Sum(Vs.Total_Unique_Views) 
							  	  from Colleges Col 
							  	  	 inner join Challenges Ch on col.College_Id = ch.College_Id
							  	  	 left join View_Stats Vs on ch.Challenge_Id = Vs.Challenge_Id
							  	  		group by Col.Contest_Id) T2 --order by 1,2
	on T1.Contest_Id = T2.Contest_Id) x
on x.Contest_Id = Con.Contest_Id 