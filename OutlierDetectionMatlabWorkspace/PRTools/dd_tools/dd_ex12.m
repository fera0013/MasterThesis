% Example of the precision-recall curve, and a comparison with the
% Receiver-Operating Characteristic Curve

a = oc_set(gendatb([10,100]),1);

w1 = ldc(a)*classc;
w2 = parzen_dd(a);
w3 = auclpm(a);

figure(1); clf; scatterd(a);
h1 = plotc(w1,'b'); h2 = plotc(w2,'k'); h3 = plotc(w3,'r');
legend([h1 h2 h3],'LDA','Gauss','AUClpm');

figure(2); clf;
h1 = plotroc(a*w1*dd_roc,'b');
h2 = plotroc(a*w2*dd_roc,'k');
h3 = plotroc(a*w3*dd_roc,'r');
legend([h1 h2 h3],'LDA','Gauss','AUClpm');

figure(3); clf;
plotroc(a*w1*dd_prc,'b');
plotroc(a*w2*dd_prc,'k');
plotroc(a*w3*dd_prc,'r');
legend('LDA','Gauss','AUClpm');
