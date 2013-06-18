%% Support Vector Data Description (SVDD) of Roller Bearing time series
% Detection of Outliers in Rolling Element Bearing Datasets using Support
% Vector Data Description
%% Preprocessing 
% Partitions Roller Bearing time signals into segments of 5 revolutions (2,3)
numberOfRevolutionsPerSegment=5;
rpm=1796;
sampleFrequency=48000;
normalSegments=SegmentRotationTimeSignal(...
    rollerBearingNormalData,...
    rpm,...
    sampleFrequency,...
    numberOfRevolutionsPerSegment); 
ballFaultSegments=SegmentRotationTimeSignal(...
    rollerBearingBallFaultData,...
    rpm,...
    sampleFrequency,...
    numberOfRevolutionsPerSegment); 
innerRacewayFaultSegments=SegmentRotationTimeSignal(...
    rollerBearingInnerRacewayFaultData,...
     rpm,...
     sampleFrequency,...
     numberOfRevolutionsPerSegment); 
 outerRacewayFaultSegments=SegmentRotationTimeSignal(...
    rollerBearingOuterRacewayFaultData,...
     rpm,...
     sampleFrequency,...
     numberOfRevolutionsPerSegment);
 
 numberOfDataPoints = size(normalSegments,1);
 deltaX = numberOfRevolutionsPerSegment/numberOfDataPoints;
 xScale = (0+deltaX):deltaX:numberOfRevolutionsPerSegment;
 
%Plots the first segment of each dataset
figure(1); clf;
subplot(4,1,1), 
    plot(xScale,normalSegments(:,1)),
    title('First five revolutions of Rolling Element Bearing Data')
    ylabel('Normal');
subplot(4,1,2), 
    plot(xScale,ballFaultSegments(:,1)),
    ylabel('Ball fault');
subplot(4,1,3), 
    plot(xScale,innerRacewayFaultSegments(:,1)),
    ylabel('IR fault');
