function [varargout]=hfd(x,kmax)
% INPUT: x - time series for HFD is to be estimated; kmax - maximum value of k
% OUTPUT: xhfd - HFD of x; lnk - ln(1/k); lnLk - ln(L(k)) log of average curve length, L; Lmk - all values of curve length, L

if ~exist('kmax','var')||isempty(kmax),
    kmax=5;
end;

N=length(x);

Lmk=zeros(kmax,kmax);
for k=1:kmax,
    for m=1:k,
        Lmki=0;
        for i=1:fix((N-m)/k),
            Lmki=Lmki+abs(x(m+i*k)-x(m+(i-1)*k));
        end;
        Ng=(N-1)/(fix((N-m)/k)*k);
        Lmk(m,k)=(Lmki*Ng)/k;%Here is the problem in the code by Mr. Tikkuhirvi & Mr. Aino
    end;
end;

Lk=zeros(1,kmax);
for k=1:kmax,
    Lk(1,k)=sum(Lmk(1:k,k))/k;
end;

lnLk=log(Lk);
lnk=log(1./[1:kmax]);

b=polyfit(lnk,lnLk,1);
xhfd=b(1);

varargout={xhfd,lnk,lnLk,Lk,Lmk};

% Reference:
% 1. T. Higuchi (1998), Approach to an irregular time series on the basis of the fractal theory, Physica D, 277-283
% 2. C E Polychronaki et al (2010), Comparison of fractal dimension
% estimation algorithms for epileptic seizure onset detection, J. Neural Eng. 7 (2010) 046007 (18pp)
% Copyright(!!!): V Salai Selvam, Tamil Nadu, India email:
% vsalaiselvam@yahoo.com

%Note: Noise affects HFD