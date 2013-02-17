%NNDIST (Average) nearest neighbor distance
%
%      D = NNDIST(A,K)
%
% Compute the averaged K-nearest neighbor distance of dataset (or data
% matrix) A. 
%
%      D = NNDIST(A,K,N)
%
% To reduce the computational load, subsample only N objects from A.
%
% Default: K=5, N=500
function d = nndist(a,k,n)
if nargin<3
	n = 500;
end
if nargin<2 | isempty(k)
	k = 5;
end

m = size(a,1);
if m>n % we have enough data: subsample
	I = randperm(m);
	a = a(I(1:n),:);
else
	n = m;
end
% check k:
if k>n
	error('Please make k<(n=%d).',n);
end
% compute squared distance, and the average k-NN distance:
D = sqeucldistm(+a,+a);
sD = sort(D);
d = mean(sqrt(sD(k+1,:))); % use k+1, because first element is always 0

