# fixing for rows %>% dplyr::filter(procedencia == 'EN INVESTIGACIÓN'), that person later shows up as "Contacto"
# see line 64 in http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-21.pdf and
# http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-20.pdf
rows[grepl("cuba", rows$patient_id, ignore.case=TRUE),]
rows[grepl("investiga", rows$origin, ignore.case=TRUE), ] 


# http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-20.txt
# http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-19.txt
# 64    CIUDAD DE MÉXICO   M   41   09/03/2020   confirmado   En investigación      NA
# 92    CIUDAD DE MÉXICO   M   41   09/03/2020 confirmado   En investigación NA

rows[
  rows$patient_id %in% c(
    "cmx_m_41_2020-03-09_en-investigacion_NA_1"
  ) & rows$file_id %in% c(
    "positivos_2020_03_19", "positivos_2020_03_20"
  ), c("origin_fixed")
  ]  <- "CONTACTO"

rows[
  rows$patient_id %in% c(
    "cmx_m_41_2020-03-09_en-investigacion_NA_1"
  ) & rows$file_id %in% c(
    "positivos_2020_03_19", "positivos_2020_03_20"
  ), c("date_origin_fixed")
  ]  <- "positivos_2020_03_21"


# line 

rows[
  rows$patient_id %in% c(
    "cmx_m_64_2020-03-10_contacto---cuba_2020-03-10_1",
    "cmx_m_64_2020-03-10_contacto-cuba_2020-03-10_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_13", "positivos_2020_03_14", "positivos_2020_03_15", 
      "positivos_2020_03_18", "positivos_2020_03_19"
    ), c("origin_fixed")
  ] <- "CONTACTO"

rows[
  rows$patient_id %in% c(
    "cmx_m_64_2020-03-10_contacto---cuba_2020-03-10_1",
    "cmx_m_64_2020-03-10_contacto-cuba_2020-03-10_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_13", "positivos_2020_03_14", "positivos_2020_03_15", 
      "positivos_2020_03_18", "positivos_2020_03_19"
    ), c("date_origin_fixed")
  ] <- "positivos_2020_03_20"


# http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-22.pdf
# http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-23.pdf
# 284 YUCATÁN M 0 17/03/2020 confirmado Contacto NA
# 287 YUCATÁN M 31 17/03/2020 confirmado Contacto NA
rows[
  rows$patient_id %in% c(
    "yuc_m_0_2020-03-17_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_22"
    ), c("age_fixed")
  ] <- 31

rows[
  rows$patient_id %in% c(
    "yuc_m_0_2020-03-17_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_22"
    ), c("date_age_fixed")
  ] <- "positivos_2020_03_23"


#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-20.txt
#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-23.txt
#line 142 was changd from contact to Estados Unidos
#142    QUINTANA ROO      M   45   15/03/2020   confirmado     Contacto       15/03/2020
#143    QUINTANA ROO      M   45   15/03/2020   confirmado   Estados Unidos   15/03/2020
rows[
  rows$patient_id %in% c(
    "roo_m_45_2020-03-15_contacto_2020-03-15_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_20", "positivos_2020_03_21", "positivos_2020_03_22"
    ), c("origin_fixed")
  ] <- "ESTADOS UNIDOS"

rows[
  rows$patient_id %in% c(
    "roo_m_45_2020-03-15_contacto_2020-03-15_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_20", "positivos_2020_03_21", "positivos_2020_03_22"
    ), c("date_origin_fixed")
  ] <- "positivos_2020_03_23"


#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-19.txt
#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-20.txt
# chh_m_30_2020-03-12_alemania_2020-03-12_1
#edad was changed from 30 to 29
#67      CHIHUAHUA        M   29   12/03/2020   confirmado      Alemania        12/03/2020
#66    CHIHUAHUA          M   30   12/03/2020 confirmado   Alemania         12/03/2020
rows[
  rows$patient_id %in% c(
    "chh_m_30_2020-03-12_alemania_2020-03-12_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_17", "positivos_2020_03_18", "positivos_2020_03_19"
    ), c("age_fixed")
  ] <- 29

