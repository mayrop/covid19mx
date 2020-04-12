# -------------------------------------------------------------------------------------

source("_functions.R")

destination <- "../../www/tablas-diarias"
destination_other <- "../../www/otros"

files <- init_files(destination)

files_lookup <- create_files_lookup(files)
my_files_lookup <- dlply(files_lookup, 1, c)

rows_orig <- do.call(rbind, files)
rows_orig <- setDT(rows_orig, keep.rownames = TRUE)[]

files %>% purrr::map(., function(x) {
  length(colnames(x))
})

str(covid19mx::daily_cases("2020-04-05", type="sospechosos"))

# we create an ID per patient based on different factors that stay constant between all files
rows <- rows_orig %>%
  tidyr::separate(rn, into = c("file_id", "row"), sep = "\\.") %>%
  dplyr::select(-row) %>%
  dplyr::filter(
    grepl("positivos", file_id)
  )

# "positivos_2020_04_07" "positivos_2020_04_08"
# ignore warning Expected 2 pieces. Missing pieces filled with `NA` in 1 rows [1].

colnames(rows) <- c(
  "file_id", "case", "state_original", "city_original", "sex_original",
  "age", "date_symptoms_original", "situation_original", "origin_original", "date_arrival_original",
  "state", "city", "sex", "date_symptoms", "is_date_symptoms_fixed", "situation",
  "origin", "date_arrival"
)

rows <- rows %>%
  dplyr::mutate(
    age_fixed = NA,
    date_age_fixed = NA,
    origin_fixed = NA,
    date_origin_fixed = NA,
    sex_fixed = NA,
    date_sex_fixed = NA,
    date_removed = NA,
    date_date_symptoms_fixed = NA
  ) %>%
  dplyr::mutate(
    date_symptoms_id = as.character(date_symptoms)
  )

rows <- rows %>%
  dplyr::rowwise() %>%
  dplyr::mutate(
    patient_id = paste0(
      slugify(c(
        as.character(state),
        as.character(sex),
        age,
        as.character(date_symptoms_id),
        as.character(origin),
        as.character(date_arrival)
      )), "_", collapse=""
    ),
    file_id = as.character(file_id)
  ) %>%
  as.data.frame() %>%
  dplyr::inner_join(
    files_lookup,
    by=c("file_id" = "file_id")
  )

rows <- rows %>%
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

source("_fixes.R")

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
    patient_id = paste0(
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
    file_id = as.character(file_id)
  ) %>%
  as.data.frame() %>%
  dplyr::arrange(file_date_std)

rows <- rows %>%
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

# we add how many rows we find per file
rows <- rows %>%
  dplyr::group_by(
    file_id
  ) %>%
  tidyr::nest() %>%
  dplyr::mutate(
    rows_per_file = purrr::map_int(data, ~nrow(.x)),
  ) %>%
  tidyr::unnest(
    cols=data
  ) %>%
  dplyr::ungroup()

# double check numbers
rows %>%
  dplyr::group_by(
    file_id
  ) %>% dplyr::slice(1) %>%
  dplyr::select(
    file_id, rows_per_file
  ) %>%
  View()


source("_sanity-check.R")

# we extract all the files where PatientX is listed
rows <- rows %>%
  dplyr::group_by(patient_id) %>%
  tidyr::nest() %>%
  dplyr::mutate(
    files_per_patient = map_chr(data, function(.x) {
      .x$file_id %>% paste0(collapse=", ")
    }),
    files_per_patient_total = map_int(data, function(.x) {
      .x$file_id %>% length()
    }),
  ) %>%
  tidyr::unnest(cols=data) %>%
  dplyr::ungroup()

rows %>%
  dplyr::group_by(patient_id) %>%
  dplyr::slice(1) %>%
  dplyr::select(patient_id, files_per_patient_total) %>%
  View()

rows %>%
  dplyr::group_by(file_id, patient_id_unique) %>%
  dplyr::summarise(
    rows_per_file_and_patient = dplyr::n()
  ) %>%
  View()

