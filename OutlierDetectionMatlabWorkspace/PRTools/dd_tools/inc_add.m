%INC_ADD Add object to a SV*
%
%     W = INC_ADD(W,NEWX,NEWY)
%
% Add object (NEWX,NEWY) to the support vector structure W. Its initial
% weigth alpha is zero, and is updated to find the global optimum again.
%
%     W = INC_ADD(W,[],[],ALREADYADDED)
%
% In some situations the weight for last added object was not optimal
% yet. By setting ALREADYADDED=1, the alpha for the last object is
% optimized to the global optimum.
%
% See also INC_SETUP, INCSVC, INCSVDD, INC_ADD, INC_STORE

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function W = inc_add(W,newx,newy,alreadyadded)

if nargin<4
    alreadyadded = 0;
end

if alreadyadded
    % the new object did not have optimal alpha yet...
    c = size(W.x,1);
    newsetD = (1:c)';
	K = dd_kernel(W.x(c,:),W.x(newsetD,:),W.ktype,W.kpar);
    switch W.type
        case 'svdd'
            Kc = 2*(W.y(c)*W.y(newsetD)').*K;
        case 'svc'
            Kc = (W.y(c)*W.y(newsetD)').*K;
    end
    
else
    % Add the object to the structure:
    W.x = [W.x; newx];
    W.y = [W.y; newy];
    W.alf = [W.alf; 0];
    c = size(W.x,1);
    newsetD = (1:c)';
	K = dd_kernel(newx,W.x(newsetD,:),W.ktype,W.kpar);
    % Now the gradient of this object:
    switch W.type
        case 'svdd'
            Kc = 2*(W.y(c)*W.y(newsetD)').*K;
            W.grad(c,1) = W.y(c)*W.b - W.y(c)*Kc(c)/2;
        case 'svc'
            Kc = (W.y(c)*W.y(newsetD)').*K;
            W.grad(c,1) = W.y(c)*W.b - 1;
    end
    if ~isempty(W.setS)
        W.grad(c,1) = W.grad(c,1) + Kc(W.setS)*W.alf(W.setS);
    end
    if ~isempty(W.setE)
        W.grad(c,1) = W.grad(c,1) + Kc(W.setE)*W.alf(W.setE);
    end
end

if W.grad(c)>0
    % Object is already correct, so leave it in R.
    dd_message(7,'\tObj %d to rest.\n',c);
    if isempty(W.setR)
        W.setR = c;
        W.Kr = Kc(W.setS);
    else
        W.setR = [W.setR; c];
        W.Kr = [W.Kr; Kc(W.setS)];
    end
else
    
    %Now we have to work
    lastSVbecame0 = [];
    done = 0;
    while ~done
        
        % compute the beta and gamma:
        beta = -W.R*[W.y(c); Kc(W.setS)'];
        gamma = Kc';
        if isempty(W.setS)
 			% here something fishy is going on: there is just a single
			% object added. Then we cannot freely move alf, and we can only
			% move b. In this case, b is moved until alf(c) enters setS
			% (that means, the gradient becomes 0).
            gamma = W.y(c)*W.y(newsetD);
            duptonow = W.y(c)*W.b;
        else
            if ~isempty(W.setE)
                gamma(W.setE) = gamma(W.setE) + [W.y(W.setE) W.Ke]*beta;
            end
            if ~isempty(W.setR)
                gamma(W.setR) = gamma(W.setR) + [W.y(W.setR) W.Kr]*beta;
            end
            gamma(c) = gamma(c) + [W.y(c) Kc(W.setS)]*beta;
            gamma(W.setS) = 0;
            duptonow = W.alf(c);
        end
        
        % (1) check upper bound of new object
        if isempty(W.setS)
            deltaAcisC = inf; %because we're moving b, not alf
        else
            deltaAcisC = W.C((3-W.y(c))/2);
        end
        % (2) check own gradient is zero
        %s = warning('off');
        deltaGcis0 = duptonow - W.grad(c)./gamma(c);
        %warning(s);
        deltaGcis0(deltaGcis0<duptonow) = inf; %obj moving the wrong way
        % (3) check upperbounds of SVs
        deltaupperC = inf;
        if ~isempty(W.setS)
			thisC = W.C((3-W.y(W.setS))/2);
            deltaupperC = duptonow + (thisC(:)-W.alf(W.setS))./beta(2:end);
            deltaupperC(deltaupperC<duptonow) = inf;
            deltaupperC(beta(2:end)<=0) = inf;
            [deltaupperC,nrS_up] = min(deltaupperC);
        end
        % (4) check lower bounds of SVs
        deltalowerC = inf;
        if ~isempty(W.setS)
            deltalowerC = duptonow + -W.alf(W.setS)./beta(2:end);
            deltalowerC(deltalowerC<=duptonow) = inf;
            %deltalowerC(beta(2:end)>-W.tol) = inf;
            deltalowerC(beta(2:end)>=0) = inf;
            [deltalowerC,nrS_low] = min(deltalowerC);
        end
        % (5) check E gradients to become 0
        deltaGeis0 = inf;
        if ~isempty(W.setE)
            %s = warning('off');
            deltaGeis0 = duptonow - W.grad(W.setE)./gamma(W.setE);
            %warning(s);
            deltaGeis0(deltaGeis0<=duptonow) = inf;
            deltaGeis0(gamma(W.setE)<=0) = inf;
            [deltaGeis0,nrE_0] = min(deltaGeis0);
        end
        % (6) check R gradients become 0
        deltaGris0 = inf;
        if ~isempty(W.setR)
            %s = warning('off');
            deltaGris0 = duptonow - W.grad(W.setR)./gamma(W.setR);
            %warning(s);
            deltaGris0(deltaGris0<=duptonow) = inf;
            deltaGris0(gamma(W.setR)>=0) = inf;
            %DXD: (1*) avoid endless looping:
            if ~isempty(lastSVbecame0)
                I = find(W.setR==lastSVbecame0);
                if ~isempty(I)
                    %disp('BOEM');
                    deltaGris0(I) = inf;
                end
            end
            [deltaGris0,nrG_0] = min(deltaGris0);
        end
        
        % which is the most urgent?
        deltas = [deltaAcisC; deltaGcis0; deltaupperC; deltalowerC; ...
            deltaGeis0; deltaGris0];
        [mindelta,situation] = min(deltas);
        dd_message(7,'\tObj %d: Situation %d (delta=%f)\n',c,situation,mindelta);

        % DXD (2*) avoid endless looping (see (1*)):
        if (situation==4)
            lastSVbecame0 = W.setS(nrS_low);
        else
            lastSVbecame0 = [];
        end

		% do we get a feasible solution?
        if ~isfinite(mindelta)
            ME = MException('inc:InfeasibleSolution','Infeasible solution');
            throw(ME);
        end
		% should we check if the stepsize is reasonably larger than
		% zero?
		if (abs(mindelta)<10*eps)
			done = 1;
			break
		end
        
        %update the parameters
        if isempty(W.setS) % we only change b:
            W.b = W.y(c)*mindelta;
        else
            W.alf(c) = mindelta;
            W.alf(W.setS) = W.alf(W.setS) + (mindelta-duptonow)*beta(2:end);
            W.b = W.b + (mindelta-duptonow)*beta(1);
        end
        W.grad = W.grad + (mindelta-duptonow)*gamma;
        
        % check:
        I = find(W.alf<0);
        if ~isempty(I)
            J = find(W.alf(I)<-W.tol);
            if ~isempty(J)
                dd_message(6,'Some alphas became <0!');
            else
                W.alf(I) = 0;
            end
        end
        
        % update sets
        switch situation
            case 1 % obj c goes to setE: bounded SV
                W.alf(c) = W.C((3-W.y(c))/2);
                % make Ke really empty when it may have size 0xN
                if isempty(W.Ke), W.Ke = []; end 
                W.Ke = [W.Ke; Kc(W.setS)];
                W.setE = [W.setE; c];
                done = 1;
            case 2 % obj c goes to setS: SV
                W.Ks = [W.Ks [W.y(c); Kc(W.setS)'];
                        W.y(c) Kc([W.setS; c])];
                W.Ke = [W.Ke Kc(W.setE)'];
                W.Kr = [W.Kr Kc(W.setR)'];
                if isempty(W.setS) % compute it directly (to avoid inf)
                    W.R = [-Kc(c) W.y(c); W.y(c) 0];
                else
                    W.R = change_R(W.R,+c,beta,gamma(c));
                end
                W.setS = [W.setS; c];
                done = 1;
            case 3 % a support object hits upper bound
                j = W.setS(nrS_up);
                W.alf(j) = W.C((3-W.y(j))/2);        % just to be sure
                if isempty(W.Ke), W.Ke = []; end
                W.Ke = [W.Ke; W.Ks(nrS_up+1,2:end)]; % update Ke
                W.setE = [W.setE; j];                % add to setE
                W.Ks(nrS_up+1,:) = [];               % update all K's
                W.Ks(:,nrS_up+1) = [];
                W.Ke(:,nrS_up) = [];
                if ~isempty(W.Kr), W.Kr(:,nrS_up) = []; end
                W.setS(nrS_up) = [];                 % remove from setS
                W.R = change_R(W.R, -nrS_up,beta,gamma(j));
            case 4 % a support object hits lower bound
                j = W.setS(nrS_low);
                W.alf(j) = 0;
                if isempty(W.Kr), W.Kr = []; end;
                W.Kr = [W.Kr; W.Ks(nrS_low+1,2:end)];
                W.setR = [W.setR; j];
                W.Ks(nrS_low+1,:) = [];
                W.Ks(:,nrS_low+1) = [];
                if ~isempty(W.Ke), W.Ke(:,nrS_low) = []; end;
                if ~isempty(W.Kr), W.Kr(:,nrS_low) = []; end;
                W.setS(nrS_low) = [];
                W.R = change_R(W.R,-nrS_low,beta,gamma(j));
            case 5 % an error becomes a support object
                j = W.setE(nrE_0);
                K = dd_kernel(W.x(j,:),W.x(newsetD,:),W.ktype,W.kpar);
                switch W.type
                    case 'svdd'
                        Kj = 2*(W.y(j)*W.y(newsetD)').*K;
                    case 'svc'
                        Kj = (W.y(j)*W.y(newsetD)').*K;
                end
                betaj = -W.R*[W.y(j); Kj(W.setS)'];
                W.Ks = [W.Ks; W.y(j) Kj(W.setS)];
                W.Kr = [W.Kr Kj(W.setR)'];
                W.Ke = [W.Ke Kj(W.setE)'];
                W.Ke(nrE_0,:) = [];
                if isempty(W.Ke), W.Ke = []; end;
                W.setE(nrE_0) = [];
                if isempty(W.setE), W.setE = []; end
                W.setS = [W.setS; j];
                W.Ks = [W.Ks [W.y(j); Kj(W.setS)']];
                
                if length(betaj)==1
                    W.R = [-Kj(j) W.y(j); W.y(j) 0];
                else
                    gammaj = W.Ks(end,:)*[betaj;1];
                    W.R = change_R(W.R, +j, betaj, gammaj);
                end
            case 6 % another object becomes a support object
                j = W.setR(nrG_0);
                K = dd_kernel(W.x(j,:),W.x(newsetD,:),W.ktype,W.kpar);
                switch W.type
                    case 'svdd'
                        Kj = 2*(W.y(j)*W.y(newsetD)').*K;
                    case 'svc'
                        Kj = (W.y(j)*W.y(newsetD)').*K;
                end
                betaj = -W.R*[W.y(j); Kj(W.setS)'];
                W.Ks = [W.Ks; W.y(j) Kj(W.setS)];
                W.Ks = [W.Ks [W.y(j); Kj([W.setS;j])']];
                W.Ke = [W.Ke Kj(W.setE)'];
                W.Kr = [W.Kr Kj(W.setR)'];
                W.Kr(nrG_0,:) = [];
                W.setS = [W.setS; j];
                W.setR(nrG_0) = [];
                if length(betaj)==1
                    W.R = [-Kj(j) W.y(j); W.y(j) 0];
                else
                    gammaj = W.Ks(end,:)*[betaj;1];
                    W.R = change_R(W.R,+j,betaj,gammaj);
                end
        end
    end
end

        
                
