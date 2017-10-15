### Create a useable table to parse the fasta file
### Get the OTUs of interest only
### Marc Sze

# Load needed libraries
library(tidyverse)


# Load needed data
imp_otu_data <- as.data.frame(read_csv("data/process/tables/imp_otus_to_model.csv") %>% slice(1:30) %>% 
  select(otu))



# Write out only the top 30 OTUs

write(imp_otu_data[, "otu"], "data/process/select_otus", ncolumns = length(imp_otu_data[, "otu"]), sep = " ")
write.table(imp_otu_data, "data/process/select_otus", quote = F, col.names = F, row.names = F)

