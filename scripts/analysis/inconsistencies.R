# -------------------------------------------------------------------------------------

setwd("~/Github/datos/scripts/analysis")
source("init.R")


# -------------------------------------------------------------------------------------
# F u n c t i o n s
convert_to_date <- function(row) {
  row %>% gsub("ARCHIVO_", "", .) %>%
    gsub("_", "-", .)
}

last_in_row <- function(row, default = NA) {
  if (length(row) >= 1) {
    return(tail(row, n = 1))
  }
  
  return(default)
}

first_in_row <- function(row, default = NA) {
  if (length(row) >= 1) {
    return(row[1])
  }
  
  return(default)
}


get_by_state <- function(df, status) {
  lapply(apply(df == status, 1, which), names) %>% 
    sapply(first_in_row) %>%
    convert_to_date(.) %>%
    as.Date(.)
}

# -------------------------------------------------------------------------------------

meta <- datosmx::get_covid_meta()
open_files <- meta[meta$Type == "abiertos" & meta$Subtype == "todos", ]

files <- list()

# loading all the files (really slow - need to cache!)
for (row in 1:nrow(open_files)) {
  file = open_files[row, ]
  
  files[[file$Date]] = covid19mx::get_covid_cases(date = file$Date)
}

# binding all the files into one big dataframe
rows_orig <- do.call(rbind, files)
rows_orig <- data.table::setDT(rows_orig, keep.rownames = TRUE)[]

rows <- rows_orig %>%
  tidyr::separate(rn, into = c("ARCHIVO", "FILA"), sep = "\\.")

# colname for the current situation
situation <- paste0("ARCHIVO_", gsub("-", "_", max(rows$ARCHIVO)))
# getting the latest updates of files
max_date <- max(rows$ARCHIVO)


# getting total days 
total_days <- rows %>% 
  dplyr::select(ARCHIVO) %>%
  dplyr::mutate(ARCHIVO = paste0("ARCHIVO_", gsub("-", "_", ARCHIVO))) %>%
  dplyr::arrange(ARCHIVO) %>%
  unique(.) %>%
  dplyr::mutate(
    DIA_PRIMERA_APARICION = 1:(dplyr::n())
  )

# creating df by patient
df <- rows %>% 
  dplyr::select(ARCHIVO, ID_REGISTRO, RESULTADO) %>%
  dplyr::mutate(ARCHIVO = gsub("-", "_", ARCHIVO)) %>%
  tidyr::spread(ARCHIVO, RESULTADO, sep = "_")

# creating all the metadata for each patient
df <- df %>%
  dplyr::mutate(
    ARCHIVO_PRIMERA_APARICION = lapply(apply(df == 1 | df == 2 | df == 3, 1, which), names) %>% 
      sapply(first_in_row),
    DIAS_TOTALES = lapply(apply(df == 1 | df == 2 | df == 3, 1, which), names) %>% 
      sapply(length)
  ) %>% 
  dplyr::left_join(
    total_days, by = c("ARCHIVO_PRIMERA_APARICION" = "ARCHIVO")
  ) %>%
  dplyr::mutate(
    FECHA_SOSPECHOSO = get_by_state(df, 3),
    FECHA_POSITIVO = get_by_state(df, 1),
    FECHA_NEGATIVO = get_by_state(df, 2),
    # didn't work with %in% ?
    ARCHIVO_ULTIMA_APARICION = lapply(apply(df == 1 | df == 2 | df == 3, 1, which), names) %>% 
      sapply(last_in_row),
    PRIMERA_APARICION = ARCHIVO_PRIMERA_APARICION %>% convert_to_date(.),
    ULTIMA_APARICION = ARCHIVO_ULTIMA_APARICION %>% convert_to_date(.),
    # remember !! is to evaluate right away
    SITUACION_ACTUAL = !!rlang::sym(situation),
    ULTIMA_SITUACION = NA,
    INCONSISTENCIA = !is.na(FECHA_POSITIVO) & !is.na(FECHA_NEGATIVO),
    CAMBIO = dplyr::case_when(
      !is.na(FECHA_POSITIVO) & !is.na(FECHA_NEGATIVO) & FECHA_POSITIVO > FECHA_NEGATIVO ~ "NEGATIVO_A_POSITIVO",
      !is.na(FECHA_POSITIVO) & !is.na(FECHA_NEGATIVO) & FECHA_NEGATIVO > FECHA_POSITIVO ~ "POSITIVO_A_NEGATIVO",
      TRUE ~ ""
    ),
    REMOVIDO = as.character(ULTIMA_APARICION) != max_date,
    REMOVIDO_PARCIALMENTE  = DIAS_TOTALES + DIA_PRIMERA_APARICION != (dim(total_days)[1] + 1)
  )

# took me ages!
# https://community.rstudio.com/t/extracting-value-from-a-data-frame-where-column-name-to-extract-from-is-dynamically-determined-by-values-in-another-column/14585/3
# last_situation <- max.col(!is.na(by_patient[, grepl("ARCHIVO_", colnames(by_patient))]), 'last')
df$ULTIMA_SITUACION = sapply( 
  seq_len(nrow(df)), 
  function(i) { 
    df[i, df$ARCHIVO_ULTIMA_APARICION[[i]], drop = TRUE]
  })

df <- df %>%
  dplyr::left_join(
    data.frame(ULTIMA_SITUACION = 1:3, ULTIMA_SITUACION_FACTOR = c("POSITIVO", "NEGATIVO", "SOSPECHOSO")),
    by = "ULTIMA_SITUACION"
  )


df_2 <- df %>%
  dplyr::select(
    ID_REGISTRO,
    dplyr::starts_with("ARCHIVO_2020")
  ) %>%
  tidyr::gather(ARCHIVO, VALOR, -ID_REGISTRO)

inconsistencies <- df %>% dplyr::filter(REMOVIDO == TRUE | INCONSISTENCIA == TRUE | REMOVIDO_PARCIALMENTE == TRUE)

# results
table(df$REMOVIDO)
table(df$ULTIMA_APARICION) %>% as.data.frame() %>% dplyr::filter(Var1 != max_date)
df %>% dplyr::filter(CAMBIO != "") %>% dplyr::pull(CAMBIO) %>% table(.)
table(inconsistencies %>% dplyr::filter(REMOVIDO == TRUE) %>% dplyr::pull(ULTIMA_SITUACION_FACTOR))
table(df$REMOVIDO_PARCIALMENTE)

write.csv(inconsistencies, "bak/inconstencias_04_27.csv", quote = FALSE)
          


