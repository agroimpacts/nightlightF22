library(readr)
library(sf)
library(raster)

# BOSTON DATA CLEANING

# Write all vector files to rds
# Project to Mass State Plan CRS
# Write CSV files to SF objects
# Create outline of Boston

bstn_tract <- read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/Boston_2020census.geojson")
saveRDS(bstn_tract, file = "~/GeoSpaAR/nightlightF22/data/bstn_tract.rds")

bstn_ph <- read_csv("notebooks/extdata/boston_publichousing.csv")
bstn_ph <-
  st_as_sf(boston_publichousing, coords = c("Long", "Lat"), crs = 4326) %>%
  st_transform(crs = st_crs(bstn_census))
saveRDS(bstn_ph, file = "~/GeoSpaAR/nightlightF22/data/bstn_ph.rds")

bstn_blgs <-
  read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/Boston_buildingfootprints.shp") %>%
  st_transform(crs = 4326) %>% st_transform(crs = st_crs(bstn_ph))
saveRDS(bstn_blgs, file = "~/GeoSpaAR/nightlightF22/data/bstn_bldg.rds")

boston_pop <- read_csv("~/GeoSpaAR/nightlightF22/notebooks/extdata/bstn_pop.csv")
saveRDS(boston_pop, file = "~/GeoSpaAR/nightlightF22/data/bstn_pop.rds")

sf_use_s2(FALSE)
bstnoutline <- st_union(bstn_tract) %>% st_buffer(dist = 0.0001) %>%
  rmapshaper::ms_simplify(.)
saveRDS(bstntract, file = "~/GeoSpaAR/nightlightF22/data/bstn.rds")

# SAN FRAN DATA CLEANING

sf_pop <- read_csv("notebooks/extdata/San_Francisco_Pop_data.csv")
saveRDS(sf_pop, file = "~/FinalProject_GeospatialAnalysisWithR/nightlightF22/data/sanfrisco_pop.rds")

sf_ftprnt <- read_sf("C:/Users/leste/OneDrive/Documents/SF_buildingfootprint.geojson")
saveRDS(sf_ftprnt, file = "~/GeoSpaAR/nightlightF22/data/sf_buildings.rds")

sf_tract <- read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/SanFrancisco_2020census.geojson")
saveRDS(sf_tract, file = "~/GeoSpaAR/nightlightF22/data/sf_tract.rds")

sf_grid<- raster("~/GeoSpaAR/nightlightF22/notebooks/extdata/SF_gridpop_2010.tif")
saveRDS(sf_grid, file = "~/GeoSpaAR/nightlightF22/data/sf_grid.rds")
