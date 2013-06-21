%% Support Vector Data Description (SVDD) of Roller Bearing time series
% Detection of Outliers in Rolling Element Bearing Datasets using Support
% Vector Data Description
%% Preprocessing 
% Partitions Roller Bearing time signals into segments of 5 revolutions (2,3)
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
 %Remove padded rows
 normalSegments=normalSegments(1:(end-1),:);
 ballFaultSegments=ballFaultSegments(1:(end-1),:);
 innerRacewayFaultSegments=innerRacewayFaultSegments(1:(end-1),:);
 outerRacewayFaultSegments=outerRacewayFaultSegments(1:(end-1),:);
 %% Feature Extraction
 % Extracts Kurtosis (k),Mel Frequency Cepstrum Coefficients (c) and Multifractal
 % Dimensions (m) as 27-tupels in the format (c1...c13,m1...,m13,k) (3)
 normalFeatures = ...
    ExtractFeatures(normalSegments, sampleFrequency);
 ballFaultFeatures =...
    ExtractFeatures(ballFaultSegments,sampleFrequency);
 innerRacewayFaultFeatures =...
    ExtractFeatures(innerRacewayFaultSegments,sampleFrequency);
 outerRacewayFaultFeatures=...
    ExtractFeatures( outerRacewayFaultSegments,sampleFrequency);
x=1:1:15;
normalLine='-';
ballFaultLine='-o';
innerRacewayFaultLine=':s';
outerRacewayFaultLine='--+';
%% Plot Mel Frequency Cepstral Coefficients
normalMfccFeatures = normalFeatures(1,1:13);
ballFaultMfccFeatures =  ballFaultFeatures(1,1:13);
innerRacewayFaultMfccFeatures=innerRacewayFaultFeatures(1,1:13);
outerRacewayFaultMfccFeatures=outerRacewayFaultFeatures(1,1:13);
minYValue=min(min(horzcat(normalMfccFeatures,ballFaultMfccFeatures,innerRacewayFaultMfccFeatures,outerRacewayFaultMfccFeatures)));
maxYValue=max(max(horzcat(normalMfccFeatures,ballFaultMfccFeatures,innerRacewayFaultMfccFeatures,outerRacewayFaultMfccFeatures)));
figure(1); clf;
subplot(4,1,1), 
    bar(normalMfccFeatures),
    title('First 13 Mel Frequency Cepstral Coefficients')
    ylabel('Normal');
    ylim([minYValue,maxYValue]);
subplot(4,1,2), 
    bar(ballFaultMfccFeatures),
    ylabel('Ball fault');
    ylim([minYValue,maxYValue]);
subplot(4,1,3), 
    bar(innerRacewayFaultMfccFeatures),
    ylabel('IR fault');
    ylim([minYValue,maxYValue]);
subplot(4,1,4), 
    bar(outerRacewayFaultMfccFeatures);
    ylabel('OR fault');
    ylim([minYValue,maxYValue]);
%% Plot Fractal Dimensions
figure(2); clf;
plot(x,normalFeatures(1:15,15),normalLine,...
    x,ballFaultFeatures(1:15,15),ballFaultLine,...
    x,outerRacewayFaultFeatures(1:15,15),outerRacewayFaultLine,...
    x,innerRacewayFaultFeatures(1:15,15),innerRacewayFaultLine)
title('First 15 Higuchi Fractal Dimensions with k=6')
ylim([1.5,2.4]);
ylabel('Fractal Dimension')
legend('normal','Ball fault','Outer raceway Fault','Inner raceway fault');
%% References
%%
% # PRTools4, A Matlab Toolbox for Pattern Recognition Version 4.1
% (R.P.W. Duin,D.M.J. Tax et al.)
% # <http://csegroups.case.edu/bearingdatacenter/pages/welcome-case-western-reserve-university-bearing-data-center-website>
% # "Early Classification Of Bearing Faults Using Hidden Markov Models,Gaussian Mixture Models, Mel-Frequency Cepstral Coefficients and Fractals" (Marwala et al)
% # "Support Vector Data Description" (Tax,Duin) <http://mediamatica.ewi.tudelft.nl/sites/default/files/ML_SVDD_04.pdf>
   

  