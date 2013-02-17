function [W] = Wei(hParameter)
%Weierstrass fractal trace

H=hParameter; %FD should be 2-H.
y=5;

for t=1:1000;
    for i=1:100
        W_apu(i,t)=y^(-i*H)*cos(2*3.1416*y^i*t);
    end
    W(t)=sum(W_apu(:,t));
end

