# Netflix Content Strategy Analysis

## Overview
This project analyzes Netflix's content catalog to understand how its
content strategy evolved over time: the shift between movies and series,
geographic expansion, genre investment, and how "fresh" newly added
content tends to be. The goal is to demonstrate an end-to-end analytics
workflow, including data ingestion, cleaning, quality validation, and
SQL-based analysis, with results visualized in Tableau.

**Tools used:** BigQuery (SQL), Tableau

## 🔗 Dashboard
[View the interactive dashboard on Tableau Public](#) *(link to be added)*

The dashboard includes:
- Content mix trend (Movie vs TV Show over time)
- Geographic expansion map (country-level content count)
- Genre growth comparison
- Content aging trend by type

## Key Findings

### 1. Content Mix: A Deliberate Pivot to Series
Netflix's catalog composition shifted in two phases. Movie-heavy
acquisition dominated from 2016 to 2018, with TV Show share falling
from 41% to a low of 25%, followed by a steady pivot back toward
series content, with TV Show share climbing to 34% by 2021. Growth
rates for both types decelerated steadily after peaking in 2016 (TV
Show +577% YoY), consistent with a maturing content library. From
2019 onward, TV Show growth outpaced Movie growth, reinforcing the
shift toward series investment.

### 2. Geographic Expansion: From US-Centric to Global
The United States leads content production by a wide margin (3,690
titles), more than 3x the #2 country, India (1,046). Country
diversification grew sharply: the number of countries contributing
5+ titles per year grew from 5 in 2015 to a peak of 41 in 2020, an
8x increase, and the clearest evidence of Netflix's shift from a
US-centric catalog to a global platform. Asian markets (India,
Japan, South Korea, Hong Kong, China, Indonesia) and emerging
markets (Egypt, Turkey, Nigeria) all appear among the top 20
producing countries.

### 3. Genre Trends: Uneven Growth, With Documentaries as the Outlier
"International Movies" is the single largest genre category (2,752
titles), reflecting Netflix's global content strategy at the genre
level as well. All top 10 genres grew substantially from 2015 to
2020, but Romantic Movies grew fastest by far (+2,371% from a small
base). Documentaries stands out as the only top 10 genre with
negative year-over-year growth in more than one year (2018 and
2020), suggesting an actual decline in investment priority rather
than mere slowing growth. 2020 saw a broad slowdown, with 7 of the
top 10 genres posting negative YoY growth that year.

### 4. Content Aging: Movies and TV Shows Moving in Opposite Directions
The average age of a Movie at the time it was added to Netflix rose
sharply, from 0.4 years in 2015 to 6.7 years in 2019. Netflix
increasingly relied on older library titles for movies, likely
reflecting rising competition for new theatrical releases. The
average age of a TV Show at addition fell steadily, from 4.3 years
in 2016 to 1.8 years in 2020, a deliberate shift toward fresher
series content, consistent with growing investment in original
series seen in the content mix and genre analyses.

## Data Source
- **Dataset:** Netflix Movies and TV Shows
- **Source:** [Kaggle (shivamb/netflix-shows)](https://www.kaggle.com/datasets/shivamb/netflix-shows)
- **Size:** 8,807 rows, 12 columns
- **License:** CC0, Public Domain

See [`data/data_source.md`](data/data_source.md) for full column
descriptions.

## Project Structure
```
sql/
  01_data_loading.sql              -- BigQuery ingestion, schema, load issues
  02_data_cleaning.sql             -- Column-shift fix (rating/duration)
  03_data_quality_check.sql        -- Systematic quality checks post-cleaning
  04_analysis_content_mix.sql      -- Movie vs TV Show trend over time
  05_analysis_country_trend.sql    -- Country-level production trends
  06_data_coverage_check.sql       -- Investigation into 2020-2021 decline
  07_analysis_genre_trend.sql      -- Genre trends and growth rates
  08_analysis_content_aging.sql    -- Gap between release year and add date
data/
  data_source.md                   -- Dataset documentation
```

## Analysis Process
The project followed a realistic, iterative workflow rather than a
perfectly linear one.

1. **Data loading.** The raw CSV failed to load into BigQuery twice:
   once due to non-standard apostrophe escaping in the `description`
   field, and once due to the header row being misread as data. Both
   were diagnosed and resolved (see `01_data_loading.sql`).
2. **Data cleaning.** While visually inspecting the loaded table, a
   column-shift issue was spotted. When `rating` was missing,
   `duration` values (e.g. "74 min") had shifted into the `rating`
   column instead. This was fixed and verified (see
   `02_data_cleaning.sql`).
3. **Data quality check.** A systematic 6-point check (duplicates,
   nulls, category consistency, year range, date parseability, rating
   values) confirmed no further data errors (see
   `03_data_quality_check.sql`). Missing `director`, `cast`, and
   `country` values (9 to 30% depending on the column) were determined
   to be a natural characteristic of the source data, since
   documentaries often lack director credits, for example, rather
   than errors. They were left as-is.
4. **Analysis.** Four analyses were run: content mix, country trends,
   genre trends, and content aging.
5. **Anomaly investigation.** Both the content mix and country trend
   analyses showed an unexplained decline in 2020 to 2021 figures.
   Rather than assuming this was a real trend, it was investigated in
   `06_data_coverage_check.sql`, which revealed that 2021 data in the
   source dataset only covers January through September. This finding
   was incorporated back into the interpretation of all affected
   analyses.

This order, cleaning before a full quality check, and an anomaly
investigation appearing after (not before) the analyses that surfaced
it, reflects how the issues were actually discovered, rather than a
reconstructed "ideal" sequence.

## Data Limitations
- **2021 data is incomplete**, covering only January through
  September. Any 2021 figures should be read as partial-year, not
  annual, totals (see `06_data_coverage_check.sql`).
- **2008 to 2014 data is sparse** (1 to 24 titles per year with
  partial-year coverage) and excluded from trend analyses as
  unreliable.
- **`director`, `cast`, and `country` have meaningful null rates**
  (30%, 9%, and 9% respectively), left unimputed since they reflect
  genuine gaps in the source data rather than errors.
- **This dataset contains catalog metadata only.** There is no viewer
  rating, watch-time, or engagement data. All findings describe
  Netflix's content supply and curation strategy (what was added,
  when, and from where), not the audience response to that strategy.
  Any recommendation about what worked would require additional data,
  such as viewership or rating datasets, beyond this project's scope.
