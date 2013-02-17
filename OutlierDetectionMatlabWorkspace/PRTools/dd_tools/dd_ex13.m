% Example of the kernelization of the AUClpm

% Generate data
a = oc_set(gendatb([10,100]),1);

% Define a plain auclpm and a kernelized version
w1 = auclpm;
w2 = myproxm([],'r',3,[],10)*auclpm;

% and train them:
w1 = a*w1;
w2 = a*w2;

%Show:
figure(1); clf; scatterd(a);
h1 = plotm(w1,'b');
h2 = plotm(w2,'k');

