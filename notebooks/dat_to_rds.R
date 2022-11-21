bstn_ftprnt <- read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/Boston_buildingfootprints.shp")
saveRDS(bstn_ftprnt, file = "~/GeoSpaAR/nightlightF22/data/boston_buildings.rds")

bstn_census <- read_sf("~/GeoSpaAR/nightlightF22/notebooks/extdata/Boston_2020census.geojson")
saveRDS(bstn_census, file = "~/GeoSpaAR/nightlightF22/data/boston_2020census.rds")

sf_ftprnt <- read_sf("C:/Users/leste/OneDrive/Documents/SF_buildingfootprint.geojson")
saveRDS(sf_ftprnt, file = "~/GeoSpaAR/nightlightF22/data/sf_buildings.rds")

