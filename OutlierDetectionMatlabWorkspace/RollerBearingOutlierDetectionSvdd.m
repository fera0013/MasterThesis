%% Support Vector Data Description (SVDD) of Roller Bearing time series
% Detection of Outliers in Rolling Element Bearing Datasets using Support
% Vector Data Description
  normalFeaturesZ=zscore(normalFeatures);
  ballFaultFeaturesZ=zscore(ballFaultFeatures);
  innerRacewayFaultFeaturesZ=zscore(innerRacewayFaultFeatures);
  outerRacewayFaultFeaturesZ=zscore(outerRacewayFaultFeatures);
  normalFeaturesDataSet=dataset(normalFeaturesZ);
  ballFaultFeaturesDataSet=dataset(ballFaultFeaturesZ);
  innerRacewayFaultFeaturesDataset=dataset( innerRacewayFaultFeaturesZ);
  outerRacewayFaultFeaturesDataset=dataset(  outerRacewayFaultFeaturesZ);
 %% Definition of performance measures
 svddRejectedNormals =0;
 svddAcceptedOutliers=0;
 %% Iterative training and testing
 for sigma=1:10,
     %Create a test dataset with 50 random samples drawn from each dataset
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
     fractionOfRejectedTrainingData=0.1;
     % RandomForest
     %w = randomforest_dd(targetTrainingData, fractionOfRejectedTrainingData)
     % SVDD
     w = svdd(  targetTrainingData,0,sigma);
     e = dd_error(  testData,w);
     currentSigma=sigma
     svddRejectedNormals =e(1)
     svddAcceptedOutliers =e(2)
 end
 %% References
 %%
 % # PRTools4, A Matlab Toolbox for Pattern Recognition Version 4.1
 % (R.P.W. Duin,D.M.J. Tax et al.)
 % # <http://csegroups.case.edu/bearingdatacenter/pages/welcome-case-western-reserve-university-bearing-data-center-website>
 % # "Early Classification Of Bearing Faults Using Hidden Markov Models,Gaussian Mixture Models, Mel-Frequency Cepstral Coefficients and Fractals" (Marwala et al)
 % # "Support Vector Data Description" (Tax,Duin) <http://mediamatica.ewi.tudelft.nl/sites/default/files/ML_SVDD_04.pdf>
   

  