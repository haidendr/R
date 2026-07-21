############################################################
# Project: Oregon Housing Affordability & Equity Analysis
# Script: 06_mapping.R
# Purpose: Create county-level thematic maps
# ACS 2019-2023 5-Year Estimates
############################################################


#-----------------------------------------------------------
# Load setup
#-----------------------------------------------------------

setwd("C:<insert your working directory here>/scripts")
source("00_setup.R")


library(tidyverse)
library(tidycensus)
library(sf)
library(ggplot2)
library(scales)



#-----------------------------------------------------------
# Create figures directory
#-----------------------------------------------------------

if (!dir.exists(figure_dir)) {
  
  dir.create(
    figure_dir,
    recursive = TRUE
  )
  
}



#-----------------------------------------------------------
# Load cleaned panel data
#-----------------------------------------------------------

housing <- read_csv(
  
  clean_data_path,
  
  show_col_types = FALSE
  
)



#-----------------------------------------------------------
# Download Oregon county boundaries
#-----------------------------------------------------------

counties_sf <- get_acs(
  
  geography = "county",
  
  state = state_code,
  
  survey = survey,
  
  year = 2023,
  
  variables = "B19013_001",
  
  geometry = TRUE
  
) %>%
  
  select(
    GEOID,
    geometry
  ) %>%
  
  mutate(
    GEOID = as.character(GEOID)
  )



#-----------------------------------------------------------
# Map function
#-----------------------------------------------------------

create_map <- function(
    
  data,
  variable,
  title,
  legend_title,
  filename,
  subtitle
  
) {
  
  
  p <- ggplot(data) +
    
    geom_sf(
      
      aes(
        fill = .data[[variable]]
      ),
      
      color = "white",
      
      linewidth = 0.3
      
    ) +
    
    scale_fill_viridis_c(
      
      option = "plasma",
      
      labels = comma,
      
      na.value = "grey90"
      
    ) +
    
    labs(
      
      title = title,
      
      subtitle = subtitle,
      
      fill = legend_title
      
    ) +
    
    theme_minimal(
      
      base_size = 12
      
    ) +
    
    theme(
      
      panel.grid = element_blank(),
      
      axis.text = element_blank(),
      
      axis.title = element_blank(),
      
      axis.ticks = element_blank()
      
    )
  
  
  ggsave(
    
    filename = file.path(
      figure_dir,
      filename
    ),
    
    plot = p,
    
    width = 9,
    
    height = 6,
    
    dpi = 300
    
  )
  
  
  print(p)
  
}



############################################################
# PART 1
# 2023 Housing Conditions Maps
############################################################


map_year <- max(
  housing$year
)


housing_2023 <- housing %>%
  
  filter(
    year == map_year
  ) %>%
  
  mutate(
    GEOID = as.character(GEOID)
  )



map_data_2023 <- counties_sf %>%
  
  left_join(
    housing_2023,
    by = "GEOID"
  )


cat(
  "Creating maps for:",
  map_year,
  "\n"
)



# Median Income

create_map(
  
  map_data_2023,
  
  "median_income",
  
  "Median Household Income",
  
  "Income ($)",
  
  "median_income_map_2023.png",
  
  "Oregon Counties - 2023 ACS 5-Year Estimates"
  
)



# Median Rent

create_map(
  
  map_data_2023,
  
  "median_rent",
  
  "Median Gross Rent",
  
  "Rent ($)",
  
  "median_rent_map_2023.png",
  
  "Oregon Counties - 2023 ACS 5-Year Estimates"
  
)



# Median Home Value

create_map(
  
  map_data_2023,
  
  "median_home_value",
  
  "Median Home Value",
  
  "Home Value ($)",
  
  "median_home_value_map_2023.png",
  
  "Oregon Counties - 2023 ACS 5-Year Estimates"
  
)



# Poverty Rate

create_map(
  
  map_data_2023,
  
  "poverty_rate",
  
  "Poverty Rate",
  
  "Rate",
  
  "poverty_rate_map_2023.png",
  
  "Oregon Counties - 2023 ACS 5-Year Estimates"
  
)



# Rent Burden

create_map(
  
  map_data_2023,
  
  "rent_burden_rate",
  
  "Rent Burden Rate",
  
  "Rate",
  
  "rent_burden_map_2023.png",
  
  "Oregon Counties - 2023 ACS 5-Year Estimates"
  
)



############################################################
# PART 2
# Persistent Housing Stress Map
# Average 2019-2023
############################################################


housing_average <- housing %>%
  
  group_by(
    GEOID
  ) %>%
  
  summarise(
    
    housing_stress_index =
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
  
  mutate(
    GEOID = as.character(GEOID)
  )



map_data_hsi <- counties_sf %>%
  
  left_join(
    housing_average,
    by = "GEOID"
  )



create_map(
  
  map_data_hsi,
  
  "housing_stress_index",
  
  "Average Housing Stress Index",
  
  "HSI",
  
  "housing_stress_index_map_2019_2023.png",
  
  "Oregon Counties - Average Housing Stress Index (2019-2023)"
  
)



#-----------------------------------------------------------
# Complete
#-----------------------------------------------------------

cat(
  "\nMaps exported to:",
  figure_dir,
  "\n"
)
