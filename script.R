# Create data visualisations to go into dashboard
library(tidyverse)
library(sf)

data_raw <- read_dta("ThrivebyFive/tb5i-ecda-2021-v4.dta")


# Get variables of interest
data <- data_raw %>% 
  select(total_elom_cuts, domain_1_cuts, domain_2_cuts, domain_3_cuts, domain_4_cuts, domain_5_cuts,
         prov_geo, quintile, mn_geo, id_mn_geo,  toilet_clean, electricity_working, starts_with("materials_"), 
         books, meals, class_size, id_ward_geo, ward_geo) 

# Assign metro vs local municipality 
data <- data %>% 
mutate(mn_type = case_when(
  mn_geo %in% c("Buffalo City", "City of Cape Town", "City of Johannesburg", "City of Tshwane", "Ekurhuleni", "eThekwini", "Mangaung", "Nelson Mandela Bay") ~ "Metropolitan Municipality",
  TRUE ~ "Local Municipality"
))



# Save file
saveRDS(data, file = "tb5-dashboard/data.RDS")


## Set some disaggregations (that would be set by dashboard user)
province <- c("Western Cape", "Eastern Cape")
municipality <- c("Local Municipality")
quintile <- c(1, 2,4,5)
toilet_clean <- c(NA, 1, 0)


# Graph
data_graph <- data %>% 
  filter(prov_geo %in% province) %>%
  filter(quintile %in% quintile) %>% 
  filter(mn_type %in% municipality) %>% 
  # Get proportion Achieving Standard by province
  #group_by(prov_geo) %>% 
  summarize(count=n(), 
            total_elom_prop = mean(total_elom_cuts==3))
