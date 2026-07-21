# Oregon Housing Affordability Analysis (2019–2023)

**A reproducible county-level analysis of housing affordability and housing stress across Oregon using American Community Survey (ACS) 5-Year Estimates.**

![R](https://img.shields.io/badge/R-276DC3?logo=r&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?logo=sqlite&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau_Public-E97627?logo=tableau&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Project Overview

Housing affordability has become one of Oregon's most significant economic and social challenges. Rising housing costs, constrained housing supply, and uneven household economic conditions have increased financial pressure on communities across the state.

This project analyzes housing affordability across all **36 Oregon counties** using **2019–2023 American Community Survey (ACS) 5-Year Estimates**. A fully reproducible workflow was developed in **R** to automate data acquisition, validation, cleaning, feature engineering, statistical analysis, geospatial visualization, database development, and dashboard preparation.

The project introduces a **Housing Stress Index (HSI)**, a composite metric that combines multiple affordability indicators to identify counties experiencing the greatest housing-related financial pressure.

---

## Skills Demonstrated

- Data Engineering (ETL)
- Census API Integration
- Data Validation & Cleaning
- Feature Engineering
- SQL & SQLite Database Design
- Statistical Analysis
- Geospatial Analysis & Mapping
- Data Visualization with **ggplot2**
- Tableau Dashboard Development
- Reproducible Research

---

## Research Questions

This project addresses the following questions:

- Which Oregon counties experience the highest housing stress?
- How do housing costs compare with household income?
- Is higher rent burden associated with higher poverty rates?
- How have affordability indicators changed between 2019 and 2023?
- Which counties may benefit from additional housing policy interventions?

---

## Data Source

**Primary Data Source**

- U.S. Census Bureau
- American Community Survey (ACS) 5-Year Estimates
- Study period: **2019–2023**

**Unit of Analysis**

- 36 Oregon counties
- Five years of observations
- 180 county-year records

Data are downloaded directly from the U.S. Census Bureau using the **tidycensus** package and processed through a fully scripted R workflow.

---

## Technologies Used

| Technology | Purpose |
|------------|---------|
| R | Data engineering, analysis, visualization |
| tidycensus | Census API access |
| tidyverse | Data manipulation |
| ggplot2 | Statistical graphics |
| sf | Geographic analysis and mapping |
| SQLite | Relational database |
| SQL | Data querying |
| Tableau Public | Interactive dashboard |

---

## Project Workflow

```text
ACS API
    │
    ▼
Download ACS Data
    │
    ▼
Validation & Quality Checks
    │
    ▼
Cleaning & Transformation
    │
    ▼
Feature Engineering
    │
    ▼
SQLite Database
    │
    ├── Statistical Analysis
    ├── Housing Stress Index
    ├── Geographic Mapping
    └── Tableau Dashboard
```

---

## Housing Stress Index (HSI)

To summarize housing affordability conditions, this project develops a **Housing Stress Index (HSI)** that combines five standardized indicators into a single composite measure.

### Indicators

- Median Household Income
- Median Gross Rent
- Poverty Rate
- Rent Burden Rate
- Rent-to-Income Ratio

### Weighting Scheme

| Indicator | Weight |
|-----------|-------:|
| Income Score | 10% |
| Rent Score | 15% |
| Poverty Score | 25% |
| Rent Burden Score | 35% |
| Rent-to-Income Ratio | 15% |

Higher HSI values indicate greater housing affordability stress.

---

## Key Findings

### Statewide Trends (2019–2023)

- Average household income increased from **$53,953** to **$69,965**
- Average monthly rent increased from **$903** to **$1,137**
- Average home values increased by approximately **51%**
- Rent burden remained consistently above **40%**
- Housing affordability pressures persisted despite income growth

### Counties with Highest Housing Stress

| Rank | County |
|-----:|--------|
| 1 | Benton |
| 2 | Josephine |
| 3 | Lane |
| 4 | Klamath |
| 5 | Jackson |
| 6 | Multnomah |

Housing stress is driven by the interaction of housing costs, household income, poverty, and rent burden rather than any single affordability indicator.

---

## Analysis Included

- Descriptive statistics
- County-level rankings
- Correlation analysis
- Time-series trend analysis
- Housing Stress Index development
- Geographic mapping
- Interactive dashboard preparation

Major findings include:

- Strong positive relationship between income and housing costs
- Moderate relationship between rent burden and rental prices
- Housing affordability challenges exist in both urban and rural counties
- Housing stress depends on both housing market conditions and household economic capacity

---

## Maps

The project includes county-level choropleth maps for:

- Housing Stress Index (2019–2023 Average)
- Median Household Income (2023)
- Median Gross Rent (2023)
- Median Home Value (2023)
- Poverty Rate (2023)
- Rent Burden Rate (2023)

Example figures are available in the **figures/** directory.

---

## Interactive Dashboard

An interactive Tableau dashboard was developed to explore housing affordability across Oregon counties.

**View the dashboard here:**

➡️ **https://public.tableau.com/app/profile/diane.haiden/viz/OregonHousingAffordabilityProject/ExecutiveSummary**

---

## Repository Structure

```text
oregon-housing-affordability/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── R/
│   ├── 00_setup.R
│   ├── 01_download_acs.R
│   ├── 02_validate_acs.R
│   ├── 03_clean_acs.R
│   ├── 04_load_sql.R
│   ├── 05_analysis.R
│   ├── 06_mapping.R
│   └── 07_export_tableau.R
│
├── data/
│   ├── raw/
│   └── processed/
│
├── database/
│   └── housing.sqlite
│
├── figures/
│   ├── housing_stress_index_map_2019_2023.png
│   ├── median_home_value_map_2023.png
│   ├── median_income_map_2023.png
│   ├── median_rent_map_2023.png
│   ├── poverty_rate_map_2023.png
│   └── rent_burden_map_2023.png
```

---

## Reproducing the Analysis

1. Clone this repository.
2. Install the required R packages.
3. Configure your U.S. Census API key using `tidycensus::census_api_key()`.
4. Run the R scripts in numerical order.
5. Explore the SQLite database or Tableau dashboard.

---

## Future Improvements

Potential extensions include:

- Automated annual ACS updates
- Additional demographic equity indicators
- Integration with HUD housing datasets
- Predictive modeling of housing affordability
- Time-series forecasting
- Expanded regional comparisons

---

## Limitations

- ACS estimates are survey-based and include sampling uncertainty.
- The Housing Stress Index is a composite measure developed for this project and depends on the selected weighting methodology.
- Additional demographic and socioeconomic variables could provide a more comprehensive assessment of housing affordability.

---

## Author

**Diane Haiden**

This independent project demonstrates an end-to-end data analytics workflow including automated data acquisition, data engineering, SQL database design, statistical analysis, geospatial visualization, and interactive dashboard development using publicly available U.S. Census data.

---

## License

This project is released under the MIT License.
