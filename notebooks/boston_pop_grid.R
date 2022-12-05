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

# Intersect Public Housing locations with Buildings to get Public Housing as polygons
bstn_intersect<- bstn_bldg  %>% st_intersects(st_combine(bstn_ph), .)
bstn_php <- bstn_bldg %>% mutate(AreaFt = st_area(.)) %>%
  slice(bstn_intersect[[1]])
saveRDS(bstn_php, file = here("data/bstn_phpoly.rds"))

# CREATE POPULATION GRID FOR BOSTON--------------------------------------------

# Drop the column header row in census pop
bstn_pop2 <- bstn_pop[-1,]
# Add area to census tracts then join population data
bstntract_pop <- bstn_tract %>%
  mutate(Area = as.numeric((st_area(.)))) %>%
  mutate(GEOCODE = GEOID20) %>%
  inner_join(., bstn_pop2, by = "GEOCODE") %>%
  mutate(TotalPop = as.numeric(P0020001))

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
# Calculate population within each 'cutup' census tract piece
tracts_cut <- st_intersection(x = bstntract_pop, y = pgeo) %>%
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

plot(bstntract_pop["TotalPop"])

# Replace cid values with population values
# Replace NA values with 0
popr <- subst(r, from = r_pop_vals$cid, to = r_pop_vals$pop)
popr[popr == cids[!cids %in% r_pop_vals$cid]] <- 0
# plot(popr[[1]])
# plot(bstn_tract %>% st_transform(crs = 4326) %>% st_geometry(), add = TRUE)

# Convert population to integer
popr[] <- as.integer(popr[])

writeRaster(popr, filename = here("data/bstn_pop.tif"), overwrite = TRUE)

# CREATE GRID OF PUBLIC HOUSING PROPORTION--------------------------------------

# Create raster with proportion of pixel covered by public housing
city_background <- popr
city_background[city_background >= 0] <- 0

ph_fraction <- exactextractr::coverage_fraction(
  raster::raster(r), st_combine(bstn_php %>% st_transform(crs = 4326)))[[1]]
ph_fraction[is.na(ph_fraction)] <- 0
ph_fraction <- mask(rast(ph_fraction), city_background)
# plot(ph_fraction)

# writeRaster(ph_fraction, filename = here("data/bstn_ph_coverage.tif",
#             overwrite = TRUE)

