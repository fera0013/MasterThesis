%LOCIDD Local Correlation Integral data description method.
%
%   W = LOCIDD(A,FRACREJ,ALPHA,FORCED_THRESHOLD,MIN_N)
%
% Calculates the Local Correlation Integral data description on dataset A. 
% The algorithm is taken from:
%
% Papadimitriou, S. and Kitagawa, H. and Gibbons, P.B. and Faloutsos, C., 
% "LOCI: fast outlier detection using the local correlation integral", in 
% Proceedings of the 19th International Conference on Data Engineering, 2003
%
% See also: datasets, lofdd, knndd
%
% Copyright: J.H.M. Janssens, jeroen@jeroenjanssens.com
% TiCC, Tilburg University
% P.O. Box 90153, 5000 LE Tilburg, The Netherlands

function W = locidd(a, fracrej, alpha, forced_threshold, min_n)

if (nargin < 5), min_n = 20; end
if (nargin < 4), forced_threshold = []; end
if (nargin < 3), alpha = 0.5; end
if ((nargin < 2) || isempty(fracrej)), fracrej = 0.05; end
if ((nargin < 1) || isempty(a))
    W = mapping(mfilename,{fracrej, alpha, forced_threshold, min_n});
    W = setname(W,sprintf('LOCI a:%1.2f, min_n:%d', alpha, min_n));
    return
end

