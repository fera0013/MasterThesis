%RELABEL Relabel classes in a dataset
%
%        B = RELABEL(A,NEWLAB)
%
% Rename the labels in dataset A to NEWLAB. Of course, the length of
% NEWLAB should be equal to the lablist of dataset A. The first class
% from the lablist will get the first label in NEWLAB. 
%
% This function is useful when from a dataset A, several classes are
% to be renamed to 'target' and the rest to the outlier class. If just a
% single class should be named 'target' then target_class or oc_set
% should be used.
%
%        B = RELABEL(A,NEWLAB,SORT)
%
% When SORT>0 the class labels are (alphabetically) sorted and stored in
% the dataset. This will change therefore also the numerical labels.
%
% See also: find_target, gendatoc, target_class, oc_set

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function b = relabel(a,newlab,sortlab)

if nargin<3
	sortlab = 0;
end

isdataset(a);
[m,k,c] = getsize(a);

if isa(newlab,'cell')
	newlab = char(newlab);
end
if (c~=size(newlab,1))
  error('Number of new labels should be equal to number of classes');
end

b = set(a,'lablist',newlab);

if sortlab
	% to make sure that the ordering of the nlab is now also consistent:
	[nl,ll] = renumlab(getlab(b));
	b = setnlab(b,nl);
	b = setlablist(b,ll);
    b = setprior(b,[]); %DXD: TRICKY!!!
end

return
