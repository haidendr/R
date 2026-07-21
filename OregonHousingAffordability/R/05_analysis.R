#===========================================================
# Oregon Housing Affordability & Equity Analysis
# Statistical Analysis
# ACS 2019-2023 5-Year Estimates
#===========================================================

setwd("C:<insert your working directory here>/scripts")
source("00_setup.R")


library(DBI)
library(RSQLite)
library(tidyverse)
library(scales)


#-----------------------------------------------------------
# Create analysis directory
#-----------------------------------------------------------

analysis_dir <- "data/analysis"

if (!dir.exists(analysis_dir)) {
  dir.create(
    analysis_dir,
    recursive = TRUE
  )
}


#-----------------------------------------------------------
# Connect to SQLite Database
#-----------------------------------------------------------

con <- dbConnect(
  SQLite(),
  database_path
)


housing <- dbReadTable(
  con,
  "housing_metrics"
)


county <- dbReadTable(
  con,
  "county"
)


housing <- housing %>%
  left_join(
    county,
    by = "GEOID"
  )


cat(
  "Rows loaded:",
  nrow(housing),
  "\n"
)


#-----------------------------------------------------------
# Verify panel structure
#-----------------------------------------------------------

cat("\nCounty and year counts:\n")

print(
  housing %>%
    group_by(year) %>%
    summarise(
      counties = n_distinct(GEOID),
      rows = n()
    )
)


#-----------------------------------------------------------
# Descriptive Statistics
# Full 2019-2023 Study Period
#-----------------------------------------------------------

summary_stats <- housing %>%
  summarise(
    
    counties =
      n_distinct(GEOID),
    
    years =
      n_distinct(year),
    
    avg_income =
      mean(
        median_income,
        na.rm = TRUE
      ),
    
    avg_rent =
      mean(
        median_rent,
        na.rm = TRUE
      ),
    
    avg_home_value =
      mean(
        median_home_value,
        na.rm = TRUE
      ),
    
    avg_poverty_rate =
      mean(
        poverty_rate,
        na.rm = TRUE
      ),
    
    avg_rent_burden =
      mean(
        rent_burden_rate,
        na.rm = TRUE
      )
    
  )


print(summary_stats)


write_csv(
  summary_stats,
  file.path(
    analysis_dir,
    "summary_statistics.csv"
  )
)



#-----------------------------------------------------------
# Correlation Analysis
# Full Study Period
#-----------------------------------------------------------

correlation_data <- housing %>%
  select(
    median_income,
    median_rent,
    median_home_value,
    poverty_rate,
    rent_burden_rate,
    rent_to_income_ratio
  )


correlation_matrix <- cor(
  correlation_data,
  use = "complete.obs"
)


print(correlation_matrix)


write.csv(
  correlation_matrix,
  file.path(
    analysis_dir,
    "correlation_matrix.csv"
  )
)



#-----------------------------------------------------------
# Housing Stress Index Calculation
#-----------------------------------------------------------

housing_hsi <- housing %>%
  
  mutate(
    
    # Lower income = higher stress
    
    income_score =
      rescale(
        -median_income
      ),
    
    
    # Higher values = higher stress
    
    rent_score =
      rescale(
        median_rent
      ),
    
    
    poverty_score =
      rescale(
        poverty_rate
      ),
    
    
    burden_score =
      rescale(
        rent_burden_rate
      ),
    
    
    ratio_score =
      rescale(
        rent_to_income_ratio
      )
    
  ) %>%
  
  
  mutate(
    
    housing_stress_index =
      
      (0.10 * income_score) +
      
      (0.15 * rent_score) +
      
      (0.25 * poverty_score) +
      
      (0.35 * burden_score) +
      
      (0.15 * ratio_score)
    
  )



cat("\nHSI Summary:\n")

print(
  summary(
    housing_hsi$housing_stress_index
  )
)



#-----------------------------------------------------------
# Housing Stress Ranking - 2023
# Current Conditions
#-----------------------------------------------------------

latest_year <-
  max(
    housing_hsi$year
  )


housing_rank_2023 <- housing_hsi %>%
  
  filter(
    year == latest_year
  ) %>%
  
  arrange(
    desc(housing_stress_index)
  )


write_csv(
  
  housing_rank_2023,
  
  file.path(
    analysis_dir,
    "housing_stress_rankings_2023.csv"
  )
  
)



#-----------------------------------------------------------
# Housing Stress Ranking
# Average 2019-2023
# Persistent Stress
#-----------------------------------------------------------

housing_rank_average <- housing_hsi %>%
  
  group_by(
    GEOID,
    county_name
  ) %>%
  
  summarise(
    
    avg_housing_stress =
      mean(
        housing_stress_index,
        na.rm = TRUE
      ),
    
    avg_income =
      mean(
        median_income,
        na.rm = TRUE
      ),
    
    avg_rent =
      mean(
        median_rent,
        na.rm = TRUE
      ),
    
    avg_home_value =
      mean(
        median_home_value,
        na.rm = TRUE
      ),
    
    avg_poverty_rate =
      mean(
        poverty_rate,
        na.rm = TRUE
      ),
    
    avg_rent_burden =
      mean(
        rent_burden_rate,
        na.rm = TRUE
      )
    
  ) %>%
  
  arrange(
    desc(avg_housing_stress)
  )


write_csv(
  
  housing_rank_average,
  
  file.path(
    analysis_dir,
    "housing_stress_rankings_2019_2023.csv"
  )
  
)



#-----------------------------------------------------------
# Trend Analysis
# 2019-2023
#-----------------------------------------------------------

trend_summary <- housing_hsi %>%
  
  group_by(
    year
  ) %>%
  
  summarise(
    
    avg_income =
      mean(
        median_income,
        na.rm = TRUE
      ),
    
    avg_rent =
      mean(
        median_rent,
        na.rm = TRUE
      ),
    
    avg_home_value =
      mean(
        median_home_value,
        na.rm = TRUE
      ),
    
    avg_poverty =
      mean(
        poverty_rate,
        na.rm = TRUE
      ),
    
    avg_rent_burden =
      mean(
        rent_burden_rate,
        na.rm = TRUE
      ),
    
    avg_housing_stress =
      mean(
        housing_stress_index,
        na.rm = TRUE
      )
    
  )


print(trend_summary)


write_csv(
  
  trend_summary,
  
  file.path(
    analysis_dir,
    "trend_summary.csv"
  )
  
)



#-----------------------------------------------------------
# Close Database
#-----------------------------------------------------------

dbDisconnect(con)


cat(
  "\nAnalysis complete.\n"
)
