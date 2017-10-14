### This code will create a RF model and then test it against samples of interest
### Main question being answered is whether children look more like T1 when older
### Marc Sze


# Load needed libraries
library(tidyverse)
library(caret)
library(randomForest)

# Load needed data
meta_data <- read_csv("data/process/Koren2012_Metadata.csv")
abund_data <- as.data.frame(t(read.csv("data/process/Koren2012_Abundance.csv", row.names = 1))) %>% 
  mutate(DATA_ID = rownames(.)) %>% 
  select(DATA_ID, everything())

# Merge data into a single data frame
all_data <- meta_data %>% inner_join(abund_data, by = "DATA_ID")


###############################################################################################################
################################## List to store used functions ###############################################
###############################################################################################################

seperate_data_by_groups <- function(data_table, groups){
  
  tempData <- sapply(groups, 
                     function(x) data_table %>% 
                       filter(TIME_OF_SAMPLING == x) %>% 
                       select(TIME_OF_SAMPLING, contains("otu")), simplify = F)
  
  return(tempData)
  
}






################################################################################################################
###################################### Execute the given functions #############################################
################################################################################################################

seperate_data <- seperate_data_by_groups(all_data, c("1st_tri", "3rd_tri", "1_month_post", 
                                                     "1_month_old", "6_month_old", "4_years_old"))






