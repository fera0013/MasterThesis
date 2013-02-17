%DD_CONFMAT Confusion matrix
%
%     [C,LABLIST] = DD_CONFMAT(LAB1,LAB2)
%     [C,LABLIST] = DD_CONFMAT(A,W)
%     [C,LABLIST] = A*W*DD_CONFMAT
%  
% Compute the confusion matrix C between the two label vectors LAB1 and
% LAB2. The respective class labels are returned in LABLIST (it might be
% that the labels stored in LAB1 and LAB2 are not the same, therefore a
% common label list LABLIST has to be extracted) 
%
% You can also supply a dataset A and a classifier W, and the confusion
% matrix beween the true labels and the output labels is computed.
% DD_CONFMAT can also be used as a mapping (like dd_error or dd_roc).
%
% See also: dd_error, dd_roc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function [C,lablist] = dd_confmat(lab1,lab2)

% Do the same as testc: when no input arguments are given, just return
% an empty mapping
if nargin==0
	C = mapping(mfilename,'fixed');
	return
elseif nargin==1
	% we only supplied a classified dataset: extract the true labels and
	% the output labels:
	if nargout==0
		feval(mfilename,getlab(lab1),lab1*labeld);
	else
		[C,lablist] = feval(mfilename,getlab(lab1),lab1*labeld);
	end
else
	if ismapping(lab2) && istrained(lab2)
		% we supplied a dataset and a mapping, apply the mapping and try
		% again:
		[C,lablist] = dd_confmat(lab1*lab2);
	else
		% finally we only have lab1 and lab2, so the real work is done
		% here:

		% first make all labels characters
		lab1 = makecharlab(lab1);
		lab2 = makecharlab(lab2);
		% now compute the matrix:
		[nlab1,nlab2,lablist] = renumlab(lab1,lab2);
		n = size(lablist,1);
		C = zeros(n,n);

		for i=1:n
			I = find(nlab1==i);
			for j=1:n
				C(i,j) = sum(nlab2(I)==j);
			end
		end
		if nargout==0
			printconfmat(C,lablist);
		end
	end
end

return

function lab = makecharlab(lab)
% standarize the labels to character strings, and take extra precautions
% for unlabeled data

if ischar(lab) % check if we have completely empty labels
	I = (lab==' ') | (lab==0);
	I = find(all(I,2));
	if ~isempty(I) % replace the empty labels with '0'
		p = size(lab,2);
		n = length(I);
		lab(I,:) = repmat(['0' repmat(' ',1,p-1)],n,1);
	end
else
	% we have to convert it to char:

	% set the not-defined/illegal/Nan values to 0:
	I = find(~isfinite(lab));
	lab(I) = 0;

	lab = int2str(lab);
end

return

function printconfmat(C,lablist)
% pretty print the confusion matrix
		
% I actually assume a square C:
n = size(C,1);
% maximally 6 characters per label in lablist:
w = size(lablist,2);
if (w > 6)
	lablist = lablist(:,1:6); 
elseif (w < 6)
	lablist = [repmat(' ',size(lablist,1),6-w) lablist];
end

fprintf('\n  True   | Estimated Labels \n  Labels |');
for j = 1:n, fprintf('%6s ',lablist(j,:)); end
fprintf('| Totals \n');
fprintf('---------+%s+-------\n',repmat('-',1,7*n));

for j = 1:n
	fprintf('  %-6s |',lablist(j,:));
	fprintf('%5i  ',C(j,:)');
	fprintf('|%5i',sum(C(j,:)));
	fprintf('\n');
end

fprintf('---------+%s+-------\n',repmat('-',1,7*n));
fprintf('  Totals |');
fprintf('%5i  ',sum(C));
fprintf('|%5i\n',sum(C(:)));

return

