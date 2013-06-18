%SOM_DD Self-Organizing Map data description
%
%           W =  SOM_DD(X,FRACREJ,K)
%
% Train a 2D SOM on dataset X. In K the size of the map is defined. The
% map can maximally be 2D. When K contains just a single value, it is
% assumed that a 1D map should be trained.
%
% For further features of SOM_DD, see som.m (the same parameters
% NRRUNS, ETA and H can be added).
%
% Default: K=[5 5]
%
% See also: pca_dd, kmeans_dd, som

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function W = randomForest_dd(x,fracrej)
if nargin < 2 
    fracrej = 0.05; 
end
if nargin < 1 || isempty(x) 
	W = mapping(mfilename,{fracrej,k,nrruns,eta,h});
	W = setname(W,'Self-organising Map data description');
	return
end

if ~ismapping(fracrej)           %training

	X = target_class(x);     % only use the target class
	[nrx,dim] = size(x);
    Y = [];
    X=getdata(X);
    labels=repmat(1,1,size(X,1));
    extra_options.proximity=1;
    model = classRF_train(X,Y,100,0,extra_options);
    prototype = classCenter(X,labels,model.proximity);
	% Now, all the work is being done by som.m:
	w = getdata(w);
	% Now map the training data:
	mD = min(sqeucldistm(+x,w.neurons),[],2);
	thresh = dd_threshold(mD,1-fracrej);

	% And save all useful data:
	V.threshold = thresh;  % a threshold should always be defined
	V.k = w.k;  %(only for plotting...)
	V.neurons = w.neurons;
	W = mapping(mfilename,'trained',V,str2mat('target','outlier'),dim,2);
	W = setname(W,'Self-organising Map data description');
else
    
	W = getdata(fracrej); %unpack
	m = size(x,1); 

	% compute the distance to the nearest neuron in the map:
	mD = min(sqeucldistm(+x,W.neurons),[],2);
	newout = [mD repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(x,-newout,fracrej);
	W = setfeatdom(W,{[-inf 0; -inf 0] [-inf 0; -inf 0]});
end

return


