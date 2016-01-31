library(reshape2)
library(ggplot2)

filename <- "getdata_dataset.zip"

## getting the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

##activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## calculating mean and standard deviation
newfeatures <- grep(".*mean.*|.*std.*", features[,2])
newfeatures.names <- features[newfeatures,2]
newfeatures.names = gsub('-mean', 'Mean', newfeatures.names)
newfeatures.names = gsub('-std', 'Std', newfeatures.names)
newfeatures.names <- gsub('[-()]', '', newfeatures.names)


# Loading data
## training set
train <- read.table("UCI HAR Dataset/train/X_train.txt")[newfeatures]
trainAct <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSub <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSub, trainAct, train)

## testing set
test <- read.table("UCI HAR Dataset/test/X_test.txt")[newfeatures]
testAct <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSub <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSub, testAct, test)

## creating new dataset
newData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", newfeatures.names)
newData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
newData$subject <- as.factor(newData$subject)
newData.melted <- melt(newData, id = c("subject", "activity"))
newData.mean <- dcast(newData.melted, subject + activity ~ variable, mean)
write.table(newData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)