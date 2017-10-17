### Test whether the median probabilities are different between the groups
### Do the probabilities of the community to be an adult (mother) increase over time?
### Marc Sze


# Load needed libraries
library(tidyverse)

# Load needed data
test_data <- read_csv("data/process/tables/probability_scores.csv")



###############################################################################################################
################################## List to store used functions ###############################################
###############################################################################################################

# Function to run the wilcox test and return the p-value
run_test <- function(first_group, second_group, dataTable = test_data){
  # first_group stands for the first comparison group
  # second_group stands for the second comparison group
  # dataTable is defaulted to test_data to allow for easier use with mapply
  
  # Generate the first comparison group
  firstData <- dataTable %>% filter(TIME_OF_SAMPLING == first_group)
  # Generate the second comparison group
  secondData <- dataTable %>% filter(TIME_OF_SAMPLING == second_group)
  # Generate the pvalue from comparing the two groups
  tempResult <- wilcox.test(firstData$yes_adult, secondData$yes_adult)$p.value
  # write out the pvalue to the global work environment
  return(tempResult)
}



################################################################################################################
###################################### Execute the given functions #############################################
################################################################################################################

#First group to cycle through
first_var <- c("3rd_tri", "3rd_tri", "3rd_tri", "1_month_post", "1_month_post", "6_month_old")
# Second group to cycle through
second_var <- c("1_month_post", "6_month_old", "4_years_old", "6_month_old", "4_years_old", "4_years_old")
# generate the final data table
final_table <- data_frame(
  g1 = first_var, g2 = second_var, pvalue = mapply(run_test, first_var, second_var)) %>% 
  mutate(bh = p.adjust(pvalue, method = "BH"))


# Write out the results
write_csv(final_table, "results/tables/wilcox_comparisons.csv")




