library("randomForest", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
#Create randomly sampled test set with roller bearing normal features
numberOfTestVectors<-30
normalTestVectorsIndices<-sample(1:length(normalFeatures[,1]),30)
normalTestVectors<-normalFeatures[normalTestVectorsIndices,]
#Create training data set with roller bearing normal features
normalTrainingVectors<-normalFeatures[-normalTestVectorsIndices,]
#Construct unsupervised random forest with roller bearings training data set
rollerBearingNormalRf<-randomForest(normalTrainingVectors[,-28],proximity=TRUE,importance=TRUE)
#Calculate class prototype of roller bearing normal data
rollerBearingNormalClassPrototype <- classCenter(normalTrainingVectors[,-28], normalTrainingVectors[,28], rollerBearingNormalRf$prox)
#Create Test Set with 30 test vectors of each feature set
ballFaultTestVectorsIndices<-sample(1:length(BallFaultFeatures[,1]),30)
ballFaultTestVectors<-BallFaultFeatures[ballFaultTestVectorsIndices,]
outerRacewayFaultTestVectorsIndices<-sample(1:length(OuterRacewayFeatures[,1]),30)
outerRacewayFaultTestVectors<-OuterRacewayFeatures[outerRacewayFaultTestVectorsIndices,]
innerRacewayFaultTestVectorsIndices<-sample(1:length(InnerRacewayFeatures[,1]),30)
innerRacewayFaultTestVectors<-InnerRacewayFeatures[innerRacewayFaultTestVectorsIndices,]
rollerBearingTestSet<-rbind(normalTestVectors,ballFaultTestVectors,outerRacewayFaultTestVectors,innerRacewayFaultTestVectors)
#Calculate Euclidean Distances between test vectors and normal features prototype
EuclideanDistanceToNormalPrototype<-function (vector) {
  return(sqrt(sum((vector- normalFeatureClassPrototype) ^ 2)))
}
euclideanDistances<-apply(rollerBearingTestSet[,-28],1,EuclideanDistanceToNormalPrototype)
rollerBearingTestSet["EuclideanDistance"]<-euclideanDistances
