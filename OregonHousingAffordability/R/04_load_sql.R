############################################################
# Project: Oregon Housing Affordability & Equity Analysis
# Script: 04_load_sql.R
# Purpose: Load cleaned ACS panel into SQLite database
############################################################

#-----------------------------------------------------------
# Load setup
#-----------------------------------------------------------

setwd("C:<insert your working directory here>/scripts")
source("00_setup.R")

library(DBI)
library(RSQLite)
library(readr)
library(dplyr)

#-----------------------------------------------------------
# Database path
#-----------------------------------------------------------

db_path <- database_path

# Remove existing database (optional)
if (file.exists(db_path)) {
  file.remove(db_path)
}

#-----------------------------------------------------------
# Connect to SQLite
#-----------------------------------------------------------

con <- dbConnect(SQLite(), db_path)

#-----------------------------------------------------------
# Read cleaned dataset
#-----------------------------------------------------------

housing <- read_csv(
  clean_data_path,
  show_col_types = FALSE
)

cat("Rows loaded:", nrow(housing), "\n")

#-----------------------------------------------------------
# Create county table
#-----------------------------------------------------------

county <- housing %>%
  select(
    GEOID,
    county_name
  ) %>%
  distinct()

dbWriteTable(
  con,
  "county",
  county,
  overwrite = TRUE,
  row.names = FALSE
)

#-----------------------------------------------------------
# Create housing metrics table
#-----------------------------------------------------------

housing_metrics <- housing %>%
  select(
    
    GEOID,
    year,
    
    median_income,
    median_rent,
    median_home_value,
    
    poverty_population,
    total_population,
    
    poverty_rate,
    
    renter_total,
    
    rent30_34,
    rent35_39,
    rent40_49,
    rent50_plus,
    
    rent_burden_rate,
    
    rent_to_income_ratio,
    
    housing_stress_index
    
  )

dbWriteTable(
  
  con,
  
  "housing_metrics",
  
  housing_metrics,
  
  overwrite = TRUE,
  
  row.names = FALSE
  
)

#-----------------------------------------------------------
# Verify tables
#-----------------------------------------------------------

cat("\nTables in database:\n")

print(
  dbListTables(con)
)

#-----------------------------------------------------------
# Row counts
#-----------------------------------------------------------

county_rows <- dbGetQuery(
  
  con,
  
  "SELECT COUNT(*) AS rows
   FROM county"
  
)

housing_rows <- dbGetQuery(
  
  con,
  
  "SELECT COUNT(*) AS rows
   FROM housing_metrics"
  
)

cat("\nCounty table rows:",
    county_rows$rows,
    "\n")

cat("Housing metrics rows:",
    housing_rows$rows,
    "\n")

#-----------------------------------------------------------
# Years loaded
#-----------------------------------------------------------

cat("\nYears in database:\n")

print(
  
  dbGetQuery(
    
    con,
    
    "
    SELECT
        year,
        COUNT(*) AS counties
    FROM housing_metrics
    GROUP BY year
    ORDER BY year
    "
    
  )
  
)

#-----------------------------------------------------------
# Preview county table
#-----------------------------------------------------------

cat("\nCounty table preview:\n")

print(
  
  dbGetQuery(
    
    con,
    
    "
    SELECT *
    FROM county
    LIMIT 5
    "
    
  )
  
)

#-----------------------------------------------------------
# Preview housing metrics
#-----------------------------------------------------------

cat("\nHousing metrics preview:\n")

print(
  
  dbGetQuery(
    
    con,
    
    "
    SELECT *
    FROM housing_metrics
    LIMIT 5
    "
    
  )
  
)

#-----------------------------------------------------------
# Disconnect
#-----------------------------------------------------------

dbDisconnect(con)

cat("\nSQLite database created successfully.\n")
