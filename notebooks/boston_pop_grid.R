# create gridded population raster from Boston census data, as well as grid of
# percentages of public housing

library(sf)
library(dplyr)
library(tidyr)
library(terra)
library(here)
library(sp)


# Boston population raster
bstn_tract <- readRDS(here("data/bstn_tract.RDS"))
bstn_pop <- readRDS(here("data/bstn_pop.RDS"))
bstn_ph <- readRDS(here("data/bstn_ph.RDS"))
bstn_bldg <- readRDS(here("data/bstn_bldg.RDS"))

# Intersect Public Housing locations with Buildings to get Public Housing in polygon format
bstn_intersect<- bstn_bldg  %>% st_intersects(st_combine(bstn_ph), .)
bstn_php <- bstn_bldg %>% mutate(AreaFt = st_area(.)) %>%
  slice(bstn_intersect[[1]])
saveRDS(bstn_php, file = here("data/bstn_phpoly.rds"))

# Drop the column header row in census pop
bstn_pop2 <- bstn_pop[-1,]
# Add area to census tracts then join population data
bstntract_pop <- bstn_tract %>%
  mutate(Area = as.numeric(units::set_units(st_area(.), "ft^2"))) %>%
  mutate(TRACT = TRACTCE20) %>%
  inner_join(., bstn_pop2, by = "TRACT") %>%
  rename(TotalPop = P0020001)

# Get nightlights grid
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
# plot(pgeo)
# plot(bstn_tract %>% st_geometry(), add = TRUE)

# Intersect tracts with polygon grid and calculate area of segments
# then calculate population within each 'cutup' census tract piece
tracts_cut <- st_intersection(x = bstntract_pop, y = pgeo) %>%
  mutate(area_seg = as.numeric(st_area(.))) %>%
  mutate(pop_seg = area_seg / area * TotalPop)
