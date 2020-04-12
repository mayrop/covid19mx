rows_to_check = rows[rows$file_date_std > "2020-04-05",]

positive_ids = get_ids_for_type("positivos", rows_to_check)

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

my_map <- my_map %>%
  dplyr::select(-starts_with("positivos"), -starts_with("status")) %>%
  tidyr::gather(date, data, -patient_id, -starts_with("status"), -starts_with("positivos")) %>%
  tidyr::unnest(cols = data)

#checking things that were removed
my_map %>%
  dplyr::arrange(date) %>%
  dplyr::group_by(patient_id) %>%
  tidyr::nest() %>%
  dplyr::mutate(
    date_added = map_chr(data, function(.x) { 
      temp <- .x %>% dplyr::filter(y == "ADDED") %>% dplyr::pull(date) %>% paste0(., "", collapse=NULL)
      if (length(temp) > 1) {
        return("CHECK")
      } 
      temp
    }),
    date_removed = map_chr(data, function(.x) { 
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
  View()
