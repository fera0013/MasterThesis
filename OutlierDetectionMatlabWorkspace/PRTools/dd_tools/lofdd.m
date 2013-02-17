%LOFDD Local Outlier Factor data description method.
%  
%   W = LOFDD(A,FRACREJ,K)
%
% Calculates the Local Outlier Factor data description on dataset A.
% The algorithm is taken from:
%
% Breunig, M.M., Kriegel, H., Ng, R.T., and Sander J., "LOF: Identifying
% Density-Based Local Outliers", ACM SIMOD Record, 2000
%
% See also: datasets, lofrangedd, locidd, knndd
%
% Copyright: J.H.M. Janssens, jeroen@jeroenjanssens.com
% TiCC, Tilburg University
% P.O. Box 90153, 5000 LE Tilburg, The Netherlands

function W = lofdd(a, fracrej, k, distmat, sD)
%distmat and sD are optional parameters and are mainly used by lofrangedd

if (nargin < 5)
   distmat = [];
   sD = [];
end

if nargin < 3 || isempty(k), k = 3; end
if nargin < 2 || isempty(fracrej), fracrej = 0.05; end
if nargin < 1 || isempty(a) % empty lofdd
	W = mapping(mfilename,{fracrej,k});
	W = setname(W,sprintf('LOF k:%d', k));
	return
end

if ~ismapping(fracrej)           %training

	% some checking of datatypes and sizes:
	a = +target_class(a);  % make sure we have a OneClass dataset
	[m,d] = size(a);
    if (m<2)
        warning('dd_tools:InsufficientData','Dataset contains less than 2 objects');
    end
    if (k>=m)
        error(['More neighbors than training samples are requested! (max=',num2str(m-1),')']);
    end
    if isa(k,'char')
        error('Argument k should define the number of neighbors');
    end
    if (k<1)
		warning('dd_tools:KNegativeK','K must be positive (>0)');
    end
    
    if(isempty(distmat) || isempty(sD))
        % calculate the euclidian distance matrix
        distmat = sqrt(sqeucldistm(a,a));
        % sort the distances
        [sD,I] = sort(distmat,2);
    end
    
        % compute the LOF values of the training samples:

        % k-distance of each object (k+1 because the first object is
        % the object itself, and is not considered to be part of the
        % neighborhood
        k_distance = sD(:,k+1);

        % construct the neighborhood matrix
        k_distance_neighborhood = zeros(m,m);
        for p = 1:m    
            k_distance_neighborhood(p,:) = logical(distmat(p,:) <= k_distance(p));
            k_distance_neighborhood(p,p) = 0;
        end

        k_distance_neighborhood_size = sum(k_distance_neighborhood,2);

        % compute reachability distances
        % please note that this distance is not symmetric
        reachability_distance = zeros(m,m);
        for p = 1:m
            for o = 1:m
                reachability_distance(p,o) = max(k_distance(o), distmat(p,o));
            end
        end

        % compute local reachability density
        local_reachability_density = zeros(m,1);
        for p = 1:m      
            local_reachability_density(p) = 1 ./ (1e-10+(sum(reachability_distance(p,logical(k_distance_neighborhood(p,:))) / k_distance_neighborhood_size(p))));
        end

        % compute the local outlier factor
        lof = zeros(m,1);
        for p = 1:m
           lof(p) = sum(local_reachability_density(logical(k_distance_neighborhood(p,:))) / local_reachability_density(p)) / k_distance_neighborhood_size(p);
        end
    
    fit = lof;    
    
	%now obtain the threshold:
	thresh = dd_threshold(fit,1-fracrej);
	%and save all useful data:
    W.distmat = distmat;
    W.sD = sD;
    W.k_distance = k_distance;
    W.local_reachability_density = local_reachability_density;
    W.lof = lof;
    
	W.x = +a;
	W.k = k;
	W.threshold = thresh;
	W.scale = mean(fit);
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
	W = setname(W,sprintf('LOF k:%d', k));

else                               %testing

	W = getdata(fracrej);  % unpack
    %m is the number of test objects
	[m,d] = size(a);
    [n,d] = size(W.x);
    
	% calculate the euclidean distance matrix
    if(isempty(distmat) || isempty(sD))
        distmat = sqrt(sqeucldistm(+a,W.x));    %dist between train and test
        [sD,I] = sort(distmat,2);
    end
    
    new_train_distmat = zeros(n+1,n+1);
    new_train_distmat(1:n,1:n) = W.distmat; 
    % compute the LOF values of the test samples:

        % k-distance of each object
        % no k+1 this time because the distance to the test object itself
        % is not present in the distance matrix
        k_distance = sD(:,W.k);

        % construct the neighborhood matrix
        k_distance_neighborhood = zeros(m,n);
        for p = 1:m
            k_distance_neighborhood(p,:) = logical(distmat(p,:) <= k_distance(p));
        end
        
        %compute the lof value for each object p:

        % add object p to the distance matrix of the training objects
        % p is the last object
        lof = zeros(m,1);
        for p = 1:m
            new_train_distmat(n+1,1:n) = distmat(p,:);
            new_train_distmat(1:n,n+1) = distmat(p,:)';
            
            [new_train_sD, I] = sort(new_train_distmat, 2);       
            new_train_k_distance = new_train_sD(:,W.k+1);
      
            %loop through the neighbors of p:
            neighbors_of_p = [n+1, find(logical(k_distance_neighborhood(p,:)))];
           
            lrd_of_nn_of_p = zeros(numel(neighbors_of_p), 1);
            
            sum_lrd_fraction = 0;
            nn_index = 0;
            for nn = neighbors_of_p
                nn_index = nn_index + 1;
                
                %determine neighbors of nn (which is a neighbor p)
                neighbors_of_neighbors_of_p = logical(new_train_distmat(nn,:) <= new_train_k_distance(nn));
                neighbors_of_neighbors_of_p(nn) = 0;
                
                sum_reach_dist = 0;
                num_nn_nn = 0;
                for nn_nn = find(neighbors_of_neighbors_of_p)
                    num_nn_nn = num_nn_nn + 1;
                    sum_reach_dist = sum_reach_dist + max(new_train_k_distance(nn_nn), new_train_distmat(nn, nn_nn));
                end
                
                lrd = 1 / ((sum_reach_dist + 1e-10) / num_nn_nn);
                
                lrd_of_nn_of_p(nn_index) = lrd;
                if(nn_index > 1),
                    sum_lrd_fraction = sum_lrd_fraction + (lrd / lrd_of_nn_of_p(1));
                end
            end
          
            lof(p) = sum_lrd_fraction / (nn_index-1);
            
        end    

    ind = lof;
    
	% store the results in the final dataset:
	out = [ind repmat(W.threshold,[m,1])];
	% Store the distance as output:
	W = setdat(a,-out,fracrej);
	W = setfeatdom(W,{[-inf 0;-inf 0] [-inf 0; -inf 0]});
end
return
