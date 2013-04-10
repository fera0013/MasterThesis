library("randomForest", lib.loc="C:/Users/RalphFehrer/Documents/R/win-library/2.15")
#Create test set with roller bearing normal features
numberOfTestVectors<-30
normalTestVectors<-normalFeatures[1:numberOfTestVectors,]
#Create training data set with roller bearing normal features
normalTrainingVectors<-normalFeatures[numberOfTestVectors:(length(normalFeatures[,1])-numberOfTestVectors),]
#Construct unsupervised random forest with roller bearings training data set
rollerBearingNormalRf<-randomForest(normalTrainingVectors,proximity=TRUE,importance=TRUE)
#Calculate class prototype of roller bearing normal data
rollerBearingNormalLabels<-c(rep("target",length(normalTrainingVectors[,5])))
rollerBearingNormalClassPrototype <- classCenter(normalTrainingVectors, rollerBearingNormalLabels, rollerBearingNormalRf$prox)

