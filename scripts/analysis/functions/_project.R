
# -------------------------------------------------------------------------------------

map_tables <- function(today, yesterday, positive_ids) {
  
  new_rows <- positive_ids[[today]]
  deleted_rows <- new_rows %>%
    dplyr::filter(is.na(patient_id))
  
  if (!is.na(yesterday)) {
    new_rows <- positive_ids[[today]] %>%
      dplyr::anti_join(positive_ids[[yesterday]], by="patient_id")
    
    deleted_rows = positive_ids[[yesterday]] %>%
      dplyr::anti_join(positive_ids[[today]], by="patient_id")
  }
  
  return(
    list(
      new_rows=new_rows,
      deleted_rows=deleted_rows
    )
  )
}

# -------------------------------------------------------------------------------------

get_ids_for_type <- function(file_type="positivos", rows) {
  my_unique_files <- rows$file_id %>%
    unique()
  
  ids_positivos = list()
  
  for (f in my_unique_files) {
    file_rows = rows %>%
      dplyr::filter(file_id == f)
    
    ids_positivos[[f]] <- file_rows %>%
      dplyr::select(patient_id, case) %>%
      # remember !! is for evaluating right away
      # so we evaluate the index and set it as string
      dplyr::rename(!!f := case)
  }
  
  return(ids_positivos)
}

# -------------------------------------------------------------------------------------

pull_original_attribute <- function(df, attr, attr_original) {
  df %>%
    dplyr::filter(!(!!rlang::enquo(attr) %in% !!rlang::enquo(attr_original))) %>%
    dplyr::pull(!!rlang::enquo(attr)) %>% unique() %>%
    paste0("", collapse = ", ")
}

# -------------------------------------------------------------------------------------

add_patient_ids <- function(rows) {
  # Adding short & long IDs
  rows <- rows %>%
    dplyr::mutate(
      age_id = ifelse(is.na(age_fixed), age, age_fixed),
      sex_id = ifelse(is.na(sex_fixed), as.character(sex), as.character(sex_fixed)),
      origin_id = ifelse(is.na(origin_fixed), as.character(origin), as.character(origin_fixed)),
      date_symptoms_id = ifelse(is.na(date_symptoms_fixed), as.character(date_symptoms), as.character(date_symptoms_fixed)),
      patient_id_bak = patient_id
    ) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      patient_id_long = paste0(
        slugify(c(
          as.character(state),
          as.character(sex_id),
          age_id,
          as.character(date_symptoms_id),
          as.character(origin_id),
          as.character(date_arrival),
          as.character(date_removed)
        )), "_", collapse=""
      ),
      patient_id = paste0(
        slugify(c(
          as.character(state),
          as.character(sex_id),
          age_id,
          as.character(date_symptoms_id)
        )), "_", collapse=""
      ),
      file_id = as.character(file_id)
    ) %>%
    as.data.frame() %>%
    dplyr::arrange(file_date_std)
  
  add_patient_ids_with_rows(rows)
}

# -------------------------------------------------------------------------------------

add_patient_ids_with_rows <- function(rows) {
  
  # add row # for the ones that have same characteristics
  rows %>%
    dplyr::group_by(
      file_id, patient_id
    ) %>%
    dplyr::mutate(
      patient_id_row = dplyr::row_number()
    ) %>%
    dplyr::ungroup() %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      patient_id_unique = patient_id,
      patient_id = paste0(patient_id, patient_id_row, sep="")
    ) %>%
    as.data.frame()
}

# -------------------------------------------------------------------------------------

create_history_from_rows <- function(rows) {
  positive_ids = get_ids_for_type("positivos", rows)
  
  positive_ids_colnames <- names(positive_ids)
  
  for (i in 1:length(positive_ids_colnames)) {
    yesterday <- ifelse(i > 1, positive_ids_colnames[i-1], NA)
    today <- positive_ids_colnames[i]
    
    new_col <- paste0("status_", today)
    new_data_col <- paste0("data_", today)
    
    mapped_table <- map_tables(
      today, yesterday, positive_ids
    )
    
    if (i == 1) {
      my_map <- positive_ids[[positive_ids_colnames[1]]]
    } else {
      my_map <- my_map %>%
        dplyr::full_join(
          positive_ids[[today]], by="patient_id", na_matches="never"
        )
    }
    
    my_map <- my_map %>%
      dplyr::mutate(
        !!new_col := dplyr::case_when(
          patient_id %in% mapped_table$new_rows$patient_id ~ "ADDED",
          patient_id %in% mapped_table$deleted_rows$patient_id ~ "REMOVED",
          is.na(!!rlang::sym(today)) ~ "NOT EXISTENT",
          TRUE ~ "SAME"
        )
      ) %>%
      dplyr::rowwise() %>%
      dplyr::mutate(
        !!new_data_col := purrr::pmap(
          .l = list(!!rlang::sym(today), !!rlang::sym(new_col)),
          .f = function(x, y) {
            tibble(x=x, y=y)
          }
        )
      )
  }
  
  my_map %>%
    dplyr::select(-starts_with("positivos"), -starts_with("status")) %>%
    tidyr::gather(date, data, -patient_id, -starts_with("status"), -starts_with("positivos")) %>%
    tidyr::unnest(cols = data)
}

