--Which manufacturer's planes had most no of flights? And how many flights?
;WITH CTE AS(
	SELECT T1.flight, T2.manufacturer
	FROM flights T1
	INNER JOIN planes T2
	ON CAST(T1.tailnum AS VARCHAR(MAX)) = CAST(T2.tailnum AS VARCHAR(MAX))
)
SELECT TOP 1 CAST(manufacturer AS VARCHAR(MAX)) AS manufacturer, 
SUM(flight) AS total_flight FROM CTE
GROUP BY CAST(manufacturer AS VARCHAR(MAX))
ORDER BY total_flight DESC

--Which manufacturer's planes had most no of flying hours? And how many hours?
;WITH CTE AS(
	SELECT CAST(T2.manufacturer AS VARCHAR(MAX)) AS manufacturer, 
	SUM(CAST(LTRIM(RTRIM(CAST(T1.air_time AS VARCHAR(MAX)))) AS FLOAT)) AS flying_time
	FROM flights T1
	INNER JOIN planes T2
	ON CAST(T1.tailnum AS VARCHAR(MAX)) = CAST(T2.tailnum AS VARCHAR(MAX))
	GROUP BY CAST(T2.manufacturer AS VARCHAR(MAX))
)
SELECT TOP 1 manufacturer, round(flying_time/60, 2) AS flying_time_in_hr FROM CTE
ORDER BY flying_time DESC

--Which plane flew the most number of hours? And how many hours?
SELECT TOP 1 CAST(tailnum AS VARCHAR(MAX)) AS tailnum, 
	ROUND(SUM(CAST(CAST(air_time AS VARCHAR(MAX))AS FLOAT))/60, 2) AS flying_time_hr
FROM flights
GROUP BY CAST(tailnum AS VARCHAR(MAX))
ORDER BY SUM(CAST(CAST(air_time AS VARCHAR(MAX))AS INT)) DESC

--Which destination had most delay in flights?
WITH CTE AS(
	SELECT 
	CAST(dest AS VARCHAR(MAX)) AS dest, 
	SUM(CAST(CAST(dep_delay AS VARCHAR(MAX))AS FLOAT) + CAST(CAST(arr_delay AS VARCHAR(MAX))AS FLOAT)) AS total_delay
	FROM flights
	GROUP BY CAST(dest AS VARCHAR(MAX))
)
SELECT TOP 1 *, ROUND(total_delay/60, 2) as total_delay_hr FROM CTE 
ORDER BY total_delay DESC

--Which manufactures planes had covered most distance? And how much distance?
SELECT TOP 1
	CAST(T2.manufacturer AS VARCHAR(MAX)) AS manufacturer, 
	SUM(CAST(CAST(T1.distance AS VARCHAR(MAX))AS INT)) AS total_distance
FROM flights T1
INNER JOIN planes T2
ON CAST(T1.tailnum AS VARCHAR(MAX)) = CAST(T2.tailnum AS VARCHAR(MAX))
GROUP BY CAST(T2.manufacturer AS VARCHAR(MAX))
ORDER BY SUM(CAST(CAST(T1.distance AS VARCHAR(MAX))AS INT)) DESC

--Which airport had most flights on weekends
;WITH WeekendFlights AS (
SELECT
    CAST(f.origin AS VARCHAR(MAX)) AS origin,
    CAST(f.year AS VARCHAR(MAX)) AS year,
    CAST(f.month AS VARCHAR(MAX)) AS month,
    CAST(f.day AS VARCHAR(MAX)) AS day,
    COUNT(*) AS weekend_flight_count
FROM
    flights f
WHERE
    DATEPART(WEEKDAY, CAST(f.year AS VARCHAR(MAX)) + '-' + 
    CAST(f.month AS VARCHAR(MAX)) + '-' + 
    CAST(f.day AS VARCHAR(MAX))) IN (1, 7)
	AND CAST(f.year AS INT) = 2013 
GROUP BY
    CAST(f.origin AS VARCHAR(MAX)),
    CAST(f.year AS VARCHAR(MAX)),
    CAST(f.month AS VARCHAR(MAX)),
    CAST(f.day AS VARCHAR(MAX))
)
SELECT TOP 1
    CAST(a.AIRPORT AS VARCHAR(MAX)) AS airport,
    SUM(wf.weekend_flight_count) AS total_weekend_flights
FROM WeekendFlights wf
JOIN airports a ON CAST(wf.origin AS VARCHAR(MAX)) = CAST(a.IATA_CODE AS VARCHAR(MAX))
GROUP BY CAST(a.AIRPORT AS VARCHAR(MAX))
ORDER BY total_weekend_flights DESC;