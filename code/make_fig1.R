### Add the first graph to be used in presentation
### Do the probabilities of the community to be an adult (mother) increase over time?
### Marc Sze


# Load needed libraries
library(tidyverse)
library(viridis)

# Load needed data
graph_data <- read_csv("data/process/tables/probability_scores.csv")

# Create the graph of the data
probs_graph <- graph_data %>% 
  rename(age_group = TIME_OF_SAMPLING) %>% 
  mutate(age_group = factor(age_group, 
                            levels = c("6_month_old", "4_years_old", "3rd_tri", "1_month_post"), 
                            labels = c("Six-Month Infant", "Four Year Old Child", 
                                       "Mother\n(3rd Trimester)", "Mother\n(1-month Post Pregnancy)"))) %>% 
  ggplot(aes(x = age_group, y = yes_adult, color = age_group)) + 
  geom_jitter(width = 0.2, size = 3, alpha = 0.75, show.legend = F) +
  stat_summary(fun.y = median, fun.ymin = median, fun.ymax = median, 
               colour = "black", geom = "crossbar", size = 0.5, width = 0.5) + 
  scale_color_viridis(discrete = T) + theme_bw() + 
  labs(x = "", y = "Probability of Being an Adult") + 
  theme(axis.title.y = element_text(face = "bold"), 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.text = element_text(size = 10))
  
# Write out the figure
ggsave("results/figures/prbability_figure.tiff", probs_graph, width = 7, height = 5, dpi = 300)




