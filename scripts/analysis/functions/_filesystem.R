
# F U N C T I O N S

# -------------------------------------------------------------------------------------

#' Function to install and load libraries
load_libraries <- function(libraries) {
  if (!is.array(libraries)) {
    libraries <- as.array(libraries)
  }
  for (library in libraries) {
    if (!require(library, character.only = TRUE)) {
      install.packages(library)
    }
    
    library(library, character.only = TRUE)
  }
}

# -------------------------------------------------------------------------------------

#' Function to install from devtools::install_github
load_github <- function(libraries) {
  load_libraries(c("remotes"))
  
  if (!is.array(libraries)) {
    libraries <- as.array(libraries)
  }
  
  for (library in libraries) {
    suffix <- gsub(".*?/", "", library)
    
    if (!require(suffix, character.only = TRUE)) {
      print(library)
      remotes::install_github(library)
    }
    
    library(suffix, character.only = TRUE)
  }
}

# -------------------------------------------------------------------------------------

# see: https://timogrossenbacher.ch/2016/12/beautiful-thematic-maps-with-ggplot2-only/
detach_all_packages <- function() {
  basic.packages.blank <-  c("stats", 
                             "graphics", 
                             "grDevices", 
                             "utils", 
                             "datasets", 
                             "methods", 
                             "base")
  basic.packages <- paste("package:", basic.packages.blank, sep = "")
  
  package.list <- search()[ifelse(unlist(gregexpr("package:", search())) == 1, 
                                  TRUE, 
                                  FALSE)]
  
  package.list <- setdiff(package.list, basic.packages)
  
  if (length(package.list) > 0)  for (package in package.list) {
    detach(package, character.only = TRUE)
    print(paste("package ", package, " detached", sep = ""))
  }
}

# -------------------------------------------------------------------------------------

init_files <- function(path, depth=2) {
  filenames <- list.files(
    path=path,
    pattern="*.csv",
    recursive=TRUE,
    full.names=TRUE
  )
  
  indexes <- basename(filenames)
  types <- filenames
  
  for (i in 1:depth) {
    types <- dirname(types)
  }
  
  types <- basename(types)
  
  names(filenames) <- gsub("(\\d{4})(\\d{2})(\\d{2}).csv", "\\1_\\2_\\3", paste(types, indexes, sep="_"))
  
  files <- lapply(filenames, read.csv, header=TRUE, na.strings="")
  
  files
}

# -------------------------------------------------------------------------------------

create_files_lookup <- function(files) {
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

# -------------------------------------------------------------------------------------