rows[
  rows$patient_id %in% c(
    "chh_m_30_2020-03-12_alemania_2020-03-12_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_17", "positivos_2020_03_18", "positivos_2020_03_19"
    ), c("date_age_fixed")
  ] <- "positivos_2020_03_20"

#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-20.txt
#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-23.txt
# line 66 was changed from contacto to Alemania
#166    QUINTANA ROO    M   35   15/03/2020  confirmado     Contacto      14/03/2020
#167    QUINTANA ROO    M   35   15/03/2020  confirmado     Alemania      14/03/2020  

rows[
  rows$patient_id %in% c(
    "roo_m_35_2020-03-15_contacto_2020-03-14_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_20", "positivos_2020_03_21", "positivos_2020_03_22"
    ), c("origin_fixed")
  ] <- "ALEMANIA"

rows[
  rows$patient_id %in% c(
    "roo_m_35_2020-03-15_contacto_2020-03-14_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_20", "positivos_2020_03_21", "positivos_2020_03_22"
    ), c("date_origin_fixed")
  ] <- "positivos_2020_03_23"


# http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-21.pdf
# http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-26.pdf
# 232 JALISCO M 56 17/03/2020 confirmado Estados Unidos 04/03/2020
# 240 JALISCO M 58 17/03/2020 confirmado Estados Unidos 04/03/2020

rows[
  rows$patient_id %in% c(
    "jal_m_56_2020-03-17_estados-unidos_2020-03-04_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_21", "positivos_2020_03_22", "positivos_2020_03_23", "positivos_2020_03_24",
      "positivos_2020_03_25"
    ), c("age_fixed")
  ] <- 58

rows[
  rows$patient_id %in% c(
    "jal_m_56_2020-03-17_estados-unidos_2020-03-04_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_21", "positivos_2020_03_22", "positivos_2020_03_23", "positivos_2020_03_24",
      "positivos_2020_03_25"
    ), c("date_age_fixed")
  ] <- "positivos_2020_03_26"


#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-22.pdf
#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-24.pdf
# 
#250 JALISCO M 0 09/03/2020 confirmado España 12/03/2020
#253 JALISCO M 55 09/03/2020 confirmado España 12/03/2020
rows[
  rows$patient_id %in% c(
    "jal_m_0_2020-03-09_espana_2020-03-12_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_22", "positivos_2020_03_23"
    ), c("age_fixed")
  ] <- 55

rows[
  rows$patient_id %in% c(
    "jal_m_0_2020-03-09_espana_2020-03-12_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_22", "positivos_2020_03_23"
    ), c("date_age_fixed")
  ] <- "positivos_2020_03_24"  


#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-22.pdf
#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-23.pdf
# jal_m_24_2020-03-17_NA_2020-03-15_si1 
# 304 JALISCO M 24 17/03/2020 confirmado Contacto 15/03/2020
# 311 JALISCO M 24 17/03/2020 confirmado Estados Unidos 15/03/2020

rows[
  rows$patient_id %in% c(
    "jal_m_24_2020-03-17_contacto_2020-03-15_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_22"
    ), c("origin_fixed")
  ] <- "ESTADOS UNIDOS"

rows[
  rows$patient_id %in% c(
    "jal_m_24_2020-03-17_contacto_2020-03-15_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_22"
    ), c("date_origin_fixed")
  ] <- "positivos_2020_03_23"


# 355 QUINTANA ROO F 21 18/03/2020 confirmado Contacto 18/03/2020


#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-24.pdf
#
#339 CIUDAD DE MÉXICO M 60 18/03/2020 confirmado Contacto NA

#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-03-26.pdf
#574 MÉXICO F 48 16/03/2020 confirmado Contacto NA


