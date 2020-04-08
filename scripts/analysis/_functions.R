library(plyr)
library(rjson)
library(tidyr)
library(data.table)
library(purrr)
library(forcats)
library(lubridate)

# -------------------------------------------------------------------------------------

# F U N C T I O N S

init_files <- function(path) {
  filenames <- list.files(
    path=path, 
    pattern="*.csv", 
    recursive=TRUE,
    full.names=TRUE
  )

  indexes <- basename(filenames)
  types <- basename(dirname(dirname(filenames)))
  names(filenames) <- gsub("(\\d{4})(\\d{2})(\\d{2}).csv", "\\1_\\2_\\3", paste(types, indexes, sep="_"))
  
  files <- lapply(filenames, read.csv, header=TRUE, na.strings="")
  
  files
}

# add_time_columns(times, "my_time", "etc", tz = "UTC", hours=TRUE, format="%Y-%m-%d %H:%M:%S")

add_time_columns <- function(df, column, prefix, format="%Y-%m-%d", tz="America/Los_Angeles", hours = FALSE) {
  colname <- paste0(prefix, "_std")
  # to create quotation: https://thisisnic.github.io/2018/04/16/how-do-i-make-my-own-dplyr-style-functions/
  # column <- enquo(column)
  #browser()
  df <- df %>%
    dplyr::mutate(
      # remember !! is for evaluating right away
      # remember sym is for converting strings to symbols
      !!colname := as.POSIXct(!!rlang::sym(column), format=format, tz=tz, usetz=TRUE),
      !!paste0(prefix, "_iso") := lubridate::as_date(!!rlang::sym(colname)),
      !!paste0(prefix, "_day") := day(!!rlang::sym(colname)),
      !!paste0(prefix, "_month") := month(!!rlang::sym(colname)),
      !!paste0(prefix, "_month_name") := factor(!!rlang::sym(paste0(prefix, "_month")), levels = 1:12, labels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")),
      !!paste0(prefix, "_year") := year(!!rlang::sym(colname)),
      !!paste0(prefix, "_weekday") := wday(!!rlang::sym(colname), week_start = getOption("lubridate.week.start", 7)),
      !!paste0(prefix, "_weekday_name") := factor(!!rlang::sym(paste0(prefix, "_weekday")), levels = 1:7, labels = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")),
      !!paste0(prefix, "_weekday_name") := forcats::fct_explicit_na(!!rlang::sym(paste0(prefix, "_weekday_name")), na_level = "NA")
    )
  
  if (hours) {
    df <- df %>% 
      dplyr::mutate(
        # remember !! is for evaluating right away
        # remember sym is for converting strings to symbols
        # format = "%Y-%m-%d %h:%m"
        !!colname := as.POSIXct(!!rlang::sym(column), format=format, tz=tz, usetz=TRUE),
        !!paste0(prefix, "_hour") := hour(!!rlang::sym(colname)),
        !!paste0(prefix, "_minute") := minute(!!rlang::sym(colname)),
        !!paste0(prefix, "_second") := second(!!rlang::sym(colname))
      )
  }
  
  df
}


slugify <- function(x, alphanum_replace="", space_replace="-", tolower=TRUE) {
  x <- gsub("/", "-", x)
  x <- gsub("[^[:alnum:] -]", alphanum_replace, x)
  x <- gsub(" ", space_replace, x)
  if (tolower) { 
    x <- tolower(x) 
  }
  
  x <- gsub("á", "a", x)
  x <- gsub("é", "e", x)
  x <- gsub("í", "i", x)
  x <- gsub("ó", "o", x)
  x <- gsub("ú", "u", x)
  x <- gsub("ñ", "n", x)
  
  return(x)
}


create_files_lookup <- function(files) {
  browser()
  files_lookup <- names(files) %>% as.data.frame()
  colnames(files_lookup) <- c("file_id")
  
  files_lookup %>% 
    dplyr::mutate(temp = gsub("([a-z]+)_(.*)", "\\1.\\2", file_id)) %>%
    tidyr::separate(temp, c("type", "file_date"), sep="\\.") %>%
    dplyr::group_by(type) %>% 
    dplyr::arrange(file_date) %>%
    dplyr::mutate(file_day = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    add_time_columns("file_date", prefix="file_date", format="%Y_%m_%d") %>%
    dplyr::mutate(
      file_id = as.character(file_id)
    ) %>%
    as.data.frame()
}


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


get_ids_for_type <- function(file_type="positivos", rows, files_lookup) {
  my_unique_files <- files_lookup %>% 
    dplyr::filter(type == file_type) %>% 
    dplyr::pull(file_id) %>% 
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


pull_original_attribute <- function(df, attr, attr_original) {
  df %>% 
    dplyr::filter(!(!!rlang::enquo(attr) %in% !!rlang::enquo(attr_original))) %>% 
    dplyr::pull(!!rlang::enquo(attr)) %>% unique() %>% 
    paste0("", collapse = ", ")
}

# -------------------------------------------------------------------------------------
