# Install the required packages once, if they are not already installed:
# install.packages(c("tidyverse", "scales", "ggalluvial","sf"))

# Load the required packages:
library(tidyverse)
library(scales)
library(ggalluvial)

# Import data
austria2019 <- read_csv("austria_2019.csv")
austria2024 <- read_csv("austria_2024.csv")

# Inspect variables
colnames(austria2024)
colnames(austria2019)

# Prepare inputs
myN <- austria2019 %>% select(REG19)

myT <-
  austria2024 %>%
  mutate(
    EPP24 = EPP24 / REG24,
    SD24  = SD24 / REG24,
    PFE24 = PFE24 / REG24,
    EFA24 = EFA24 / REG24,
    REE24 = REE24 / REG24,
    OTH24 = OTH24 / REG24,
    ABS24 = ABS24 / REG24,
    INV24 = INV24 / REG24
  ) %>%
  select(EPP24, SD24, PFE24, EFA24, REE24, OTH24, ABS24, INV24)

myX <-
  austria2019 %>%
  mutate(
    EPP19 = EPP19 / REG19,
    SD19  = SD19 / REG19,
    ID19  = ID19 / REG19,
    EFA19 = EFA19 / REG19,
    REE19 = REE19 / REG19,
    OTH19 = OTH19 / REG19,
    ABS19 = ABS19 / REG19,
    INV19 = INV19 / REG19
  ) %>%
  select(EPP19, SD19, ID19, EFA19, REE19, OTH19, ABS19, INV19)
 
# Data checks
austria2019$CODE == austria2024$CODE

sum(austria2019$CODE == austria2024$CODE)

myX %>% 
  summarize_all(min) %>% View()

myX %>% 
  summarize_all(max) %>% View()

myT %>% 
  summarize_all(min) %>% View()

myT %>% 
  summarize_all(max) %>% View()

rowSums(myX)
rowSums(myT)

all(myX >= 0 & myX <= 1)
all(myT >= 0 & myT <= 1)

# Estimate voter transitions
source("VTR.R")

z <- multirate(myN, myX, myT, 0.01)
write_rds(z, "z.rds")
z <- read_rds("z.rds")

# Export aggregate transition matrix
z$Bb %>% 
  as.data.frame() %>%
  rownames_to_column() %>%
  write_csv2(file = "austria19-austria24.csv")

# Convert the aggregate transition matrix to long format
transitions_long <-
  z$Bb %>%
  as.data.frame() %>%
  rownames_to_column("group_2019") %>%
  pivot_longer(
    cols = -group_2019,
    names_to = "group_2024",
    values_to = "transition_rate"
  ) %>%
  arrange(desc(transition_rate))

transitions_long

# Keep estimated voter transitions of at least 5%
major_transitions <-
  transitions_long %>%
  filter(transition_rate >= 0.05)

major_transitions

# Voter retention
retention <-
  major_transitions %>%
  filter(
    (group_2019 == "ID19"  & group_2024 == "PFE24") |
      (group_2019 == "REE19" & group_2024 == "REE24") |
      (group_2019 == "SD19"  & group_2024 == "SD24") |
      (group_2019 == "EFA19" & group_2024 == "EFA24") |
      (group_2019 == "EPP19" & group_2024 == "EPP24")
  ) %>%
  mutate(
    european_political_groups = case_when(
      group_2019 == "ID19"  ~ "ID → PfE",
      group_2019 == "REE19" ~ "Renew",
      group_2019 == "SD19"  ~ "S&D",
      group_2019 == "EFA19" ~ "Greens/EFA",
      group_2019 == "EPP19" ~ "EPP"
    ),
    national_party = case_when(
      group_2019 == "ID19"  ~ "FPÖ",
      group_2019 == "REE19" ~ "NEOS",
      group_2019 == "SD19"  ~ "SPÖ",
      group_2019 == "EFA19" ~ "Greens",
      group_2019 == "EPP19" ~ "ÖVP"
    )
  )

retention

# Retention visualization
retention %>% 
  ggplot(aes(
    x = reorder(european_political_groups, -transition_rate),
    y = transition_rate,
    fill = european_political_groups
  )) +
  geom_col() +
  geom_text(
    aes(label = scales::percent(transition_rate, accuracy = 0.1)),
    vjust = -0.5
  ) +
  scale_fill_manual(
    values = c(
      "ID → PfE" = "navy",
      "Renew" = "orange",
      "S&D" = "red",
      "Greens/EFA" = "green",
      "EPP" = "blue"
    )
  ) +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(
    x = "European Political Groups",
    y = "Estimated Retention Rate",
    fill = "European Political Group"
  ) +
  theme_classic()

# Selected voter transitions
selected_transitions <-
  major_transitions %>%
  filter(
    (group_2019 == "EPP19" & group_2024 == "PFE24") |
      (group_2019 == "EPP19" & group_2024 == "SD24") |
      (group_2019 == "EPP19" & group_2024 == "ABS24") |
      (group_2019 == "SD19"  & group_2024 == "ABS24")
  ) %>%
  mutate(
    european_group_transition = case_when(
      group_2019 == "EPP19" & group_2024 == "PFE24" ~ "EPP → PfE",
      group_2019 == "EPP19" & group_2024 == "SD24"  ~ "EPP → S&D",
      group_2019 == "EPP19" & group_2024 == "ABS24" ~ "EPP → Abstention",
      group_2019 == "SD19"  & group_2024 == "ABS24" ~ "S&D → Abstention"
    ),
    national_party = case_when(
      group_2019 == "EPP19" & group_2024 == "PFE24" ~ "ÖVP → FPÖ",
      group_2019 == "EPP19" & group_2024 == "SD24"  ~ "ÖVP → SPÖ",
      group_2019 == "EPP19" & group_2024 == "ABS24" ~ "ÖVP → Abstention",
      group_2019 == "SD19"  & group_2024 == "ABS24" ~ "SPÖ → Abstention"
    )
  )

