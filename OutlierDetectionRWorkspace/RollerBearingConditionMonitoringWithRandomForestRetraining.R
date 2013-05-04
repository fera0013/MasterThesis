library("randomForest", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
library("mda", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
#Define names
targetClassName<-"Target"
outlierClassName<-"Outlier"
className<-"Class"
euclideanDistanceName<-"EuclideanDistance"
thresholdName<-"Threshold"
predictedName<-"Predicted"
#Create data sets
sizeOfTestSet<-25
normalTestSetIndices<-sample(row(normalFeatures),sizeOfTestSet*3)
normalTestSet<-normalFeatures[normalTestSetIndices,]
trainingSet<-normalFeatures[-normalTestSetIndices,]
ballFaultTestSetIndices<-sample(1:length(BallFaultFeatures[,1]),sizeOfTestSet)
ballFaultTestSet<-BallFaultFeatures[ballFaultTestSetIndices,]
outerRacewayFaultTestSetIndices<-sample(1:length(OuterRacewayFeatures[,1]),sizeOfTestSet)
outerRacewayFaultTestSet<-OuterRacewayFeatures[outerRacewayFaultTestSetIndices,]
innerRacewayFaultTestSetIndices<-sample(1:length(InnerRacewayFeatures[,1]),sizeOfTestSet)
innerRacewayFaultTestSet<-InnerRacewayFeatures[innerRacewayFaultTestSetIndices,]
completeTestSet<-rbind(normalTestSet,ballFaultTestSet,outerRacewayFaultTestSet,innerRacewayFaultTestSet)
rollerBearingRandomForestClassification<- OneClassRandomForest(trainingSet[,-28],trainingSet[,28],completeTestSet[,-28],completeTestSet[,28])
rollerBearingRandomForestClassification$Confusion
rollerBearingRandomForestClassification$Type1Error
rollerBearingRandomForestClassification$Type2Error
#Retrain RF 
numberOfAttributes<-15
rollerBearingNormalDataAttributeImportance<-importance(randomForestClassification$RandomForest,type=1)
varImpPlot(randomForestClassification$RandomForest)
rollerBearingFeatureNames<-colnames(completeTestSet)[1:27]
rollerBearingAttributeImportanceTable<-data.frame(Feature=rollerBearingFeatureNames,AccuracyDecrease=rollerBearingNormalDataAttributeImportance)
rollerBearingAttributeImportanceTable<-rollerBearingAttributeImportanceTable[order(rollerBearingAttributeImportanceTable$MeanDecreaseAccuracy),]
reducedTrainingSet<-trainingSet[,as.character(rollerBearingAttributeImportanceTable$Feature[1:numberOfAttributes])]
reducedTestSet<-completeTestSet[,as.character(rollerBearingAttributeImportanceTable$Feature[1:numberOfAttributes])]
rollerBearingRandomForestClassificationWithReducedAttributes<-OneClassRandomForest(reducedTrainingSet,trainingSet[,28],reducedTestSet,completeTestSet[,28])
rollerBearingRandomForestClassificationWithReducedAttributes$Confusion
rollerBearingRandomForestClassificationWithReducedAttributes$Type1Error
rollerBearingRandomForestClassificationWithReducedAttributes$Type2Error
