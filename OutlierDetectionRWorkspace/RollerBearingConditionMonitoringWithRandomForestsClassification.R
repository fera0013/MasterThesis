library("randomForest", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
#Define names
targetClassName<-"Target"
outlierClassName<-"Outlier"
className<-"Class"
euclideanDistanceName<-"EuclideanDistance"
thresholdName<-"Threshold"
predictedName<-"Predicted"
#Create randomly sampled test set with roller bearing normal features
numberOfTestVectors<-100
normalTestVectorsIndices<-sample(1:length(normalFeatures[,1]),numberOfTestVectors)
normalTestVectors<-normalFeatures[normalTestVectorsIndices,]
#Training 
#Create training data set with roller bearing normal features
normalTrainingVectors<-normalFeatures[-normalTestVectorsIndices,]
#Construct unsupervised random forest with roller bearings training data set
rollerBearingNormalRf<-randomForest(normalTrainingVectors[,-28],proximity=TRUE,importance=TRUE)
#Calculate class prototype of roller bearing normal data
rollerBearingNormalClassPrototype <- classCenter(normalTrainingVectors[,-28], normalTrainingVectors[,28], rollerBearingNormalRf$prox)
#Calculate Euclidean Distances between test vectors and normal features prototype
EuclideanDistanceToNormalPrototype<-function (vector) {
    return(sqrt(sum((vector- normalFeatureClassPrototype) ^ 2)))
  }
euclideanDistancesOfTargetVectors<-apply(normalTestVectors[,-28],1,EuclideanDistanceToNormalPrototype)
normalTestVectors[euclideanDistanceName]<-euclideanDistancesOfTargetVectors
threshold<-max(normalTestVectors[,euclideanDistanceName])
#Classification
#Create Test Set with [numberOfTestVectors] test vectors of each outlier feature set
ballFaultTestVectorsIndices<-sample(1:length(BallFaultFeatures[,1]),numberOfTestVectors)
ballFaultTestVectors<-BallFaultFeatures[ballFaultTestVectorsIndices,]
outerRacewayFaultTestVectorsIndices<-sample(1:length(OuterRacewayFeatures[,1]),numberOfTestVectors)
outerRacewayFaultTestVectors<-OuterRacewayFeatures[outerRacewayFaultTestVectorsIndices,]
innerRacewayFaultTestVectorsIndices<-sample(1:length(InnerRacewayFeatures[,1]),numberOfTestVectors)
innerRacewayFaultTestVectors<-InnerRacewayFeatures[innerRacewayFaultTestVectorsIndices,]
outlierTestSet<-rbind(ballFaultTestVectors,outerRacewayFaultTestVectors,innerRacewayFaultTestVectors)
#Calculate Euclidean distance between outlier test vectors and normal prototype
euclideanDistancesOfOutlierVectors<-apply(outlierTestSet[,-28],1,EuclideanDistanceToNormalPrototype)
outlierTestSet[euclideanDistanceName]<-euclideanDistancesOfOutlierVectors
#Create Complete testset
completeTestSet<-rbind(normalTestVectors,outlierTestSet)
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