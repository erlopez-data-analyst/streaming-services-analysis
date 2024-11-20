-- Identifying CSV Files Import Successfully --
SELECT TOP 20 * FROM Amazon_Prime_Dataset;
SELECT TOP 20 * FROM Apple_TV_Dataset;
SELECT TOP 20 * FROM HBO_Max_Dataset;
SELECT TOP 20 * FROM Hulu_Dataset;
SELECT TOP 20 * FROM Netflix_Dataset;

SELECT COUNT(*) FROM Amazon_Prime_Dataset;
SELECT COUNT(*) FROM Apple_TV_Dataset;
SELECT COUNT(*) FROM HBO_Max_Dataset;
SELECT COUNT(*) FROM Hulu_Dataset;
SELECT COUNT(*) FROM Netflix_Dataset;

-- Adding Platform Column to Each Table --
ALTER TABLE Amazon_Prime_Dataset ADD platform VARCHAR(50);
ALTER TABLE Apple_TV_Dataset ADD platform VARCHAR(50);
ALTER TABLE HBO_Max_Dataset ADD platform VARCHAR(50);
ALTER TABLE Hulu_Dataset ADD platform VARCHAR(50);
ALTER TABLE Netflix_Dataset ADD platform VARCHAR(50);

-- Putting Values Into Platform Column --
UPDATE Amazon_Prime_Dataset SET platform = 'Amazon Prime';
UPDATE Apple_TV_Dataset SET platform = 'Apple TV';
UPDATE HBO_Max_Dataset SET platform = 'HBO Max';
UPDATE Hulu_Dataset SET platform = 'Hulu';
UPDATE Netflix_Dataset SET platform = 'Netflix';

-- Create Combined View of Datasets --
CREATE VIEW All_Dataset AS
SELECT * FROM Amazon_Prime_Dataset
UNION ALL
SELECT * FROM Apple_TV_Dataset
UNION ALL
SELECT * FROM HBO_Max_Dataset
UNION ALL
SELECT * FROM Hulu_Dataset
UNION ALL
SELECT * FROM Netflix_Dataset;

SELECT * FROM All_Dataset;

-- IDENTIFYING PATTERNS & TRENDS --
-- Popular Genres --
SELECT genres, COUNT(*) AS 'COUNT'
FROM (
	SELECT genres FROM Amazon_Prime_Dataset
	UNION ALL
	SELECT genres FROM Apple_TV_Dataset
	UNION ALL
	SELECT genres FROM HBO_Max_Dataset
	UNION ALL
	SELECT genres FROM Hulu_Dataset
	UNION ALL
	SELECT genres FROM Netflix_Dataset
) AS AllDatasets
GROUP BY genres
ORDER BY 'count' DESC;

-- Highest Rating Content --
SELECT title, platform, imdbAverageRating
FROM (
	SELECT title, 'Amazon Prime' AS platform, imdbAverageRating FROM Amazon_Prime_Dataset
	UNION ALL
	SELECT title, 'Apple TV' AS platform, imdbAverageRating FROM Apple_TV_Dataset
	UNION ALL
	SELECT title, 'HBO Max' AS platform, imdbAverageRating FROM HBO_Max_Dataset
	UNION ALL
	SELECT title, 'Hulu' AS platform, imdbAverageRating FROM Hulu_Dataset
	UNION ALL
	SELECT title, 'Netflix' AS platform, imdbAverageRating FROM Netflix_Dataset
) AS AllDatasets
ORDER BY imdbAverageRating DESC;

-- Platform Distribution --
SELECT platform, COUNT(*) AS title_count
FROM All_Dataset
GROUP BY platform
ORDER BY title_count DESC;

-- Yearly Trends --
SELECT releaseYear, COUNT(*) AS title_count
FROM All_Dataset
GROUP BY releaseYear
ORDER BY releaseYear DESC;

SELECT (releaseYear/10) * 10 AS period_start, genres, COUNT(*) AS genre_count
FROM All_Dataset
GROUP BY (releaseYear/10) * 10, genres
ORDER BY period_start, genre_count DESC;

-- Popular Genres in the Last 10 Years --
SELECT genres, COUNT(*) AS genre_count
FROM All_Dataset
WHERE releaseYear >= Year(GETDATe()) - 10
GROUP BY genres
ORDER BY genre_count DESC;

-- Popular Titles in the Last 10 Years --
SELECT title, COUNT(*) AS title_count
FROM All_Dataset
WHERE releaseYear >= YEAR(GETDATE()) - 10
GROUP BY title
ORDER BY title_count DESC;

-- Popular Titles by Number of Votes in the Last 10 Years --
SELECT title, genres, platform, SUM(imdbNumVotes) AS total_votes
FROM All_Dataset
WHERE releaseYear >= YEAR(GETDATE()) - 10
GROUP BY title, genres, platform
ORDER BY total_votes DESC;

-- Popular Titles Between Specific Years --
SELECT title, genres, platform, SUM(imdbNumVotes) AS total_votes
FROM All_Dataset
WHERE releaseYear BETWEEN 2011 AND 2024
GROUP BY title, genres, platform
ORDER BY total_votes DESC;

SELECT title, genres, platform, SUM(imdbNumVotes) AS total_votes
FROM All_Dataset
WHERE releaseYear BETWEEN 2000 AND 2010
GROUP BY title, genres, platform
ORDER BY total_votes DESC;

SELECT title, genres, platform, SUM(imdbNumVotes) AS total_votes
FROM All_Dataset
WHERE releaseYear BETWEEN 1990 AND 1999
GROUP BY title, genres, platform
ORDER BY total_votes DESC;

