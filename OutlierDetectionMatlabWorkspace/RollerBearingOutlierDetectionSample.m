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

%References
% (1) "Early Classification Of Bearing Faults Using Hidden Markov Models,
%      Gaussian Mixture Models, Mel-Frequency Cepstral Coefficients and
%      Fractals" (Marwala et al)
% (2) "Support Vector Data Description" (Tax,Duin)
%      http://mediamatica.ewi.tudelft.nl/sites/default/files/ML_SVDD_04.pdf       f

%Preprocessing
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
    
%Extract Features
   %Extract Normal Features
normalFeatureMatrix=[];
for j=1:size(normalSegments,2),
    segment=normalSegments(:,j);
    kurtosisFeature= kurtosis(segment);
    mfccFeatures=melfcc(segment,sampleFrequency);
    %partition segment for hfd extraction into same number of frames as
    %implicitely done in Melfcc
    numberOfFramesPerSegment=size(mfccFeatures,2);
    frames = SegmentTimeSignalIntoNSegments(segment,numberOfFramesPerSegment);
    %Calculate HF for each frame 
    for i=1:numberOfFramesPerSegment,
        hfdFeature = hfd(frames,10);
        frameMfccFeatures = mfccFeatures(:,i)';
        featureVector= cat(2,frameMfccFeatures, hfdFeature,kurtosisFeature);
        featureMatrix=...
            [featureMatrix;featureVector];
    end
end
    %Remove NaN
    featureMatrix(any(isnan(featureMatrix),2),:)=[];
    %Calculate Principa Components
    featureDataSet=dataset(featureMatrix);
    eigenvalues=pca(featureDataSet,2);