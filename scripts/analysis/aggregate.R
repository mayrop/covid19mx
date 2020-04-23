# -------------------------------------------------------------------------------------

setwd("~/Github/datos/scripts/analysis")
source("init.R")

fix_na_in_rows <- function(df) {
  if (!("Defunciones_Positivos" %in% colnames(df))) {
    df %>% 
      dplyr::rename(Defunciones_Positivos = Defunciones)
  }
  
  df %>%
    dplyr::mutate(
      Positivos = ifelse(is.na(Positivos), 0, Positivos),
      Defunciones_Positivos = ifelse(is.na(Defunciones_Positivos), 0, Defunciones_Positivos)
    )
}

generate_all <- function(df, destination) {
  generate_all_federal(df, destination)
  generate_all_state(df, destination)
}


generate_all_federal <- function(df, destination) {
  customFun  = function(DF) {
    date_file <- gsub("-", "", unique(DF$Fecha))
    month <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1\\2", date_file)

    write.csv(DF, paste0(destination, "federal/", month, "/federal_", date_file,".csv"), row.names = FALSE, na = "")
    return(DF)
  }

  df %>%
    dplyr::group_by(Fecha) %>%
    dplyr::do(customFun(.))
}


generate_all_state <- function(df, destination) {
  customFun  = function(DF) {
    write.csv(DF, paste0(destination, "estatal/estatal_", tolower(unique(DF$Estado)),".csv"), row.names = FALSE, na = "")
    return(DF)
  }

  df %>%
    dplyr::group_by(Estado) %>%
    dplyr::do(customFun(.))
}

generate_main_file <- function(destination) {
  files <- init_files(paste0(destination, "federal/"))
  
  for (name in names(files)) {
    if ("Inconsistencias" %in% colnames(files[[name]])) {
      files[[name]] <- files[[name]] %>%
        dplyr::select(-Inconsistencias) %>%
        dplyr::rename(
          Defunciones_Positivos = Defunciones
        ) %>%
        dplyr::mutate(
          Defunciones_Sospechosos = 0,
          Defunciones_Negativos = 0,
          Positivos_Sintomas_14_Dias = 0,
          Sospechosos_Sintomas_14_Dias = 0,
          Negativos_Sintomas_14_Dias = 0,
          Positivos_Sintomas_7_Dias = 0,
          Sospechosos_Sintomas_7_Dias = 0,
          Negativos_Sintomas_7_Dias = 0)
    }
    
    files[[name]] <- files[[name]] %>%
      dplyr::select(
        -ends_with("_Delta")
      )
  }
  
  rows <- do.call(rbind, files)
  rows <- setDT(rows, keep.rownames = TRUE)[]
  rows <- fix_na_in_rows(rows) %>%
    dplyr::select(-rn)
  
  rows <- rows %>%
    dplyr::group_by(Estado) %>%
    dplyr::mutate(
      Positivos_Delta = Positivos - lag(Positivos),
      Positivos_Delta = ifelse(is.na(Positivos_Delta), 0, Positivos_Delta),
      Sospechosos_Delta = Sospechosos - lag(Sospechosos),
      Sospechosos_Delta = ifelse(is.na(Sospechosos_Delta), 0, Sospechosos_Delta),
      Negativos_Delta = Negativos - lag(Negativos),
      Negativos_Delta = ifelse(is.na(Negativos_Delta), 0, Negativos_Delta),
      Defunciones_Positivos_Delta = Defunciones_Positivos - lag(Defunciones_Positivos),
      Defunciones_Positivos_Delta = ifelse(is.na(Defunciones_Positivos_Delta), 0, Defunciones_Positivos_Delta),
      Defunciones_Sospechosos_Delta = Defunciones_Sospechosos - lag(Defunciones_Sospechosos),
      Defunciones_Sospechosos_Delta = ifelse(is.na(Defunciones_Sospechosos_Delta), 0, Defunciones_Sospechosos_Delta),
      Defunciones_Negativos_Delta = Defunciones_Negativos - lag(Defunciones_Negativos),
      Defunciones_Negativos_Delta = ifelse(is.na(Defunciones_Negativos_Delta), 0, Defunciones_Negativos_Delta),
    ) %>%
    dplyr::select(
      Fecha,
      Estado,
      Positivos,
      Positivos_Delta,
      Sospechosos,
      Sospechosos_Delta,
      Negativos,
      Negativos_Delta,
      Defunciones_Positivos,
      Defunciones_Positivos_Delta,
      Defunciones_Sospechosos,
      Defunciones_Sospechosos_Delta,
      Defunciones_Negativos,
      Defunciones_Negativos_Delta,
      dplyr::everything()
    ) 

  write.csv(rows, paste0(destination, "/agregados/federal.csv"), row.names = FALSE, na = "")
  
  rows
}

