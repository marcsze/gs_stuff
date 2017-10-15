### Add the third graph to be used in presentation (but first in order)
### Using NMDS to visualize beta-diversity differences
### Marc Sze


# Load needed libraries
library(tidyverse)
library(viridis)

# Load needed data
nmds_data <- read_csv("data/process/tables/nmds_data.csv")
meta_data <- read_csv("data/process/Koren2012_Metadata.csv")


# Munge the data into the variables of interest
graph_data <- meta_data %>% 
  inner_join(nmds_data, by = "DATA_ID") %>% 
  rename(age_group = TIME_OF_SAMPLING, nmds1 = NMDS1, nmds2 = NMDS2) %>% 
  select(age_group, nmds1, nmds2)

# Create NMDS graph
nmds_graph <- graph_data %>% 
  mutate(age_group = factor(age_group, 
                            levels = c("1_month_old", "6_month_old", "4_years_old", "1st_tri", 
                                       "3rd_tri", "1_month_post"), 
                            labels = c("One-Month Infant", "Six-Month Infant", "Four Year Old Child", 
                                       "Mother (1st Trimester)", "Mother (3rd Trimester)", 
                                       "Mother\n(1-month Post Pregnancy)"))) %>% 
  ggplot(aes(x=nmds1, y=nmds2, color=age_group)) + 
  geom_point(size = 4, alpha = 0.75) + theme_bw() + coord_equal() + 
  ylim(-0.6, 0.6) + xlim(-0.6, 0.6) + 
  scale_color_manual(name = "", values = c('#414487FF', '#440154FF', '#31688EFF', '#7AD151FF', 
                                '#35B779FF', '#FDE725FF')) + 
  labs(x = "NMDS1", y = "NMDS2") + 
  theme(axis.title = element_text(face = "bold"), 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.text = element_text(size = 10))

# Write out the figure
ggsave("results/figures/nmds_figure.tiff", nmds_graph, width = 6, height = 6, dpi = 300)