subplot(4,1,4), 
    plot(xScale,outerRacewayFaultSegments(:,1));
    ylabel('OR fault');
    %% Feature Extraction
    % Extracts Kurtosis (k),Mel Frequency Cepstrum Coefficients (c) and Multifractal
    % Dimensions (m) as 27-tupels in the format (c1...c13,m1...,m13,k) (3)
    normalFeatures = ...
        ExtractRollerBearingFeatures(normalSegments, sampleFrequency);
    ballFaultFeatures =...
        ExtractRollerBearingFeatures(ballFaultSegments,sampleFrequency);
    innerRacewayFaultFeatures =...
        ExtractRollerBearingFeatures(innerRacewayFaultSegments,sampleFrequency);
    outerRacewayFaultFeatures=...
        ExtractRollerBearingFeatures( outerRacewayFaultSegments,sampleFrequency);
    %% Feature reduction with PCA
    numberOfPrincipalComponents=27;
    [principalComponentsOfNormalData,transformedNormalData]=princomp(zscore(normalFeatures));
    figure()
    plot(transformedNormalData(:,1),transformedNormalData(:,2),'+')
    xlabel('1st Principal Component')
    ylabel('2nd Principal Component')
    reducedPrincipalComponentsOfNormalData = principalComponentsOfNormalData(:,1: numberOfPrincipalComponents);
    reducedNormalData = zscore(normalFeatures)*reducedPrincipalComponentsOfNormalData;
    reducedBallFaultData=zscore(ballFaultFeatures)*reducedPrincipalComponentsOfNormalData;
    reducedOuterRacewayFaultData=zscore(outerRacewayFaultFeatures)*reducedPrincipalComponentsOfNormalData;
    reducedInnerRacewayFaultData=zscore(innerRacewayFaultFeatures)*reducedPrincipalComponentsOfNormalData;
    %% Iterative training and testing with different OC-Classifiers
    % Creates a target dataset with normal features for training and a
    % dataset with target and outlier samples for testing 
    normalFeaturesDataSet=dataset(normalFeatures);
    ballFaultFeaturesDataSet=dataset(ballFaultFeatures);
    innerRacewayFaultFeaturesDataset=dataset( innerRacewayFaultFeatures );
    outerRacewayFaultFeaturesDataset=dataset(  outerRacewayFaultFeatures);
    %Creates a target data training set with normal features
    %Put away normal data for testing
    targetData =...
        gendatoc(normalFeaturesDataSet);
    %Creates an outlier dataset with ball fault features
    ballFaultOutliers =...
        gendatoc([],  ballFaultFeaturesDataSet);
    %Creates an outlier dataset with inner raceway fault features
    innerRacewayFaultOutliers=...
        gendatoc([],  innerRacewayFaultFeaturesDataset);
    %Creates an outlier dataset with outer raceway fault features
    outerRacewayFaultOutliers=...
        gendatoc([],  outerRacewayFaultFeaturesDataset);
  
   numberOfIterations=1;
   svddRejectedNormals =0;
   svddAcceptedOutliers=0; 
   kMeansRejectedNormals= 0;
   kMeansAcceptedOutliers= 0; 
   kcenterRejectedNormals= 0;
   kcenterAcceptedOutliers= 0;
   nddRejectedNormals= 0;
   nddAcceptedOutliers= 0;
   parzenWindowsRejectedNormals =0;
   parzenWindowsAcceptedOutliers= 0;
   somRejectedNormals=0;
   somAcceptedOutliers=0;
   for i=0:numberOfIterations
       %Creates a test dataset with 50 random samples drawn from each dataset
       numberOfTestSamples=100;
       [targetTestData,targetTrainingData,normalTestDataIndices,normalTrainingDataIndices]=...
           gendat(targetData, numberOfTestSamples);
       [ballFaultTestData,unused,ballFaultTestDataIndices,unused2]=...
           gendat(ballFaultOutliers, numberOfTestSamples);
       [innerRacewayFaultTestData,unused,innerRacewayFaultTestDataIndices,unused2]=...
           gendat(innerRacewayFaultOutliers,numberOfTestSamples);
       [outerRacewayFaultTestData,unused,outerRacewayFaultTestDataIndices,unused2]=...
           gendat(outerRacewayFaultOutliers,numberOfTestSamples);  
       testData=[targetTestData;...
           ballFaultTestData;...
           innerRacewayFaultTestData;...
           outerRacewayFaultTestData];
       %Create training and test dataset with reduced features
       reducedTrainingData=dataset(zscore(+targetTrainingData)* reducedPrincipalComponentsOfNormalData,getlabels(targetTrainingData));
       reducedTestData=dataset(zscore(+testData)* reducedPrincipalComponentsOfNormalData,getlabels(testData));
       fractionOfRejectedTrainingData=0.1;
       % RandomForest
       w = randomforest_dd(targetTrainingData, fractionOfRejectedTrainingData)
       % SVDD
       w = svdd(  reducedTrainingData, fractionOfRejectedTrainingData,5);
       e = dd_error(reducedTestData,w);
       svddRejectedNormals =svddRejectedNormals+ e(1);
       svddAcceptedOutliers =svddAcceptedOutliers+e(2);
       % K-MEANS  
       w = kmeans_dd( reducedTrainingData, fractionOfRejectedTrainingData,5);
       e = dd_error(reducedTestData,w);
       kMeansRejectedNormals= kMeansRejectedNormals+e(1);
       kMeansAcceptedOutliers= kMeansAcceptedOutliers+e(2);
       % K-Centers
       w = kcenter_dd( reducedTrainingData, fractionOfRejectedTrainingData,5);
       e = dd_error(reducedTestData,w);
       kcenterRejectedNormals= kcenterRejectedNormals+e(1);
       kcenterAcceptedOutliers= kcenterAcceptedOutliers+e(2);
       % NN-d
       w = nndd( reducedTrainingData, fractionOfRejectedTrainingData);
       e = dd_error(reducedTestData,w);
       nddRejectedNormals= nddRejectedNormals+e(1);
       nddAcceptedOutliers=   nddAcceptedOutliers+e(2);
       % Parzen-dd
       w = parzen_dd(reducedTrainingData, fractionOfRejectedTrainingData);
       e = dd_error(reducedTestData,w);
       parzenWindowsRejectedNormals =   parzenWindowsRejectedNormals+e(1);
       parzenWindowsAcceptedOutliers=   parzenWindowsAcceptedOutliers+e(2);
       % SOM-dd
       w = som_dd( reducedTrainingData, fractionOfRejectedTrainingData);
       e = dd_error(reducedTestData,w);
       somRejectedNormals=somRejectedNormals+e(1);
       somAcceptedOutliers= somAcceptedOutliers+e(2);
   end
   svddRejectedNormals =svddRejectedNormals/numberOfIterations
   svddAcceptedOutliers=svddAcceptedOutliers/numberOfIterations
   kMeansRejectedNormals=  kMeansRejectedNormals/numberOfIterations
   kMeansAcceptedOutliers= kMeansAcceptedOutliers/numberOfIterations
   kcenterRejectedNormals=  kcenterRejectedNormals/numberOfIterations
   kcenterAcceptedOutliers=  kcenterAcceptedOutliers/numberOfIterations
   nddRejectedNormals= nddRejectedNormals/numberOfIterations
   nddAcceptedOutliers=  nddAcceptedOutliers/numberOfIterations
   parzenWindowsRejectedNormals = parzenWindowsRejectedNormals/numberOfIterations
   parzenWindowsAcceptedOutliers=  parzenWindowsAcceptedOutliers/numberOfIterations
   somRejectedNormals= somRejectedNormals/numberOfIterations
   somAcceptedOutliers= somAcceptedOutliers/numberOfIterations
   %% References
   %%
   % # PRTools4, A Matlab Toolbox for Pattern Recognition Version 4.1
   % (R.P.W. Duin,D.M.J. Tax et al.)
   % # <http://csegroups.case.edu/bearingdatacenter/pages/welcome-case-western-reserve-university-bearing-data-center-website>
   % # "Early Classification Of Bearing Faults Using Hidden Markov Models,Gaussian Mixture Models, Mel-Frequency Cepstral Coefficients and Fractals" (Marwala et al)
   % # "Support Vector Data Description" (Tax,Duin) <http://mediamatica.ewi.tudelft.nl/sites/default/files/ML_SVDD_04.pdf>
   

  