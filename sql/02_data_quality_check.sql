-- 02_data_quality_check.sql
-- Quality checks performed on the raw table (netflix_titles).
--
-- Note: A column-shift issue was first identified by manually inspecting
-- the table preview — some rows had duration-like values (e.g. "74 min")
-- appearing in the `rating` column, with `duration` showing NULL instead.
-- This was fixed separately in 03_data_cleaning.sql. The checks below
-- cover the remaining systematic checks, plus verification of that fix.

-- 1) Duplicate rows check (by show_id, which should be unique)
-- Result: 0 rows -> no duplicates
SELECT show_id, COUNT(*) AS cnt
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles`
GROUP BY show_id
HAVING cnt > 1;

-- 2) Null counts per column
-- Result: director 2634, cast 825, country 831 (expected, see note below),
-- date_added 10, rating 4, duration 3
SELECT
  COUNTIF(director IS NULL) AS null_director,
  COUNTIF(`cast` IS NULL) AS null_cast,
  COUNTIF(country IS NULL) AS null_country,
  COUNTIF(date_added IS NULL) AS null_date_added,
  COUNTIF(rating IS NULL) AS null_rating,
  COUNTIF(duration IS NULL) AS null_duration
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles`;

-- Note on director/cast/country nulls: these are not data errors but a
-- natural characteristic of the source data (e.g. documentaries and
-- stand-up specials often lack director/cast credits). No imputation
-- applied; documented here instead.

-- Follow-up on rating/duration nulls: investigated below, found to
-- overlap entirely with the column-shift issue.
SELECT show_id, title, rating, duration
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles`
WHERE rating IS NULL OR duration IS NULL;
-- Result: 7 rows, all column-shift cases (e.g. Louis C.K. specials).
-- No separate/new issue.

-- Verification against the cleaned table
SELECT show_id, title, rating, duration
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`
WHERE show_id IN ('s6828', 's7538', 's7313', 's5990', 's5814', 's5542', 's5795');
-- Result: rating correctly NULL, duration correctly recovered for all 7 rows.

-- 3) Distinct values in `type`
-- Result: Movie, TV Show only -> no unexpected categories
SELECT DISTINCT type
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles`;

-- 4) release_year range check
-- Result: 1925–2021, plausible range
SELECT MIN(release_year) AS earliest, MAX(release_year) AS latest
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles`;

-- 5) date_added parseability
-- Result: 0 unparseable rows -> consistent date format throughout
SELECT date_added
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles`
WHERE date_added IS NOT NULL
  AND SAFE.PARSE_DATE('%B %e, %Y', TRIM(date_added)) IS NULL;

-- 6) Distinct rating values (checked on the cleaned table)
-- Result: only standard MPAA/TV rating categories remain
SELECT DISTINCT rating
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`
ORDER BY rating;
