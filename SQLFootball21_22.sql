
--This Query shows the name of and number of goals scored by the top scorer in each league of the 21-22 Season


SELECT p.Comp, p.Player, p.Nation, ROUND(p.Goals*[90s], 0) AS Goals_Scored
FROM [EuropeanFootball21-22].dbo.['2021-2022 Football Player Stats$'] p
INNER JOIN (
    SELECT Comp, MAX(ROUND(Goals*[90s], 0)) AS max_goals_scored
    FROM [EuropeanFootball21-22].dbo.['2021-2022 Football Player Stats$']
    GROUP BY Comp
) AS max_goals ON p.Comp = max_goals.Comp AND ROUND(p.Goals*[90s], 0) = max_goals.max_goals_scored
ORDER BY 3 DESC



--This Query shows the 3 players that played the most minutes per position across all leagues

SELECT  Comp, Squad, Pos, Player, Age, MP, Min
FROM (
    SELECT Comp, Squad, Pos, Player, Age,  MP, Min,
           DENSE_RANK() OVER (PARTITION BY Pos ORDER BY Min DESC) AS minutes_rank
    FROM [EuropeanFootball21-22].dbo.['2021-2022 Football Player Stats$']
	WHERE Pos IN ('DF', 'MF', 'FW')
) AS ranked_players
WHERE minutes_rank = 1




-- This Query Compares the Pts Per game as well as goal differences of the Top 3 teams from each league


SELECT Country, Squad, [Pts/G], MP, Round((W/MP)*100, 2) AS WinPercentage, Pts ,GF, GA, GD
FROM [EuropeanFootball21-22]..['2021-2022 Football Team Stats$']
Where LgRk IN (1, 2, 3)




--This Query shows the winning team per league and thier key players


SELECT Country, Squad, [Top Team Scorer], Goalkeeper
FROM [EuropeanFootball21-22]..['2021-2022 Football Team Stats$']
Where LgRk = 1;
