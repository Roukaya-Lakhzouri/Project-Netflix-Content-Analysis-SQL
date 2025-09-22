-- Netflix Project 
DROP TABLE IF EXISTS netflix; 
CREATE TABLE  netflix
(
	show_id VARCHAR(50),
	type VARCHAR(10),
	title VARCHAR(150), 
	director VARCHAR(250),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(90),
	description VARCHAR(250)

);

SELECT * FROM netflix; 

SELECT 
	count(*) as total_content 
FROM netflix; 

-- HOW MANY DIFFRENT TYPES OF CONTENT 
SELECT
	DISTINCT(type) as nbr_type_content
FROM netflix

-- 1. Count the number of Movies vs TV Shows
-- Proposition 1 
SELECT count(*) as nbr_movies
FROM netflix 
where type = 'Movie';

SELECT count(*) as nbr_TV_Show
FROM netflix 
where type = 'TV Show'

-- Proposition 2 
SELECT type , count(*) as nbr_of_content 
From netflix 
GROUP BY type ;

-- 2. Find the most common rating for movies and TV shows 
SELECT type , rating 
from (
	SELECT  type  , rating ,count(*) ,RANK() over (PARTITION BY type ORDER BY count(*) DESC) AS ranking
	FROM netflix
	GROUP BY type, rating
)
WHERE ranking= 1
 

--3. List all movies released in a specific year (e.g., 2020)
SELECT * 
FROM netflix 
WHERE type= 'Movie' and release_year= 2020

-- 4. Find the top 5 countries with the most content on Netflix
SELECT UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,  count(*) as nbr_content
FROM netflix 
GROUP BY new_country
ORDER BY nbr_content DESC
LIMIT 5
---5. Identify the longest movie
SELECT DISTINCT(STRING_TO_ARRAY(duration,' '))[1] ::INT as duration_in_minutes ,*
FROM netflix 
WHERE type= 'Movie' and duration is NOT NULL 
ORDER BY duration_in_minutes DESC
limit 1
-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM 
(
	SELECT *,UNNEST(STRING_TO_ARRAY(director,',')) as new_director
	FROM netflix
)
WHERE new_director = 'Rajiv Chilaka'
--8. List all TV shows with more than 5 seasons
SELECT * 
FROM 
(
	SELECT *,(STRING_TO_ARRAY(duration,' '))[1] as duration_in_season
	FROM netflix
	WHERE type='TV Show's
)
WHERE duration_in_season:: INT > 5
-- 9. Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1


-- 10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5
