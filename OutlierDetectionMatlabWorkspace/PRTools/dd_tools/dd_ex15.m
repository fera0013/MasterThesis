% Show the use of the GRIDSEARCH script to optimize the free parameters
% of a classifier.

% Generate data:
a = oc_set(gendatb([50 50]),1);

% Optimize the SVDD:
w = dd_gridsearch(a,'svdd',10,[0.3 0.2 0.1],[10 5 3 1]);

% Show it:
scatterd(a); plotc(w);

% We can also define an untrained mapping, and train that:
u = dd_gridsearch([],'mog_dd',10,[0.3 0.2 0.1],[1 2 3 4]);
w = a*u;

plotc(w,'r');
