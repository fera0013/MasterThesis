%GENDATKRIEGEL
%
%     x = gendatkriegel(nr,dim,k)
%
% Generate target data from a 5-cluster Mixture of Gaussians. This is
% according to the paper 'Angle-based outlier detection in high-dimensional
% data', KDD'08. It requires the moghmm toolbox.

function x = gendatkriegel(nr,dim,k)

if nargin<3
    k = 5;
end
if nargin<2
    dim = 25;
end
if nargin<1
    nr = 500;
end
if length(nr)<2
    nr(2) = 10;
end

% target objects from Mixture of Gaussians:
mog.prior = repmat(1/k,k,1);
mog.mean = randn(k,dim);
s = randn(k,1)/3;
s = s.*s; % magic to invent variances
s = repmat(1./s,1,dim);
for i=1:k
    mog.icov(i,:,:) = diag(s(i,:));
end
x = gendatmog(nr(1),mog);
% outlier objects uniformly distributed in a sphere:
R = 2*sqrt(dim);  % radius of the sphere
z = R*randsph(nr(2),dim);
% final dataset:
x = gendatoc(x,z);
