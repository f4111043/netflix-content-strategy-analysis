-- 08_analysis_content_aging.sql
-- Analysis: Content aging - the gap between when a title was produced
--(release_year) and when it was added to Netflix (date_added).
-- A small gap suggests Netflix is licensing/releasing fresh content;
-- a large gap suggests it's building out a catalog with older library titles.
-- Using 2015-2020 only (reliable data range, see 06_data_coverage_check.sql).

-- Step 1: Overall average and range of age at addition, by type
SELECT
  type,
  ROUND(AVG(EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) - release_year), 1) AS avg_age_at_addition,
  MIN(EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) - release_year) AS min_age,
  MAX(EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) - release_year) AS max_age
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`
WHERE date_added IS NOT NULL
  AND EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) BETWEEN 2015 AND 2020
GROUP BY type;

-- Result: Movie avg 5.3 years (range -1 to 75), TV Show avg 2.4 years
-- (range -2 to 93). TV Shows are added noticeably fresher on average
-- than Movies.

-- Investigation: negative age gaps (release_year appears "in the future" relative to date_added)
SELECT show_id, title, type, release_year, date_added,
  EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) - release_year AS age_gap
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`
WHERE date_added IS NOT NULL
  AND EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) - release_year < 0
ORDER BY age_gap;

-- Result: 13 rows (out of 8,807, ~0.15%), all TV Shows (e.g. Sense8, BoJack Horseman, Arrested Development).
-- For multi-season series,`release_year` appears to reflect the show's most recent/final season year, 
-- while date_added reflects when an earlier season first premiered on Netflix
-- a characteristic of how the source dataset
-- records release_year for TV Shows, not a data error. 
-- Left as-is in all calculations; negligible impact given the small count.

-- Step 2: Yearly trend of average content age at addition, by type
SELECT
  EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) AS year_added,
  type,
  ROUND(AVG(EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) - release_year), 1) AS avg_age_at_addition,
  COUNT(*) AS title_count
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`
WHERE date_added IS NOT NULL
  AND EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) BETWEEN 2015 AND 2020
GROUP BY year_added, type
ORDER BY year_added, type;

-- Result summary:
-- Movie and TV Show content aging trends move in opposite directions.
-- Movies: average age at addition rose sharply from 0.4 years (2015)
-- to 6.7 years (2019), suggesting Netflix increasingly relied on older
-- library titles rather than fresh releases for movies -- likely due
-- to rising competition for new theatrical releases (e.g. other
-- streaming platforms' exclusive deals).
-- TV Shows: average age at addition fell steadily from 4.3 years (2016)
-- to 1.8 years (2020), suggesting a deliberate shift toward fresher
-- series content, consistent with Netflix's growing investment in
-- original series seen in 04_analysis_content_mix.sql and
-- 07_analysis_genre_trend.sql.
