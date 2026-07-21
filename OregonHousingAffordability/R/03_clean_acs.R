############################################################
# Project: Oregon Housing Affordability & Equity Analysis
# Script: 03_clean_acs.R
# Purpose: Clean and combine ACS 5-Year county data
# Years: 2019–2023
############################################################

#-----------------------------------------------------------
# Load setup
#-----------------------------------------------------------

setwd("C:<insert your working directory here>/scripts")
source("00_setup.R")

library(readr)
library(dplyr)
library(stringr)

#-----------------------------------------------------------
# Read all raw ACS files
#-----------------------------------------------------------

acs_list <- lapply(acs_years, function(year) {
  
  file_path <- file.path(
    raw_dir,
    paste0("acs_", year, "_raw.csv")
  )
  
  read_csv(
    file_path,
    show_col_types = FALSE
  )
  
})

# Combine all years

acs_raw <- bind_rows(acs_list)

cat("Rows imported:", nrow(acs_raw), "\n")

#-----------------------------------------------------------
# Clean county names
#-----------------------------------------------------------

acs_clean <- acs_raw %>%
  mutate(
    county_name = str_remove(NAME, " County, Oregon")
  )

#-----------------------------------------------------------
# Select estimate variables only
#-----------------------------------------------------------

acs_clean <- acs_clean %>%
  select(
    
    GEOID,
    county_name,
    year,
    
    median_incomeE,
    median_rentE,
    median_home_valueE,
    
    poverty_populationE,
    total_populationE,
    
    renter_totalE,
    rent30_34E,
    rent35_39E,
    rent40_49E,
    rent50_plusE
    
  )

#-----------------------------------------------------------
# Rename variables
#-----------------------------------------------------------

acs_clean <- acs_clean %>%
  rename(
    
    median_income = median_incomeE,
    
    median_rent = median_rentE,
    
    median_home_value = median_home_valueE,
    
    poverty_population = poverty_populationE,
    
    total_population = total_populationE,
    
    renter_total = renter_totalE,
    
    rent30_34 = rent30_34E,
    
    rent35_39 = rent35_39E,
    
    rent40_49 = rent40_49E,
    
    rent50_plus = rent50_plusE
    
  )

#-----------------------------------------------------------
# Derived variables
#-----------------------------------------------------------

acs_clean <- acs_clean %>%
  mutate(
    
    poverty_rate =
      poverty_population /
      total_population,
    
    rent_to_income_ratio =
      (median_rent * 12) /
      median_income,
    
    rent_burden_rate =
      (
        rent30_34 +
          rent35_39 +
          rent40_49 +
          rent50_plus
      ) /
      renter_total,
  )%>%
  mutate(
    income_score =
      1 - scales::rescale(median_income),
    
    rent_score =
      scales::rescale(median_rent),
    
    poverty_score =
      scales::rescale(poverty_rate),
    
    burden_score =
      scales::rescale(rent_burden_rate),
    
    ratio_score =
      scales::rescale(rent_to_income_ratio),
    
    
    # Housing Stress Index
    housing_stress_index =
      (
        income_score +
          rent_score +
          poverty_score +
          burden_score +
          ratio_score
      ) / 5
    
  )

#-----------------------------------------------------------
# Validation
#-----------------------------------------------------------

cat("\nChecking for duplicate county-year records...\n")

duplicates <- acs_clean %>%
  count(GEOID, year) %>%
  filter(n > 1)

print(duplicates)

cat("\nMissing values by variable:\n")

print(
  
  acs_clean %>%
    summarise(
      across(
        everything(),
        ~sum(is.na(.))
      )
    )
  
)

cat("\nCounty count by year:\n")

print(
  
  acs_clean %>%
    group_by(year) %>%
    summarise(
      counties = n_distinct(GEOID)
    )
  
)

cat("\nHousing Stress Index summary:\n")

print(
  summary(acs_clean$housing_stress_index)
)

cat("\nChecking for invalid Housing Stress Index values...\n")

print(
  acs_clean %>%
    filter(
      housing_stress_index < 0 |
        housing_stress_index > 1
    )
)

cat("\nMissing Housing Stress Index values:\n")

print(
  sum(
    is.na(
      acs_clean$housing_stress_index
    )
  )
)

cat("\nChecking derived affordability indicators:\n")

print(
  acs_clean %>%
    summarise(
      min_poverty_rate = min(
        poverty_rate,
        na.rm = TRUE
      ),
      
      max_poverty_rate = max(
        poverty_rate,
        na.rm = TRUE
      ),
      
      min_rent_burden = min(
        rent_burden_rate,
        na.rm = TRUE
      ),
      
      max_rent_burden = max(
        rent_burden_rate,
        na.rm = TRUE
      ),
      
      min_rent_ratio = min(
        rent_to_income_ratio,
        na.rm = TRUE
      ),
      
      max_rent_ratio = max(
        rent_to_income_ratio,
        na.rm = TRUE
      )
    )
)

cat("\nFinal dataset dimensions:\n")

print(
  dim(acs_clean)
)

cat("\nValidation Summary:\n")

if(
  nrow(duplicates) == 0 &
  sum(is.na(acs_clean$housing_stress_index)) == 0
){
  
  cat("DATA VALIDATION PASSED\n")
  
} else {
  
  cat("DATA VALIDATION FAILED - REVIEW ISSUES\n")
  
}


#-----------------------------------------------------------
# Export cleaned panel
#-----------------------------------------------------------

output_file <- file.path(
  processed_dir,
  "oregon_housing_panel.csv"
)

write_csv(
  acs_clean,
  output_file
)

cat("\nClean panel dataset saved to:\n")
cat(output_file, "\n")

cat("\nRows:", nrow(acs_clean), "\n")
cat("Columns:", ncol(acs_clean), "\n")