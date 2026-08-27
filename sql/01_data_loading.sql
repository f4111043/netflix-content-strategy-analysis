-- ============================================
-- Netflix Titles - Data Loading (BigQuery)
-- ============================================
-- Source: Netflix Movies and TV Shows dataset (Kaggle)
-- https://www.kaggle.com/datasets/shivamb/netflix-shows
-- 8,808 rows, 12 columns

-- Table creation settings used in BigQuery UI:
-- Destination: netflix_portfolio.netflix_titles
-- Source format: CSV
-- Schema: manually specified (see below)
-- Header rows to skip: 1
-- Number of errors allowed: 5
-- Quoted newlines: enabled

-- Manual schema (auto-detect failed due to header recognition issues):
-- show_id:STRING, type:STRING, title:STRING, director:STRING,
-- cast:STRING, country:STRING, date_added:STRING, release_year:INTEGER,
-- rating:STRING, duration:STRING, listed_in:STRING, description:STRING

-- ============================================
-- Issues encountered & resolved
-- ============================================
-- 1) Initial load failed: "Missing close quote character"
--    Cause: source CSV escapes apostrophes with backslash (\'),
--    not the standard CSV double-quote escaping ("").
--    Fix: increased "max bad records" to 5 to skip the 2 malformed rows
--    out of 8,808 total.
--
-- 2) Second load succeeded but all columns loaded as string_field_0,
--    string_field_1, etc., with header row treated as data.
--    Cause: "Header rows to skip" was not set.
--    Fix: recreated table with manual schema + Header rows to skip = 1.

-- ============================================
-- Verification query
-- ============================================
SELECT *
FROM `ibm-data-analysis-506010.netflix_portfolio.netflix_titles`
LIMIT 10;
