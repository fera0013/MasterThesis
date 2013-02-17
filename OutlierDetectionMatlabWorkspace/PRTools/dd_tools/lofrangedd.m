%LOFRANGEDD Local Outlier Factor data description method.
%  
%   W = LOFRANGEDD(A,FRACREJ,RANGE)
%
% Calculates the Local Outlier Factor data description on dataset A. 
% For each object, the maximum LOF value is calculated over a range.
%
% RANGE is a vector containing the k values. For example: [10:20]
%
% The algorithm is taken from:
%
% Breunig, M.M., Kriegel, H., Ng, R.T., and Sander J., "LOF: Identifying
% Density-Based Local Outliers", 2001
%
% See also: datasets, lofdd, locidd, knndd
%
% Copyright: J.H.M. Janssens, jeroen@jeroenjanssens.com
% TiCC, Tilburg University
% P.O. Box 90153, 5000 LE Tilburg, The Netherlands

function W = lofrangedd(a, fracrej, range)

if((nargin == 3) && ~isempty(a))
    if ((nargin < 3) || isempty(range)),
        range = 1:(size(target_class(a),1)-1);
    elseif ((size(range, 2)) == 1),
        range = range:(size(target_class(a),1)-1);
    end
end

if ((nargin < 3) || isempty(range)), range = 20; end
if ((nargin < 2) || isempty(fracrej)), fracrej = 0.05; end
if ((nargin < 1) || isempty(a)) 
	W = mapping(mfilename,{fracrej,range});
	W = setname(W,sprintf('LOF range:%d', range(1)));
	return
end

if ~ismapping(fracrej)      % training
    a = +target_class(a);
    [m,d] = size(a);
    distmat = sqeucldistm(a,a);
    [sD,I] = sort(distmat,2);
    num_range = size(range,2);
    lofs = zeros(m, num_range);

    % Compute for each object its LOF value for each range
    for index = 1:num_range
        k = range(index);
        w = lofdd(a,fracrej, k, distmat, sD);
        w.data.lof;
        lofs(:,index) = w.data.lof;
        ws(index).w = w;
    end
  
    % Take the maximum LOF value over the range
    fit = max(lofs, [], 2);
    
    thresh = dd_threshold(fit,1-fracrej);
    W.threshold = thresh;
    W.ws = ws;
    W.range = range;
    W = mapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
    W = setname(W,sprintf('LOF range'));
else                      % testing         
    W = getdata(fracrej);  % unpack
    [m,d] = size(a);
    distmat = sqeucldistm(+a,W.ws(1).w.data.x);    %dist between train and test
    [sD,I] = sort(distmat,2);
    range = W.range;
    num_range = size(range,2);
    lofs = zeros(size(a,1), num_range);
    
    % Compute for each object its LOF value for each range
    for index = 1:num_range
        k = range(index);
        w = W.ws(index).w;
        out = lofdd(a, w, k, distmat, sD);
        lofs(:, index) = -out(:,1);
    end
    
    % Take the maximum LOF value over the range
    ind = max(lofs, [], 2);
    
    % store the results in the final dataset:
	out = [ind repmat(W.threshold,[m,1])];
	% Store the distance as output:
	W = setdat(a,-out,fracrej);
	W = setfeatdom(W,{[-inf 0;-inf 0] [-inf 0;-inf 0]});
end
return
