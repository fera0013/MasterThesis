%INCSVC Incremental support vector classifier
%
%     W = INCSVC(A,KTYPE,KPAR,C)
%
%  Optimizes a support vector classifier for the dataset A by an
%  incremental procedure to perform the quadratic programming. The
%  kernel can be of one of the types as defined by DD_PROXM. Default is
%  linear (KTYPE = 'p', KPAR = 1). The kernel computation is done by
%  DD_KERNEL which is more lightweight than DD_PROXM.
%

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function W = isvc(a,ktype,kpar,C)

if nargin < 4 | isempty(C)
	C = 1;
end
if nargin < 3 | isempty(kpar)
	kpar = 1;
end
if nargin < 2 | isempty(ktype)
	ktype = 'p';
end
if nargin < 1 | isempty(a)
	w = mapping(mfilename,{ktype,kpar,C});
	W = setname(w,'Inc. SVC (%s)',getname(dd_proxm([],ktype,kpar)));
	return;
end

if ~isa(ktype,'mapping')  %training

	% remove double objects...
	[B,I] = unique(+a,'rows');
	a = a(I,:);

	[n,dim,c] = getsize(a);
	if (c>2)
		W = mclassc(a,mapping(mfilename,{ktype,kpar,C}));
	else
        % make sure that objects of different classes are mixed a bit
		a = unrandomize(a);
		y = 3 - 2*getnlab(a);
		if length(C)==1, C = [C;C]; end
		% do the adding:
		V = inc_setup('svc',ktype,kpar,C,+a,y);
		% store:
        dat.ktype = ktype;
        dat.kpar = kpar;
        if isempty(V)
            % fill in something stupid:
            dat.alf = 0;
            dat.sv = +a(1,:);
            dat.b = 0;
        else
            setSV = [V.setS; V.setE];
            dat.alf = V.y(setSV).*V.alf(setSV);
            dat.sv = V.x(setSV,:);
            dat.b = V.b;

				% DXD: it seems that when there are no, or just one, support
				% vectors in the active set, the offset b is not properly
				% defined. Set it then by hand:
				if length(V.setS)<2
					K = dd_kernel(V.x(V.setS,:),dat.sv,ktype,kpar);
					V.b = mean(K*dat.alf);
				end
        end
		ll = getlablist(a);
		W = mapping(mfilename,'trained',dat,ll,dim,size(ll,1));
		W = setname(W,'Inc SVC (%s)',getname(dd_proxm([],ktype,kpar)));
	end

else
	% evaluation!
	W = getdata(ktype);
	[n,dim] = size(a);
	out = repmat(W.b,n,1);
	out = zeros(n,1);
	for i=1:n
		K = dd_kernel(+a(i,:),W.sv,W.ktype,W.kpar);
		out(i) = out(i) + K*W.alf;
	end
	W = setdat(a,[out -out],ktype);

end

