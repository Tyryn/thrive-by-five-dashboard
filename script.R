# Create data visualisations to go into dashboard
library(tidyverse)
library(sf)
library(haven)


data_raw <- read_dta("ThrivebyFive/tb5i-ecda-2021-v4.dta")


# Get variables of interest
data <- data_raw %>% 
  select(total_elom_cuts, domain_1_cuts, domain_2_cuts, domain_3_cuts, domain_4_cuts, domain_5_cuts,
         prov_geo, quintile, mn_geo, id_mn_geo,  toilet_clean, electricity_working, 
         books, meals, class_size, id_ward_geo, ward_geo, space) 

# Assign metro vs local municipality 
data <- data %>% 
mutate(mn_type = case_when(
  mn_geo %in% c("Buffalo City", "City of Cape Town", "City of Johannesburg", "City of Tshwane", "Ekurhuleni", "eThekwini", "Mangaung", "Nelson Mandela Bay") ~ "Metropolitan Municipality",
  TRUE ~ "Local Municipality"
))



# Save file
saveRDS(data, file = "tb5-dashboard/data.RDS")

