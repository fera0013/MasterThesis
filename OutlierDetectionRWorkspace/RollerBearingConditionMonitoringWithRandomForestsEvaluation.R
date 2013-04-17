library("randomForest", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
#Define names
targetClassName<-"Target"
outlierClassName<-"Outlier"
className<-"Class"
euclideanDistanceName<-"EuclideanDistance"
thresholdName<-"Threshold"
#Create randomly sampled test set with roller bearing normal features
numberOfTestVectors<-30
normalTestVectorsIndices<-sample(1:length(normalFeatures[,1]),numberOfTestVectors)
normalTestVectors<-normalFeatures[normalTestVectorsIndices,]
#Create training data set with roller bearing normal features
normalTrainingVectors<-normalFeatures[-normalTestVectorsIndices,]
#Construct unsupervised random forest with roller bearings training data set
rollerBearingNormalRf<-randomForest(normalTrainingVectors[,-28],proximity=TRUE,importance=TRUE)
#plot variabe importance
rollerBearingAttributeImportance<-rollerBearingNormalRf$importance[,1]
sortedRollerBearingAttributeImportance<-sort(rollerBearingAttributeImportance)
windows.options(width=10, height=50)
barplot(sortedRollerBearingAttributeImportance, horiz=TRUE,cex.names=0.6,las = 1,main="Normal Features Attribute importance",xlab="Mean Decrease in Accuracy",space=0.5)
#build in plot for attribute importance
varImpPlot(rollerBearingNormalRf,cex=0.6)
windows.options(reset=TRUE)
#Scaling plot
MDSplot(rollerBearingNormalRf,normalTrainingVectors$Class)
#calculate outlier measures 
rollerBearingTrainingSetOutliers<-outlier(rollerBearingNormalRf)
numericalClassValues<-rep(2,length(normalTrainingVectors))
numericalClassValues[normalTrainingVectors$Class==targetClassName]<-1
plot(rollerBearingTrainingSetOutliers,type="l",xlab="Training data vectors",ylab="Outlying measure")
title("Outlier measures of normal roller bearing data")
#Calculate class prototype of roller bearing normal data
rollerBearingNormalClassPrototype <- classCenter(normalTrainingVectors[,-28], normalTrainingVectors[,28], rollerBearingNormalRf$prox)
#Create Test Set with 30 test vectors of each feature set
ballFaultTestVectorsIndices<-sample(1:length(BallFaultFeatures[,1]),numberOfTestVectors)
ballFaultTestVectors<-BallFaultFeatures[ballFaultTestVectorsIndices,]
outerRacewayFaultTestVectorsIndices<-sample(1:length(OuterRacewayFeatures[,1]),numberOfTestVectors)
outerRacewayFaultTestVectors<-OuterRacewayFeatures[outerRacewayFaultTestVectorsIndices,]
innerRacewayFaultTestVectorsIndices<-sample(1:length(InnerRacewayFeatures[,1]),numberOfTestVectors)
innerRacewayFaultTestVectors<-InnerRacewayFeatures[innerRacewayFaultTestVectorsIndices,]
rollerBearingTestSet<-rbind(normalTestVectors,ballFaultTestVectors,outerRacewayFaultTestVectors,innerRacewayFaultTestVectors)
#Calculate Euclidean Distances between test vectors and normal features prototype
EuclideanDistanceToNormalPrototype<-function (vector) {
  return(sqrt(sum((vector- normalFeatureClassPrototype) ^ 2)))
}
euclideanDistances<-apply(rollerBearingTestSet[,-28],1,EuclideanDistanceToNormalPrototype)
rollerBearingTestSet[euclideanDistanceName]<-euclideanDistances
#Plot the results
numericalClassValues<-rep(2,length(euclideanDistances))
numericalClassValues[rollerBearingTestSet$Class==targetClassName]<-1
plot(euclideanDistances,xlab="Test vectors ",ylab="Euclid. Distance",pch=c(2,1)[numericalClassValues])
title("Euclidean distances between 
      Roller Bearing test vectors and target prototype")
#Set the threshold separating normal conditions from faulty conditions
targetClassTestVectors<-subset(rollerBearingTestSet,rollerBearingTestSet$Class==targetClassName)
threshold<-max(targetClassTestVectors[,euclideanDistanceName])
abline(h=threshold,lty=2)
legend("topleft",cex=0.75, inset=.05,c(targetClassName,outlierClassName,thresholdName), pch=c(2,1,NA),lty=c(NA,NA,2))