%CHULL_DD Convex hull data description
%
%  W = CHULL_DD(X,FRACREJ,C)
%
% Define a convex hull around data X. To test objects if they are inside
% the hull, a linear support vector classifier is trained between the
% new object and the data x. When this give a positive margin, the new
% object is outside the hull, otherwise it is inside. The C is the
% tradeoff parameter in the svm.
%
% NOTE: this is experimental code. The FRACREJ is currently just the
% threshold on the margin, because I have no idea yet how to set it.
function w = chull(x,fracrej,C)
if nargin<3
	C = 1000;
end
if nargin<2
	fracrej = 0.1;
end
if nargin<1 || isempty(x)
	w = mapping(mfilename,{fracrej,C});
	w = setname(w,'ConvexHull');
	return
end

if ~ismapping(fracrej)
	% no real training, just storing the data...
	W.x = +target_class(x);
	W.y = ones(size(x,1),1);
	W.C = C;
	W.fracrej = fracrej;
	w = mapping(mfilename,'trained',W,['target ';'outlier'],size(x,2),2);
else
	% evaluation, here we have to train a linear svm for each test object
	W = getdata(fracrej);
	n = size(x,1);
	out = zeros(n,1);
	warning off dd_tools:change_R:DivideByZero;
    if length(W.C)==1
        W.C = [W.C W.C];
    end
	for i=1:n
		dd_message(6,'%d ',i);
		V = inc_setup('svc','p',1,W.C,[+x(i,:);W.x],[-1;W.y]);
		if isempty(V) || any(~isfinite(V.alf)) || ~isfinite(V.b) % infeasible!
			out(i,1) = 0;
		else
			setSV = [V.setS;V.setE];
			alf = V.y(setSV).*V.alf(setSV);
			dat = V.x(setSV,:);
			if ((+x(i,:)*dat')*alf+V.b>=0) %classified as target
				out(i,1) = 0;
			else
				w2 = sum(sum((alf*alf').*(dat*dat')));
				if ~isfinite(w2)
					keyboard
				end
				if (w2<0)  % infeasible
					out(i,1) = 0;
				else  % just the margin distance:
					out(i,1) = 1/sqrt(w2);
				end
			end
		end
	end
	% the threshold here is still magic...
	w = setdat(x,-[out repmat(W.fracrej,n,1)],fracrej);
	w = setfeatdom(w,{[-inf 0; -inf 0] [-inf 0; -inf 0]});
end

end

