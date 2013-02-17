function xmk=hfdxmk(x,kmax)
% Function to compute new time serieses for Higuchi FD estimation - just compute the series and plot them
% INPUT: x - time series for which HFD is to be estimated; kmax - maximum value of k
% OUTPUT: xmk - new time serieses

if ~exist('kmax','var')||isempty(kmax),
    kmax=5;
end;

N=length(x);

xmk=cell(1,kmax);
for k=1:kmax,
    xmki=[];
    for m=1:k,
        for i=0:fix((N-m)/k),
            xmki=[xmki,x(m+i*k)];
        end;
    end;
    xmk{1,k}=xmki;
end;

% Reference:
% 1. T. Higuchi (1998), Approach to an irregular time series on the basis of the fractal theory, Physica D, 277-283
% 2. C E Polychronaki et al (2010), Comparison of fractal dimension
% estimation algorithms for epileptic seizure onset detection, J. Neural Eng. 7 (2010) 046007 (18pp)
% Copyright(!!!): V Salai Selvam, Tamil Nadu, India email:
% vsalaiselvam@yahoo.com