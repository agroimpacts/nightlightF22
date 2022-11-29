library(readr)
library(sf)
library(raster)

bstn_ftprnt <- read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/Boston_buildingfootprints.shp")
saveRDS(bstn_ftprnt, file = "~/GeoSpaAR/nightlightF22/data/boston_buildings.rds")

bstn_census <- read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/Boston_2020census.geojson")
saveRDS(bstn_census, file = "~/GeoSpaAR/nightlightF22/data/boston_2020census.rds")

sf_ftprnt <- read_sf("C:/Users/leste/OneDrive/Documents/SF_buildingfootprint.geojson")
saveRDS(sf_ftprnt, file = "~/GeoSpaAR/nightlightF22/data/sf_buildings.rds")

sf_census <- read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/SanFrancisco_2020census.geojson")
saveRDS(sf_census, file = "~/GeoSpaAR/nightlightF22/data/sf_2020census.rds")

boston_publichousing <- read_csv("notebooks/extdata/boston_publichousing.csv")
boston_ph <- st_as_sf(boston_publichousing, coords = c("Long", "Lat"), crs = 4326)
saveRDS(boston_ph, file = "~/GeoSpaAR/nightlightF22/data/boston_ph.rds")

boston_grid<- raster("~/GeoSpaAR/nightlightF22/notebooks/extdata/boston_pop2010.tif")
saveRDS(boston_grid, file = "~/GeoSpaAR/nightlightF22/data/bstn_grid.rds")


sf_grid<- raster("~/GeoSpaAR/nightlightF22/notebooks/extdata/SF_gridpop_2010.tif")
saveRDS(sf_grid, file = "~/GeoSpaAR/nightlightF22/data/sf_grid.rds")








