%% Support Vector Data Description (SVDD) of Roller Bearing time series
% Example of an outlier detection problem with roller bearing data
% Involves the following steps:
%  - Preprocessing (1)
%    + Segmentation of roller bearing time series data 
%    + Further segmentation of each segment into frames
%  - Feature Extraction (1)
%    + Kurtosis of each segment
%    + Mel Frequency Cepstrum of each frame
%    + Higuchi Fractal Dimensions of each frame
%  - Semisupervised Classification
%    + Support Vector Data Description (2)
%  - Error evaluation
%    + false negative and false positive rate
%    + Roc Curve
%% SVDD sample
% Creates a banana-shaped one-class dataset and calculates three different
% SVDD mappings with Radial Basis Functions with different Sigma values

a = gendatb([30 30]);
% make the second class the target class and change the labels:
a = oc_set(a,'1');
% only use target class:
a = target_class(a);
% generate test data:
b = oc_set(gendatb(200),'1');

V = axis; axis(1.5*V);
% train the individual data descriptions and plot them
% the error on the target class
H=[0;0];
fracrej = 0.2;
figure(1); clf; hold on;
s=scatterd(a);
w1 = svdd(a,fracrej,2);
h=plotc(w1,'k--');
H(1)=s;
H(2)=h;
legend(H,'Target Data','SVDD with RBF, Sigma=2');
hold off;
figure(2); clf; hold on;
s=scatterd(a);
w2 = svdd(a,fracrej,3);
h=plotc(w2,'k--');
H(1)=s;
H(2)=h;
legend(H,'Target Data','SVDD with RBF, Sigma=3');
hold off;
figure(3); clf; hold on;
s=scatterd(a);
w3 = svdd(a,fracrej,5);
h=plotc(w3,'k--');
H(1)=s;
H(2)=h;
legend(H,'Target Data','SVDD with RBF, Sigma=5');
axis equal;
axis image;
%% Preprocessing
% Partitions Roller Bearing time signals into segments with 5 revolutions 
numberOfRevolutionsPerSegment=5;
rpm=1796;
sampleFrequency=48000;
normalSegments=SegmentRotationTimeSignal(...
    normalRawData1797rpm48k,...
    rpm,...
    sampleFrequency,...
    numberOfRevolutionsPerSegment); 
ballFaultSegments=SegmentRotationTimeSignal(...
    ballFaultRawData1797rpm48k,...
    rpm,...
    sampleFrequency,...
    numberOfRevolutionsPerSegment); 
innerRacewayFaultSegments=SegmentRotationTimeSignal(...
    innerRacewayFaultRawData1797rpm48k,...
     rpm,...
     sampleFrequency,...
     numberOfRevolutionsPerSegment); 
 outerRacewayFaultSegments=SegmentRotationTimeSignal(...
    outerRacewayRawData1797rpm48k,...
     rpm,...
     sampleFrequency,...
     numberOfRevolutionsPerSegment);
 
%Plot first five revolutions of each signal
figure(1); clf;
subplot(4,1,1), 
    plot(normalSegments(:,1)),
    title('Normal');
subplot(4,1,2), 
    plot(ballFaultSegments(:,1)),
    title('Ball Faults');
subplot(4,1,3), 
    plot(innerRacewayFaultSegments(:,1)),
    title('Inner Raceway Faults');
subplot(4,1,4), 
    plot(outerRacewayFaultSegments(:,1));
    title('Outer Raceway Faults');
    %% Extract Features
    % Extracts Kurtosis (k), Cepstrum Coefficients (c) and Multifractal
    % Dimensions (m) as 17-tupels in the format (k,c1...c13,m1...,m13) 
    normalFeatures = ...
        ExtractRollerBearingFeatures(normalSegments, sampleFrequency);
    ballFaultFeatures =...
        ExtractRollerBearingFeatures(ballFaultSegments,sampleFrequency);
    innerRacewayFaultFeatures =...
        ExtractRollerBearingFeatures(innerRacewayFaultSegments,sampleFrequency);
    outerRacewayFaultFeatures=...
        ExtractRollerBearingFeatures( outerRacewayFaultSegments,sampleFrequency);
    
    %% Convert features to PRTools datasets
    % Creates PR-Tools One-Class Datasets with labels "target" and
    % "outliers" for training and a dataset for training with target and
    % outlier samples
    
    normalFeaturesDataSet=dataset(normalFeatures);
    ballFaultFeaturesDataSet=dataset(ballFaultFeatures);
    innerRacewayFaultFeaturesDataset=dataset( innerRacewayFaultFeatures );
    outerRacewayFaultFeaturesDataset=dataset(  outerRacewayFaultFeatures);
    
    targetData =...
        gendatoc(normalFeaturesDataSet);
    ballFaultOutliers =...
        gendatoc([],  ballFaultFeaturesDataSet);
    innerRacewayFaultOutliers=...
        gendatoc([],  innerRacewayFaultFeaturesDataset);
    outerRacewayFaultOutliers=...
        gendatoc([],  outerRacewayFaultFeaturesDataset);
   
   %Create test dataset with 50 random samples of each data set
   numberOfTestSamples=50;
   [targetTestData,targetTrainingData]=...
       gendat(targetData, numberOfTestSamples);
   [ballFaultTestData,]=...
       gendat(ballFaultOutliers, numberOfTestSamples);
   [innerRacewayFaultTestData,]=...
       gendat(innerRacewayFaultOutliers,numberOfTestSamples);
   [outerRacewayFaultTestData,]=...
       gendat(outerRacewayFaultOutliers,numberOfTestSamples);
   testData=[targetTestData;...
             ballFaultTestData;...
             innerRacewayFaultTestData;...
             outerRacewayFaultTestData];
   

   %% SVDD Training
   % Calculates an SVDD mapping with target training data and a
   % RBF-Kernel with Sigma=5 
         
   w = svdd( targetData,0.2,5);
   
   %% Error evaluation
   % Calculates false negative (rejected targets) and false positive
   % (accepted outliers) rates and plots a ROC curve.
   
   e = dd_error(testData,w);
   +e
   %plot roc curve
   figure(2); clf;
   plotroc(dd_roc(testData*w),'r');

   %% References
   % (1) "Early Classification Of Bearing Faults Using Hidden Markov Models,
   %      Gaussian Mixture Models, Mel-Frequency Cepstral Coefficients and
   %      Fractals" (Marwala et al)
   % (2) "Support Vector Data Description" (Tax,Duin)
   %      http://mediamatica.ewi.tudelft.nl/sites/default/files/ML_SVDD_04.pdf
  
  