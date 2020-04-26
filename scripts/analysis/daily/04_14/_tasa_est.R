
# todo to fix encoding on diarios_2020_04_13
positive_state <- merged %>%
  dplyr::group_by(ENTIDAD_RES, RESULTADO_FACTOR) %>%
  dplyr::summarise(
    n = dplyr::n()
  ) %>%
  dplyr::filter(
    RESULTADO_FACTOR == "Positivo SARS-CoV-2"
  )

# join needs to be this way! https://github.com/tidyverse/ggplot2/issues/3391#issuecomment-508527985
positive_state <- states_shp %>%
  dplyr::right_join(
    positive_state,
    by=c("CVE_ENT"="ENTIDAD_RES")
  )

positive_state <- positive_state %>%
  dplyr::left_join(
    states, by = c("CVE_ENT" = "Clave")
  )

positive_state <- positive_state %>%
  dplyr::mutate(
    n_just = n * 100000 / Poblacion_2019,
    cuts = cut(
      n, 
      breaks = c(1, 10, 25, 50, max(positive_state$n) + 1),
      labels = c("1-10", "11-25", "26-50", "51-max"),
      include.lowest = TRUE
    )
  ) 

positive_state <- positive_state %>%
  dplyr::mutate(
    cuts_just = cut(
      n_just, 
      breaks = c(0, 2, 5, 10, 15, 20, max(positive_state$n_just, na.rm = TRUE) + 1),
      labels = c("0-2", "2-5", "5-10", "10-15", "15-20", ">20"),
      include.lowest = TRUE)    
  ) %>%
  dplyr::filter(
    !is.na(n_just)
  )

# https://covid19.sinave.gob.mx/mapatasas.aspx
positive_state %>% 
  dplyr::group_by(cuts_just) %>%
  dplyr::arrange(desc(Poblacion_2019)) %>%
  dplyr::summarise(n=dplyr::n())


ggplot() +
  scale_alpha(
    name = "",
    range = c(0.7, 0),
    guide = FALSE
  ) +

  # Adding counties
  geom_sf(
    data = states_shp,
    color = "gray",
    fill = "transparent",
    size = 0.3
  ) +
  geom_sf(
    data = positive_state,
    aes(
      fill = cuts_just
    ),
    size = 0.05
  ) +
  geom_text(
    data = positive_state, 
      aes(
        LONGITUDE, 
        LATITUDE, 
        label = Nombre
      ), 
    colour = "black",
    size = 2
  ) +
  scale_fill_manual(
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
