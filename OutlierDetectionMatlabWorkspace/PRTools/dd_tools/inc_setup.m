%INC_SETUP Startup incremental optimization
%
%   W = INC_SETUP(ITYPE,KTYPE,KPAR,C,X,Y)
%
% Setup the data structure for the incremental optimization of a support
% vector something.
%
% See also  INCSVDD, INCSVC, INC_ADD, INC_STORE
function W = inc_setup(itype,ktype,kpar,C,x,y)

W.type = itype;
W.ktype = ktype;
W.kpar = kpar;
W.C = C;
W.tol = 1e-12;
W.alf = zeros(0,1);
W.b = 0;
W.grad = [];
W.R = [];
W.setR = [];
W.setS = [];
W.setE = [];
W.Kr = [];
W.Ks = 0;
W.Ke = [];

switch itype
    case 'svdd'
        N = ceil(1/C(1));  %DXD is this good?
        N = max(N,1); %less than one does not make sense...
        % find N target objects to add first:
        It = find(y==1);
        if (length(It)<N)
            error('Not enough target objects available.');
        end
        dd_message(7,'Start with the first %d objects.\n',N);
        W.x = x(It(1:N),:);
        W.y = ones(N,1);
        % we are left with these (x,y)
        x(It(1:N),:) = [];
        y(It(1:N),:) = [];
        if (W.C(1)>=1)  % the 'hard' svdd, one obj. becomes SV:
            W.setS = 1;
			K = dd_kernel(W.x(1,:),W.x(1,:),W.ktype,W.kpar);
            W.Ks = [0 W.y(1); W.y(1) 2*K];
            W.alf = 1;
            W.b = -W.Ks(2,2)/2;
            W.grad = 0;
            W.R = inv(W.Ks);
        else % the 'soft' svdd, more than one SV:
            if abs(1-N*W.C(1))<eps, % very rare situation, troublesome:
                W.C(1) = W.C(1)+10*eps;
            end
            set0 = (1:N)';
            W.alf(set0,1) = [repmat(W.C(1),N-1,1); 1-(N-1)*W.C(1)];
			K = dd_kernel(W.x(set0,:),W.x(set0,:),W.ktype,W.kpar);
            W.grad = 2*K*W.alf(set0) - diag(K);
            W.b = -max(W.grad(1:(end-1))) - W.tol;
            W.grad = W.grad + W.b.*W.y(set0);
            W.setE = (1:N-1)';
            W.Ks = 0;
            W.R = inf;            
            W = inc_add(W,[],[],1);
        end
    case 'svc'
        W.R = inf;
        W.x = [];
        W.y = [];
        W.alf = [];
    otherwise
        error('Not implemented yet.');
end

try
    for i=1:size(x,1)
        dd_message(7,'ADD object %d\n',i);
        W = inc_add(W,x(i,:),y(i,:));
    end
catch ME
    if strcmp(ME.identifier,'inc:InfeasibleSolution') || ...
            strcmp(ME.identifier,'dd_tools:change_R:DivideByZero')
        warning('inc:inc_setup','Incremental SV: Infeasible solution.');
        W = [];
    else
        rethrow(ME);
    end
end

