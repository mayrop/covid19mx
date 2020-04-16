
# -------------------------------------------------------------------------------------

setwd("~/Github/datos/scripts/analysis/daily/04_14")
source("../../init.R")

# Create city from

get_population <- function(year = NA) {
  pop01 <- read.csv("../../data/poblacion/poblacion01.csv", fileEncoding="latin1")
  pop02 <- read.csv("../../data/poblacion/poblacion02.csv", fileEncoding="latin1")
  
  pop <- rbind(pop01, pop02)
  
  if (!is.na(year)) {
    pop <- pop %>%
      dplyr::filter(`AÑO` == year)
  }
  
  pop
}


########################################################################################

cities_shp <- get_cities_shp(config$data$geo$city)
cities_shp$CVE_MUN = as.numeric(cities_shp$CVE_MUN)
cities_shp$CVE_ENT = as.numeric(cities_shp$CVE_ENT)

cities_geo <- cities_shp %>%
  dplyr::select(CVE_ENT, CVE_MUN, NOM_MUN, LONGITUDE, LATITUDE) %>%
  as.data.frame() %>%
  dplyr::select(-geometry)

states_shp <- get_cities_shp(config$data$geo$state)
states_shp$CVE_ENT = as.numeric(states_shp$CVE_ENT)

states_geo <- states_shp %>%
  dplyr::select(CVE_ENT, NOM_ENT, LONGITUDE, LATITUDE) %>%
  as.data.frame() %>%
  dplyr::select(-geometry)


########################################################################################


########################################################################################
population_orig <- get_population(year = 2020) %>%
  dplyr::rename(
    CVE_MUN = CLAVE,
    CVE_ENT = CLAVE_ENT,
    NOM_MUN = MUN
  )
  
population <- population_orig %>%
  dplyr::select(-RENGLON, -`AÑO`, -NOM_ENT, -NOM_MUN) %>%
  dplyr::group_by(CVE_MUN, CVE_ENT, SEXO) %>%
  tidyr::spread(EDAD_QUIN, POB) %>%
  dplyr::left_join(
    population_orig %>% 
      dplyr::select(CVE_MUN, CVE_ENT, NOM_ENT, NOM_MUN) %>%
      dplyr::group_by(CVE_MUN, CVE_MUN) %>%
      dplyr::slice(1),
    by = c("CVE_MUN", "CVE_ENT")
  ) %>%
  dplyr::select(
    starts_with("CVE_"),
    starts_with("NOM_"),
    SEXO,
    starts_with("pobm_")
  ) %>%
  dplyr::ungroup()

population <- population %>%
  dplyr::mutate(
    POB_2020 = population %>% 
      dplyr::select(dplyr::starts_with("pobm_")) %>% rowSums()
  ) 

population_summary <- population %>%
  dplyr::select(
    starts_with("CVE_"),
    starts_with("NOM_"),
    SEXO,
    POB_2020
  ) %>%
  tidyr::spread(SEXO, POB_2020) %>%
  dplyr::mutate(
    POB_2020 = Hombres + Mujeres
  ) %>%
  dplyr::select(
    -Hombres, -Mujeres
  ) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(
    CVE_MUN = as.numeric(gsub(paste0("^", CVE_ENT), "", CVE_MUN)),
  )

population_states <- population %>% 
  dplyr::select(-CVE_MUN, -NOM_ENT, -NOM_MUN) %>%
  dplyr::group_by(CVE_ENT, SEXO) %>% 
  dplyr::summarise_all(.funs=(sum = sum))

population_states_summary <- population_states %>%
  dplyr::select(
    starts_with("CVE_"),
    SEXO,
    POB_2020
  ) %>%
  tidyr::spread(SEXO, POB_2020) %>%
  dplyr::mutate(
    POB_2020 = Hombres + Mujeres
  ) %>%
  dplyr::select(
    -Hombres, -Mujeres
  )

###############################################################

cities_summary <- cities_geo %>%
  dplyr::full_join(
    population_summary, by = c("CVE_ENT", "CVE_MUN")
  )

# double check names match!
cities_summary %>%
  dplyr::filter(as.character(NOM_MUN.x) != as.character(NOM_MUN.y))

cities_summary <- cities_summary %>%
  dplyr::rename(
    NOM_MUN = NOM_MUN.x
  ) %>%
  dplyr::select(-NOM_MUN.y) %>%
  dplyr::select(
    CVE_ENT, 
    CVE_MUN,
    NOM_MUN,
    LONGITUDE,
    LATITUDE,
    POB_2020
  ) %>%
  dplyr::arrange(CVE_ENT, CVE_MUN)

cities_summary <- cities_summary %>% 
  `names<-`(toupper(names(.))) %>%
  dplyr::rename(
    Clave_Entidad = CVE_ENT,
    Clave_Municipio = CVE_MUN,
    Nombre = NOM_MUN,
    Longitud = LONGITUDE,
    Latitud = LATITUDE,
    Poblacion_2020 = POB_2020
  )

###############################################################

states_summary <- read.csv("bak/estados.csv") %>%
  dplyr::rename(
    Clave = CLAVE,
    Nombre_Mayuscula = NOMBRE_MAYUSCULA,
    Nombre_Completo = NOMBRE_COMPLETO,
    Abreviatura = ABREVIATURA
  ) %>%
  dplyr::full_join(
    states_geo, by = c("Clave" = "CVE_ENT")
  ) %>%
  dplyr::full_join(
    population_states_summary, by = c("Clave" = "CVE_ENT")
  ) %>% 
  dplyr::select(-NOM_ENT) %>%
  dplyr::rename(
    Nombre = NOMBRE,
    Longitud = LONGITUDE,
    Latitud = LATITUDE,
    Poblacion_2020 = POB_2020
  )

###############################################################

# writing now!
write.csv(cities_summary, config$data$summary$cities, row.names = FALSE)
write.csv(population, config$data$summary$cities_segregated, row.names = FALSE)

write.csv(states_summary, config$data$summary$states, row.names = FALSE)
write.csv(population_states, config$data$summary$states_segregated, row.names = FALSE)

# https://datos.gob.mx/busca/dataset/proyecciones-de-la-poblacion-de-mexico-y-de-las-entidades-federativas-2016-2050/resource/0cda121e-5e8f-48a0-9468-d2cc921f3f3c?inner_span=True
# https://timogrossenbacher.ch/2016/12/beautiful-thematic-maps-with-ggplot2-only/
# library(rgdal)
# library(spdplyr)
# library(geojsonio)
# library(rmapshaper)
# library(lawn)