#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-27.txt
#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-04-03.txt
#614       TLAXCALA       M   56   22/03/2020   confirmado   Estados Unidos   21/03/2020
#629       TLAXCALA       F   56   22/03/2020   Confirmado   Estados Unidos   21/03/2020

rows[
  rows$patient_id %in% c(
    "tla_m_56_2020-03-22_estados-unidos_2020-03-21_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_27", "positivos_2020_03_28", "positivos_2020_03_29", 
      "positivos_2020_03_30", "positivos_2020_03_31", "positivos_2020_04_01",
      "positivos_2020_04_02"
    ), c("sex_fixed")
  ] <- "F"

rows[
  rows$patient_id %in% c(
    "tla_m_56_2020-03-22_estados-unidos_2020-03-21_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_27", "positivos_2020_03_28", "positivos_2020_03_29", 
      "positivos_2020_03_30", "positivos_2020_03_31", "positivos_2020_04_01",
      "positivos_2020_04_02"
    ), c("date_sex_fixed")
  ] <- "positivos_2020_04_03"



#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-30.txt
#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-31.txt
#1043       COAHUILA         F   46   24/03/2020   confirmado   Estados Unidos   22/03/2020
#1066       COAHUILA         F   76   24/03/2020   confirmado   Estados Unidos   22/03/2020
rows[
  rows$patient_id %in% c(
    "coa_f_46_2020-03-24_estados-unidos_2020-03-22_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_30"
    ), c("age_fixed")
  ] <- 76

rows[
  rows$patient_id %in% c(
    "coa_f_46_2020-03-24_estados-unidos_2020-03-22_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_30"
    ), c("date_age_fixed")
  ] <- "positivos_2020_03_31"


#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-29.txt
#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-31.txt
#892       SINALOA        M   55   22/03/2020   confirmado     Contacto          NA
#893           SINALOA        M   85   22/03/2020   confirmado     Contacto          NA

rows[
  rows$patient_id %in% c(
    "sin_m_55_2020-03-22_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_29", "positivos_2020_03_30"
    ), c("age_fixed")
  ] <- 85

rows[
  rows$patient_id %in% c(
    "sin_m_55_2020-03-22_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_29", "positivos_2020_03_30"
    ), c("date_age_fixed")
  ] <- "positivos_2020_03_31"



#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-23.txt
#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-24.txt
#355          QUINTANA ROO          F         21          18/03/2020             confirmado             Contacto       18/03/2020
#367     QUINTANA ROO        F   21   18/03/2020   confirmado   Estados Unidos   18/03/2020

rows[
  rows$patient_id %in% c(
    "roo_f_21_2020-03-18_contacto_2020-03-18_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_23"
    ), c("origin_fixed")
  ] <- "ESTADOS UNIDOS"

rows[
  rows$patient_id %in% c(
    "roo_f_21_2020-03-18_contacto_2020-03-18_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_23"
    ), c("date_origin_fixed")
  ] <- "positivos_2020_03_24"


#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-04-02.txt
#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-22.txt
#135       MÉXICO         F   52   10/03/2020   confirmado      España        12/03/2020
#156       MÉXICO         F   52   10/03/2020   Confirmado      España        12/03/2020
#mex_f_52_2020-03-10_espana_2020-03-12_1  

rows[
  rows$patient_id %in% c(
    "mex_f_52_2020-03-10_espana_2020-03-12_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_20",
      "positivos_2020_03_21", "positivos_2020_03_22", "positivos_2020_03_23", 
      "positivos_2020_03_24", "positivos_2020_03_25", "positivos_2020_03_26", 
      "positivos_2020_03_27", "positivos_2020_03_28", "positivos_2020_03_29", 
      "positivos_2020_03_30", "positivos_2020_03_31", "positivos_2020_04_01", 
      "positivos_2020_04_02"
    ), c("date_removed")
  ] <- "positivos_2020_04_03"


