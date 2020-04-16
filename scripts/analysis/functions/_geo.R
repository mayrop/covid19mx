# -------------------------------------------------------------------------------------

get_cities_shp <- function(file) {
  shp <- sf::st_read(file)
  # converting coordinates
  # https://gis.stackexchange.com/questions/296170/r-shapefile-transform-longitude-latitude-coordinates
  shp <- st_transform(shp, "+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  # we extract the centroid
  shp %>%
    dplyr::mutate(
      LONGITUDE = purrr::map_dbl(geometry, ~st_centroid(.x)[[1]]),
      LATITUDE = purrr::map_dbl(geometry, ~st_centroid(.x)[[2]])
    )
}

# -------------------------------------------------------------------------------------