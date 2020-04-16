
# -------------------------------------------------------------------------------------

# https://timogrossenbacher.ch/2016/12/beautiful-thematic-maps-with-ggplot2-only/
setwd("~/Github/datos/scripts/analysis/daily/04_14")
source("../../init.R")



remotes::install_github("mayrop/covid19mx")

descriptions <- covid19mx::get_covid_descriptions()
cases <- covid19mx::get_covid_cases()
merged <- covid19mx::complete_covid(cases, descriptions)

# https://blog.exploratory.io/creating-geojson-out-of-shapefile-in-r-40bc0005857d

####################################################################################
states <- readOGR(dsn = "../../data/geo/conjunto_de_datos/",
 "areas_geoestadisticas_estatales", verbose = FALSE)

municipios <- readOGR(dsn = "../../data/geo/municipios/", "mun2005kgw", verbose = FALSE)

head(states@data, 10)
states_json <- geojsonio::geojson_json(states)
states_json_simplified <- rmapshaper::ms_simplify(states_json)
geojson_write(states_json_simplified, file = "cities_json_simplified.geojson")
####################################################################################

# Loading SHP
# https://shapesdemexico.wixsite.com/shapes/agebs


cities_shp <- sf::st_read("../../data/geo/municipios/mun2005kgw.shp")
states_shp <- sf::st_read("../../data/geo/Mexico_States/Mexico_States.shp")

states_shp <- states_shp %>% dplyr::mutate(CODE = as.numeric(gsub("MX", "", CODE)))
states_shp$CODE = as.numeric(states_shp$CODE)

# casting to numeric so we can do the join!
cities_shp$CVE_MUN = as.numeric(cities_shp$CVE_MUN)
cities_shp$CVE_ENT = as.numeric(cities_shp$CVE_ENT)
states_shp$CVE_ENT = as.numeric(states_shp$CVE_ENT)

# we extract the centroid
cities_shp <- cities_shp %>%
  dplyr::mutate(
    Longitude = purrr::map_dbl(geometry, ~st_centroid(.x)[[1]]),
    Latitude = purrr::map_dbl(geometry, ~st_centroid(.x)[[2]])
  )

# we extract the centroid for states now!
states_shp <- states_shp %>%
  dplyr::mutate(
    Longitude = purrr::map_dbl(geometry, ~st_centroid(.x)[[1]]),
    Latitude = purrr::map_dbl(geometry, ~st_centroid(.x)[[2]])
  )

# Load data & merge it
data_04_14 <- join_covid_mx(data$covid$diarios_2020_04_14, data$covid_descriptions)

# Check missing coordinates
check <- data_04_14 %>%
  dplyr::left_join(cities_shp, by=c("ENTIDAD_RES"="CVE_ENT", "MUNICIPIO_RES"="CVE_MUN"))

check[is.na(check$longitude),]$MUNICIPIO_RES_FACTOR
# if all are "No especifico" we are good!

# todo to fix encoding on diarios_2020_04_13
positive <- merged %>%
  dplyr::group_by(ENTIDAD_RES, MUNICIPIO_RES, FECHA_DEF) %>%
  dplyr::summarise(
    n = dplyr::n()
  ) %>%
  dplyr::filter(FECHA_DEF != "9999-99-99")

# join needs to be this way! https://github.com/tidyverse/ggplot2/issues/3391#issuecomment-508527985
positive <- cities_shp %>%
  dplyr::right_join(
    positive,
    by=c("CVE_ENT"="ENTIDAD_RES", "CVE_MUN"="MUNICIPIO_RES")
  )

dim(positive)

#### Normalizing the size of the circles!

max_size <- max(positive$n)
min_size <- 1

b <- 10
a <- 0.001

alpha_b <- 0.9
alpha_a <- 0.5

my_map <- positive %>%
  dplyr::mutate(
    # Here we try to normalize the size by a skewed density of votes by party
    # The reason is to emphasize the difference in number of cases
    size_normalized = (b-a) * ((n - min_size) / (max_size - min_size)) + a,
    alpha_size_normalized = (alpha_b-alpha_a) * ((n - min_size) / (max_size - min_size)) + alpha_a
  )

ggplot() +
  scale_alpha(
    name = "",
    range = c(0.7, 0),
    guide = FALSE
  ) +
  # Adding counties
  geom_sf(
    data = states_shp,
    color = "gray",
    fill = "white",
    size = 0.5
  ) +
  geom_point(
    data = my_map,
    aes(
      x = Longitude,
      y = Latitude
    ),
    size = my_map$size_normalized,
    alpha = my_map$alpha_size_normalized
  ) +
  theme_bw() +
  theme(
    legend.position = c(0.01, 0.01),
    legend.justification = c("left", "bottom"),
    legend.text = element_text(size = 18),
    legend.title = element_text(size = 20),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    #legend.key.size = unit(5,"cm"),
    axis.ticks.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.x = element_blank(),
    axis.text.x = element_blank()
  ) +
  # changes the size of the points in legend
  guides(color = guide_legend(
    override.aes = list(size=5))
  )


ggplot(positive) +
  geom_sf(aes(fill = n))

municipios <- states %>%
  dplyr::group_by(CVE_ENT_FIXED, CVE_MUN_FIXED) %>%
  dplyr::slice(1)






#merged$MUNICIPIO_RES_FACTOR_SLUG = slugify(merged$MUNICIPIO_RES_FACTOR)
#merged$NOMBRE_MUN_SLUG = slugify(merged$NOMBRE_MUN)
#
#merged <- merged %>%
#  dplyr::mutate(same_mun = MUNICIPIO_RES_FACTOR_SLUG == NOMBRE_MUN_SLUG)

ggplot(merged = merged$geometry, aes(x=long, y=lat)) + geom_polygon()

# Unprojected data
print("6:12")
ggplot(municipios[,] %>% dplyr::filter(CVE_ENT %in% c("04", "05", "06"))) +
  geom_sf(aes(fill = PERIMETER))

municipios[1:10,] %>% leaflet()

