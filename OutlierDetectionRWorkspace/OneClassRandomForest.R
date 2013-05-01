OneClassRandomForest <- function (trainingSet,trainingSetLabels,testSet,testLabels) 
{ 
library("randomForest", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
library("mda", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
euclideanDistanceName<-"EuclideanDistance"
targetClassName<-"Target"
outlierClassName<-"Outlier"
className<-"Class"
#Construct unsupervised random forest with roller bearings training data set
randomForestObject<-randomForest(trainingSet,proximity=TRUE,importance=TRUE)
#Calculate class prototype of roller bearing normal data
classPrototype <- classCenter(trainingSet, trainingSetLabels, randomForestObject$prox)
#Calculate Euclidean Distances between test vectors and normal features prototype
EuclideanDistanceToPrototype<-function (vector) {
  return(sqrt(sum((vector- classPrototype) ^ 2)))
}
euclideanDistancesOfTargetVectors<-apply(trainingSet,1,EuclideanDistanceToPrototype)
trainingSet[euclideanDistanceName]<-euclideanDistancesOfTargetVectors
threshold<-max(trainingSet[,euclideanDistanceName])
#Classification
#Calculate Euclidean distance between outlier test vectors and normal prototype
euclideanDistancesOfTestSet<-apply(testSet,1,EuclideanDistanceToPrototype)
testSet[euclideanDistanceName]<-euclideanDistancesOfTestSet
#Classify complete set
predictedClasses<-ifelse(testSet[,euclideanDistanceName]<=threshold, targetClassName, outlierClassName)
testSet[predictedName]<-predictedClasses  
testSet[className]<-testLabels
rollerBearingTestSetConfusionMatrix<-confusion(object=testSet$Predicted,true=testSet$Class)
#Calculate type 1 error as the ratio of accepted outliers
numberOfAcceptedOutliers<-rollerBearingTestSetConfusionMatrix[targetClassName,outlierClassName]
acceptedOutliersRatio<-numberOfAcceptedOutliers/sum(rollerBearingTestSetConfusionMatrix[,])
#Calculate type 2 error as the ratio of rejected targets
numberOfRejectedTargets<-rollerBearingTestSetConfusionMatrix[outlierClassName,targetClassName]
rejectedTargetsRatio<-numberOfRejectedTargets/sum(rollerBearingTestSetConfusionMatrix[,])
return(list(RandomForest=randomForestObject,Confusion=rollerBearingTestSetConfusionMatrix,Type1Error=acceptedOutliersRatio,Type2Error=rejectedTargetsRatio))
}