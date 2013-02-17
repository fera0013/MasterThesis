function [y,z,I] = dd_looxval(x,I)
% Leave-one-out crossvalidation...

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if (nargin<2)
	error('I should be given (although it can be empty).');
end

% Check if the coding vector I is already defined
if ~isempty(I) % is already defined, go for the next fold.
	if (I(5)~=170673)
		error('Sorry, I has not the right format');
	end
	I(2) = I(2) + 1; % goto next fold
	if (I(2)>I(1))
		warning('dd_tools:IllegalFoldNr','Maximal number of folds is extracted');
	end
	% Extract the class priors for Y and Z, but without warning:
	pr = getprior(x,0);
else % Create a vector I to code for the folds
	nrx = size(x,1);
	% now fill the indices:
	I = (1:nrx)';
		
	% Encode the rest:
	I = [zeros(5,1); I];
	I(5) = 170673;  %Magic code;-)
	I(1) = nrx;
	I(2) = 1;      % number of active fold

	% Extract the class priors from X for Y and Z
	% This is the first time, so when the priors are not well-defined in
	% X, give a warning.
	pr = getprior(x);
end

% Extract the correct data given the I:
J = I(6:end);
Itr = find(J~=I(2));
y = x(Itr,:);
z = x((J==I(2)),:);

% One security check:
if nargout<3
	warning('dd_tools:XvalIndexLost',...
		'You probably want to use the index vector I for the next time!');
end

% Useful for inspection purposes, and to avoid too many complains about
% missing priors:
if isdataset(y)
	y = setname(y,[getname(y),' (Xval trn)']);
	z = setname(z,[getname(z),' (Xval tst)']);
	y = setprior(y,pr);
	z = setprior(z,pr);
end


return