# -------------------------------------------------------------------------------------

create_inconsistencies_from_history <- function(history) {
  history %>%
    dplyr::arrange(date) %>%
    dplyr::group_by(patient_id) %>%
    tidyr::nest() %>%
    dplyr::mutate(
      date_added = purrr::map_chr(data, function(.x) {
        temp <- .x %>% dplyr::filter(y == "ADDED") %>% dplyr::pull(date) %>% paste0(., "", collapse=NULL)
        if (length(temp) > 1) {
          return("CHECK")
        }
        temp
      }),
      date_removed = purrr::map_chr(data, function(.x) {
        temp <- .x %>% dplyr::filter(y == "REMOVED") %>% dplyr::pull(date) %>% paste0(., "", collapse=NULL)
        if (length(temp) > 1) {
          return("CHECK")
        }
        temp
      })
    ) %>%
    tidyr::unnest(cols=data) %>%
    dplyr::filter(
      date_removed != "" & y != "NOT EXISTENT"
    ) %>%
    dplyr::mutate(
      date_friendly = gsub("data_positivos_", "", date)
    )
}

# -------------------------------------------------------------------------------------


join_covid_mx <- function(input, descriptions) {
  input %>%
    dplyr::left_join(descriptions$origin, by=c("ORIGEN"="CLAVE")) %>%
    dplyr::rename(
      ORIGEN_FACTOR=DESCRIPCION
    ) %>%
    # adding sector
    dplyr::left_join(descriptions$sector, by=c("SECTOR"="CLAVE")) %>%
    dplyr::rename(
      SECTOR_FACTOR=DESCRIPCION
    ) %>%
    # adding state that gave attention
    dplyr::left_join(descriptions$states, by=c("ENTIDAD_UM"="CLAVE_ENTIDAD")) %>%
    dplyr::rename(
      ENTIDAD_UM_FACTOR=ENTIDAD_FEDERATIVA
    ) %>%
    dplyr::select(-ABREVIATURA) %>%
    # adding sex
    dplyr::left_join(descriptions$sex, by=c("SEXO"="CLAVE")) %>%
    dplyr::rename(
      SEXO_FACTOR=DESCRIPCION
    ) %>%
    # adding state where patient was born
    dplyr::left_join(descriptions$states, by=c("ENTIDAD_NAC"="CLAVE_ENTIDAD")) %>%
    dplyr::rename(
      ENTIDAD_NAC_FACTOR=ENTIDAD_FEDERATIVA
    ) %>%
    dplyr::select(-ABREVIATURA) %>%
    # adding patient's state of residency
    dplyr::left_join(descriptions$states, by=c("ENTIDAD_RES"="CLAVE_ENTIDAD")) %>%
    dplyr::rename(
      ENTIDAD_RES_FACTOR=ENTIDAD_FEDERATIVA
    ) %>%
    dplyr::select(-ABREVIATURA) %>%
    # adding patient's city of residency
    dplyr::left_join(descriptions$cities, by=c("ENTIDAD_RES"="CLAVE_ENTIDAD", "MUNICIPIO_RES"="CLAVE_MUNICIPIO")) %>%
    dplyr::rename(
      MUNICIPIO_RES_FACTOR=MUNICIPIO
    ) %>%
    # adding patient's type
    dplyr::left_join(descriptions$patient_type, by=c("TIPO_PACIENTE"="CLAVE")) %>%
    dplyr::rename(
      TIPO_PACIENTE_FACTOR=DESCRIPCION
    ) %>%
    # ? intubated
    dplyr::left_join(descriptions$yes_no, by=c("INTUBADO"="CLAVE")) %>%
    dplyr::rename(
      INTUBADO_FACTOR=DESCRIPCION
    ) %>%
    # ? pneumonia
    dplyr::left_join(descriptions$yes_no, by=c("NEUMONIA"="CLAVE")) %>%
    dplyr::rename(
      NEUMONIA_FACTOR=DESCRIPCION
    ) %>%
    # ? pregnant
    dplyr::left_join(descriptions$yes_no, by=c("EMBARAZO"="CLAVE")) %>%
    dplyr::rename(
      EMBARAZO_FACTOR=DESCRIPCION
    ) %>%
    # ? speaks native language
    dplyr::left_join(descriptions$yes_no, by=c("HABLA_LENGUA_INDI"="CLAVE")) %>%
    dplyr::rename(
      HABLA_LENGUA_INDI_FACTOR=DESCRIPCION
    ) %>%
    # ? diabetes
    dplyr::left_join(descriptions$yes_no, by=c("DIABETES"="CLAVE")) %>%
    dplyr::rename(
      DIABETES_FACTOR=DESCRIPCION
    ) %>%
    # ? epoc
    dplyr::left_join(descriptions$yes_no, by=c("EPOC"="CLAVE")) %>%
    dplyr::rename(
      EPOC_FACTOR=DESCRIPCION
    ) %>%
    # ? asthma
    dplyr::left_join(descriptions$yes_no, by=c("ASMA"="CLAVE")) %>%
    dplyr::rename(
      ASMA_FACTOR=DESCRIPCION
    ) %>%
    # ? immunosuppression
    dplyr::left_join(descriptions$yes_no, by=c("INMUSUPR"="CLAVE")) %>%
    dplyr::rename(
      INMUSUPR_FACTOR=DESCRIPCION
    ) %>%
    # ? hypertension
    dplyr::left_join(descriptions$yes_no, by=c("HIPERTENSION"="CLAVE")) %>%
    dplyr::rename(
      HIPERTENSION_FACTOR=DESCRIPCION
    ) %>%
    # ? other diseases
    dplyr::left_join(descriptions$yes_no, by=c("OTRA_CON"="CLAVE")) %>%
    dplyr::rename(
      OTRA_CON_FACTOR=DESCRIPCION
    ) %>%
    # ? cardiovascular
    dplyr::left_join(descriptions$yes_no, by=c("CARDIOVASCULAR"="CLAVE")) %>%
    dplyr::rename(
      CARDIOVASCULAR_FACTOR=DESCRIPCION
    ) %>%
    # ? obesity
    dplyr::left_join(descriptions$yes_no, by=c("OBESIDAD"="CLAVE")) %>%
    dplyr::rename(
      OBESIDAD_FACTOR=DESCRIPCION
    ) %>%
    # ? renal chronic
    dplyr::left_join(descriptions$yes_no, by=c("RENAL_CRONICA"="CLAVE")) %>%
    dplyr::rename(
      RENAL_CRONICA_FACTOR=DESCRIPCION
    ) %>%
    # ? smoker
    dplyr::left_join(descriptions$yes_no, by=c("TABAQUISMO"="CLAVE")) %>%
    dplyr::rename(
      TABAQUISMO_FACTOR=DESCRIPCION
    ) %>%
    # ? contact with other case?
    dplyr::left_join(descriptions$yes_no, by=c("OTRO_CASO"="CLAVE")) %>%
    dplyr::rename(
      OTRO_CASO_FACTOR=DESCRIPCION
    ) %>%
    # ? migrant
    dplyr::left_join(descriptions$yes_no, by=c("MIGRANTE"="CLAVE")) %>%
    dplyr::rename(
      MIGRANTE_FACTOR=DESCRIPCION
    ) %>%
    # ? uci
    dplyr::left_join(descriptions$yes_no, by=c("UCI"="CLAVE")) %>%
    dplyr::rename(
      UCI_FACTOR=DESCRIPCION
    ) %>%
    # adding result factor
    dplyr::left_join(descriptions$result, by=c("RESULTADO"="CLAVE")) %>%
    dplyr::rename(
      RESULTADO_FACTOR=DESCRIPCION
    ) %>%
    # adding nationality
    dplyr::left_join(descriptions$nationality, by=c("NACIONALIDAD"="CLAVE")) %>%
    dplyr::rename(
      NACIONALIDAD_FACTOR=DESCRIPCION
    )
}
