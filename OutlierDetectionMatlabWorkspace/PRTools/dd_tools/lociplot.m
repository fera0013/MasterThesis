%LOCIPLOT Local Correlation Integral plot
%
%   W = LOCIPLOT(W)
%
% Plots a LOCI plot of LOCI mapping W. 
% The algorithm is taken from:
%
% Papadimitriou, S. and Kitagawa, H. and Gibbons, P.B. and Faloutsos, C., 
% "LOCI: fast outlier detection using the local correlation integral", in 
% Proceedings of the 19th International Conference on Data Engineering, 2003
%
% See also: datasets, locidd
%
% Copyright: J.H.M. Janssens, jeroen@jeroenjanssens.com
% TiCC, Tilburg University
% P.O. Box 90153, 5000 LE Tilburg, The Netherlands

function [ ] = lociplot(W)

n = size(W.data.critical_distances, 1);

figure
hold on;
cs  = ['r', 'b'];
for i = 1:n
    if(W.data.k_sigmas(i) > W.data.threshold)
        c = cs(1);
    else 
        c = cs(2);
    end
    
    stairs(W.data.critical_distances(i,:), W.data.ns(i,:), [':' c], 'linewidth', 2);
    stairs(W.data.critical_distances(i,:), W.data.n_hats(i,:), ['-' c], 'linewidth', 2);
end