

removed_ids <- only_on_april_05$patient_id

rows[rows$file_date_std < "2020-04-06" & rows$patient_id %in% removed_ids,]$age_fixed = rows[rows$file_date_std < "2020-04-06" & rows$patient_id %in% removed_ids,]$age + 1

april_05 <- rows[rows$file_id=="positivos_2020_04_05",]
april_06 <- rows[rows$file_id=="positivos_2020_04_06",]

april_05[april_05$state=="TLA",c("age", "date_symptoms", "origin", "date_arrival")] %>% dplyr::arrange(date_symptoms, age)
april_06[april_06$state=="TLA",c("age", "date_symptoms", "origin", "date_arrival")] %>% dplyr::arrange(date_symptoms, age)

ggplot(only_on_april_05, aes(x=age)) +
  geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                 binwidth=5,
                 colour="black", fill="white") +
  geom_density(alpha=.2, fill="#FF6666") +
  ggtitle(id)
