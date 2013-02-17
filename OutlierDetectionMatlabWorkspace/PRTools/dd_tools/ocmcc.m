%OCMCC One-class and multi-class class sequential classifier
%
%   V = OCMCC(A,WOCC,W)
%
% Train on dataset A a one-class classifier WOCC (given by an untrained
% mapping), and on the objects that are classified as 'target'
% subsequently the supervised classifier W (also given as an untrained
% mapping). The mapping V now evaluates new objects by first applying
% the one-class classifier, and then the multi-class classifier. Objects
% that are classified as outlier by the first classifier will be labeled
% 'outlier' when the class labels are text strings, or will be labeled
% 'max(getlablist(A))+1' when the class labels are numeric.
%
% A typical example is:
%    a = gendatb;
%    v = ocmcc(a,gauss_dd,ldc);
%
% Objects in A that are labeled 'outlier' will be used in the training of 
% WOCC, but will be ignored in the training of W.
%
% See also: MULTIC, DD_NORMC, DD_EX14

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function W = ocmcc(a,wocc,w)

if nargin < 3 || isempty(w), w = ldc; end
if nargin < 2 || isempty(wocc), wocc = gauss_dd; end
if nargin < 1 || isempty(a) 
	W = mapping(mfilename,{wocc,w});
	W = setname(W,'One-class multiclass');
	return
end

if ismapping(wocc) && ~istrained(wocc)           %training

    % find if there is outlier data present:
    I = strmatch('outlier',getlablist(a));
    if ~isempty(I)
        [outclass,J] = seldat(a,I);
        a(J,:) = [];
        a = remclass(a);
    else
        outclass = [];
    end
    
	[n,k] = size(a);

	% Train the one-class classifier: all data is used for training:
	wocc_tr = gendatoc(+a,outclass)*wocc;
	% Find the (training, non-outlier) objects that are accepted by this classifier:
	I = istarget(a*wocc_tr*labeld);
	% Train on this data the supervised classifier:
	w_tr = a(I,:)*w;

	%and save all useful data:
	ll = getlablist(a);
	if ischar(ll)
		newlablist = strvcat(ll,'outlier');
	else
		newlablist = [ll; max(ll)+1];
	end
	W.wocc = wocc_tr;
	W.w = w_tr;
	W = mapping(mfilename,'trained',W,newlablist,k,size(newlablist,1));
	W = setname(W,'One-class multiclass');

else                               %testing

	% Extract the data:
	W = getdata(wocc);
	m = size(a,1);
	p = size(wocc,2);
	out = zeros(m,p);

	% First find which objects are outliers:
	I = istarget(a*W.wocc*labeld);
	out(~I,p) = 1;
	% Then classify the accepted data:
	out(I,1:(p-1)) = +(a(I,:)*W.w);

	% Store the output:
	W = setdat(a,out,wocc);
end
return


