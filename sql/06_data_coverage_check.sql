-- 06_data_coverage_check.sql
-- Triggered by an apparent decline in 2020-2021 figures seen in
-- 04_analysis_content_mix.sql and 05_analysis_country_trend.sql.
-- Rather than checking 2021 alone, this systematically checks data
-- coverage (which months have data) across all years to catch any
-- similar issues elsewhere in the dataset.

SELECT
  EXTRACT(YEAR FROM PARSE_DATE('%B %e, %Y', TRIM(date_added))) AS year_added,
  MIN(EXTRACT(MONTH FROM PARSE_DATE('%B %e, %Y', TRIM(date_added)))) AS first_month,
  MAX(EXTRACT(MONTH FROM PARSE_DATE('%B %e, %Y', TRIM(date_added)))) AS last_month,
  COUNT(DISTINCT EXTRACT(MONTH FROM PARSE_DATE('%B %e, %Y', TRIM(date_added)))) AS distinct_months_with_data,
  COUNT(*) AS title_count
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles_clean`
WHERE date_added IS NOT NULL
GROUP BY year_added
ORDER BY year_added;

-- Result summary:
-- 2015-2020 all have full 12-month coverage, confirming the 2019->2020
-- decline (2,016 -> 1,879 titles) is a genuine trend, not a data
-- artifact. 2021 has only 9 months of data (Jan-Sep), confirming the
-- 2020->2021 decline is a coverage artifact, not a real decline.
-- 2008-2014 have sparse, partial-year coverage across the board
-- (1-13 titles/year), consistent with these years being excluded from
-- trend analysis in 04_analysis_content_mix.sql and
-- 05_analysis_country_trend.sql.
