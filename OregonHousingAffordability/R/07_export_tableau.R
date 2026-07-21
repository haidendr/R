############################################################
# Project: Oregon Housing Affordability & Equity Analysis
# Script: 07_export_tableau.R
# Purpose: Create Tableau-ready datasets
# ACS 2019-2023 5-Year Estimates
############################################################


#-----------------------------------------------------------
# Load setup
#-----------------------------------------------------------

setwd("C:<insert your working directory here>/scripts")
source("00_setup.R")


library(DBI)
library(RSQLite)
library(tidyverse)



#-----------------------------------------------------------
# Create Tableau directory
#-----------------------------------------------------------

tableau_dir <- "tableau"


if (!dir.exists(tableau_dir)) {
  
  dir.create(
    tableau_dir,
    recursive = TRUE
  )
  
}



#-----------------------------------------------------------
# Connect to SQLite
#-----------------------------------------------------------

con <- dbConnect(
  SQLite(),
  database_path
)



#-----------------------------------------------------------
# Load database tables
#-----------------------------------------------------------

county <- dbReadTable(
  con,
  "county"
)


housing <- dbReadTable(
  con,
  "housing_metrics"
)



#-----------------------------------------------------------
# Combine housing and county data
#-----------------------------------------------------------

tableau_data <- housing %>%
  
  left_join(
    county,
    by = "GEOID"
  ) %>%
  
  relocate(
    county_name,
    .after = GEOID
  )



#-----------------------------------------------------------
# Export complete county-year dataset
# 180 rows
#-----------------------------------------------------------

write_csv(
  
  tableau_data,
  
  file.path(
    tableau_dir,
    "oregon_housing_tableau_full.csv"
  )
  
)



#-----------------------------------------------------------
# Latest year dataset
# 2023 snapshot
#-----------------------------------------------------------

latest_year <- max(
  tableau_data$year
)


housing_2023 <- tableau_data %>%
  
  filter(
    year == latest_year
  )


write_csv(
  
  housing_2023,
  
  file.path(
    tableau_dir,
    "oregon_housing_2023.csv"
  )
  
)



#-----------------------------------------------------------
# Persistent Housing Stress Dataset
# Average 2019-2023
#-----------------------------------------------------------

persistent_stress <- tableau_data %>%
  
  group_by(
    GEOID,
    county_name
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
    
    avg_poverty_rate =
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
    
  ) %>%
  
  arrange(
    desc(avg_housing_stress)
  )



write_csv(
  
  persistent_stress,
  
  file.path(
    tableau_dir,
    "persistent_housing_stress.csv"
  )
  
)



#-----------------------------------------------------------
# Executive Summary KPIs
# 2023
#-----------------------------------------------------------

executive_summary <- housing_2023 %>%
  
  summarise(
    
    Counties =
      n_distinct(GEOID),
    
    Median_Income =
      mean(
        median_income,
        na.rm = TRUE
      ),
    
    Median_Rent =
      mean(
        median_rent,
        na.rm = TRUE
      ),
    
    Median_Home_Value =
      mean(
        median_home_value,
        na.rm = TRUE
      ),
    
    Poverty_Rate =
      mean(
        poverty_rate,
        na.rm = TRUE
      ),
    
    Rent_Burden =
      mean(
        rent_burden_rate,
        na.rm = TRUE
      ),
    
    Housing_Stress_Index =
      mean(
        housing_stress_index,
        na.rm = TRUE
      )
    
  )



write_csv(
  
  executive_summary,
  
  file.path(
    tableau_dir,
    "executive_summary.csv"
  )
  
)



#-----------------------------------------------------------
# County Rankings - 2023
#-----------------------------------------------------------

county_rankings_2023 <- housing_2023 %>%
  
  arrange(
    desc(housing_stress_index)
  ) %>%
  
  mutate(
    
    Rank =
      row_number()
    
  ) %>%
  
  select(
    
    Rank,
    county_name,
    housing_stress_index,
    median_income,
    median_rent,
    median_home_value,
    poverty_rate,
    rent_burden_rate,
    rent_to_income_ratio
    
  )


write_csv(
  
  county_rankings_2023,
  
  file.path(
    tableau_dir,
    "county_rankings_2023.csv"
  )
  
)



#-----------------------------------------------------------
# County Rankings - Persistent Stress
#-----------------------------------------------------------

county_rankings_persistent <- persistent_stress %>%
  
  mutate(
    
    Rank =
      row_number()
    
  ) %>%
  
  select(
    
    Rank,
    county_name,
    avg_housing_stress,
    avg_income,
    avg_rent,
    avg_home_value,
    avg_poverty_rate,
    avg_rent_burden
    
  )



write_csv(
  
  county_rankings_persistent,
  
  file.path(
    tableau_dir,
    "county_rankings_persistent.csv"
  )
  
)



#-----------------------------------------------------------
# Trend Dataset
# 2019-2023
#-----------------------------------------------------------

trend_summary <- tableau_data %>%
  
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



write_csv(
  
  trend_summary,
  
  file.path(
    tableau_dir,
    "trend_summary.csv"
  )
  
)



#-----------------------------------------------------------
# County Explorer Dataset
#-----------------------------------------------------------

county_profile <- tableau_data %>%
  
  select(
    county_name,
    year,
    median_income,
    median_rent,
    median_home_value,
    poverty_rate,
    rent_burden_rate,
    rent_to_income_ratio,
    housing_stress_index
  ) %>%
  
  arrange(
    county_name,
    year
  )



write_csv(
  
  county_profile,
  
  file.path(
    tableau_dir,
    "county_profile.csv"
  )
  
)



#-----------------------------------------------------------
# Disconnect
#-----------------------------------------------------------

dbDisconnect(con)


cat(
  "\nTableau exports completed successfully.\n"
)

cat(
  "Files saved to:",
  tableau_dir,
  "\n"
)