if ~ismapping(fracrej)          % training
    
    % Extract the target-class from dataset a:
    a = +target_class(a);  
    % m = number of objects
    % d = number of dimensions
    [m,d] = size(a);
    
    if(m < 2)
        warning('dd_tools:InsufficientData','Dataset contains less than 2 objects');
    end

    % Calculate the Euclidian distance matrix and sort it per object
    distmat = sqrt(sqeucldistm(a,a));
    [sD,I] = sort(distmat,2);
        
    % Each object p has a different set of (alpha) critical distances:
    critical_distances = sort([sD sD/alpha],2);
    num_critical_distances = size(critical_distances,2);

    % Determine for each critical distance which object should be updated:
    [all_critical_distances, ind_all_cd] = sort(critical_distances(:));
    [objects_i, objects_j] = ind2sub(size(critical_distances), ind_all_cd);
    duplicate_cd = [logical(diff(all_critical_distances)==0); 0];
    duplicate_ind = find(duplicate_cd == 0);
    duplicate_ind_i = 1;
    
    % Allocate matrices for the n, nhat, and MDEF value for each
    % object p, at each critical distance, so that later, a LOCI plot
    % can be created using this mapping:
    ns = zeros(m, num_critical_distances);
    n_hats = zeros(m, num_critical_distances);
    mdefs = zeros(m, num_critical_distances);
    
    % The threshold is determined using the k_sigma value of each object:
    k_sigmas = zeros(m, 1);

    % Because we increase the range of the neighborhoods, we keep track of
    % each object what its current couting- and sampling-neighborhood is.
    critical_distance_index = zeros(m,1);
    current_alpha_neighborhood_size = zeros(m, 1);
    current_neighborhood = zeros(m,m);

    % Global critical distance index (to be used with the
    % all_critical_distances vector):
    cdi = 1;

    % Loop through all the critical distances
    % We use a while loop so that we can skip duplicates
    %disp('Calculating mdefs for all critical distances...');
    while(cdi < size(all_critical_distances,1)+1)
        
        % Retrieve the actual range and alpha range:
        r = all_critical_distances(cdi);
        alpha_r = alpha * r;

        % Are there duplicates of this critical distance?
        to_cdi = duplicate_ind(duplicate_ind_i);
        duplicate_ind_i = duplicate_ind_i + 1;
        
        % Which objects have this as a critical distance?
        % (usually two)
        objects = objects_i(cdi:to_cdi);
        
        % When an object has this critical distance more than once (when
        % there are two other objects with the same distance to it), we
        % increase their critical distance index with more than one:
        x = sort(objects(:));
        difference = diff([x;max(x)+1]);
        count = diff(find([1;difference]));
        objects_to_update = x(logical(difference));
        critical_distance_index(objects_to_update) = critical_distance_index(objects_to_update) + count;
        % objects_to_update now contains only unique objects
        
        % We need to update their neighborhoods first because they might
        % influence each other with respect to MDEF and k_sigma etc (see below).
        % Also note that LOCI distinguishes between a sampling (alpha)
        % neighborhood and a counting neighborhood. That's why we have both
        % r and alpha_r.
        for object = objects_to_update'
            % Update the alpha neighborhood size:
            current_alpha_neighborhood_size(object) = size(find(sD(object,:) <= alpha_r),2);
            % Update the couting neighborhood matrix:
            current_neighborhood(object,:) = logical(distmat(object,:) <= r);
        end

        % Loop again over these objects to compute the MDEF and k_sigma
        % values:
        i = 0;
        for object = objects_to_update'
            % n = sampling neighborhood count:
            n = current_alpha_neighborhood_size(object);
            % n_hat = mean of sampling neighborhood count of the neighbors
            % within the counting neighborhood:
            n_of_r_neighbors = current_alpha_neighborhood_size(logical(current_neighborhood(object,:)));
            n_hat = mean(n_of_r_neighbors);
            % MDEF = multi-granularity deviation factor:
            mdef = 1 - (n / n_hat);

            % Standard deviation of alpha-neighborhood size of r-neighbors:
            % (with 1e-10 we suppress the divide by zero warning)
            sample_size = sum(current_neighborhood(object,:));
            std_n_of_r_neighbors = sqrt(mean((n_of_r_neighbors - n_hat).^2)) + 1e-10;
            normalized_deviation = std_n_of_r_neighbors / n_hat;
            k_sigma = mdef / normalized_deviation;

            % Get the critical distance indices of this object for which
            % we are updating. Again, equal to the number of duplicate
            % critical distances r:
            i = i +1;
            indices_to_update = critical_distance_index(object)-(count(i)-1):critical_distance_index(object);

            % Update the matrices:
            ns(object, indices_to_update) = n;
            n_hats(object, indices_to_update) = n_hat;
            mdefs(object, indices_to_update) = mdef;

            % For stability (see article, min_n is 20 by default)
            
            if(sample_size >= min_n)
                k_sigmas(object) = max(k_sigmas(object), k_sigma);
            end
        end

        % Go to the next critical distance (which isn't a duplicate of the current one)
        cdi = to_cdi + 1;
    end

    % In the LOCI article, the threshold k_sigma is set to 3.
    % If you which to force this, then you need to specify it as a
    % paramater. Otherwise it is computed like all other data description
    % methods.
    if((isempty(forced_threshold)) || (forced_threshold == -1))
        threshold = dd_threshold(k_sigmas, 1-fracrej);
    else
        threshold = forced_threshold;
    end
    
    % Save all useful data:
    W.x = +a;
    W.alpha = alpha;
    % Include the matrices ns, n_hats, and mdefs so that later, a LOCI plot
    % can be created.
    W.distmat = distmat;
    W.critical_distances = critical_distances;
    W.ns = ns;
    W.n_hats = n_hats;
    W.mdefs = mdefs;
    W.k_sigmas = k_sigmas;

    W.threshold = threshold;
    W.scale = mean(k_sigmas);
    W = mapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
    W = setname(W,sprintf('LOCI a:%1.2f, min_n:%d', alpha, min_n));

else            % testing

    % Get the data from the training phase:
    W = getdata(fracrej);
    alpha = W.alpha;
    
    % m = number of test objects, mt = number of training objects, d = number of dimensions
    [m,d] = size(a);
    [mt,d] = size(W.x);

    k_sigmas = zeros(m,1);
    
    % Calculate the Euclidian distance matrix.
    % This now contains the distances between the test and training
    % objects:
    distmat = sqrt(sqeucldistm(+a,W.x));       

    % Each test object has a different set of (alpha) critical distances:
    critical_distances = sort([zeros(m,1) distmat distmat/alpha],2);
    
    
    % Determine for each critical distance which test object should be updated:
    [all_critical_distances, ind_all_cd] = sort(critical_distances(:));
    [objects_i, objects_j] = ind2sub(size(critical_distances), ind_all_cd);
    duplicate_cd = [logical(diff(all_critical_distances) == 0); 0];
    duplicate_ind = find(duplicate_cd == 0);
    duplicate_ind_i = 1;
    num_all_critical_distances = size(all_critical_distances,1);
    
    
    % Retrieve the critical distances of the training objects
    train_critical_distances = [W.critical_distances (Inf * ones(mt,1))];
    % And their sampling (alpha) neighborhood sizes for those critical
    % distances:
    train_ns = W.ns;
    % Maintain an index so that the current alpha neighborhood size does
    % not have to computed over and over again
    train_current_critical_distance_index = ones(mt, 1);
    train_current_alpha_neighborhood_size = ones(mt, 1);
    %train_current_critical_distance = train_critical_distances(:, 1);
    train_next_critical_distance = train_critical_distances(:, 2);
    size_train_critical_distances = size(train_critical_distances);
    
   
    % Global critical distance index (to be used with the
    % all_critical_distances vector):
    cdi = 1;

    % Loop through all the critical distances
    % We use a while loop so that we can skip duplicates
    while(cdi <= num_all_critical_distances)
               
        r = all_critical_distances(cdi);
        alpha_r = alpha * r;

        update_indices = (r > train_next_critical_distance);
        
        % Update the neighborhood sizes of the objects
        while(sum(update_indices) > 0)
            train_current_critical_distance_index = train_current_critical_distance_index + update_indices;
            train_current_alpha_neighborhood_size = train_ns(sub2ind(size_train_critical_distances, 1:mt, (train_current_critical_distance_index)'))';
            train_next_critical_distance = train_critical_distances(sub2ind(size_train_critical_distances, 1:mt, (1+train_current_critical_distance_index)'))';
            update_indices = (r > train_next_critical_distance);    
        end

        to_cdi = duplicate_ind(duplicate_ind_i);
        duplicate_ind_i = duplicate_ind_i + 1;
        objects = objects_i(cdi:to_cdi);
        
        if(length(objects) > 1)
            x = sort(objects(:));
            difference = diff([x;max(x)+1]);
            objects_to_update = x(logical(difference))';
        else
            objects_to_update = objects;
        end
        
        for object = objects_to_update
            
            n = 1 + size(find(distmat(object,:) <= alpha_r),2);         
            r_neighbors = logical(distmat(object,:) <= r);           
            n_of_r_neighbors = [n ; (train_current_alpha_neighborhood_size(logical(r_neighbors)) + (distmat(object,logical(r_neighbors)) <= alpha_r)')];            
            n_hat = mean(n_of_r_neighbors);
            mdef = 1 - (n / n_hat);

            %with 1e-10 we suppress the divide by zero warning
            std_n_of_r_neighbors = sqrt(mean((n_of_r_neighbors - n_hat).^2)) + 1e-10;
            normalized_deviation = std_n_of_r_neighbors / n_hat;
            k_sigma = mdef / normalized_deviation;
            
            sample_size = sum(r_neighbors) + 1;
            if(sample_size >= min_n)
                k_sigmas(object) = max(k_sigmas(object), k_sigma);
            end
            
        end
        
        %go to the next critical distance
        cdi = to_cdi + 1;
        
    end

    % store the results in the final dataset:
    out = [k_sigmas repmat(W.threshold,[m,1])];
    % Store the distance as output:
    W = setdat(a,-out,fracrej);
    W = setfeatdom(W,{[-inf 0;-inf 0] [-inf 0;-inf 0]});
end
return
