% DD_EX1
%
% Example of the creation of a One-Class problem, and the solutions
% obtained by the Nearest Neighbor Data Description and the Support
% Vector Data Description. Furthermore, the ROC curve is plotted and
% the AUC-error and F1-performance is computed.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%a = gendatb([30 30]);
% make the second class the target class and change the labels:
%a = oc_set(a,'1');
% only use target class:
%a = target_class(a);
% generate test data:
%b = oc_set(gendatb(200),'1');

% train the individual data descriptions and plot them
% the error on the target class:
fracrej = 0.2;
% train the nndd:
w1 = nndd(a,fracrej);
% and plot the decision boundary:
figure(1); clf; 
scatterd(a);
axis; axis(1.5*V);
plotc(w1,'k-');
title('N-dd boundary');
% second, train the svdd:
w2 = svdd(a,fracrej,5);
% and also plot this:
figure(2); clf; 
scatterd(a);
axis; axis(1.5*V);
plotc(w2,'k--');
title('SV-dd boundary');
% train k-means:
w3 = kmeans_dd(a,fracrej,5);
% and also plot this:
figure(3); clf; 
scatterd(a);
axis; axis(1.5*V);
plotc(w3,'k--');
title('K-means-dd boundary');
% train K-Centers
w4 = kcenter_dd(a,fracrej,5);
% and also plot this:
figure(4); clf; 
scatterd(a);
axis; axis(1.5*V);
plotc(w4,'k--');
title('K-center-dd boundary');
% train Parzen-dd
w5 = parzen_dd(a,fracrej);
% and also plot this:
figure(5); clf; 
scatterd(a);
axis; axis(1.5*V);
plotc(w5,'k--');
title('Parzen-dd boundary');
% train SOM-dd
w6 = som_dd( a,fracrej);
% and also plot this:
figure(6); clf; 
scatterd(a);
axis; axis(1.5*V);
plotc(w6,'k--');
title('Som-dd boundary');
    

