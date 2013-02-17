%DD_KAPPA Cohen's kappa coefficient
%
%     K = DD_KAPPA(X,W)
%     K = DD_KAPPA(X*W)
%     K = X*W*DD_KAPPA
%
% Compute Cohen's kappa coefficient to compare the predictions by
% classifier W to the true labels in dataset X. The kappa coefficient
% is defined as:
%     K = (P(agree) - P(rand))/(1-P(rand))
% where P(agree) is the probability that the prediction agrees with the
% true label, and P(rand) is the probability that *by change* the true
% and predicted label agree.
%
% See also: dd_error, dd_roc, gendatoc, plotroc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function k = dd_kappa(x,w)

% Do it the same as testc:
% When no input arguments are given, we just return an empty mapping:

if nargin==0
	
	% Sometimes Prtools is crazy, but fun!:
	k = mapping(mfilename,'fixed');
	return

elseif nargin == 1
	% Now we are doing the actual work:

	% get the true and predicted labels:
	truelab = getlab(x);
	predlab = x*labeld;

	% now match them:
	[n1,n2,ll] = renumlab(truelab,predlab);
	% and which do agree...?
	P_agr = mean(n1==n2);
	% what is the chance that they would agree anyway?
	c = size(ll,1);
	for i=1:c
		n(i,1) = sum(n1==i);
		n(i,2) = sum(n2==i);
	end
	n = n/size(x,1); %normalize
	P_err = sum(prod(n,2));

	% so the kappa becomes:
	k = (P_agr-P_err)/(1-P_err);

else

	ismapping(w);
	istrained(w);

	k = feval(mfilename,x*w);

end

return
