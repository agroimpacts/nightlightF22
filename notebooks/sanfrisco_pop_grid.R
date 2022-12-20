# create gridded population raster from San Francisco census data, as well as grid of
# percentages of public housing

library(sf)
library(dplyr)
library(tidyr)
library(terra)
library(here)
library(sp)
library(exactextractr)


# San Francisco population raster

sanfrisco_pop_tract <- readRDS(here("data/sf_poptract.rds"))
sanfrisco_ph <- readRDS(here("data/sf_ph.RDS"))
sanfrisco_bldg <- readRDS(here("data/sf_buildings.RDS"))

# Intersect Public Housing locations with Buildings to get Public Housingpolygons
sf_intersect <- sanfrisco_bldg %>% st_intersects(st_combine(sanfrisco_ph), .)
sf_php <- sanfrisco_bldg %>% mutate(AreaFt = st_area(.)) %>%
  slice(sf_intersect[[1]])
saveRDS(sf_php, file = here("data/sf_phpoly.rds"))


# CREATE POPULATION GRID FOR San Francisco--------------------------------------

# Rename the estimate column to population
sanfrisco_pop_tract <- sanfrisco_pop_tract  %>% mutate(Area = as.numeric((st_area(.)))) %>%
  mutate(TotalPop = as.numeric(estimate))


# Get nightlights grid

nld <- rast(here("data/SF_nightlights_mean.tif")) %>%
  project(.,"EPSG:3310")
sfran <- readRDS(here("data/sf.rds")) %>%
  st_transform(crs = 3310) %>%
  st_as_sf()

# Create empty raster with the same properties as nld
r <- nld[[1]]
values(r) <- 1:ncell(r)
# Mask to San Francisco, convert to polygons and project to California Albers
r <- mask(r, sfran)
p <- as.polygons(r) %>% st_as_sf()
pgeo <- st_buffer(st_transform(p, st_crs(sanfrisco_pop_tract)), dist = 0) %>%
  rename(cid = "2012-2021")

# Intersect tracts with polygon grid and calculate area of segments
# Calculate population within each 'cutup' census tract piece
tracts_cut <- st_intersection(x = sanfrisco_pop_tract, y = pgeo) %>%
  mutate(area_seg = as.numeric(st_area(.))) %>%
  mutate(pop_seg = area_seg / Area * TotalPop)


# Calculate sum of population of tract segments within each cell
# The 'layer' column indicates which cell index the tract segment belongs to
r_pop_vals <- tracts_cut %>% group_by(cid) %>% st_drop_geometry() %>%
  summarise(., pop = sum(pop_seg, na.rm = TRUE))
# tracts_cut %>% select(cid) %>% plot()

# Retrieve values from r
cids <- values(r)[!is.na(values(r))]
# plot(p$geometry)

plot(sanfrisco_pop_tract["TotalPop"])

# Replace cid values with population values
poprast <- subst(r, from = r_pop_vals$cid, to = r_pop_vals$pop)
#poprast[poprast = cids[!cids %in% r_pop_vals$cid]] <- 0
# plot(sanfrisco_tract %>% st_transform(crs = 3310) %>% st_geometry(), add = TRUE)

# Convert population to integer
poprast[] <- as.integer(poprast[])

writeRaster(poprast, filename = here("data/sf_pop.tif"), overwrite = TRUE)

# CREATE GRID OF PUBLIC HOUSING PROPORTION--------------------------------------

# Create raster with proportion of pixel covered by public housing
city_background <- poprast
city_background[city_background >= 0] <- 0

ph_fraction <- exactextractr::coverage_fraction(
  raster::raster(r), st_combine(sf_php %>% st_transform(crs = 3310)))[[1]]
ph_fraction[is.na(ph_fraction)] <- 0
ph_fraction <- mask(rast(ph_fraction), city_background)
# plot(ph_fraction)

writeRaster(ph_fraction, filename = here("data/sf_ph_coverage.tif"),
            overwrite = TRUE)

