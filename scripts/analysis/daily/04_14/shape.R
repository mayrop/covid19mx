# https://blog.exploratory.io/creating-geojson-out-of-shapefile-in-r-40bc0005857d

# Loading SHP

# https://timogrossenbacher.ch/2016/12/beautiful-thematic-maps-with-ggplot2-only/
setwd("~/Github/datos/scripts/analysis/daily/04_14")
source("../../init.R")
library(RColorBrewer)

# Loading SHP
# https://gis.stackexchange.com/questions/243569/simplify-polygons-of-sf-object
cities_shp <- sf::st_read(config$data$geo$city)
states_shp <- sf::st_read(config$data$geo$state)

cities <- datosmx::get_cities()
# puerto morelo. https://www.gob.mx/inafed/articulos/puerto-morelos-es-el-municipio-de-mas-reciente-creacion-del-estado-de-quintana-roo?idiom=es
cities[cities$Clave_Entidad == 23 & cities$Clave_Municipio == 11, ]$Poblacion_2019 <- 37099	

states <- datosmx::get_states()
datosmx::get_covid_meta()

descriptions <- datosmx::get_covid_descriptions()
cases <- datosmx::get_covid_cases()
cases_18 <- datosmx::get_covid_cases(date="2020-04-18")
merged <- datosmx::complete_covid_cases(cases, descriptions)
merged_18 <- datosmx::complete_covid_cases(cases_18, descriptions)
# Check missing coordinates
check <- merged %>%
  dplyr::left_join(
    cities_shp, by=c("ENTIDAD_RES"="CVE_ENT", "MUNICIPIO_RES"="CVE_MUN"))

check[is.na(check$LONGITUDE),] %>% dplyr::select(MUNICIPIO_RES, MUNICIPIO_RES_FACTOR)
# if all are "No especifico" we are good!

#edf8e9
#c7e9c0
#a1d99b
#74c476
#31a354
#006d2c
colors <- c('#edf8e9','#c7e9c0','#a1d99b','#74c476','#31a354', '#006d2c')

# check _tasa_mun.R





