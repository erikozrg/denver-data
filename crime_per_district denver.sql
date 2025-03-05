WITH CrimeRanking as (
SELECT 
    offense_category_id,
	DISTRICT_ID,
    COUNT(*) AS crime_count,
	SUM(COUNT(*)) OVER (PARTITION BY district_id) AS total_crimes_in_district,
	RANK() OVER (
	PARTITION BY DISTRICT_ID
	ORDER BY COUNT(*) DESC) as crimerank
FROM crimesclean
WHERE district_id IS NOT NULL AND district_id != 'U'
GROUP BY offense_category_id, DISTRICT_ID
)
SELECT district_id,
offense_category_id,
crime_count,
CAST(ROUND((crime_count * 100.0 / total_crimes_in_district), 2) AS DECIMAL(5,2)) AS percent_of_total_district

FROM CrimeRanking
WHERE crimerank <=3