-- Popular Content Between Generations --
-- Gen-Alpha (2010-2024), Gen-Z(1997-2012), Millennials(1981-1996), Gen-X(1965-1980) --
SELECT title, genres, platform, SUM(imdbNumVotes) AS total_votes, SUM(imdbAverageRating) AS total_ratings
FROM All_Dataset
WHERE releaseYear BETWEEN 2010 AND 2024
GROUP BY title, genres, platform
ORDER BY total_votes DESC;

SELECT title, genres, platform, SUM(imdbNumVotes) AS total_votes, SUM(imdbAverageRating) AS total_ratings
FROM All_Dataset
WHERE releaseYear BETWEEN 1997 AND 2012
GROUP BY title, genres, platform
ORDER BY total_votes DESC;

SELECT title, genres, platform, SUM(imdbNumVotes) AS total_votes, SUM(imdbAverageRating) AS total_ratings
FROM All_Dataset
WHERE releaseYear BETWEEN 1981 AND 1996
GROUP BY title, genres, platform
ORDER BY total_votes DESC;

SELECT title, genres, platform, SUM(imdbNumVotes) AS total_votes, SUM(imdbAverageRating) AS total_ratings
FROM All_Dataset
WHERE releaseYear BETWEEN 1965 AND 1980
GROUP BY title, genres, platform
ORDER BY total_votes DESC;

-- Rating Distribution by Genres --
SELECT genres, ROUND(AVG(imdbAverageRating), 1) AS avg_rating
FROM All_Dataset
GROUP BY genres
ORDER BY avg_rating DESC;

-- Rating Distribution by Platform --
SELECT platform, ROUND(AVG(imdbAverageRating), 1) AS avg_rating
FROM All_Dataset
GROUP BY platform
ORDER BY avg_rating DESC;

-- AUDIENCE ENGAGEMENT --
--Number of Votes by Genre & Platform --
SELECT genres, platform, SUM(imdbNumVotes) AS total_votes
FROM All_Dataset
GROUP BY genres, platform
ORDER BY total_votes DESC;

 -- Number of Votes by Title, Genre, & Platform --
SELECT TOP 20 title, genres, platform, sum(imdbNumVotes) AS popular_titles
FROM All_Dataset
GROUP BY title, genres, platform
ORDER BY popular_titles DESC;

 -- Available Country Count --
SELECT availableCountries, COUNT(*) AS title_count
FROM All_Dataset
GROUP BY availableCountries
ORDER BY title_count DESC;

 -- Available Country by Title & Genres --
SELECT title, genres, availableCountries, COUNT(*) AS title_count
FROM All_Dataset
GROUP BY title, genres, availableCountries
ORDER BY title_count DESC;

 -- Popular Genres by Countries --
SELECT availableCountries, genres, COUNT(*) AS genres_count
FROM All_Dataset
GROUP BY availableCountries, genres
ORDER BY genres_count DESC;

 -- Popular Titles by Countries --
SELECT availableCountries, title, SUM(imdbNumVotes) AS num_votes
FROM All_Dataset
GROUP BY availableCountries, title
ORDER BY num_votes DESC;

 -- Tremds in Genre Popularity Over Time by Country --
SELECT availableCountries, genres, releaseYear, COUNT(*) AS genres_count
FROM All_Dataset
GROUP BY availableCountries, genres, releaseYear
ORDER BY genres_count DESC;

 -- Pivot Table Identify the Number of Titles for Each Genre on Each Platform --
SELECT platform,
	COUNT(CASE WHEN genres LIKE '%Drama%' THEN 1 END) AS Drama_Count,
	COUNT(CASE WHEN genres LIKE '%Comedy%' THEN 1 END) AS Comedy_Count,
	COUNT(CASE WHEN genres LIKE '%Horror%' THEN 1 END) AS Horror_Count,
	COUNT(CASE WHEN genres LIKE '%Action%' THEN 1 END) AS Action_Count,
	COUNT(CASE WHEN genres LIKE '%Adventure%' THEN 1 END) AS Adventure_Count,
	COUNT(CASE WHEN genres LIKE '%Romance%' THEN 1 END) AS Romance_Count,
	COUNT(CASE WHEN genres LIKE '%Animation%' THEN 1 END) AS Animation_Count,
	COUNT(CASE WHEN genres LIKE '%Biography%' THEN 1 END) AS Biography_Count,
	COUNT(CASE WHEN genres LIKE '%Comedy%' THEN 1 END) AS Comedy_Count,
	COUNT(CASE WHEN genres LIKE '%Music%' THEN 1 END) AS Music_Count,
	COUNT(CASE WHEN genres LIKE '%Musical%' THEN 1 END) AS Musical_Count,
	COUNT(CASE WHEN genres LIKE '%Mystery%' THEN 1 END) AS Mystery_Count,
	COUNT(CASE WHEN genres LIKE '%Crime%' THEN 1 END) AS Crime_Count,
	COUNT(CASE WHEN genres LIKE '%Documentary%' THEN 1 END) AS Documentary_Count,
	COUNT(CASE WHEN genres LIKE '%Reality-TV%' THEN 1 END) AS RealityTV_Count,
	COUNT(CASE WHEN genres LIKE '%Family%' THEN 1 END) AS Family_Count,
	COUNT(CASE WHEN genres LIKE '%Sci-Fi%' THEN 1 END) AS SciFi_Count,
	COUNT(CASE WHEN genres LIKE '%Thriller%' THEN 1 END) AS Thriller_Count,
	COUNT(CASE WHEN genres LIKE '%Talk-Show%' THEN 1 END) AS TalkShow_Count,
	COUNT(CASE WHEN genres LIKE '%War%' THEN 1 END) AS War_Count,
	COUNT(CASE WHEN genres LIKE '%Western%' THEN 1 END) AS Western_Count
FROM All_Dataset
GROUP BY platform;