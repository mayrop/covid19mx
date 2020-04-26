
# todo to fix encoding on diarios_2020_04_13
positive_cities <- merged %>%
  dplyr::group_by(ENTIDAD_RES, MUNICIPIO_RES, RESULTADO_FACTOR) %>%
  dplyr::summarise(
    n = dplyr::n()
  ) %>%
  dplyr::filter(
    RESULTADO_FACTOR == "Positivo SARS-CoV-2"
  )

# join needs to be this way! 
  # https://github.com/tidyverse/ggplot2/issues/3391#issuecomment-508527985
positive_cities <- cities_shp %>%
  dplyr::right_join(
    positive_cities,
    by=c("CVE_ENT" = "ENTIDAD_RES", "CVE_MUN" = "MUNICIPIO_RES")
  )

positive_cities <- positive_cities %>%
  dplyr::left_join(
    cities, by = c("CVE_ENT" = "Clave_Entidad", "CVE_MUN" = "Clave_Municipio")
  )

positive_cities %>% 
  dplyr::filter(
    is.na(Poblacion_2019)
  )

positive_cities <- positive_cities %>%
  dplyr::filter(!is.na(CVE_MUN)) %>%
  dplyr::mutate(
    n = ifelse(is.na(n), 0, n),
    n_just = n * 100000 / Poblacion_2019,
    n_just = ifelse(is.na(n_just), 0, n_just),
  )

positive_cities <- positive_cities %>%
  dplyr::mutate(
    cuts = cut(
      n, 
      breaks = c(0, 1, 11, 26, 51, max(positive_cities$n) + 1),
      labels = c("0", "1-10", "11-25", "26-50", "51-max"),
      include.lowest = TRUE,
      right = FALSE
    )
  )

breaks <- c(0, 2, 5, 10, 15, 20, max(positive_cities$n_just, na.rm = TRUE) + 1)
cuts <- cut(
  positive_cities$n_just, 
  breaks = breaks,
  labels = c(
    "0 a 2.0", "2.1 a 5.0", "5.1 a 10.0", "10.1 a 15.0", "15.1 a 20.0", "> 20.1"),
  include.lowest = TRUE, 
  right = FALSE)

labels <- paste0(
  names(table(cuts)), 
  " (", table(cuts), " municipios)"
)

positive_cities <- positive_cities %>%
  dplyr::mutate(
    cuts_just = cut(
      n_just, 
      breaks = breaks,
      labels = labels,
      include.lowest = TRUE)    
  )

table(positive_cities$cuts_just)

my_n <- positive_cities %>% 
    dplyr::group_by(CVE_ENT, CVE_ENT)  %>% 
    dplyr::summarise(my_n = dplyr::n())

sum(my_n$my_n)
#state <- 2
#positive_coah <- positive %>% dplyr::filter(CVE_ENT == state)

png("mapa.png", width = 1500, height=1032, res = 180) 

ggplot() +
  scale_alpha(
    name = "",
    range = c(0.7, 0),
    guide = FALSE
  ) +
  # Adding citites
  geom_sf(
    data = cities_shp,
    color = "#aaaaaa",
    fill = "white",
    size = 0.03
  ) +
  # Adding states
  geom_sf(
    data = states_shp,
    color = "#AAAAAA",
    fill = "transparent",
    size = 0.15
  ) +
  geom_sf(
    data = positive_cities,
    aes(
      fill = cuts_just
    ),
    size = 0.05
  ) +
  scale_fill_manual(
    values = colors
  ) +  
  scale_color_manual(
    values = colors
  ) +
  labs(
    x = "",
    y = "",
    color = "Tasa de Incidencia\npor cada 100,000 habitantes",
    fill = "Tasa de Incidencia\npor cada 100,000 habitantes"
  ) +  
  theme_bw() +
  theme(
    legend.justification = c("right", "top"),
    legend.position = c(0.25, 0.35),
    legend.text = element_text(size = 7.5),
    legend.title = element_text(size = 7.5),
    title = element_text(size = 8, face = "bold"),
    plot.caption = element_text(hjust = 0, face = "plain"),
    legend.key.size = unit(0.8, "line"),
    legend.box.background = element_rect(colour = "gray")
    #panel.border = element_blank(),
    #panel.grid.major = element_blank(),
    #panel.grid.minor = element_blank(),
    #legend.key.size = unit(5,"cm"),
    #axis.ticks.y = element_blank(),
    #axis.title.y = element_blank(),
    #axis.text.y = element_blank(),
    #axis.ticks.x = element_blank(),
    #axis.title.x = element_blank(),
    #axis.text.x = element_blank()
  ) +
  labs(
    title = "COVID-19: Mapa de Tasa de Incidencia por cada 100,000 Habitantes (nivel Municipal)",
    subtitle = "Datos al 19 de Abril de 2020",
    caption = paste0(
      "Nota: De un total de 2458 municipios en México, ", sum(my_n$my_n), " (", round(sum(my_n$my_n)/2458, digits=4)  * 100, "%) de ellos tienen al menos un caso confirmado de COVID-19\nElaborado por: Mayra A. Valdés @mayrop\nFuentes: Secretaría de Salud de México, CONAPO, INEGI")
  )


dev.off()



state <- 5
positive_cities_state <- positive_cities %>%
  dplyr::filter(CVE_ENT == state)

