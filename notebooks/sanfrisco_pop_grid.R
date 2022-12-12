# create gridded population raster from San Francisco census data, as well as grid of
# percentages of public housing

library(sf)
library(dplyr)
library(tidyr)
library(terra)
library(here)
library(sp)


# San Francisco population raster

sanfrisco_tract <- readRDS(here("data/sf_tract.RDS"))
sanfrisco_pop <- readRDS(here("data/sanfrisco_pop.RDS"))
sanfrisco_ph <- readRDS(here("data/sf_ph.RDS"))
sanfrisco_bldg <- readRDS(here("data/sf_buildings.RDS"))



