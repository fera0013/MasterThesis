%% Support Vector Data Description (SVDD) of Roller Bearing time series
% Detection of Outliers in Rolling Element Bearing Datasets using Support
% Vector Data Description
%% Preprocessing 
%Split Roller Bearing time signals into segments of 5 revolutions 
numberOfRevolutionsPerSegment=5;
rpm=1796;
sampleFrequency=48000;
normalSegments=SplitSignal(...
    rollerBearingNormalData,...
    rpm,...
    sampleFrequency,...
    numberOfRevolutionsPerSegment); 
ballFaultSegments=SplitSignal(...
    rollerBearingBallFaultData,...
    rpm,...
    sampleFrequency,...
    numberOfRevolutionsPerSegment); 
innerRacewayFaultSegments=SplitSignal(...
    rollerBearingInnerRacewayFaultData,...
     rpm,...
     sampleFrequency,...
     numberOfRevolutionsPerSegment); 
 outerRacewayFaultSegments=SplitSignal(...
    rollerBearingOuterRacewayFaultData,...
     rpm,...
     sampleFrequency,...
     numberOfRevolutionsPerSegment);
%   % Feature Extraction
%   Extracts Kurtosis (k),Mel Frequency Cepstrum Coefficients (c) and Multifractal
%   Dimensions (m) as 27-tupels in the format (c1...c13,m1...,m13,k) (3)
  normalFeatures = ...
      ExtractFeatures(normalSegments, sampleFrequency);
  ballFaultFeatures =...
      ExtractFeatures(ballFaultSegments,sampleFrequency);
  innerRacewayFaultFeatures =...
      ExtractFeatures(innerRacewayFaultSegments,sampleFrequency);
  outerRacewayFaultFeatures=...
      ExtractFeatures( outerRacewayFaultSegments,sampleFrequency);
  % Data set construction
  normalFeaturesDataSet=dataset(normalFeatures);
  ballFaultFeaturesDataSet=dataset(ballFaultFeatures);
  innerRacewayFaultFeaturesDataset=dataset( innerRacewayFaultFeatures );
  outerRacewayFaultFeaturesDataset=dataset(  outerRacewayFaultFeatures);
  %Creates a target data training set with normal features
  normalFeaturesOcDataset =...
      gendatoc(normalFeaturesDataSet);
  %Creates an outlier dataset with ball fault features
  ballFaultFeaturesOcDataset =...
      gendatoc([],  ballFaultFeaturesDataSet);
  %Creates an outlier dataset with inner raceway fault features
  innerRacewayFaultFeaturesOcDataset=...
      gendatoc([],  innerRacewayFaultFeaturesDataset);
  %Creates an outlier dataset with outer raceway fault features
  outerRacewayFaultFeaturesOcDataset=...
      gendatoc([],  outerRacewayFaultFeaturesDataset);
 %% Definition of performance measures
 numberOfRuns=2;
 numberOfFeatures=size(normalFeaturesOcDataset,2);
 rfddRejectedNormals =zeros(numberOfFeatures,numberOfRuns);
 rfddAcceptedOutliers=zeros(numberOfFeatures,numberOfRuns);
 rfddTrainingRuntime =zeros(numberOfFeatures,numberOfRuns);
 rfddTestingRuntime =zeros(numberOfFeatures,numberOfRuns);
 svddRejectedNormals =zeros(numberOfFeatures,numberOfRuns);
 svddAcceptedOutliers=zeros(numberOfFeatures,numberOfRuns);
 svddTrainingRuntime =zeros(numberOfFeatures,numberOfRuns);
 svddTestingRuntime =zeros(numberOfFeatures,numberOfRuns);
 kMeansRejectedNormals= zeros(numberOfFeatures,numberOfRuns);
 kMeansAcceptedOutliers= zeros(numberOfFeatures,numberOfRuns);
 kMeansTrainingRuntime= zeros(numberOfFeatures,numberOfRuns);
 kMeansTestingRuntime= zeros(numberOfFeatures,numberOfRuns);
 kcenterRejectedNormals= zeros(numberOfFeatures,numberOfRuns);
 kcenterAcceptedOutliers= zeros(numberOfFeatures,numberOfRuns);
 kcenterTrainingRuntime= zeros(numberOfFeatures,numberOfRuns);
 kcenterTestingRuntime= zeros(numberOfFeatures,numberOfRuns);
 nddRejectedNormals= zeros(numberOfFeatures,numberOfRuns);
 nddAcceptedOutliers= zeros(numberOfFeatures,numberOfRuns);
 nddTrainingRuntime= zeros(numberOfFeatures,numberOfRuns);
 nddTestingRuntime= zeros(numberOfFeatures,numberOfRuns);
 parzenWindowsRejectedNormals =zeros(numberOfFeatures,numberOfRuns);
 parzenWindowsAcceptedOutliers= zeros(numberOfFeatures,numberOfRuns);
 parzenWindowsTrainingRuntime=zeros(numberOfFeatures,numberOfRuns);
 parzenWindowsTestingRuntime=zeros(numberOfFeatures,numberOfRuns);
 somRejectedNormals=zeros(numberOfFeatures,numberOfRuns);
 somAcceptedOutliers=zeros(numberOfFeatures,numberOfRuns);
 somTrainingRuntime=zeros(numberOfFeatures,numberOfRuns);
 somTestingRuntime=zeros(numberOfFeatures,numberOfRuns);
 %% Iterative training and testing
 for i=1:numberOfRuns
     %Create a test dataset with 50 random samples drawn from each dataset
     numberOfTestSamplesPerClass=90; %Should be divisible by 3 for a balanced test set
     [targetTestSet,trainingSet]=...
         gendat(normalFeaturesOcDataset, numberOfTestSamplesPerClass);
     [ballFaultTestSet]=...
         gendat(ballFaultFeaturesOcDataset, numberOfTestSamplesPerClass/3);
     [innerRacewayFaultTestSet]=...
         gendat(innerRacewayFaultOutliers,numberOfTestSamplesPerClass/3);
     [outerRacewayFaultTestSet]=...
         gendat(outerRacewayFaultFeaturesOcDataset,numberOfTestSamplesPerClass/3);  
     testSet=[targetTestSet;...
         ballFaultTestSet;...
         innerRacewayFaultTestSet;...
         outerRacewayFaultTestSet];
     fractionOfRejectedTrainingData=0.1;
     % RandomForest
     tic;
     [w,model] = randomforest_dd(trainingSet, fractionOfRejectedTrainingData);
     rfddTrainingRuntime=rfddTrainingRuntime+toc;
     % Get indices of most important features (i.e, features with highest
     % values in meanDecreaseInAccuracy
     featureImportance = model.importance;
     meanDecreaseInAccuracy = featureImportance(:,3);
     [unused,variableImportanceRank]=sort(meanDecreaseInAccuracy);
     for numberOfMostImportantFeatures=1:numberOfFeatures,
        importanceThreshold = numberOfFeatures-(numberOfMostImportantFeatures-1);
        mostImportantFeatures=variableImportanceRank(importanceThreshold:numberOfFeatures);
        % SVDD
        tic;
        w = svdd(  trainingSet(:,mostImportantFeatures), fractionOfRejectedTrainingData,6);
        svddTrainingRuntime(numberOfMostImportantFeatures,i)=toc;
        tic;
        e = dd_error(  testSet(:,mostImportantFeatures),w);
        svddTestingRuntime(numberOfMostImportantFeatures,i)=toc;
        svddRejectedNormals(numberOfMostImportantFeatures,i) =e(1);
        svddAcceptedOutliers(numberOfMostImportantFeatures,i) =e(2);
        % K-MEANS  
        tic;
        importantFeatures=trainingSet(:,mostImportantFeatures);
        w = kmeans_dd( trainingSet(:,mostImportantFeatures), fractionOfRejectedTrainingData,5);
        snapnow;
        kMeansTrainingRuntime(numberOfMostImportantFeatures,i) = toc;
        tic;
        e = dd_error(  testSet(:,mostImportantFeatures),w);
        kMeansTestingRuntime(numberOfMostImportantFeatures,i) = toc;
        kMeansRejectedNormals(numberOfMostImportantFeatures,i)= e(1);
        kMeansAcceptedOutliers(numberOfMostImportantFeatures,i)= e(2);
        % K-Centers
        tic;
        w = kcenter_dd( trainingSet(:,mostImportantFeatures), fractionOfRejectedTrainingData,5);
        kcenterTrainingRuntime(numberOfMostImportantFeatures,i)=toc;
        e = dd_error(  testSet(:,mostImportantFeatures),w);
        kcenterTestingRuntime(numberOfMostImportantFeatures,i)=toc;
        kcenterRejectedNormals(numberOfMostImportantFeatures,i)= e(1);
        kcenterAcceptedOutliers(numberOfMostImportantFeatures,i)= e(2);
        % NN-d
        tic;
        w = nndd( trainingSet(:,mostImportantFeatures), fractionOfRejectedTrainingData);
        nddTrainingRuntime(numberOfMostImportantFeatures,i)= toc;
        tic;
        e = dd_error(  testSet(:,mostImportantFeatures),w);
        nddTestingRuntime(numberOfMostImportantFeatures,i)=toc;
        nddRejectedNormals(numberOfMostImportantFeatures,i)= e(1);
        nddAcceptedOutliers(numberOfMostImportantFeatures,i)= e(2);
        % Parzen-dd
        tic;
        w = parzen_dd(trainingSet(:,mostImportantFeatures), fractionOfRejectedTrainingData);
        parzenWindowsTrainingRuntime(numberOfMostImportantFeatures,i)=toc;
        tic;
        e = dd_error(  testSet(:,mostImportantFeatures),w);
        parzenWindowsTestingRuntime(numberOfMostImportantFeatures,i)=toc;
        parzenWindowsRejectedNormals(numberOfMostImportantFeatures,i) =   e(1);
        parzenWindowsAcceptedOutliers(numberOfMostImportantFeatures,i)=   e(2);
        % SOM-dd
        tic;
        w = som_dd( trainingSet(:,mostImportantFeatures), fractionOfRejectedTrainingData);
        somTrainingRuntime(numberOfMostImportantFeatures,i)= toc;
        tic;
        e = dd_error(  testSet(:,mostImportantFeatures),w);
        somTestingRuntime(numberOfMostImportantFeatures,i)= toc;
        somRejectedNormals(numberOfMostImportantFeatures,i)=e(1);
        somAcceptedOutliers(numberOfMostImportantFeatures,i)= e(2);
        %% Calculate performance measures
        % Creates a target dataset with normal features for training and a
        % dataset with target and outlier samples for testing 
     end
 end
 rfddAccuracy=[];
 svddAccuracy=[];
 kMeansAccuracy=[];
 kcenterAccuracy=[];
 nddAccuracy=[];
 parzenWindowsAccuracy=[];
 somAccuracy=[];
 for j=1:numberOfFeatures,
     svddAccuracy(j) = CalculateAccuracy(mean(svddRejectedNormals(j,:)),mean(svddAcceptedOutliers(j,:)),testSet)
     kMeansAccuracy(j) = CalculateAccuracy(mean(kMeansRejectedNormals(j,:)),mean(kMeansAcceptedOutliers(j,:)),testSet)
     kcenterAccuracy(j)=CalculateAccuracy(mean(kcenterRejectedNormals(j,:)),mean(kcenterAcceptedOutliers(j,:)),testSet)
     nddAccuracy(j)=CalculateAccuracy(mean(nddRejectedNormals(j,:)),mean(nddAcceptedOutliers(j,:)),testSet)
     parzenWindowsAccuracy(j)=CalculateAccuracy(mean(parzenWindowsRejectedNormals(j,:)),mean(parzenWindowsAcceptedOutliers(j,:)),testSet)
     somAccuracy(j)=CalculateAccuracy(mean(somRejectedNormals(j,:)),mean(somAcceptedOutliers(j,:)),testSet)
 end
 x=1:1:numberOfFeatures;
 plot(x,svddAccuracy,'-+');
 hold on;
 plot(x,kMeansAccuracy,'-o');
 plot(x,kcenterAccuracy,'-*');
 plot(x,nddAccuracy,'-+');
 plot(x,parzenWindowsAccuracy,'-s');
 plot(x,somAccuracy,'-d');
 legend('svdd','kMeans','kCenter','ndd','parzen','som');
 hold off;
 %% References
 % # PRTools4, A Matlab Toolbox for Pattern Recognition Version 4.1
 % (R.P.W. Duin,D.M.J. Tax et al.)
 % # <http://csegroups.case.edu/bearingdatacenter/pages/welcome-case-western-reserve-university-bearing-data-center-website>


  