%UNRANDOMIZE 'Unrandomize' a dataset
%
%     A= UNRANDOMIZE(A);
%
% Reorder the objects in dataset A such that objects of the two classes
% appear uniformly in the whole dataset. This is needed for the
% incremental SVC to avoid that first the SVC gets all objects of class
% +1, and after that all objects of class -1. The optimization becomes
% very tough and numerically instable by that.


% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a= unrandomize(a);

[n,k,c]=getsize(a);
if c~=2
	error('Unrandomize requires just 2 classes.');
end

nlab = getnlab(a);
I1 = find(nlab==1);
I2 = find(nlab==2);

if length(I1)<length(I2)
	cmin = length(I1);
else
	cmin = length(I2);
	tmpI = I1;
	I1 = I2;
	I2 = tmpI;
end

J=[];
J(1:2:2*cmin) = I1;
J(2:2:2*cmin) = I2(1:cmin);
J = [J,I2((cmin+1):end)'];
a = a(J,:);

return

