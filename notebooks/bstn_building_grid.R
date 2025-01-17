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
pgeo <- st_buffer(st_transform(p, st_crs(bstn_bldg)), dist = 0) %>%
  rename(cid = "2012-2021")


# Create building square footage grid
# Intersection
buildings <- st_buffer(st_make_valid(bstn_bldg), dist = 0)
build_int <- st_intersection(buildings, pgeo)

# Find total building square ft in each cell and convert square ft to square m
build_dims <- st_drop_geometry(build_int) %>%
  group_by(cid) %>%
  summarise(area_sqm = (sum(AREA_SQ_FT, na.rm = TRUE)) / 10.764) %>%
  left_join(p %>% rename(cid = "2012-2021"), .) %>%
  na.omit(.)


# Create gridded building sq footage raster
buildr <- rasterize(vect(build_dims), r, field = 'area_sqm')
plot(buildr)

writeRaster(buildr, filename = here("data/bstn_bldg_grid.tif"),
            overwrite = TRUE)
