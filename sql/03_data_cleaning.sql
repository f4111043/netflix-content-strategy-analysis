-- 02_data_cleaning.sql
-- Issue: Some rows have their columns shifted — when the original
-- `rating` value was missing, the `duration` value shifted left
-- into the `rating` column (e.g. rating = "74 min").
-- This query detects and fixes that shift.

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
