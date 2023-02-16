select * from athletes_event_results;

Select ID,Name as 'Competitor Name'-- Renamed Column
,CASE WHEN Sex = 'M' THEN 'Male' ELSE 'Female' END AS Sex --  Better name for filters and visualisations
, Age
,CASE	WHEN Age < 18 THEN 'Under 18'
		WHEN Age BETWEEN 18 and 25 THEN '18-25'
		WHEN Age BETWEEN 25 AND 30 THEN '25-30'
		WHEN Age > 30 THEN 'Over 30'
END AS [Age Grouping]
, Height, Weight
,NOC as 'Nation Code' -- Explaining abbreviation
, LEFT(Games, CHARINDEX(' ',Games) -1) AS 'Year'
,-- RIGHT(Games, CHARINDEX(' ', REVERSE(Games)) - 1) AS 'Season' 
 Sport, Event
, CASE WHEN Medal = 'NA' THEN 'Not Registered' ELSE Medal END AS Medal
from Olympic_Games.dbo.athletes_event_results
WHERE RIGHT(Games, CHARINDEX(' ', REVERSE(Games)) - 1) = 'Summer';
