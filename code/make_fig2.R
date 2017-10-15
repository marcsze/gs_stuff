### Add the second graph to be used in presentation
### What are the most important OTUs to this model (Look at Top 30)?
### Marc Sze


# Load needed libraries
library(tidyverse)
library(viridis)

# Load needed data
graph_data <- read_csv("data/process/tables/imp_otus_to_model.csv") %>% 
  slice(1:30) %>% arrange(mda)

tax_data <- read_tsv("data/process/select_fasta_classified.txt", col_names = F) %>% 
  rename(domain = X8, phylum = X11, class = X14, order = X17, family = X20, 
         genus = X23, otu = X1) %>% 
  select(-X2, -X3, -X4, -X5, -X7, -X10, -X13, -X16, -X19, -X22) %>%  
  gather(key = taxa, value = percent_match, domain, phylum, 
                            class, order, family, genus) %>% 
  rename(domain = X6, phylum = X9, class = X12, order = X15, family = X18, genus = X21)

# Select only the lowest ID to use



# Create the graph of the data
imp_otu_graph <- graph_data %>% 
  mutate(otu = factor(otu, levels = graph_data$otu)) %>% 
  ggplot(aes(x = otu, y = mda)) + 
  geom_point(show.legend = F, size = 4) + 
  coord_flip() + 
  theme_bw() + 
  labs(y = "Mean Decrease in Accuracy", x = "") + 
  theme(axis.title.y = element_text(face = "bold"), 
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(), 
        axis.text = element_text(size = 13))

# Write out the figure
ggsave("results/figures/imp_otu_figure.tiff", imp_otu_graph, width = 6, height = 5, dpi = 300)


