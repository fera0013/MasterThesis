%% Roller Bearing Outlier Detection with different One Class Classifiers
%% Preparation
clf;
   %% SVDD
   w = svdd( targetData,0.2,5);
   e = dd_error(testData,w);
   svddFalseNegatives = e(1)
   svddFalsePositives=e(2)
   h=plotroc(dd_roc(testData*w),'r');
   H(1) = h(1);
   %% K-Means   
   w = kmeans_dd(targetData,0.1,5);
   e = dd_error(testData,w);
   kMeansFalseNegatives= e(1)
   kMeansFalsePositives= e(2)
   h=plotroc(dd_roc(testData*w),'b');
   H(2) = h(1);
    %% K-Centers
   w = kcenter_dd(targetData,0.1,5);
   e = dd_error(testData,w);
   kcenterFalseNegative= e(1)
   kcenterFalsePositibe= e(2)
   h=plotroc(dd_roc(testData*w),'g');
   H(3) = h(1);
    %% NN-d
   w = NNdd(targetData,0.1);
   e = dd_error(testData,w);
   nndFalseNegative= e(1)
   nndFalsePositive= e(2)
   h=plotroc(dd_roc(testData*w),'y');
   H(4) = h(1);
    %% Parzen-dd
   w = parzen_dd(targetData,0.1);
   e = dd_error(testData,w);
   parzenFalseNegative =e(1)
   parzenFalsePositive= e(2)
   h=plotroc(dd_roc(testData*w),'m');
   H(5) = h(1);
    %% SOM-dd
   w = som_dd(targetData,0.1);
   e = dd_error(testData,w);
   somFalseNegative=e(1)
   somFalsePositive= e(2)
   h=plotroc(dd_roc(testData*w),'k');
   H(6) = h(1);
   %% Plot
   legend(H,'SVDD','K-Means','K-Centers','NN-d','Parzen','SOM')
   
   %% References
   %%
   % # PRTools4, A Matlab Toolbox for Pattern Recognition Version 4.1
   % (R.P.W. Duin,D.M.J. Tax et al.)
   % # <http://csegroups.case.edu/bearingdatacenter/pages/welcome-case-western-reserve-university-bearing-data-center-website>
   % # "Early Classification Of Bearing Faults Using Hidden Markov Models,Gaussian Mixture Models, Mel-Frequency Cepstral Coefficients and Fractals" (Marwala et al)
   % # "Support Vector Data Description" (Tax,Duin) <http://mediamatica.ewi.tudelft.nl/sites/default/files/ML_SVDD_04.pdf>
   

  