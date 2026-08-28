-- 04_analysis_content_mix.sql
-- Analysis: Yearly trend of Movie vs TV Show additions to Netflix,
-- based on date_added (year the title was added to Netflix), not
-- release_year, since this better reflects Netflix's content
-- investment strategy over time.

-- Step 1: Yearly counts by type
SELECT
  EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) AS year_added,
  type,
  COUNT(*) AS title_count
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`
WHERE date_added IS NOT NULL
GROUP BY year_added, type
ORDER BY year_added, type;

-- Step 2: Same data as a percentage share within each year
WITH yearly_counts AS (
  SELECT
    EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) AS year_added,
    type,
    COUNT(*) AS title_count
  FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`
  WHERE date_added IS NOT NULL
  GROUP BY year_added, type
)
SELECT
  year_added,
  type,
  title_count,
  ROUND(title_count / SUM(title_count) OVER (PARTITION BY year_added) * 100, 1) AS pct_of_year
FROM yearly_counts
ORDER BY year_added, type;

-- Result summary:
-- 2008-2014 sample sizes are too small (1-24 titles/year) to be meaningful.
-- From 2015 onward: TV Show share rose from 32% (2015) to a peak of 41%
-- (2016), then dropped to a low of 25% (2018) as Netflix appears to have
-- prioritized movie acquisition, before climbing steadily back to 34%
-- by 2021 -- consistent with a renewed strategic push into series content.
-- Note: absolute title counts also decline in 2020-2021, which may
-- partly reflect incomplete data for the dataset's final collection year
-- rather than an actual slowdown.

-- Step 3: Year-over-year growth rate per type
WITH yearly_counts AS (
  SELECT
    EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) AS year_added,
    type,
    COUNT(*) AS title_count
  FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`
  WHERE date_added IS NOT NULL
  GROUP BY year_added, type
)
SELECT
  year_added,
  type,
  title_count,
  LAG(title_count) OVER (PARTITION BY type ORDER BY year_added) AS prev_year_count,
  ROUND(
    (title_count - LAG(title_count) OVER (PARTITION BY type ORDER BY year_added))
    / LAG(title_count) OVER (PARTITION BY type ORDER BY year_added) * 100, 1
  ) AS yoy_growth_pct
FROM yearly_counts
ORDER BY type, year_added;

-- Result summary:
-- Growth peaked in 2016 (TV Show +576.9%, Movie +351.8%), then
-- decelerated steadily through 2019 -- a typical maturing-market pattern.
-- Notably, from 2019 onward TV Show growth rate exceeds Movie growth
-- rate (+43.7% vs +15.1% in 2019), aligning with the mix-share shift
-- seen in Step 2. Both types show negative growth in 2020-2021,
-- possibly reflecting pandemic-related production delays and/or
-- incomplete data for the dataset's final collection year.
