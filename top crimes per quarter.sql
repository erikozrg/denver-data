WITH CRIMERANKING AS 
(
SELECT ISNULL(district_id,'OFFENCE_TOTAL') district_id,
       ISNULL(offense_category_id,'district_TOTAL') offense_category_id,
	   DATEPART(QUARTER,first_occurrence_date) AS season,
       COUNT(*) AS crime_count,
	   SUM(COUNT(*)) OVER (PARTITION BY district_id,DATEPART(QUARTER,first_occurrence_date)) AS total_crimes_in_district_Q,
	   RANK() OVER (
		PARTITION BY DISTRICT_ID,DATEPART(QUARTER,first_occurrence_date)
		ORDER BY COUNT(*) DESC) as crimerank
FROM crimesclean
WHERE district_id IS NOT NULL AND district_id != 'U'
GROUP BY district_id, offense_category_id,DATEPART(QUARTER,first_occurrence_date)
HAVING NOT (district_id IS NULL AND offense_category_id IS NULL)
)

SELECT district_id,
offense_category_id,
season,
crime_count,
CAST(ROUND((crime_count * 100.0 / total_crimes_in_district_Q), 2) AS DECIMAL(5,2)) AS percent_of_total_district_Q

FROM CRIMERANKING
WHERE crimerank <=3