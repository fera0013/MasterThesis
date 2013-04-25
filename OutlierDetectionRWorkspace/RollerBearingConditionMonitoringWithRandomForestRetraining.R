ibrary("randomForest", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
library("mda", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
#Define names
targetClassName<-"Target"
outlierClassName<-"Outlier"
className<-"Class"
euclideanDistanceName<-"EuclideanDistance"
thresholdName<-"Threshold"
predictedName<-"Predicted"
#Create randomly sampled test set with roller bearing normal features
sizeOfTestSet<-25
normalTestSetIndices<-sample(row(normalFeatures),sizeOfTestSet)
normalTestSet<-normalFeatures[normalTestSetIndices,]
#Create randomly sampled validation set with roller bearing normal features
sizeOfTrainingSet2<-100
trainingSet2Indices<-sample(row(normalFeatures[-normalTestSetIndices]),sizeOfTrainingSet2)
trainingSet2<-normalFeatures[trainingSet2Indices,]
#Training 
#Create training data set with roller bearing normal features
trainingSet1<-normalFeatures[-c(normalTestSetIndices,trainingSet2Indices),]
#Construct unsupervised random forest with roller bearings training data set
rollerBearingNormalRf<-randomForest(trainingSet1[,-28],proximity=TRUE,importance=TRUE)
#Calculate class prototype of roller bearing normal data
rollerBearingNormalClassPrototype <- classCenter(trainingSet1[,-28], trainingSet1[,28], rollerBearingNormalRf$prox)
#Calculate Euclidean Distances between test vectors and normal features prototype
EuclideanDistanceToNormalPrototype<-function (vector) {
  return(sqrt(sum((vector- rollerBearingNormalClassPrototype) ^ 2)))
}
euclideanDistancesOfTargetVectors<-apply(trainingSet2[,-28],1,EuclideanDistanceToNormalPrototype)
trainingSet2[euclideanDistanceName]<-euclideanDistancesOfTargetVectors
threshold<-max(trainingSet2[,euclideanDistanceName])
#Classification
#Create Test Set with [numberOfTestVectors] test vectors of each outlier feature set
ballFaultTestSetIndices<-sample(1:length(BallFaultFeatures[,1]),sizeOfTestSet)
ballFaultTestSet<-BallFaultFeatures[ballFaultTestSetIndices,]
outerRacewayFaultTestSetIndices<-sample(1:length(OuterRacewayFeatures[,1]),sizeOfTestSet)
outerRacewayFaultTestSet<-OuterRacewayFeatures[outerRacewayFaultTestSetIndices,]
innerRacewayFaultTestSetIndices<-sample(1:length(InnerRacewayFeatures[,1]),sizeOfTestSet)
innerRacewayFaultTestSet<-InnerRacewayFeatures[innerRacewayFaultTestSetIndices,]
completeTestSet<-rbind(normalTestSet,ballFaultTestSet,outerRacewayFaultTestSet,innerRacewayFaultTestSet)
#Calculate Euclidean distance between outlier test vectors and normal prototype
euclideanDistancesOfTestSet<-apply(completeTestSet[,-28],1,EuclideanDistanceToNormalPrototype)
completeTestSet[euclideanDistanceName]<-euclideanDistancesOfTestSet
#Classify complete set
predictedClasses<-ifelse(completeTestSet[,euclideanDistanceName]<=threshold, targetClassName, outlierClassName)
completeTestSet[predictedName]<-predictedClasses
rollerBearingTestSetConfusionMatrix<-confusion(object=completeTestSet$Predicted,true=completeTestSet$Class)
#Calculate type 1 error as the ratio of accepted outliers
numberOfAcceptedOutliers<-rollerBearingTestSetConfusionMatrix[targetClassName,outlierClassName]
acceptedOutliersRatio<-numberOfAcceptedOutliers/sum(rollerBearingTestSetConfusionMatrix[,])
#Calculate type 2 error as the ratio of rejected targets
numberOfRejectedTargets<-rollerBearingTestSetConfusionMatrix[outlierClassName,targetClassName]
rejectedTargetsRatio<-numberOfRejectedTargets/sum(rollerBearingTestSetConfusionMatrix[,])
#Retrain RF with 10 most important attributes
rollerBearingNormalDataAttributeImportance<-importance(rollerBearingNormalRf,type=1)
varImpPlot(rollerBearingNormalRf)
rollerBearingFeatureNames<-colnames(rollerBearingTestSet)[1:27]
rollerBearingAttributeImportanceTable<-data.frame(Feature=rollerBearingFeatureNames,AccuracyDecrease=rollerBearingNormalDataAttributeImportance)
rollerBearingAttributeImportanceTable<-rollerBearingAttributeImportanceTable[order(rollerBearingAttributeImportanceTable$MeanDecreaseAccuracy),]
rollerBearingTenMostImportantFeatures<-rownames(rollerBearingAttributeImportanceTable)[1:10]
rollerBearingNormalRf<-randomForest(trainingSet1[,rollerBearingTenMostImportantFeatures],proximity=TRUE,importance=TRUE)