selected_transitions

# Voter transition visualization
selected_transitions %>%
  ggplot(aes(
    axis1 = group_2019,
    axis2 = group_2024,
    y = transition_rate
  )) +
  geom_alluvium(aes(fill = group_2024)) +
  geom_stratum() +
  geom_text(
    stat = "stratum",
    aes(label = after_stat(stratum))
  ) +
  scale_fill_manual(
    values = c(
      "PFE24" = "navy",
      "SD24" = "red",
      "ABS24" = "grey"
    )
  ) +
  labs(
    x = "Electoral Categories (2019 → 2024)",
    y = NULL,
    fill = "2024 Destination"
  ) +
  theme_classic() +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  )

# Regional Electoral Analysis
library(sf)

# Import geographical data
austria_map <- st_read(
  "austria_map.geojson",
  quiet = TRUE
)

# Keep Austrian NUTS-2 regions
austria_map <-
  austria_map %>%
  filter(CNTR_CODE == "AT")

# Inspect regional codes and names
austria_map %>%
  select(NUTS_ID, NAME_LATN) %>%
  st_drop_geometry()

# Calculate regional change in EPP/ÖVP support
epp_regional <-
  austria2019 %>%
  select(CODE, `NUTS 2`, EPP19, REG19, ABS19, INV19) %>%
  left_join(
    austria2024 %>%
      select(CODE, EPP24, REG24, ABS24, INV24),
    by = "CODE"
  ) %>%
  mutate(
    valid19 = REG19 - ABS19 - INV19,
    valid24 = REG24 - ABS24 - INV24,
    EPP19_share = EPP19 / valid19,
    EPP24_share = EPP24 / valid24,
    EPP_change = (EPP24_share - EPP19_share) * 100
  )

epp_regional

# Combine electoral and geographical data
epp_map <-
  austria_map %>%
  left_join(
    epp_regional %>%
      select(CODE, EPP_change),
    by = c("NUTS_ID" = "CODE")
  )

# Transform coordinate reference system
epp_map_projected <- st_transform(epp_map, 3035)

# Map regional change in EPP/ÖVP support
ggplot(epp_map_projected) +
  geom_sf(aes(fill = EPP_change)) +
  geom_sf_text(
    aes(label = NAME_LATN),
    size = 3
  ) +
  scale_fill_gradient(
    low = "paleturquoise",
    high = "darkturquoise",
    name = "Change (pp)"
  ) +
  labs(
    title = "Change in EPP/ÖVP Electoral Support by Austrian Federal State",
    subtitle = "2019–2024 European Parliament Elections",
    fill = "Change (pp)"
  ) +
  theme_void()

# ÖVP Regional Vote Share by Austrian Federal State
epp_table <-
  epp_regional %>%
  select(`NUTS 2`, EPP19_share, EPP24_share, EPP_change) %>%
  arrange(EPP_change)

epp_table

write_csv(epp_table, "ovp_regional_results.csv")

# FPÖ regional vote-share change
FPO_regional <-
  austria2019 %>%
  select(CODE, `NUTS 2`, ID19, REG19, ABS19, INV19) %>%
  left_join(
    austria2024 %>%
      select(CODE, PFE24, REG24, ABS24, INV24),
    by = "CODE"
  ) %>%
  mutate(
    valid19 = REG19 - ABS19 - INV19,
    valid24 = REG24 - ABS24 - INV24,
    ID19_share = ID19 / valid19,
    PFE24_share = PFE24 / valid24,
    FPO_change = (PFE24_share - ID19_share) * 100
  )

FPO_regional

# Join regional results with NUTS 2 boundaries
FPO_map <- austria_map %>%
  left_join(
    FPO_regional %>%
      select(CODE, FPO_change),
    by = c("NUTS_ID" = "CODE")
  )

# Transform coordinate reference system
FPO_map_projected <- st_transform(FPO_map, 3035)

# Map of FPÖ vote-share change
ggplot(FPO_map_projected) +
  geom_sf(
    aes(fill = FPO_change),
    color = "white",
    linewidth = 0.5
  ) +
  geom_sf_text(
    aes(label = NAME_LATN),
    size = 3
  ) +
  scale_fill_gradient(
    low = "lightblue",
    high = "darkblue",
    name = "Change (pp)"
  ) +
  labs(
    title = "Change in FPÖ Vote Share across Austrian Federal States, 2019–2024",
    subtitle = "European Parliament elections"
  ) +
  theme_void()

# FPÖ Regional Vote Share by Austrian Federal State
FPO_table <-
  FPO_regional %>%
  select(`NUTS 2`, ID19_share, PFE24_share, FPO_change) %>%
  arrange(desc(FPO_change))

FPO_table

write_csv(FPO_table, "fpo_regional_results.csv")
