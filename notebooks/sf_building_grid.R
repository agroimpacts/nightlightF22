library(sf)
library(dplyr)
library(terra)
library(here)

# Read in necessary data
sanfrisco_bldg <- readRDS(here("data/sf_buildings.RDS"))
sanfrisco_pop_tract <- readRDS(here("data/sf_poptract.rds"))
# Get nightlights grid
crs <- "+proj=aea +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
nld <- rast(here("data/SF_nightlights_mean.tif")) %>%
  project(.,crs)
sfran <- readRDS(here("data/sf.rds")) %>%
  st_transform(crs = 3310) %>%
  st_as_sf()

# Create empty raster with the same properties as nld
r <- nld[[1]]
values(r) <- 1:ncell(r)
# Mask to San Francisco, convert to polygons and project to California Albers
r <-mask(r, sfran)
p <- as.polygons(r) %>% st_as_sf() %>% rename(cid = "2012-2021")
pgeo <- st_buffer(st_transform(p, st_crs(sanfrisco_pop_tract)), dist = 0)

# Create building square footage grid
# Intersection
sf_buildings <- st_buffer(st_make_valid(sanfrisco_bldg), dist = 0)
sf_build_int <- st_intersection(sf_buildings, pgeo)

# Find total building square ft in each cell and convert square ft to square m
sf_build_dims <- st_drop_geometry(sf_build_int) %>%
  group_by(cid) %>%
  summarise(area_sqm = (sum(AREA_SQ_FT, na.rm = TRUE)) / 10.764) %>%
  left_join(p %>% rename(cid = "2012-2021"), .) %>%
  na.omit(.)

area_buildings <- st_area(sf_buildings)
sf_build_dims <- st_drop_geometry(sf_build_int) %>%
  group_by(cid) %>%
  summarise(area_sqm = (as.numeric(hgt_median_m))/4.3 * area_buildings) %>%
  left_join(p, .) %>%
  na.omit(.)


# Create gridded building sq footage raster
sf_buildr <- rasterize(vect(sf_build_dims), r, field = 'area_sqm')
plot(sf_buildr)

writeRaster(sf_buildr, filename = here("data/sf_bldg_grid.tif"),
            overwrite = TRUE)
