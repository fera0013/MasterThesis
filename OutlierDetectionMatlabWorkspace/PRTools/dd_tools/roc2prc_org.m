function r = roc2prc(r,n)
%ROC2PRC Conversion ROC to precision-recall graph
%
%     P = ROC2PRC(R,N)
%
% Convert ROC curve R into a Precision-Recall graph P.
% This is only possible when you supply the number of positive and
% negative objects in N:
%   N(1): number of positive/target objects
%   N(2): number of negative/outier objects
%
% Although the ROC curve is independent of the class skew, the
% precision-recall is certainly not!
%
% See also: dd_roc, dd_prc, plotroc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if ~isfield(r,'type')
    % just hope it is a valid roc curve... :-(
else
    if ~strcmp(r.type,'roc')
        error('R should be an ROC curve.');
    end
end
if length(n)~=2
	error('I should have a number for each of the classes.');
end

% compute the True Positives and the False Positives from the ROC curve
% and the number of objects in each of the classes:
e = r.err;
TP = (1-e(:,1))*n(1);
FP = e(:,2)*n(2);
Nposout = TP+FP;

% now compute the precision and recall
warning off MATLAB:divideByZero;
	r.err = [TP./Nposout TP/n(1)];
warning on MATLAB:divideByZero;
% take special care when both the precision=0 and recall=0
I = find(Nposout==0);
if ~isempty(I)
	J = find(TP(I)==0);
	if ~isempty(J)
		%r.err(I(J),1) = 1;  % set it to 1??
		r.err(I(J),:) = [];  % remove?
	end
end

% details for a good RPC curve:
r.op = [];
r.type = 'prc';

return
