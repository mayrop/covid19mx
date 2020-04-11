# -------------------------------------------------------------------------------------

source("_functions.R")

fix_na_in_rows <- function(df) {
  df %>%
    dplyr::mutate(
      Positivos = ifelse(is.na(Positivos), 0, Positivos),
      Defunciones = ifelse(is.na(Defunciones), 0, Defunciones)
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
  
  rows <- do.call(rbind, files)
  rows <- setDT(rows, keep.rownames = TRUE)[]
  rows <- fix_na_in_rows(rows) %>%
    dplyr::select(-rn)
  
  write.csv(rows, paste0(destination, "/agregados/federal.csv"), row.names = FALSE, na = "")
}

generate_aggregated_file <- function(df, destination) {
  df <- df %>% 
    dplyr::group_by(Fecha) %>% 
    dplyr::summarise(
      Positivos=sum(Positivos, na.rm = TRUE),
      Sospechosos=sum(Sospechosos, na.rm = TRUE),
      Negativos=sum(Negativos, na.rm = TRUE),
      Defunciones=sum(Defunciones, na.rm = TRUE),
      Inconsistencias=sum(Inconsistencias, na.rm = TRUE)
    )
  
  totales_bak <- read.csv("bak/totales.csv")
  
  df <- df %>% 
    dplyr::left_join(totales_bak, by="Fecha") %>% 
    dplyr::mutate(
      Sospechosos=ifelse(Sospechosos==0, S, Sospechosos),
      Negativos=ifelse(Negativos==0, N, Negativos)
    ) %>%
    dplyr::select(
      -S, -N
    )
  
  df %>% View()
  
  write.csv(df, paste0(destination, "/agregados/totales.csv"), row.names = FALSE)
}


# ------------------------------------------

destination <- "../../www/series-de-tiempo/"

# Run the following line to go from individual files to main federal.csv file
generate_main_file(destination)

# Run the following to go from main federal.csv file to write all individual files
# as well as the aggregated file
df <- read.csv(paste0(destination, "agregados/federal.csv"))
df <- fix_na_in_rows(df)
generate_all(df, destination)
generate_aggregated_file(df, destination)



