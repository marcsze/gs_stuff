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

# Select only the lowest ID to use for each OTU
genus_otus <- as.data.frame(filter(tax_data, percent_match >= 0.6, taxa == "genus"))[, "otu"]
family_otus <- as.data.frame(filter(tax_data, percent_match >= 0.6, taxa == "family", 
                                    !(otu %in% genus_otus)))[, "otu"]
order_otus <- as.data.frame(filter(tax_data, percent_match >= 0.6, taxa == "order", 
                                   !(otu %in% genus_otus), 
                                   !(otu %in% family_otus)))[, "otu"]
phylum_otus <- as.data.frame(filter(tax_data, percent_match >= 0.6, taxa == "phylum", 
                                   !(otu %in% genus_otus), 
                                   !(otu %in% family_otus), 
                                   !(otu %in% order_otus)))[, "otu"]
domain_otus <- as.data.frame(filter(tax_data, percent_match >= 0.6, taxa == "domain", 
                                    !(otu %in% genus_otus), 
                                    !(otu %in% family_otus), 
                                    !(otu %in% order_otus), 
                                    !(otu %in% phylum_otus)))[, "otu"]

# Create label call within graph data table

graph_data <- graph_data %>% 
  inner_join(tax_data, by = "otu") %>% 
  mutate(label_call = ifelse(otu %in% genus_otus, invisible(genus), 
                             ifelse(otu %in% family_otus, invisible(family), 
                                    ifelse(otu %in% order_otus, invisible(order), 
                                           ifelse(otu %in% phylum_otus, invisible(phylum), 
                                                  invisible(domain)))))) %>% 
  distinct(otu, .keep_all = TRUE) %>% 
  select(otu, mda, label_call)


# Generate the labels needed for the MDA graph
otu_num <- as.numeric(gsub("otu", "", graph_data$otu))
low_tax_ID <- gsub("_", " ", graph_data$label_call)

graph_labels <- paste(gsub("_", " ", graph_data$label_call), " (OTU", otu_num, ")", sep = "")

test <- c()
for(i in 1:length(low_tax_ID)){
  
  test <- c(test, bquote(paste(italic(.(low_tax_ID[i])) ~ "(OTU", .(otu_num[i]), ")", sep = "")))
  
}

used_graph_labels <- do.call(expression, test)



# Create the graph of the data
imp_otu_graph <- graph_data %>% 
  mutate(otu = factor(otu, 
                      levels = graph_data$otu, 
                      labels = graph_labels)) %>% 
  ggplot(aes(x = otu, y = mda)) + 
  geom_point(show.legend = F, size = 4) + 
  scale_x_discrete(labels = used_graph_labels) + 
  coord_flip() + 
  theme_bw() + 
  labs(y = "Mean Decrease in Accuracy", x = "") + 
  theme(axis.title.y = element_text(face = "bold"), 
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(), 
        axis.text = element_text(size = 13))

# Write out the figure
ggsave("results/figures/imp_otu_figure.tiff", imp_otu_graph, width = 6, height = 5, dpi = 300)


