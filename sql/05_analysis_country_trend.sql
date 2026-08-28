-- 05_analysis_country_trend.sql
-- Analysis: Country-level content production trends on Netflix.
-- The `country` column contains comma-separated multi-country values
-- (e.g. "United States, Canada"), so we split and unnest it to count
-- each country's contribution separately. A title with 2 countries
-- listed counts once toward each country.

-- Step 1: Country ranking by total content count
SELECT
  TRIM(country_split) AS country,
  COUNT(*) AS title_count
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`,
  UNNEST(SPLIT(country, ',')) AS country_split
WHERE country IS NOT NULL
GROUP BY country
ORDER BY title_count DESC
LIMIT 20;

-- Result summary:
-- United States leads by a wide margin (3,690 titles), more than 3x
-- the #2 country. India is a clear #2 (1,046), well ahead of the next
-- non-English-language market. Asian markets (Japan, South Korea,
-- Hong Kong, China, Indonesia) occupy 5 of the top 20 spots, alongside
-- emerging markets like Egypt, Turkey, and Nigeria -- indicating
-- deliberate content sourcing beyond traditional English-speaking
-- markets.


-- Step 2: Yearly content count by country, to see how production
-- expanded geographically over time
SELECT
  EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) AS year_added,
  TRIM(country_split) AS country,
  COUNT(*) AS title_count
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`,
  UNNEST(SPLIT(country, ',')) AS country_split
WHERE country IS NOT NULL
  AND date_added IS NOT NULL
GROUP BY year_added, country
HAVING title_count >= 5
ORDER BY year_added, title_count DESC;

-- Result summary:
-- Multiple non-English-language markets show rapid growth between
-- 2016-2019, most notably across Asian and Latin American markets.

-- Step 3: Country diversification over time
-- Counts the number of distinct countries contributing 5+ titles per year
SELECT
  year_added,
  COUNT(DISTINCT country) AS distinct_country_count
FROM (
  SELECT
    EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) AS year_added,
    TRIM(country_split) AS country,
    COUNT(*) AS title_count
  FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`,
    UNNEST(SPLIT(country, ',')) AS country_split
  WHERE country IS NOT NULL AND date_added IS NOT NULL
  GROUP BY year_added, country
  HAVING title_count >= 5
)
GROUP BY year_added
ORDER BY year_added;

-- Result summary:
-- Country diversification grew sharply: from 5 countries contributing
-- 5+ titles in 2015 to a peak of 41 countries in 2020 -- an 8x increase.
-- This is the strongest evidence of Netflix's shift from a
-- US-centric catalog to a genuinely global content platform.
