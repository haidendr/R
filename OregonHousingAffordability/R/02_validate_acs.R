############################################################
# Project: Oregon Housing Affordability & Equity Analysis
# Script: 02_validate_acs.R
# Purpose: Validate raw ACS county data (2019-2023)
############################################################


#-----------------------------------------------------------
# Load setup
#-----------------------------------------------------------

setwd("C:<insert your working directory here>/scripts")
source("00_setup.R")


#-----------------------------------------------------------
# Create validation log
#-----------------------------------------------------------

validation_output <- file.path(
  processed_dir,
  "validation_report.txt"
)


sink(validation_output)


cat("============================================\n")
cat("Oregon Housing ACS Validation Report\n")
cat("ACS Years: 2019-2023\n")
cat("============================================\n\n")


#-----------------------------------------------------------
# Load all raw ACS files
#-----------------------------------------------------------

acs_list <- list()


for (year in acs_years) {
  
  
  file_path <- file.path(
    raw_dir,
    paste0("acs_", year, "_raw.csv")
  )
  
  
  cat("Checking file:", file_path, "\n")
  
  
  if (file.exists(file_path)) {
    
    
    data <- read_csv(
      file_path,
      show_col_types = FALSE
    )
    
    
    acs_list[[as.character(year)]] <- data
    
    
    cat(
      "Loaded",
      year,
      "- Rows:",
      nrow(data),
      "\n\n"
    )
    
    
  } else {
    
    
    cat(
      "ERROR: Missing file for",
      year,
      "\n\n"
    )
    
  }
  
}


#-----------------------------------------------------------
# Combine datasets
#-----------------------------------------------------------

acs_all <- bind_rows(
  acs_list
)


cat("\nCombined dataset rows:",
    nrow(acs_all),
    "\n\n")


#-----------------------------------------------------------
# Check expected counties
#-----------------------------------------------------------

cat("County count by year:\n")

county_check <- acs_all %>%
  group_by(year) %>%
  summarise(
    counties = n_distinct(GEOID)
  )


print(county_check)


cat("\n")


#-----------------------------------------------------------
# Duplicate GEOID-year check
#-----------------------------------------------------------

cat("Duplicate GEOID-year records:\n")


duplicates <- acs_all %>%
  count(
    GEOID,
    year
  ) %>%
  filter(
    n > 1
  )


print(duplicates)


cat("\n")


#-----------------------------------------------------------
# Missing values
#-----------------------------------------------------------

cat("Missing values by variable:\n")


missing_values <- acs_all %>%
  summarise(
    across(
      everything(),
      ~sum(is.na(.))
    )
  )


print(missing_values)


cat("\n")


#-----------------------------------------------------------
# GEOID validation
#-----------------------------------------------------------

cat("Invalid GEOID format:\n")


invalid_geoid <- acs_all %>%
  filter(
    nchar(GEOID) != 5
  )


print(invalid_geoid)


cat("\n")


#-----------------------------------------------------------
# Negative value checks
#-----------------------------------------------------------

cat("Negative numeric values:\n")


numeric_columns <- acs_all %>%
  select(
    ends_with("E")
  )


negative_values <- numeric_columns %>%
  summarise(
    across(
      everything(),
      ~sum(. < 0, na.rm = TRUE)
    )
  )


print(negative_values)


cat("\n")


#-----------------------------------------------------------
# Summary statistics
#-----------------------------------------------------------

cat("Summary statistics:\n\n")


summary_stats <- acs_all %>%
  select(
    median_incomeE,
    median_rentE,
    median_home_valueE,
    poverty_populationE,
    total_populationE
  ) %>%
  summary()


cat("\n============================================\n")
cat("Validation Complete\n")
cat("============================================\n")


sink()


cat(
  "Validation report saved:",
  validation_output,
  "\n"
)