#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-15.txt
#10 PUEBLA  M 47  08/03/2020  confirmado Italia 04/03/2020

rows[
  rows$patient_id %in% c(
    "pue_m_47_2020-03-08_italia_2020-03-04_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_15"
    ), c("date_removed")
  ] <- "positivos_2020_03_16"


#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-26.txt
#576  MÉXICO  F   33   22/03/2020   confirmado   Contacto      NA

rows[
  rows$patient_id %in% c(
    "mex_f_33_2020-03-22_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_26", "positivos_2020_03_27", "positivos_2020_03_28", 
      "positivos_2020_03_29", "positivos_2020_03_30", "positivos_2020_03_31",
      "positivos_2020_04_01"
    ), c("date_removed")
  ] <- "positivos_2020_04_02"


# 1184      JALISCO          M   46   17/03/2020   confirmado     Contacto          NA
# http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-31.txt
rows[
  rows$patient_id %in% c(
    "jal_m_46_2020-03-17_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_31"
    ), c("date_removed")
  ] <- "positivos_2020_04_01"



# 585        CHIAPAS          F   32   20/03/2020   confirmado   Estados Unidos   07/03/2020
# http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-27.txt

rows[
  rows$patient_id %in% c(
    "chp_f_32_2020-03-20_estados-unidos_2020-03-07_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_27"
    ), c("date_removed")
  ] <- "positivos_2020_03_28"


# 640       MÉXICO         F   31   19/03/2020   confirmado     Contacto          NA
# http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-27.txt

rows[
  rows$patient_id %in% c(
    "mex_f_31_2020-03-19_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_26", "positivos_2020_03_27", "positivos_2020_03_28",
      "positivos_2020_03_29", "positivos_2020_03_30", "positivos_2020_03_31"
    ), c("date_removed")
  ] <- "positivos_2020_04_01"


# http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-26.txt
# 339   CIUDAD DE MÉXICO   M   60   18/03/2020   confirmado   Contacto      NA

rows[
  rows$patient_id %in% c(
    "cmx_m_60_2020-03-18_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_24", "positivos_2020_03_25", "positivos_2020_03_26"
    ), c("date_removed")
  ] <- "positivos_2020_03_27"


# http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-25.txt
# 302       JALISCO        M   31   18/03/2020   confirmado   Estados Unidos   08/03/2020
rows[
  rows$patient_id %in% c(
    "jal_m_31_2020-03-18_estados-unidos_2020-03-08_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_22", "positivos_2020_03_23", "positivos_2020_03_24",
      "positivos_2020_03_25"
    ), c("date_removed")
  ] <- "positivos_2020_03_26"


# http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-26.txt
# 574               MÉXICO                      F   48   16/03/2020   confirmado   Contacto      NA

rows[
  rows$patient_id %in% c(
    "mex_f_48_2020-03-16_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_26", "positivos_2020_03_27", "positivos_2020_03_28",
      "positivos_2020_03_29", "positivos_2020_03_30", "positivos_2020_03_31"
    ), c("date_removed")
  ] <- "positivos_2020_04_01"



# http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-26.txt
# 575 MÉXICO  M   60   20/03/2020   confirmado   Contacto      NA
rows[
  rows$patient_id %in% c(
    "mex_m_60_2020-03-20_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_26", "positivos_2020_03_27", "positivos_2020_03_28",
      "positivos_2020_03_29", "positivos_2020_03_30", "positivos_2020_03_31"
    ), c("date_removed")
  ] <- "positivos_2020_04_01"



#573  MÉXICO  F   31   21/03/2020   confirmado   Contacto      NA
#http://localhost:1313/data/results/txt/covid-19-resultado-positivos-indre-2020-03-26.txt
rows[
  rows$patient_id %in% c(
    "mex_f_31_2020-03-21_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_26", "positivos_2020_03_27", "positivos_2020_03_28",
      "positivos_2020_03_29", "positivos_2020_03_30", "positivos_2020_03_31",
      "positivos_2020_04_01"
    ), c("date_removed")
  ] <- "positivos_2020_04_02"



