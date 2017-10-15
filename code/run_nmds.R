### This code will create the NMDS values needed to create a general NMDS plot
### Main question being answered is whether general NMDS visualization can help resolve differences
### Marc Sze

# Load needed libraries
library(tidyverse)
library(vegan)


# Load needed data
meta_data <- read_csv("data/process/Koren2012_Metadata.csv")
abund_data <- as.data.frame(t(read.csv("data/process/Koren2012_Abundance.csv", row.names = 1))) %>% 
  mutate(DATA_ID = rownames(.)) %>% 
  select(DATA_ID, everything())

# Assign row names for later ID of samples
rownames(abund_data) <- abund_data$DATA_ID
# Remove the column with the ID 
abund_data <- abund_data[, -1]
# Run the NMDS values generation for a bray-curtis distance matrix
test <- vegdist(abund_data, method = "bray", diag = T)
test2 <- metaMDS(test, trymax = 3000, trace = 0)
# Generate the needed values
nmds_data <- scores(test2) %>% as.data.frame() %>% 
  mutate(DATA_ID = rownames(.))
# WRite out to file
write_csv(nmds_data, "data/process/tables/nmds_data.csv")
