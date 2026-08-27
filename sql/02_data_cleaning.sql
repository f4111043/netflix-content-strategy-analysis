-- 02_data_cleaning.sql
--
-- Issue: While visually inspecting the raw table preview, a column-shift
-- pattern was spotted — in some rows, when the original `rating` value
-- was missing, the `duration` value had shifted left into the `rating`
-- column instead (e.g. rating = "74 min", duration = NULL).
--
-- This query detects and fixes that shift. The result is written to a
-- new table, keeping the original `netflix_titles` table untouched
-- for reference. (Affected row count and further verification are
-- documented in 03_data_quality_check.sql.)

CREATE OR REPLACE TABLE `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean` AS
SELECT
  show_id,
  type,
  title,
  director,
  `cast`,
  country,
  date_added,
  release_year,

  -- If rating actually contains a duration value, treat it as missing
  CASE
    WHEN rating LIKE '%min%' OR rating LIKE '%Season%' THEN NULL
    ELSE rating
  END AS rating,

  -- If duration is null but rating holds a duration-like value, recover it
  CASE
    WHEN duration IS NULL AND (rating LIKE '%min%' OR rating LIKE '%Season%') THEN rating
    ELSE duration
  END AS duration,

  listed_in,
  description
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles`;


-- Verification query
-- Should return 0 rows if the column-shift cleaning worked correctly
SELECT *
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`
WHERE rating LIKE '%min%' OR rating LIKE '%Season%';
-- Result: 0 rows returned -> the shift was successfully corrected.
