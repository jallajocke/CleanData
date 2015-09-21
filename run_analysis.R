
# Import data
testFile <- ".\\UCI HAR Dataset\\test\\X_test.txt"
testLFile <- ".\\UCI HAR Dataset\\test\\y_test.txt"
testSFile <- ".\\UCI HAR Dataset\\test\\subject_test.txt"

trainFile <- ".\\UCI HAR Dataset\\train\\X_train.txt"
trainLFile <- ".\\UCI HAR Dataset\\train\\y_train.txt"
trainSFile <- ".\\UCI HAR Dataset\\train\\subject_train.txt"

featuresFile <- ".\\UCI HAR Dataset\\features.txt"
activityFile <- ".\\UCI HAR Dataset\\activity_labels.txt"


{stopifnot(file.exists(testFile) & 
           file.exists(testLFile) &
           file.exists(testSFile) &
           file.exists(trainFile) & 
           file.exists(trainLFile) & 
           file.exists(trainSFile) & 
           file.exists(featuresFile) &
           file.exists(activityFile) )}

testData <- read.table(testFile)
testLData <- read.table(testLFile)
testSData <- read.table(testSFile)

trainData <- read.table(trainFile)
trainLData <- read.table(trainLFile)
trainSData <- read.table(trainSFile)

featuresData <- read.table(featuresFile)
activityData <- read.table(activityFile)

# Merge training and test sets
mergedData <- rbind(testData, trainData)
mergedLData <- rbind(testLData, trainLData)
mergedSData <- rbind(testSData, trainSData)

# Add appropriate column names
colnames(mergedData) <- featuresData$V2

# Extract only measurements on the mean and standard deviation
isMeanOrStd <- function(x) {
  xStr <- as.character(x)
  variable1 <- substr(xStr, nchar(xStr)-7, nchar(xStr)-4)
  variable2 <- substr(xStr, nchar(xStr)-4, nchar(xStr)-1)
  variable1 == "mean" | variable1 == "-std" | variable2 == "Mean"
}
columnsMeanAndStd <- featuresData[isMeanOrStd(featuresData$V2),]
featuresMeanAndStd <- mergedData[,columnsMeanAndStd$V1]

# Add activity and subject data
featuresMeanAndStd$activityInt <- mergedLData$V1
featuresMeanAndStd$subjectInt <- mergedSData$V1

# Add descriptive activity names
replaceName <- function(valueIndex, nameTable, nameColumn){
  nameTable[valueIndex, nameColumn]
}
featuresMeanAndStd$activityInt <- replaceName(featuresMeanAndStd$activityInt, activityData, 2)

# Aggregate the average of each variable for each activity and each subject
byList = list(activity = featuresMeanAndStd$activityInt, subject = featuresMeanAndStd$subject)
tidyData <- aggregate(featuresMeanAndStd, by=byList, mean)

# Export data set
tidyDataFile <- "tidy_data.txt"
write.table(tidyData, tidyDataFile, row.name=FALSE)
