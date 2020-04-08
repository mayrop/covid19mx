library(plyr)
library(rjson)
library(tidyr)
library(data.table)
library(purrr)
library(forcats)
library(lubridate)

source("_functions.R")

#---------------------------------------------------------------

add_short_ids <- function(df) {
  df %>% dplyr::rowwise() %>%
    dplyr::mutate(
      Paciente_Id_Corto = paste0(
        slugify(c(
          as.character(Estado), 
          as.character(Sexo), 
          Edad,
          as.character(Fecha_Sintomas), 
          as.character(Procedencia)
        )), "_", collapse="")
    ) %>%
    as.data.frame() %>%
    dplyr::group_by(
      Paciente_Id_Corto
    ) %>%
    dplyr::mutate(
      Paciente_Id_Corto_Fila = dplyr::row_number()
    ) %>%
    dplyr::ungroup() %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      Paciente_Id_Corto_Unico = Paciente_Id_Corto,
      Paciente_Id_Corto = paste0(Paciente_Id_Corto, Paciente_Id_Corto_Fila, sep="")
    )
}

#---------------------------------------------------------------

# Init of the file

files <- init_files("../static/data/results/csv")
positive <- read.csv("../static/data/positivos.csv")


april_06 <- files[["positivos_2020_04_06"]] %>% 
  dplyr::mutate(
    Procedencia = as.character(Procedencia),
    Procedencia = ifelse(is.na(Procedencia) | Procedencia == "OTRO", "CONTACTO", Procedencia),
    Sexo = ifelse(Sexo == "MASCULINO", "M", "F"),
    Fecha_Sintomas_Original = Fecha_Sintomas,
    Fecha_Sintomas = ifelse(
      is.na(Fecha_Sintomas_Corregido), as.character(Fecha_Sintomas), as.character(Fecha_Sintomas_Corregido))
  )

april_07 <- files[["positivos_2020_04_07"]] %>% 
  dplyr::mutate(
    Procedencia = as.character(Procedencia),
    Procedencia = ifelse(is.na(Procedencia) | Procedencia == "OTRO", "CONTACTO", Procedencia),
    Sexo = ifelse(Sexo == "MASCULINO", "M", "F"),
    Fecha_Sintomas_Original = Fecha_Sintomas,
    Fecha_Sintomas = ifelse(
      is.na(Fecha_Sintomas_Corregido), as.character(Fecha_Sintomas), as.character(Fecha_Sintomas_Corregido))
  )

april_06 <- add_short_ids(april_06)
april_07 <- add_short_ids(april_07)
positive_ids <- get_short_ids(positive)

length(setdiff(april_06$Paciente_Id_Corto, april_07$Paciente_Id_Corto))

april_06 %>% dplyr::anti_join(
  april_07, by="Paciente_Id_Corto"
) %>% View()

april_06 %>% dplyr::inner_join(
  april_07, by="Paciente_Id_Corto"
) %>% View()
