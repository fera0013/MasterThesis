%DD_GRIDSEARCH Parameter optimization of OCCs
%
%     [W,BESTARG] = DD_GRIDSEARCH(A,CLNAME,NRFOLDS,ARGVAL1,ARGVAL2,...)
%
% Optimize classifier with the name CLNAME on dataset A, by varying all
% input arguments of the classifier. The best parameter settings BESTARG
% are estimated using NRFOLDS-cross validation on dataset A, using the
% Area under the ROC curve performance measure (dd_auc). The classifier is
% trained using the optimized BESTARG on all training data A.
% An example would be:
% >> w = dd_gridsearch(a,'svdd',10,[0.1 0.2 0.3],[1 3 5 10]);
%
% Note, the best performance is found by using 'max'. When more than one
% combination of parameter values obtain the best performance, the first
% combination is taken!
%
% It is also possible to define it as a mapping, so you can use it as a
% 'meta-mapping':
% First define the untrained mapping:
% >> u = dd_gridsearch([],'svdd',10,[0.1 0.2 0.3],[1 3 5 10]);
% Train it:
% >> w = a*w;
%
% TODO: This version only supports real-valued input arguments. So no
% string values, or vectors are now acceptable. This should be
% implemented once.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function [w,bestarg,perf] = dd_gridsearch(a,clname,nrfolds,varargin)

% first check if we want to make an untrained mapping:
if isempty(a)
	w = mapping(mfilename,{clname,nrfolds,varargin{:}});
	w = setname(w,['Opt.',clname]);
	return
end

% do some checking:
if ~isa(clname,'char')
	error('The classifier name should be a string.');
end
pars = varargin;

% find first all combinations of parameters:
nrpars = length(pars);
arg = pars{1};
arg = arg(:); % make sure it is a column vector
for i=2:nrpars
	newarg = pars{i};
	newarg = newarg(:)'; % make sure it is a row vector
	n = length(newarg);
	m = size(arg,1);
	newarg = repmat(newarg,m,1);
	arg = [repmat(arg,n,1) newarg(:)];
end
arg = num2cell(arg);

% now run over all combinations (ooph)
nrcomb = size(arg,1);
perf = zeros(nrcomb,nrfolds);
for i = 1:nrcomb
	thisarg = arg(i,:);
	I = nrfolds;
	for j=1:nrfolds
		[x,z,I] = dd_crossval(a,I);
		w = feval(clname,x,thisarg{:});
		perf(i,j) = z*w*dd_auc;
	end
end
% average over the runs:
perf = mean(perf,2);

% and who is the winner?
[mx,I] = max(perf);
% retrain this on all data:
bestarg = arg(I,:);
w = feval(clname,x,bestarg{:});