# TODO: improve later, see: https://github.com/tidyverse/purrr/issues/254
rows <- rows %>%
  dplyr::group_by(patient_id) %>%
  tidyr::nest() %>%
  dplyr::mutate(
    date_confirmed = purrr::map_chr(data, ~.x[1, ]$file_date_iso %>% paste0("")),
    date_removed_temp = purrr::map_chr(data, ~my_files_lookup[[.x$date_removed[1]]]$file_date_iso %>% paste0("")),
    date_age_fixed_temp = purrr::map_chr(data, ~my_files_lookup[[.x$date_age_fixed[1]]]$file_date_iso %>% paste0("")),
    date_sex_fixed_temp = purrr::map_chr(data, ~my_files_lookup[[.x$date_sex_fixed[1]]]$file_date_iso %>% paste0("")),
    date_origin_fixed_temp = purrr::map_chr(data, ~my_files_lookup[[.x$date_origin_fixed[1]]]$file_date_iso %>% paste0("")),
    date_date_symptoms_fixed_temp = purrr::map_chr(data, ~my_files_lookup[[.x$date_date_symptoms_fixed[1]]]$file_date_iso %>% paste0("")),
    # TODO: clean & improve later with "R" style - see: https://github.com/tidyverse/purrr/issues/254
    date_removed_temp = ifelse(date_removed_temp == "", NA, date_removed_temp),
    date_age_fixed_temp = ifelse(date_age_fixed_temp == "", NA, date_age_fixed_temp),
    date_sex_fixed_temp = ifelse(date_sex_fixed_temp == "", NA, date_sex_fixed_temp),
    date_origin_fixed_temp = ifelse(date_origin_fixed_temp == "", NA, date_origin_fixed_temp),
    date_date_symptoms_fixed_temp = ifelse(date_date_symptoms_fixed_temp == "", NA, date_date_symptoms_fixed_temp),
    any_fixed = sum(
      !is.na(date_removed_temp),
      !is.na(date_age_fixed_temp),
      !is.na(date_sex_fixed_temp),
      !is.na(date_origin_fixed_temp),
      !is.na(date_date_symptoms_fixed_temp)
    )
  ) %>%
  tidyr::unnest(cols=data)

# adding original data
rows <- rows %>%
  dplyr::group_by(patient_id) %>%
  tidyr::nest() %>%
  dplyr::mutate(
    age_original = purrr::map_chr(data, ~pull_original_attribute(.x, age, age_id)),
    sex_original = purrr::map_chr(data, ~pull_original_attribute(.x, sex, sex_id)),
    origin_original = purrr::map_chr(data, ~pull_original_attribute(.x, origin, origin_id)),
    date_symptoms_original = purrr::map_chr(data, ~pull_original_attribute(.x, date_symptoms, date_symptoms_id)),
    # TODO: clean & improve later with "R" style - see: https://github.com/tidyverse/purrr/issues/254
    age_original = ifelse(age_original == "", NA, age_original),
    sex_original = ifelse(sex_original == "", NA, sex_original),
    origin_original = ifelse(origin_original == "", NA, origin_original),
    date_symptoms_original = ifelse(date_symptoms_original == "", NA, date_symptoms_original)
  ) %>%
  tidyr::unnest(cols=data) %>%
  dplyr::ungroup()

processed <- rows %>%
  dplyr::mutate(
    day_confirmed = min(file_day)
  ) %>%
  dplyr::mutate(
    file_id = sub("(.)", "\\U\\1", file_id, perl=TRUE)
  ) %>%
  dplyr::select(
    file_id,
    case,
    state,
    age_id,
    sex_id,
    situation,
    date_symptoms_id,
    origin_id,
    date_arrival,

    date_confirmed,
    date_removed_temp,
    day_confirmed,

    age_original,
    sex_original,
    origin_original,
    date_symptoms_original,

    date_age_fixed_temp,
    date_sex_fixed_temp,
    date_origin_fixed_temp,
    date_date_symptoms_fixed_temp,

    any_fixed,
    patient_id,
    patient_id_unique
  ) %>%
  dplyr::rename(
    Estado = state,
    Edad = age_id,
    Sexo = sex_id,
    Situacion = situation,
    Fecha_Sintomas = date_symptoms_id,
    Procedencia = origin_id,
    Fecha_Llegada = date_arrival,

    Fecha_Confirmacion_Positivo = date_confirmed,
    Fecha_Eliminacion = date_removed_temp,
    Dia_Positivo = day_confirmed,

    Edad_Original = age_original,
    Sexo_Original = sex_original,
    Procedencia_Original = origin_original,
    Fecha_Sintomas_Original = date_symptoms_original,

    Edad_Fecha_Correccion = date_age_fixed_temp,
    Sexo_Fecha_Correccion = date_sex_fixed_temp,
    Procedencia_Fecha_Correccion = date_origin_fixed_temp,
    Sintomas_Fecha_Correction = date_date_symptoms_fixed_temp,

    Total_Inconsistencias = any_fixed,
    Paciente_Id = patient_id,
    Paciente_Id_Unico = patient_id_unique
  ) %>%
  tidyr::spread(key=file_id, value=case)


write.csv(processed, paste0(destination_other, "positivos.csv"), row.names=FALSE)




