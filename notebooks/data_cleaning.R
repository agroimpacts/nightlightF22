library(readr)
library(sf)
library(raster)
library(tidycensus)

# BOSTON DATA CLEANING

# Write all vector files to rds
# Project to Mass State Plan CRS
# Write CSV files to SF objects
# Create outline of Boston

bstn_tract <-
  read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/Boston_2020census.geojson") %>%
  st_transform(crs = 26986)
saveRDS(bstn_tract, file = "~/GeoSpaAR/nightlightF22/data/bstn_tract.rds")

bstn_ph <- read_csv("notebooks/extdata/boston_publichousing.csv")
bstn_ph <-
  st_as_sf(bstn_ph, coords = c("Long", "Lat"), crs = 4326) %>%
  st_transform(crs = 26986)
saveRDS(bstn_ph, file = "~/GeoSpaAR/nightlightF22/data/bstn_ph.rds")

bstn_blgs <-
  read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/structures_poly_35.shp") %>%
  st_transform(crs = 4326) %>% st_transform(crs = 26986)
saveRDS(bstn_blgs, file = "~/GeoSpaAR/nightlightF22/data/bstn_bldg.rds")

boston_pop <- read_csv("~/GeoSpaAR/nightlightF22/notebooks/extdata/bstn_pop.csv")
saveRDS(boston_pop, file = "~/GeoSpaAR/nightlightF22/data/bstn_pop.rds")

sf_use_s2(FALSE)
bstnoutline <- st_union(bstn_tract) %>% st_buffer(dist = 0.0001) %>%
  rmapshaper::ms_simplify(.)
saveRDS(bstntract, file = "~/GeoSpaAR/nightlightF22/data/bstn.rds")

# SAN FRAN DATA CLEANING
#sanfran_pop_data <-  read_csv("notebooks/extdata/San_Francisco_Pop_data.csv")

#saveRDS(sanfran_pop_data, file = "~/FinalProject_GeospatialAnalysisWithR/nightlightF22/data/sanfrisco_pop.rds")

sf_ph <- read_csv("notebooks/extdata/publichousing_SanFrancisco.csv")

sf_ph <- st_as_sf(sf_ph, coords = c("Long", "Lat"), crs = 4326) %>%
         st_transform(crs = 3310)
saveRDS(sf_ph,file = "data/sf_ph.rds")

sf_ftprnt <- read_sf("notebooks/extdata/SF_buildingfootprint.geojson")  %>%  st_transform(crs = 4326) %>% st_transform(crs = 3310)
saveRDS(sf_ftprnt, file = "data/sf_buildings.rds")

sf_tract <- read_sf("notebooks/extdata/SanFrancisco_2020census.geojson") %>% st_transform(crs = 3310)
saveRDS(sf_tract, file = "data/sf_tract.rds")

library(tidycensus)
census_api_key("335e46144113732bfbc05dafe54edfbfdd433299")
Sanfran_poptract <-  get_acs(geography = "tract",state = "CA", county = "San Francisco County",variables = "B01003_001", geometry = TRUE) %>% st_transform(crs = 3310)
saveRDS(Sanfran_poptract, file = "data/sf_poptract.rds")

sf_use_s2(FALSE)
sfoutline <- st_union(Sanfran_poptract) %>% st_buffer(dist = 0.0001) %>%
  rmapshaper::ms_simplify(.)

sanfran <- sfoutline %>% st_transform(3310)
saveRDS(sanfran, file = "data/sf.rds")