breaks <- c(0, 0.00000001, 2, 5, 10, 15, 20, max(positive_cities_state$n_just, na.rm = TRUE) + 1)
cuts <- cut(
  positive_cities_state$n_just, 
  breaks = breaks,
  labels = c(
    "Sin casos", "0.1 a 2.0", "2.1 a 5.0", "5.1 a 10.0", "10.1 a 15.0", "15.1 a 20.0", "> 20.1"),
  include.lowest = TRUE, 
  right = FALSE)

labels <- paste0(
  names(table(cuts)), 
  " (", table(cuts), " municipios)"
)

positive_cities_state <- positive_cities_state %>%
  dplyr::mutate(
    cuts_just = cut(
      n_just, 
      breaks = breaks,
      labels = labels,
      include.lowest = TRUE)    
  )

table(positive_cities_state$cuts_just)

my_n <- positive_cities_state %>% 
  dplyr::group_by(CVE_ENT, CVE_ENT)  %>% 
  dplyr::summarise(my_n = dplyr::n())

sum(my_n$my_n)

png("mapa_coah.png", width = 1300, height=1532, res = 180) 

map_colors <- ifelse(
  positive_cities_state$n_just > 15,
  "white",
  "black")

ggplot() +
  scale_alpha(
    name = "",
    range = c(0.7, 0),
    guide = FALSE
  ) +
  # Adding citites
  geom_sf(
    data = cities_shp %>% dplyr::filter(CVE_ENT == state),
    color = "#aaaaaa",
    fill = "white",
    size = 0.03
  ) +
  # Adding states
  geom_sf(
    data = states_shp %>% dplyr::filter(CVE_ENT == state),
    color = "#AAAAAA",
    fill = "transparent",
    size = 0.15
  ) +
  geom_sf(
    data = positive_cities_state,
    aes(
      fill = cuts_just
    ),
    size = 0.05
  ) +
  scale_fill_manual(
    values = colors
  ) +  
  scale_color_manual(
    values = colors
  ) +
  geom_text(
    data = positive_cities_state, 
    aes(
      Longitud, 
      Latitud, 
      label = Nombre
    ), 
    colour = map_colors,
    size = 1.75
  ) +  
  labs(
    x = "",
    y = "",
    color = "Tasa de Incidencia\npor cada 100,000 habitantes",
    fill = "Tasa de Incidencia\npor cada 100,000 habitantes"
  ) +  
  theme_bw() +
  theme(
    legend.justification = c("right", "top"),
    legend.text = element_text(size = 7.5),
    legend.title = element_text(size = 7.5),
    title = element_text(size = 8, face = "bold"),
    plot.caption = element_text(hjust = 0, face = "plain"),
    legend.key.size = unit(0.8, "line")
    #panel.border = element_blank(),
    #panel.grid.major = element_blank(),
    #panel.grid.minor = element_blank(),
    #legend.key.size = unit(5,"cm"),
    #axis.ticks.y = element_blank(),
    #axis.title.y = element_blank(),
    #axis.text.y = element_blank(),
    #axis.ticks.x = element_blank(),
    #axis.title.x = element_blank(),
    #axis.text.x = element_blank()
  ) +
  labs(
    title = "COVID-19: Mapa de Tasa de Incidencia por 100,000 Habitantes en Coahuila (nivel Municipal)",
    subtitle = "Datos al 19 de Abril de 2020",
    caption = paste0("Nota: De un total de 38 municipios en Coahuila, ", my_n$my_n, " (", round(sum(my_n$my_n)/38, digits=2)  * 100, "%)  de ellos tienen al menos un caso confirmado de COVID-19\nElaborado por: Mayra A. Valdés @mayrop\nFuentes: Secretaría de Salud de México, CONAPO, INEGI")
  )

dev.off()


# https://www.r-spatial.org/r/2018/10/25/ggplot2-sf-3.html
ggplot() +
  scale_alpha(
    name = "",
    range = c(0.7, 0),
    guide = FALSE
  ) +
  # Adding counties
  geom_sf(
    data = cities_shp,
    color = "gray",
    fill = "white",
    size = 0.03
  ) +
  # Adding counties
  geom_sf(
    data = states_shp,
    color = "gray",
    fill = "transparent",
    size = 0.3
  ) +
  geom_sf(
    data = positive,
    aes(
      fill = positive$cuts_just
    ),
    size = 0.05
  ) +
  geom_text(
    data = positive_citi, 
    aes(
      Longitud, 
      Latitud, 
      label = Nombre
    ), 
    colour = "black",
    size = 2
  ) +
  scale_fill_manual(
    values = colors
  ) +  
  scale_color_manual(
    values = colors
  ) +
  labs(
    x = "",
    y = "",
    color = "Tasa de Incidencia\n (x100,000 hab)",
    fill = "Tasa de Incidencia\n (x100,000 hab)"
  ) +  
  theme_bw() +
  theme(
    legend.justification = c("right", "top"),
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    #legend.key.size = unit(5,"cm"),
    axis.ticks.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.x = element_blank(),
    axis.text.x = element_blank()
  ) +
  # changes the size of the points in legend
  guides(color = guide_legend(
    override.aes = list(size=5))
  )




max_size <- max(positive$n_just)
min_size <- min(positive$n_just)

b <- 10
a <- 0.5

alpha_b <- 0.9
alpha_a <- 0.3

my_map <- positive %>%
  dplyr::mutate(
    # Here we try to normalize the size by a skewed density of votes by party
    # The reason is to emphasize the difference in number of cases
    size_normalized = log((b-a) * ((n_just - min_size) / (max_size - min_size)) + a),
    alpha_size_normalized = (alpha_b-alpha_a) * ((n_just - min_size) / (max_size - min_size)) + alpha_a
  )
