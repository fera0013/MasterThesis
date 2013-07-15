%RandomForest_DD Random Forest data description
%
%     [W,proximity,model] = randomForest_dd(x,fracrej)
%
% - Trains a random forest model on the target training data X
% - Calculates the target class prototype
% - Sets a threshold based on the Euclidean Distances between training
%   objects and prototype
% - Classifies test objects with Euclidean Distance to prototype below the
%   threshold value as target, otherwise as outliers
% Copyright:
% Ralph Fehrer
% University of Freiburg, Germany
% ralphfehrer@web.de
function [W,model] = randomForest_dd(x,fracrej)
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
    %Switch on extra options
    extra_options.proximity=1;
    extra_options.importance = 1;
    extra_options.proximity = 1;
    %Train random forest
    model = classRF_train(X,Y,100,0,extra_options);
    %Calculate class prototype
    prototype = classCenter(X,labels,model.proximity);
    %Calculate euclidean distances between training objects and prototype
    mD = sqeucldistm(+x, prototype);
    %Calculate threshold
	W.threshold = dd_threshold(mD,1-fracrej);
    W.prototype=prototype;
    %Create mapping
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),dim,2);
	W = setname(W,'Random Forest data description');
else
    %unpack
	W = getdata(fracrej); 
	m = size(x,1); 

	% compute the distances netween the test objects and the normal class
	% prototype
	mD = sqeucldistm(+x,W.prototype);
	newout = [mD repmat(W.threshold,m,1)];
	% Store the distance as output
	W = setdat(x,-newout,fracrej);
	W = setfeatdom(W,{[-inf 0; -inf 0] [-inf 0; -inf 0]});
end

return
%References:
%- DDtools, the Data Description Toolbox for Matlab  V 1.9.1
%  Tax, D.M.J.,2012
%  Delft University of Technology
%  http://prlab.tudelft.nl/david-tax/dd_tools.html
%- Classification and Regression by randomForest-matlab,
%  Abhishek Jaiantilal, 2013
%  http://code.google.com/p/randomforest-matlab

