library(readr)
library(sf)
library(raster)

bstn_blgs <- read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/Boston_buildingfootprints.shp")
saveRDS(bstn_blgs, file = "~/GeoSpaAR/nightlightF22/data/bstn_blgs.rds")

bstn_tract <- read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/Boston_2020census.geojson")
saveRDS(bstn_tract, file = "~/GeoSpaAR/nightlightF22/data/bstn_tract.rds")

sf_ftprnt <- read_sf("C:/Users/leste/OneDrive/Documents/SF_buildingfootprint.geojson")
saveRDS(sf_ftprnt, file = "~/GeoSpaAR/nightlightF22/data/sf_buildings.rds")

sf_tract <- read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/SanFrancisco_2020census.geojson")
saveRDS(sf_tract, file = "~/GeoSpaAR/nightlightF22/data/sf_tract.rds")

bstn_ph <- read_csv("notebooks/extdata/boston_publichousing.csv")
bstn_ph <-
  st_as_sf(boston_publichousing, coords = c("Long", "Lat"), crs = 4326) %>%
  st_transform(crs = st_crs(bstn_census))
saveRDS(bstn_ph, file = "~/GeoSpaAR/nightlightF22/data/bstn_ph.rds")

sf_grid<- raster("~/GeoSpaAR/nightlightF22/notebooks/extdata/SF_gridpop_2010.tif")
saveRDS(sf_grid, file = "~/GeoSpaAR/nightlightF22/data/sf_grid.rds")

boston_pop <- read_csv("~/GeoSpaAR/nightlightF22/notebooks/extdata/bstn_pop.csv")
saveRDS(boston_pop, file = "~/GeoSpaAR/nightlightF22/data/bstn_pop.rds")

