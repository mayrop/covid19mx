
# -------------------------------------------------------------------------------------

# set the folder to the level above
source("_functions.R")

destination <- "../../www/tablas-diarias"

files <- init_files(destination)

files_lookup <- create_files_lookup(files)
my_files_lookup <- dlply(files_lookup, 1, c)

# we merge all rows together
rows_orig <- do.call(rbind, files)
rows_orig <- setDT(rows_orig, keep.rownames = TRUE)[]

# we create an ID per patient based on different factors that stay constant between all files
# we will only read positive cases
rows <- rows_orig %>%
  tidyr::separate(rn, into = c("File_Id", "Fila"), sep = "\\.") %>%
  dplyr::select(-Fila) %>%
  dplyr::filter(
    grepl("positivos", File_Id)
  )
# ignore warning Expected 2 pieces. Missing pieces filled with `NA` in 1 rows [1].

# for now we convert columns to english
# pending to change to spanish - if time permits
colnames(rows) <- c(
  "file_id", "case", "state_original", "city_original", "sex_original",
  "age", "date_symptoms_original", "situation_original", "origin_original", "date_arrival_original",
  "state", "city", "sex", "date_symptoms", "is_date_symptoms_fixed", "situation",
  "origin", "date_arrival"
)

print("Adding empty columns")
rows <- rows %>%
  dplyr::mutate(
    age_fixed = NA,
    date_age_fixed = NA,
    origin_fixed = NA,
    date_origin_fixed = NA,
    sex_fixed = NA,
    date_sex_fixed = NA,
    date_removed = NA,
    date_date_symptoms_fixed = NA,
    date_symptoms_id = as.character(date_symptoms)
  )

print("Adding the main patient ID")
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

print("Now we separate the cases with same characteristics")
rows <- add_patient_ids_with_rows(rows)

print("Now we apply manual fixes for age etc")
source("_fixes.R")

print("After the fixes, we go back and calculate the new ids")
rows <- add_patient_ids(rows)

history <- create_history_from_rows(rows)
inconsistencies <- create_inconsistencies_from_history(history)

# set back to spanish
write.csv(rows, "cache/analysis.04_06.rows.04.12.csv", row.names=FALSE)
write.csv(history, "cache/analysis.04_06.history.04.12.csv", row.names=FALSE)
write.csv(inconsistencies, "cache/analysis.04_06.inconsistencies.04.12.csv", row.names=FALSE)

# check how many inconsistencies
inconsistencies %>%
  dplyr::group_by(date_removed) %>%
  dplyr::summarise(n = length(unique(patient_id)))

rows[rows$file_id == "positivos_2020_04_05",]$patient_id