#1194 COAHUILA F 0 28/03/2020 Confirmado Contacto NA
#1189 COAHUILA F 37 28/03/2020 Confirmado Contacto NA
#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-04-03.pdf
#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-04-04.pdf
rows[
  rows$patient_id %in% c(
    "coa_f_0_2020-03-28_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_31", "positivos_2020_04_01", "positivos_2020_04_02",
      "positivos_2020_04_03"
    ), c("age_fixed")
  ] <- 37

rows[
  rows$patient_id %in% c(
    "coa_f_0_2020-03-28_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_31", "positivos_2020_04_01", "positivos_2020_04_02",
      "positivos_2020_04_03"
    ), c("date_age_fixed")
  ] <- "positivos_2020_04_04"



#638 MÉXICO M 37 21/03/2020 Confirmado Contacto NA
#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-04-03.pdf

rows[
  rows$patient_id %in% c(
    "mex_m_37_2020-03-21_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_26", "positivos_2020_03_27", "positivos_2020_03_28",
      "positivos_2020_03_29", "positivos_2020_03_30", "positivos_2020_03_31",
      "positivos_2020_04_01", "positivos_2020_04_02", "positivos_2020_04_03"
    ), c("date_removed")
  ] <- "positivos_2020_04_04"



# 633 MÉXICO F 22 24/03/2020 Confirmado Contacto NA
#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-04-03.pdf
rows[
  rows$patient_id %in% c(
    "mex_f_22_2020-03-24_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_26", "positivos_2020_03_27", "positivos_2020_03_28",
      "positivos_2020_03_29", "positivos_2020_03_30", "positivos_2020_03_31",
      "positivos_2020_04_01", "positivos_2020_04_02", "positivos_2020_04_03"
    ), c("date_removed")
  ] <- "positivos_2020_04_04"


# 634 MÉXICO F 22 16/03/2020 Confirmado Contacto 15/03/2020
#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-04-03.pdf
rows[
  rows$patient_id %in% c(
    "mex_f_22_2020-03-16_contacto_2020-03-15_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_26", "positivos_2020_03_27", "positivos_2020_03_28",
      "positivos_2020_03_29", "positivos_2020_03_30", "positivos_2020_03_31",
      "positivos_2020_04_01", "positivos_2020_04_02", "positivos_2020_04_03"
    ), c("date_removed")
  ] <- "positivos_2020_04_04"


# 634 MÉXICO F 22 16/03/2020 Confirmado Contacto 15/03/2020
#http://localhost:1313/data/results/covid-19-resultado-positivos-indre-2020-04-03.pdf
rows[
  rows$patient_id %in% c(
    "mex_f_22_2020-03-16_contacto_2020-03-15_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_26", "positivos_2020_03_27", "positivos_2020_03_28",
      "positivos_2020_03_29", "positivos_2020_03_30", "positivos_2020_03_31",
      "positivos_2020_04_01", "positivos_2020_04_02", "positivos_2020_04_03"
    ), c("date_removed")
  ] <- "positivos_2020_04_04"


# 167       JALISCO        F   49   12/03/2020   Confirmado      España        09/03/2020
# https://covid19in.mx/data/results/txt/covid-19-resultado-positivos-indre-2020-04-04.txt
rows[
  rows$patient_id %in% c(
    "jal_f_49_2020-03-12_espana_2020-03-09_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_19", "positivos_2020_03_20", "positivos_2020_03_21", 
      "positivos_2020_03_22", "positivos_2020_03_23", "positivos_2020_03_24",
      "positivos_2020_03_25", "positivos_2020_03_26", "positivos_2020_03_27",
      "positivos_2020_03_28", "positivos_2020_03_29", "positivos_2020_03_30", 
      "positivos_2020_03_31", "positivos_2020_04_01", "positivos_2020_04_02",
      "positivos_2020_04_03", "positivos_2020_04_04"
    ), c("date_removed")
  ] <- "positivos_2020_04_05"


