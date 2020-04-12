# -------------------------------------------------------------------------------------

source("_functions.R")

destination <- "../../www/tablas-diarias"
destination_other <- "../../www/otros"

files <- init_files(destination)

files_lookup <- create_files_lookup(files)
my_files_lookup <- dlply(files_lookup, 1, c)

# putting all the rows together
rows_orig <- do.call(rbind, files)
rows_orig <- setDT(rows_orig, keep.rownames = TRUE)[]

# separate the first column to get File_Id
rows <- rows_orig %>% 
  tidyr::separate(rn, into = c("File_Id", "row"), sep = "\\.") %>%
  dplyr::select(-row) %>%
  dplyr::mutate(
    # todo - change original files later
    Fecha_Sintomas_Corregido = ifelse(Fecha_Sintomas_Corregido == "True", TRUE, FALSE)
  ) %>%
  dplyr::inner_join(
    files_lookup %>% dplyr::select(file_id, file_date_iso, type), 
    by=c("File_Id" = "file_id")
  ) %>%
  dplyr::rename(
    File_Date = file_date_iso,
    Type = type
  )

# -------------------------------------------------------------------------------------
# D a t e . N o r m a l i z a t i o n

# check how many files have at least 1 date fixed
rows %>% 
  dplyr::filter(Fecha_Sintomas_Corregido == TRUE) %>% 
  dplyr::pull(File_Id) %>% 
  unique()

# specific examples
rows %>%
  dplyr::filter(
    File_Id == "positivos_2020_04_08" &
      Edad == 71 & 
      Estado_Normalizado == "YUC"
  ) %>%
  dplyr::select(
    Caso, Estado, Sexo, Edad, 
    Fecha_Sintomas, Fecha_Sintomas_Normalizado
  )

rows %>%
  dplyr::filter(
    File_Id == "positivos_2020_04_09" &
      Edad == 71 & 
      Estado_Normalizado == "YUC"
  ) %>%
  dplyr::select(
    Caso, Estado, Sexo, Edad, 
    Fecha_Sintomas, Fecha_Sintomas_Normalizado
  )

# -------------------------------------------------------------------------------------
# S e x . N o r m a l i z a t i o n

table(rows$Sexo)

table(rows$Sexo_Normalizado)

rows %>%
  dplyr::filter(Sexo %in% c("MASCULINO", "FEMENINO")) %>%
  dplyr::pull(File_Id) %>%
  unique()

# -------------------------------------------------------------------------------------
# S t a t e . N o r m a l i z a t i o n

# how many different we have
table(rows$Estado) %>% 
  length()

# examples of san luis
rows %>% 
  dplyr::filter(
    grepl("SAN|San", Estado)
  ) %>%
  dplyr::pull(Estado) %>%
  unique()

# getting files with a * (recovered)
rows %>% 
  dplyr::filter(
    grepl("\\*", Estado)
  ) %>%
  dplyr::select(
    File_Id, Estado, Caso, Sexo, Edad,
    Fecha_Sintomas_Normalizado
  )

# files where we have distrito
rows %>% 
  dplyr::filter(
    grepl("Distrito", Estado, ignore.case=TRUE)
  ) %>%
  dplyr::pull(File_Id) %>%
  unique()

# we verify there's no ciudad de mexico in these files
rows %>% 
  dplyr::filter(
    grepl("Ciudad", Estado, ignore.case=TRUE) &
      File_Id %in% c("positivos_2020_04_06", "sospechosos_2020_04_06")
  ) %>% 
  nrow() 


# -------------------------------------------------------------------------------------
# O r i g i n . N o r m a l i z a t i o n

table(rows$Procedencia) %>% 
  length()

# how many only for positive cases
rows %>% 
  dplyr::filter(
    Type == "positivos"
  ) %>% 
  dplyr::select(Procedencia) %>%
  unique() %>% 
  nrow()


# checking positive vs suspected files
rows %>% 
  dplyr::group_by(File_Date, Type) %>%
  dplyr::summarise(
    N=unique(Procedencia) %>% length()
  ) %>%
  tidyr::spread(Type, N) %>%
  dplyr::filter(
    File_Date > "2020-04-01"
  )
  
