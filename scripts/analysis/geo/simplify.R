# -------------------------------------------------------------------------------------

setwd("~/Github/datos/scripts/analysis/geo")
source("../init.R")

library("rmapshaper")
library("pryr")

cities_shp <- sf::st_read("../../data/geo/conjunto_de_datos/areas_geoestadisticas_municipales.shp")
states_shp <- sf::st_read("../../data/geo/conjunto_de_datos/areas_geoestadisticas_estatales.shp")

# converting coordinates
# https://gis.stackexchange.com/questions/296170/r-shapefile-transform-longitude-latitude-coordinates
cities_shp <- sf::st_transform(cities_shp, "+proj=longlat +ellps=WGS84 +datum=WGS84")
states_shp <- sf::st_transform(states_shp, "+proj=longlat +ellps=WGS84 +datum=WGS84")

# we extract the centroid
cities_shp <- cities_shp %>%
  dplyr::mutate(
    LONGITUDE = purrr::map_dbl(geometry, ~st_centroid(.x)[[1]]),
    LATITUDE = purrr::map_dbl(geometry, ~st_centroid(.x)[[2]])
  ) %>%
  dplyr::group_by(CVE_ENT, CVE_MUN) %>%
  dplyr::slice(1) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(
    CVE_MUN = as.numeric(CVE_MUN),
    CVE_ENT = as.numeric(CVE_ENT)
  )

states_shp <- states_shp %>%
  dplyr::mutate(
    LONGITUDE = purrr::map_dbl(geometry, ~st_centroid(.x)[[1]]),
    LATITUDE = purrr::map_dbl(geometry, ~st_centroid(.x)[[2]])
  ) %>%
  dplyr::mutate(
    CVE_ENT = as.numeric(CVE_ENT)
  )

# Simplifying... states
# https://gis.stackexchange.com/a/243576/162042
pryr::object_size(states_shp)
# 11.1 MB
states_shp <- rmapshaper::ms_simplify(states_shp) %>%
  sf::st_as_sf()
pryr::object_size(states_shp)
# 613 kB
sf::st_write(states_shp, paste0("bak/geo/", "estados.shp"))


# Simplifying... cities
pryr::object_size(cities_shp)
# 54.4 MB
cities_shp <- rmapshaper::ms_simplify(cities_shp) %>%
  sf::st_as_sf()

pryr::object_size(cities_shp)
# 4.31 MB

# Write them now!
sf::st_write(cities_shp, paste0("bak/geo/", "municipios.shp"))

# -------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------

library(geojsonio)

cities_shp <- sf::st_read(config$data$geo$city)
states_shp <- sf::st_read(config$data$geo$state)

states_json <- geojsonio::geojson_json(states_shp)
cities_json <- geojsonio::geojson_json(cities_shp)

states_json_simplified <- rmapshaper::ms_simplify(states_json)
cities_json_simplified <- rmapshaper::ms_simplify(states_json)

geojson_write(states_json_simplified, file = "bak/geo/states.geojson")
geojson_write(states_json_simplified, file = "bak/geo/cities.geojson")