generate_aggregated_file <- function(df, destination) {
  df <- df %>%
    dplyr::mutate(
      Fecha=as.character(Fecha)
    ) %>%
    dplyr::group_by(Fecha) %>%
    dplyr::summarise(
      Positivos=sum(Positivos, na.rm = TRUE),
      Sospechosos=sum(Sospechosos, na.rm = TRUE),
      Negativos=sum(Negativos, na.rm = TRUE),
      Defunciones_Positivos=sum(Defunciones_Positivos, na.rm = TRUE),
      Defunciones_Sospechosos=sum(Defunciones_Sospechosos, na.rm = TRUE),
      Defunciones_Negativos=sum(Defunciones_Negativos, na.rm = TRUE),
      Positivos_Sintomas_14_Dias=sum(Positivos_Sintomas_14_Dias, na.rm = TRUE),
      Sospechosos_Sintomas_14_Dias=sum(Sospechosos_Sintomas_14_Dias, na.rm = TRUE),
      Negativos_Sintomas_14_Dias=sum(Negativos_Sintomas_14_Dias, na.rm = TRUE),
      Positivos_Sintomas_7_Dias=sum(Positivos_Sintomas_7_Dias, na.rm = TRUE),
      Sospechosos_Sintomas_7_Dias=sum(Sospechosos_Sintomas_7_Dias, na.rm = TRUE),
      Negativos_Sintomas_7_Dias=sum(Negativos_Sintomas_7_Dias, na.rm = TRUE)
    )

  totales_bak <- read.csv("bak/totales.csv") %>%
    dplyr::mutate(
      Fecha=as.character(Fecha)
    )
  
  df <- df %>%
    dplyr::left_join(totales_bak, by="Fecha") %>%
    dplyr::mutate(
      Sospechosos=ifelse(Sospechosos==0, S, Sospechosos),
      Negativos=ifelse(Negativos==0, N, Negativos)
    ) %>%
    dplyr::select(
      -S, -N
    )
  
  df <- df %>%
    dplyr::mutate(
      Positivos_Delta = Positivos - lag(Positivos),
      Positivos_Delta = ifelse(is.na(Positivos_Delta), 0, Positivos_Delta),
      Sospechosos_Delta = Sospechosos - lag(Sospechosos),
      Sospechosos_Delta = ifelse(is.na(Sospechosos_Delta), 0, Sospechosos_Delta),
      Negativos_Delta = Negativos - lag(Negativos),
      Negativos_Delta = ifelse(is.na(Negativos_Delta), 0, Negativos_Delta),
      Defunciones_Positivos_Delta = Defunciones_Positivos - lag(Defunciones_Positivos),
      Defunciones_Positivos_Delta = ifelse(is.na(Defunciones_Positivos_Delta), 0, Defunciones_Positivos_Delta),
      Defunciones_Sospechosos_Delta = Defunciones_Sospechosos - lag(Defunciones_Sospechosos),
      Defunciones_Sospechosos_Delta = ifelse(is.na(Defunciones_Sospechosos_Delta), 0, Defunciones_Sospechosos_Delta),
      Defunciones_Negativos_Delta = Defunciones_Negativos - lag(Defunciones_Negativos),
      Defunciones_Negativos_Delta = ifelse(is.na(Defunciones_Negativos_Delta), 0, Defunciones_Negativos_Delta),
    ) %>%
    dplyr::select(
      Fecha,
      Positivos,
      Positivos_Delta,
      Sospechosos,
      Sospechosos_Delta,
      Negativos,
      Negativos_Delta,
      Defunciones_Positivos,
      Defunciones_Positivos_Delta,
      Defunciones_Sospechosos,
      Defunciones_Sospechosos_Delta,
      Defunciones_Negativos,
      Defunciones_Negativos_Delta,
      dplyr::everything()
    )

  write.csv(df, paste0(destination, "/agregados/totales.csv"), row.names = FALSE)
  df
}


# ------------------------------------------

destination <- "../../www/series-de-tiempo/"

# Run the following line to go from individual files to main federal.csv file
agg <- generate_main_file(destination)

# Run the following to go from main federal.csv file to write all individual files
# as well as the aggregated file
df <- read.csv(paste0(destination, "agregados/federal.csv"))
df <- fix_na_in_rows(df)
generate_all(df, destination)
generate_aggregated_file(df, destination)

