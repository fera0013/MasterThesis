library("randomForest", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
library("mda", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
#Define names
targetClassName<-"Target"
outlierClassName<-"Outlier"
className<-"Class"
euclideanDistanceName<-"EuclideanDistance"
thresholdName<-"Threshold"
predictedName<-"Predicted"
#Create randomly sampled test set with roller bearing normal features
#Create randomly sampled validation set with roller bearing normal features
#Create training data set with roller bearing normal features
sizeOfTestSet<-75
normalTestSetIndices<-sample(row(normalFeatures),sizeOfTestSet)
normalTestSet<-normalFeatures[normalTestSetIndices,]
trainingSet<-normalFeatures[-normalTestSetIndices,]
ballFaultTestSetIndices<-sample(1:length(BallFaultFeatures[,1]),sizeOfTestSet)
ballFaultTestSet<-BallFaultFeatures[ballFaultTestSetIndices,]
outerRacewayFaultTestSetIndices<-sample(1:length(OuterRacewayFeatures[,1]),sizeOfTestSet)
outerRacewayFaultTestSet<-OuterRacewayFeatures[outerRacewayFaultTestSetIndices,]
innerRacewayFaultTestSetIndices<-sample(1:length(InnerRacewayFeatures[,1]),sizeOfTestSet)
innerRacewayFaultTestSet<-InnerRacewayFeatures[innerRacewayFaultTestSetIndices,]
completeTestSet<-rbind(normalTestSet,ballFaultTestSet,outerRacewayFaultTestSet,innerRacewayFaultTestSet)
randomForestClassification<- OneClassRandomForest(trainingSet[,-28],trainingSet[,28],completeTestSet[,-28],completeTestSet[,28])
#Retrain RF 
rollerBearingNormalDataAttributeImportance<-importance(randomForestClassification$RandomForest,type=1)
varImpPlot(randomForestClassification$RandomForest)
rollerBearingFeatureNames<-colnames(completeTestSet)[1:27]
rollerBearingAttributeImportanceTable<-data.frame(Feature=rollerBearingFeatureNames,AccuracyDecrease=rollerBearingNormalDataAttributeImportance)
rollerBearingAttributeImportanceTable<-rollerBearingAttributeImportanceTable[order(rollerBearingAttributeImportanceTable$MeanDecreaseAccuracy),]
reducedTrainingSet<-trainingSet[,as.character(rollerBearingAttributeImportanceTable$Feature[1:15])]
reducedTestSet<-completeTestSet[,as.character(rollerBearingAttributeImportanceTable$Feature[1:15])]
rollerBearingRandomForestClassificationWithReducedAttributes<-OneClassRandomForest(reducedTrainingSet,trainingSet[,28],reducedTestSet,completeTestSet[,28])