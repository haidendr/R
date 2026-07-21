############################################################
# Project: Oregon Housing Affordability & Equity Analysis
# Script: 01_download_acs.R
# Purpose: Download ACS 5-Year data for Oregon counties
# Years: 2019-2023
############################################################


#-----------------------------------------------------------
# Load setup
#-----------------------------------------------------------
setwd("C:<insert your working directory here>/scripts")
source("00_setup.R")

#-----------------------------------------------------------
# ACS variables
#-----------------------------------------------------------
acs_variables <- c(
  
  median_income      = "B19013_001",
  
  median_rent        = "B25064_001",
  
  median_home_value  = "B25077_001",
  
  poverty_population = "B17001_002",
  
  total_population   = "B17001_001",
  
  renter_total       = "B25070_001",
  
  rent30_34          = "B25070_007",
  
  rent35_39          = "B25070_008",
  
  rent40_49          = "B25070_009",
  
  rent50_plus        = "B25070_010"
  
)


#-----------------------------------------------------------
# Download ACS data by year
#-----------------------------------------------------------


for (year in acs_years) {
  
  
  cat("\nDownloading ACS", year, "\n")
  
  
  acs_data <- get_acs(
    
    geography = "county",
    
    variables = acs_variables,
    
    state = state_code,
    
    survey = survey,
    
    year = year,
    
    geometry = TRUE,
    
    output = "wide"
    
  )
  
  
  # Add year variable
  
  acs_data <- acs_data %>%
    mutate(
      year = year
    )
  
  
  # Save raw data
  
  output_file <- file.path(
    raw_dir,
    paste0(
      "acs_",
      year,
      "_raw.csv"
    )
  )
  
  
  write_csv(
    acs_data,
    output_file
  )
  
  
  cat(
    "Saved:",
    output_file,
    "\n"
  )
  
}


cat("\nACS download complete.\n")