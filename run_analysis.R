##
#
# The data used in this project is 
# data collected from the accelerometers from the Samsung Galaxy S smartphone
# A full description is available at
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
#
##

library(utils)
#library(plyr) # Setp5 use ddply

# download and unzipi files if nececssary
if(!file.exists("./data")) {
        dir.create("./data")
}
if(!file.exists("./data/dataset.zip")) {
        download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                      dest="./data/dataset.zip", method="curl")
        unzip(zipfile="./data/dataset.zip",exdir="./data/")
}
        
# Clean up workspace
rm(list=ls())

# set working directory under extracted data folder
curwd <- getwd()
setwd(paste(curwd, "data", "UCI\ HAR\ Dataset", sep="//"))
        
# read data
activityLabel   <- read.table("activity_labels.txt", sep = " ")
colnames(activityLabel) <- c("activityId", "activityType")
features        <- read.csv("features.txt", header=FALSE, sep = " ")

###############################################################
# Step 1
# Merges the training and the test sets to create one data set
###############################################################

trainSet   <- read.table("train//X_train.txt", header=FALSE)
trainLabel <- read.table("train//y_train.txt", header=FALSE)
trainSub   <- read.table("train//subject_train.txt", header=FALSE)

testSet   <- read.table("test//X_test.txt", header=FALSE)
testLabel <- read.table("test//y_test.txt", header=FALSE)
testSub   <- read.table("test//subject_test.txt", header=FALSE)

# Assign col names to columns
colnames(trainSet)   <- features[,2]
colnames(testSet)    <- features[,2]
colnames(trainLabel) <- "activityId"
colnames(testLabel)  <- "activityId"
colnames(trainSub)   <- "subjectId"
colnames(testSub)    <- "subjectId"

# Merge training data
trainingData <- cbind(trainSet, trainLabel, trainSub)

# Merge test data
testData <- cbind(testSet, testLabel, testSub)

# Merge training and test data
data <- rbind(trainingData, testData)

# Clean up workspace
rm(trainSet,trainLabel,trainSub,trainingData)
rm(testSet, testLabel, testSub, testData)

###############################################################
# Step 2
# Extracts only the measurements on the mean and standard deviation for each measurement
###############################################################

mean_and_std_features <- grep(".*(mean|std).*", features[,2])

# subset the mean and std measurement with ActivityId and SubjectId
data <- data[, c(mean_and_std_features, ncol(data)-1, ncol(data))]

###############################################################
# Step 3
# Uses descriptive activity names to name the activities in the data set
###############################################################

# get coresponding names
activityName <- activityLabel[data$activityId, 2]

# Substitue old id data with names
data$activityId <- activityName

# Change colname from activityId to activityName
names(data)[ncol(data)-1] <- "activityName"

###############################################################
# Step 4
# Appropriately labels the data set with descriptive variable names
###############################################################

# done in Step 1: assgining names to columns

###############################################################
# Step 5
# Create a second, independent tidy data set with the average of 
# each variable for each activity and each subject
###############################################################

dataTidy <- aggregate(data[1:(ncol(data)-2)],by=list(activity=data$activityName,subject=data$subjectId),mean)

# at the end set back to original working directory
setwd(curwd)

# writing tidy data to a .txt file
write.table(dataTidy, file='./tidy_data.txt', row.names=FALSE, sep=",")
