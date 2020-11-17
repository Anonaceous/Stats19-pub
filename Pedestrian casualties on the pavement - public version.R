#
# Interactive map of pedestrian casualties on the pavement
#

library(tidyverse)
library(stats19)
library(mapdeck)

# The years for which we want to plot the data
target_years <- 2014:2019

# Directory for cached STATS19 data. Needs RW access. 
custom_data_dir <- "C:\\stats19_data_dir"

# Mapdeck access token.  Register at https://mapdeck.com to obtain one.
access_token <- 'insert access token here'

# Get the crash data from the year
casualties <- get_stats19(year=target_years, type = "Casualties" , ask=FALSE, data_dir = custom_data_dir)
crashes <- get_stats19(year=target_years, type="Accidents", ask=FALSE, data_dir=custom_data_dir)

# obtain the accident index numbers for crashes involving pedestrian casualties
# on the footway for verge. Remove duplicates
casualties_peds <- casualties[casualties$casualty_type=='Pedestrian', ]
casualties_peds <- casualties_peds[casualties_peds$pedestrian_location =="On footway or verge", ]
casualties_peds <- data.frame(accident_index=unique(casualties_peds))

# Now join the crash data with the casualty data, so we have locations for pedestrian casualties
merged_data <- merge(x=crashes, y=casualties_peds, by.x="accident_index", by.y="accident_index.accident_index")

# Colours for plotting
yellow <- '#FFFF00FF'
red <- '#FF0000FF'

# Separate the fatal and the serious injuries
fatal <- merged_data[merged_data$accident_index.casualty_severity=="Fatal",]
serious <- merged_data[merged_data$accident_index.casualty_severity=="Serious",]

# 200 is about right for a UK-wide plot.  If zooming in to small areas, reduce this number. 
blob_radius <- 200

# Draw the map. 
mapdeck(style = mapdeck_style(style = 'dark'), pitch = 0, token = access_token) %>%
  add_scatterplot(layer_id = 'serious', data = format_sf(serious,1), lat = 'latitude', lon = 'longitude', fill_colour = yellow, tooltip="accident_index", radius = blob_radius) %>%
  add_scatterplot(layer_id = 'fatal', data = format_sf(fatal,1), lat = 'latitude', lon = 'longitude', fill_colour = red, tooltip="accident_index", radius = blob_radius) 

