%INC_STORE Pack the results of INC_ADD in a mapping
%
%   V = INC_STORE(W)
%
% Store the data structure W obtained from inc_add into a Prtools
% mapping V.

function w = inc_store(W)

setSV = [W.setS; W.setE];
dat.ktype = W.ktype;
dat.kpar = W.kpar;
dat.alf = W.y(setSV).*W.alf(setSV);
dat.sv = W.x(setSV,:);
dat.b = W.b;
% the offset and threshold:
K = dd_kernel(dat.sv,dat.sv,W.ktype,W.kpar);
dat.offs = sum(sum((dat.alf*dat.alf').*K));
dat.threshold = dat.offs + W.b;
w = mapping('incsvdd','trained',dat,char('target','outlier'),size(W.x,2),2);

