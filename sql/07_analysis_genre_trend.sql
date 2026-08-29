-- 07_analysis_genre_trend.sql
-- Analysis: Genre trends in Netflix's content library over time.
-- The `listed_in` column contains comma-separated multi-genre values
-- (e.g. "Dramas, International Movies"), so we split and unnest it,
-- same approach as used for country in 05_analysis_country_trend.sql.

-- Step 1: Overall genre ranking
SELECT
  TRIM(genre_split) AS genre,
  COUNT(*) AS title_count
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`,
  UNNEST(SPLIT(listed_in, ',')) AS genre_split
GROUP BY genre
ORDER BY title_count DESC;

-- Step 2: Yearly trend for top genres (2015-2020 only)
-- 2008-2014 excluded: insufficient/partial-year data (see 06_data_coverage_check.sql)
-- 2021 excluded: incomplete data, only Jan-Sep (see 06_data_coverage_check.sql)
WITH genre_totals AS (
  SELECT TRIM(genre_split) AS genre, COUNT(*) AS total
  FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`,
    UNNEST(SPLIT(listed_in, ',')) AS genre_split
  GROUP BY genre
  ORDER BY total DESC
  LIMIT 10
)
SELECT
  EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(t.date_added))) AS year_added,
  TRIM(genre_split) AS genre,
  COUNT(*) AS title_count
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean` AS t,
  UNNEST(SPLIT(t.listed_in, ',')) AS genre_split
WHERE TRIM(genre_split) IN (SELECT genre FROM genre_totals)
  AND t.date_added IS NOT NULL
  AND EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(t.date_added))) BETWEEN 2015 AND 2020
GROUP BY year_added, genre
ORDER BY year_added, title_count DESC;

-- Step 3: Year-over-year growth rate for top genres (2015-2020 only)
WITH genre_totals AS (
  SELECT TRIM(genre_split) AS genre, COUNT(*) AS total
  FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`,
    UNNEST(SPLIT(listed_in, ',')) AS genre_split
  GROUP BY genre
  ORDER BY total DESC
  LIMIT 10
),
yearly_genre_counts AS (
  SELECT
    EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(t.date_added))) AS year_added,
    TRIM(genre_split) AS genre,
    COUNT(*) AS title_count
  FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean` AS t,
    UNNEST(SPLIT(t.listed_in, ',')) AS genre_split
  WHERE TRIM(genre_split) IN (SELECT genre FROM genre_totals)
    AND t.date_added IS NOT NULL
    AND EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(t.date_added))) BETWEEN 2015 AND 2020
  GROUP BY year_added, genre
)
SELECT
  year_added,
  genre,
  title_count,
  LAG(title_count) OVER (PARTITION BY genre ORDER BY year_added) AS prev_year_count,
  ROUND(
    (title_count - LAG(title_count) OVER (PARTITION BY genre ORDER BY year_added))
    / LAG(title_count) OVER (PARTITION BY genre ORDER BY year_added) * 100, 1
  ) AS yoy_growth_pct
FROM yearly_genre_counts
ORDER BY genre, year_added;

-- Result summary:
-- Documentaries is the only top-10 genre with negative growth in more
-- than one year (2018: -18.9%, 2020: -37.2%), suggesting an actual
-- decline in investment priority rather than mere growth deceleration.
-- 2020 saw broad-based slowdown: 7 of 10 top genres posted negative
-- YoY growth, consistent with the overall 2020 decline confirmed as
-- genuine in 04_analysis_content_mix.sql (full 12-month data).
-- Note: International TV Shows' 2016 figure (+2,766.7%) reflects a
-- base-effect artifact from a tiny 2015 sample (3 titles) and should
-- not be read as a meaningful growth rate.
