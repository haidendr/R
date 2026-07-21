############################################################
# Project: Oregon Housing Affordability & Equity Analysis
# Script: 00_setup.R
# Purpose: Project setup and configuration
############################################################


#-----------------------------------------------------------
# Load packages
#-----------------------------------------------------------

library(tidyverse)
library(tidycensus)
library(sf)
library(DBI)
library(RSQLite)


#-----------------------------------------------------------
# Project directories
#-----------------------------------------------------------

raw_dir <- "data/raw"
processed_dir <- "data/processed"
external_dir <- "data/external"
figure_dir <- "figures"


# Create folders if they do not exist

directories <- c(
  raw_dir,
  processed_dir,
  external_dir,
  figure_dir
)

for (dir in directories) {
  
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
  
}


#-----------------------------------------------------------
# ACS configuration
#-----------------------------------------------------------

# ACS 5-Year estimates

acs_years <- 2019:2023

survey <- "acs5"

state_code <- "41"   # Oregon


#-----------------------------------------------------------
# Census API key
#-----------------------------------------------------------

census_api_key("<insert your API key here>", install = TRUE, overwrite=TRUE)


#-----------------------------------------------------------
# Database configuration
#-----------------------------------------------------------

database_path <- file.path(
  processed_dir,
  "oregon_housing.sqlite"
)


#-----------------------------------------------------------
# File configuration
#-----------------------------------------------------------

clean_data_path <- file.path(
  processed_dir,
  "oregon_housing_panel.csv"
)


#-----------------------------------------------------------
# Helper message
#-----------------------------------------------------------

cat("----------------------------------\n")
cat("Oregon Housing Analysis Setup Complete\n")
cat("----------------------------------\n")

cat("ACS Years:",
    paste(acs_years, collapse = ", "),
    "\n")

cat("Database:",
    database_path,
    "\n")