function [f,thr] = simpleprc(netout,truelab)

% Check the size of the netout vector
if size(netout,2)~=1
	netout = netout';
	if size(netout,2)~=1
		error('Please make netout a column vector.');
	end
end

% Collect all sizes:
n = size(netout,1);
n_t = sum(truelab);

% Sort the netout:
[sout,I] = sort(-netout);
% and therefore also reorder the true labels accordingly
slab = truelab(I);

% I am not bothered by identical objects now... but it should be here

% slab   1110011101 0001001000000
%    + <-----------+-------------
%TP=     111  111 1
%FP=        11   1
%FN=                   1  1
%
% precision = TP/(TP+FP)
% recall =    TP/(TP+FN)

f = cumsum(slab);
normprec = (1:n)';
prec = f./normprec;
rec = f/n_t;
f = [prec rec];

% On request, also the thresholds are returned:
if nargout>1
	thr = sout;
end

return

