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

# Function to seperate the different data groups so that I can recombine them as needed
seperate_data_by_groups <- function(data_table, groups){
  # data_table is the data of interest
  # groups is the different groups by which one wants to separate the data by
  
  # generate the separation 
  tempData <- sapply(groups, 
                     function(x) data_table %>% 
                       filter(TIME_OF_SAMPLING == x) %>% 
                       select(TIME_OF_SAMPLING, contains("otu")), simplify = F)
  # Write the tabel to the global work environment
  return(tempData)
  
}


# Function to create different combinations of test and train sets as needed
make_combination <- function(dataList, test_names, train_names){
  # dataList is the list generated from the seperate_data_by_groups function
  # test_names is the names of the groups in the test set
  # train_names if the names of the groups in the train set
  
  # Convert the dataList to a data frame
  tempData <- dataList %>% bind_rows()
  # keep only samples in the test_names vector
  tempTest <- tempData %>% filter(TIME_OF_SAMPLING %in% test_names)
  # keep only samples in the train_names vector
  tempTrain <- tempData %>% filter(TIME_OF_SAMPLING %in% train_names)
  # Create output data list
  finalData <- list(
    train_data = tempTrain, 
    test_data = tempTest)
  # write out list to the global work environment
  return(finalData)
}

# Function to remove near zero variance OTUs
run_nzv <- function(dataList, train_name, test_name){
  # the dataList generated from the make_combination function
  # train_name is the name of the train data
  # test_name is the name of the test data
  
  # Pull the training data
  tempTrain <- dataList[[train_name]]
  groupTrainIDs <- tempTrain$TIME_OF_SAMPLING # get the train set group IDs
  # Pull the test data
  tempTest <- dataList[[test_name]]
  groupTestIDs <- tempTest$TIME_OF_SAMPLING # get the test set group IDs
  # Obtain the near zero variance within the train set
  nzv <- nearZeroVar(tempTrain)
  # Check to see if the length of the nzv variable is 0
  if(length(nzv) == 0){
    # keeps everything as is
    tempTrain <- tempTrain
    tempTest <- tempTest
    
  } else{
    # Removes all near zero variance values from train and test sets
    tempTrain <- tempTrain[, -nzv]
    tempTest <- tempTest[, -nzv]
    # Check if group labels were removed
    if("TIME_OF_SAMPLING" %in% colnames(tempTrain)){
      
      print("groups were not removed...no correction required")
      
    } else{
      # add the grou labels back to the data set
      tempTrain <- cbind(groupTrainIDs, tempTrain)
      tempTest <- cbind(groupTestIDs, tempTest)
      
      print("groups were removed...correcting this problem")
    }
  }
  # Create the final data list
  finalData <- list(train_data = tempTrain, 
                    test_data = tempTest)
  # Output to the global envirnoment
  return(finalData)
}


# Function that builds the model
make_rf_model <- function(dataList, train_data_name){
  # dataList is the data list generated from run_nzv
  # train_data_name is the name of the training set in the list
  
  # grab the test data and convert the label to mother and child
  tempdata <- dataList[[train_data_name]] %>% 
    mutate(TIME_OF_SAMPLING = factor(TIME_OF_SAMPLING, 
                                     levels = c("1st_tri", "1_month_old"), 
                                     labels = c("mother", "child")))
  
  
  #Create Overall specifications for model tuning
  # number controls fold of cross validation
  # Repeats control the number of times to run it
  fitControl <- trainControl(## 10-fold CV
    method = "cv",
    number = 10,
    p = 0.8,
    classProbs = TRUE, 
    summaryFunction = twoClassSummary, 
    savePredictions = "final")
  
  # Set the mtry to be based on the number of total variables in data table to be modeled
  # this formula seems to be an accepted default to use
  number_try <- round(sqrt(ncol(tempdata)))
  
  # Set the mtry hyperparameter for the training model
  tunegrid <- expand.grid(.mtry = number_try)
  
  # set seed to make the data the same each run
  set.seed(1234567)
  
  # Train the model
  training_model <- 
    train(TIME_OF_SAMPLING ~ ., data = tempdata, 
          method = "rf", 
          ntree = 500, 
          trControl = fitControl,
          tuneGrid = tunegrid, 
          metric = "ROC", 
          importance = TRUE, 
          na.action = na.omit, 
          verbose = FALSE)
  
  # Return the model object
  return(training_model)
  
}



# Function to create a temp test table with calls used for the train model
make_temp_test_data <- function(dataList, test_data_name, pattern_key){
  # dataList is from from data list generated from run_nzv
  # test_data_name is the name of the test data set
  # pattern_key is what is assigned child and adult 
  
  # Generate the temp test data set
  tempData <- dataList[[test_data_name]] %>% 
    mutate(TIME_OF_SAMPLING = stringr::str_replace_all(TIME_OF_SAMPLING, pattern_key), 
           TIME_OF_SAMPLING = factor(TIME_OF_SAMPLING))
  # write it back out to the global work environment
  return(tempData)
  
}




################################################################################################################
###################################### Execute the given functions #############################################
################################################################################################################

# runs the seperation function and allows for each group to be seperate
seperate_data <- seperate_data_by_groups(all_data, c("1st_tri", "3rd_tri", "1_month_post", 
                                                     "1_month_old", "6_month_old", "4_years_old"))

# Creates the needed test and train sets for the RF
rf_data <- make_combination(seperate_data, c("3rd_tri", "1_month_post", "6_month_old", "4_years_old"), 
                            c("1st_tri", "1_month_old"))

# Removes the nzv variables from both test and train data sets
rf_nzv_completed <- run_nzv(rf_data, "train_data", "test_data")

# Create the RF model
training_model <- make_rf_model(rf_nzv_completed, "train_data")

# Create the temp test data
temp_test_data <- make_temp_test_data(rf_nzv_completed, "test_data", 
                                      c("3rd_tri" = "adult", "1_month_post" = "adult", 
                                        "6_month_old" = "child", "4_years_old" = "child"))

# Run the prediction
predictions_from_model <- predict(training_model, temp_test_data, type = "prob") %>% 
  mutate(TIME_OF_SAMPLING = rf_nzv_completed[["test_data"]]$TIME_OF_SAMPLING) %>% 
  rename(yes_adult = mother, no_adult = child)


# Generate the most important variables to the model
imp_otus <- varImp(training_model, scale = FALSE)[["importance"]] %>% 
  mutate(otu = rownames(.), mda = mother) %>% arrange(desc(mda)) %>% 
  select(otu, mda)
  

# Write out the tables to be graphed
write_csv(predictions_from_model, "data/process/tables/probability_scores.csv")
write_csv(imp_otus, "data/process/tables/imp_otus_to_model.csv")





