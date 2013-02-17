%ABOF_DD Angle-based Outlier factor data description.
% 
%       W = ABOF_DD(A,FRACREJ)
% 
% Use the Angle-based Outlier Factor to find the outliers in a dataset.
% This should work for high dimensional datasets, but it is kind of slow.
% More information in 'Angle-based outlier detection in high-dimensional
% data', H-P Kriegel, M. Schubert, A. Zimek, Proc.14th ACM SIGKDD conf. on
% KDD'08.
%
%
% See also lof_dd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function W = abof_dd(a,fracrej)

if nargin < 2 || isempty(fracrej), fracrej = 0.1; end
if nargin < 1 || isempty(a) 
	W = mapping(mfilename,{fracrej});
	W = setname(W,'ABOF');
	return
end

if ~ismapping(fracrej)           %training

	a = target_class(a);     % only use the target class
	% checks:
    xx = unique(+a,'rows');
    [m,k] = size(xx);
    if (m<3)
        error('I need at least 3 (unique) target objects.');
    end
	% Obtain the threshold on the train data:
    out = zeros(m,1);
    I = find(triu(ones(m-1,m-1),1));
    for i=1:m
        % the difference vectors:
        df = repmat(xx(i,:),m,1)-xx;
        df(i,:) = [];  % do LOO
        % all inner products:
        df2 = df*df';
        % normalise:
        ang = df2./(repmat(diag(df2),1,m-1).*repmat(diag(df2)',m-1,1));
        % and compute the variance:
        out(i) = var(ang(I));
    end
	thr = dd_threshold(out,1-fracrej);

	%and save all useful data:
	W.x = xx;
	W.threshold = thr;
	W.scale = mean(out);
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'ABOF');

else                               %testing

	% Extract the data:
	W = getdata(fracrej);
    n = size(W.x,1);
	m = size(a,1);

	% Compute the abof for all test objects
    out = zeros(m,1);
    I = find(triu(ones(n,n),1));
    for i=1:m
        df = repmat(+a(i,:),n,1) - W.x;
        df2 = df*df';
        ang = df2./(repmat(diag(df2),1,n).*repmat(diag(df2)',n,1));
        out(i) = var(ang(I));
    end
    newout = [out repmat(W.threshold,m,1)];
    
	% Store the output:
	W = setdat(a,newout,fracrej);
	W = setfeatdom(W,{[0 inf; 0 inf] [0 inf; 0 inf]});
end
return


