library(sf)
library(dplyr)
library(terra)
library(here)

# Read in necessary data
bstn_bldg <- readRDS(here("data/bstn_bldg.rds"))
nld <- rast(here("data/Boston_nightlights_mean.tif"))
bstn <- readRDS(here("data/bstn.rds")) %>% st_transform(crs = 4326)

# Create empty raster with the same properties as nld
r <- nld[[1]]
r[] <- 1:ncell(r)
# Mask to bstn, convert to polygons and project to Mass State Plane
r <- mask(r, bstn)
p <- as.polygons(r) %>% st_as_sf()
pgeo <- st_buffer(st_transform(p, st_crs(bstn_tract)), dist = 0) %>%
  rename(cid = "2012-2021")


# Create building square footage grid
# Intersection
buildings <- st_buffer(st_make_valid(bstn_bldg), dist = 0)
build_int <- st_intersection(buildings, pgeo)

# Find total building volume in each cell
build_dims <- st_drop_geometry(build_int) %>%
  group_by(cid) %>%
  summarise(area = sum(area_seg, na.rm = TRUE),
            vol = sum(volume_seg, na.rm = TRUE) / 1e06, # to cubic hectometers
            hgt = mean(heightroof_1, na.rm = TRUE)) %>%
  left_join(p %>% rename(cid = "2012-2021"), .) %>%
  na.omit(.)

# Create gridded building volume raster
buildr <- lapply(c("area", "vol", "hgt"), function(x) {
  rasterize(vect(build_dims), r, x)
}) %>% do.call(c, .)
# plot(buildr)

writeRaster(buildr, filename = "inst/extdata/nyc_building_dims.tif",
            overwrite = TRUE)
