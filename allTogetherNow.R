#downloading census zipcode info

# Load libraries
library(censusapi)
library(tidycensus)
library(tidyverse)
library(sf)
library(stringr)
library(reshape2)
library(data.table)

wd <- dirname(rstudioapi::getActiveDocumentContext()$path)

#set and install api key
api_key <-"219399afeaa3b3c28f7b5351b56bb92d7d0f576d"

#load zip by county file
county_list2 <- county_list <- c("Bucks County, Pennsylvania", "Chester County, Pennsylvania", "Delaware County, Pennsylvania", "Montgomery County, Pennsylvania", "Philadelphia County, Pennsylvania", "Burlington County, New Jersey", "Camden County, New Jersey", "Gloucester County, New Jersey", "Mercer County, New Jersey")
county_zip <- read.csv("C:/Users/jdobkin/Documents/censusRetrival/github/countyZip2.csv", header = TRUE)
county_zip2 <- county_zip %>% 
  filter(NAME %in% county_list) 

#output name
output_Name <- '\\acs_Output.csv'

#varible list
vari = c(ratio_Pov_to_income                    <- "S1701_C01_042E",
         hispanic                               <- "B03003_003E",
         afArm                                  <- "B02009_001E",
         total_pop_pov                          <- "S1701_C01_001E",
         total_pop                              <- "B01001_001E"
         )

rename = c("C17002_008E" = "count_pov",
          "B03003_003E" = "count_hispanic_pop",
          "B02009_001E" = "afAm",
          "B01001_001E"= "total_pop"
)

#geom list
zip_list <- c(county_zip2$GEOID)
dvrpc_states <- c("PA", "NJ")

#### get data #####

#get zip code level data
tmp = get_acs(geography = "zcta",
              state = dvrpc_states,
              variables = vari,
              output = "wide"
)

zip_Only <- tmp %>% 
  filter(GEOID %in% zip_list)  

#get county level data

tmp2 = get_acs(geography = "county",
               state = dvrpc_states,
               variables = vari,
               output = "wide"
)

county_Only <- tmp2 %>% 
  filter(NAME %in% county_list)  


#joining
cnty_name <- merge(x = zip_Only, y = county_zip2, by = "GEOID", all.x = TRUE)
county_plus_zip <- merge(x = cnty_name, y = county_Only, by.x = "NAME.y", by.y = "NAME", all.x = TRUE)

#clean up
drop <- c("GEOID.y", "c", "city", "county", "state_abbr")
final_df <- select(county_plus_zip, -drop)

#####Export CSV files#####

path_out = wd

# Create csv files

write.csv(final_df,paste0(path_out, output_Name),row.names = FALSE)