# 198       JALISCO        M   49   13/03/2020   Confirmado   Estados Unidos   08/03/2020
# https://covid19in.mx/data/results/txt/covid-19-resultado-positivos-indre-2020-04-04.txt
rows[
  rows$patient_id %in% c(
    "jal_m_49_2020-03-13_estados-unidos_2020-03-08_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_19", "positivos_2020_03_20", "positivos_2020_03_21", 
      "positivos_2020_03_22", "positivos_2020_03_23", "positivos_2020_03_24",
      "positivos_2020_03_25", "positivos_2020_03_26", "positivos_2020_03_27",
      "positivos_2020_03_28", "positivos_2020_03_29", "positivos_2020_03_30", 
      "positivos_2020_03_31", "positivos_2020_04_01", "positivos_2020_04_02",
      "positivos_2020_04_03", "positivos_2020_04_04"
    ), c("date_removed")
  ] <- "positivos_2020_04_05"


# 64   CIUDAD DE MÉXICO   M   59   07/03/2020   Confirmado      España        04/03/2020
# https://covid19in.mx/data/results/txt/covid-19-resultado-positivos-indre-2020-04-04.txt
rows[
  rows$patient_id %in% c(
    "cmx_m_59_2020-03-07_espana_2020-03-04_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_16", "positivos_2020_03_17", "positivos_2020_03_18", 
      "positivos_2020_03_19", "positivos_2020_03_20", "positivos_2020_03_21", 
      "positivos_2020_03_22", "positivos_2020_03_23", "positivos_2020_03_24",
      "positivos_2020_03_25", "positivos_2020_03_26", "positivos_2020_03_27",
      "positivos_2020_03_28", "positivos_2020_03_29", "positivos_2020_03_30", 
      "positivos_2020_03_31", "positivos_2020_04_01", "positivos_2020_04_02",
      "positivos_2020_04_03", "positivos_2020_04_04"
    ), c("date_removed")
  ] <- "positivos_2020_04_05"

# 1156    CIUDAD DE MÉXICO     M   45   13/03/2020   Confirmado      España        19/03/2020
# https://covid19in.mx/data/results/txt/covid-19-resultado-positivos-indre-2020-04-04.txt
rows[
  rows$patient_id %in% c(
    "cmx_m_45_2020-03-13_espana_2020-03-19_2"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_03_31", "positivos_2020_04_01", "positivos_2020_04_02",
      "positivos_2020_04_03", "positivos_2020_04_04"
    ), c("date_removed")
  ] <- "positivos_2020_04_05"


# 1699    CIUDAD DE MÉXICO     M   42   09/03/2020   Confirmado     Contacto          NA
# https://covid19in.mx/data/results/txt/covid-19-resultado-positivos-indre-2020-04-04.txt

rows[
  rows$patient_id %in% c(
    "cmx_m_42_2020-03-09_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_04_03", "positivos_2020_04_04"
    ), c("date_removed")
  ] <- "positivos_2020_04_05"


# 1834        QUERETARO         M   49   30/01/2020   Confirmado     Contacto          NA
# https://covid19in.mx/data/results/txt/covid-19-resultado-positivos-indre-2020-04-04.txt
rows[
  rows$patient_id %in% c(
    "que_m_49_2020-01-30_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_04_04"
    ), c("date_symptoms_fixed")
  ] <- "2020-03-30"

rows[
  rows$patient_id %in% c(
    "que_m_49_2020-01-30_contacto_NA_1"
  ) & 
    rows$file_id %in% c(
      "positivos_2020_04_04"
    ), c("date_date_symptoms_fixed")
  ] <- "positivos_2020_04_05"


