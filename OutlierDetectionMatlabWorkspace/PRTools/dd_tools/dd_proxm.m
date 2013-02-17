%DD_PROXM DD Proximity mapping
% 
% 	W = DD_PROXM(A,TYPE,P)
% 
% Computation of the k*m proximity mapping (or kernel) defined by 
% the m*k dataset A.  The computation is done in dd_kernel. See
% dd_kernel for the proximities that are defined.
% The only exception is the Gower distance, because for that one it is
% needed what features are discrete and continuous, and that should be
% defined in the dataset A.
% 
% Default is the Euclidean distance: type = 'distance', p = 1
%
% 	W = MYPROXM(A,TYPE,P,NR_PROTO)
% 	W = MYPROXM(A,TYPE,P,FRAC_PROTO)
%
% For situations where the dataset is (very) large, you can subsample
% the dataset and randomly choose NR_PROTO prototypes (or a fraction
% FRAC_PROTO of the dataset).
% 
% See also dd_kernel, mappings, datasets, gower, sqeucldistm

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function W = dd_proxm(A,type,s,subs)
		prtrace(mfilename);

if nargin < 4, subs = []; end
if nargin < 3 || isempty(s), s = 1; end
if nargin < 2 || isempty(type), type = 'd'; end
if nargin < 1 || isempty(A),
	W = mapping(mfilename,{type,s,subs});
	W = setname(W,makeproxname(type,s));
	return
end

%A = dataset(A); % why do I need this??
[m,k] = size(A);
  
% Definition, just store it
if ischar(type)
	
	% Check the inputs, to avoid problems later.
	all = char('polynomial','p','exponential','e','radial_basis','r', ...
             'sigmoid','s','distance','d','minkowski','m',...
             'city-block','c','gower','g','linear','l', 'kcenter','k');
	if ~any(strcmp(cellstr(all),type))
		error(['Unknown proximity type: ' type])
	end
	
	% if you supply SUBS, a number of fraction of the objects are used
	% as prototypes.
	if ~isempty(subs)
		if subs>=1
			n = subs;
		else
			n = ceil(subs*size(A,1));
		end
		J = randperm(size(A,1));
		A = A(J(1:n),:);
	end
	% per default, only store the data
	W.A = A;
	W.type = type;
	W.s = s;
	W = mapping(mfilename,'trained',W,[],k,m);
	W = setname(W,makeproxname(type,s));
										   
elseif isa(type,'mapping')  
% Execution, input data A and W.A, output in D (-->W)

	W = getdata(type);
	[kk,n] = size(type);

	if k ~= kk, error('Matrices should have equal numbers of columns'); end
	
	% here the work is done:
	switch W.type

	case {'minkowski','m'}
		if length(W.s)>1, error('Only scalar parameter P possible'); end
		D = zeros(m,n);
		if isfinite(W.s)
			for j=1:n
				D(:,j) = sum(abs(A - repmat(+(W.A(j,:)),m,1)).^W.s,2).^(1/W.s);
			end
		else
			for j=1:n
				D(:,j) = max(abs(+A - repmat(+(W.A(j,:)),m,1)),[],2);
			end
		end
		
	case {'gower', 'g'} 
		[feattype,featrange] = getfeattype(W.A);
		ft2 = getfeattype(A);
		if any(feattype~=ft2),
			error('Both datasets have to have the same discrete features');
		end
		D = zeros(m,n);
		for j=1:m
			D(j,:) = gower(+A(j,:),+W.A,feattype,featrange)';
		end
		
	otherwise
		% here most of the work is done:
		D = dd_kernel(A,W.A,W.type,W.s);
	end
	W = setdat(A,D,type);
	
end

return

function kname = makeproxname(type,s)

switch type
case {'linear','l'}
	kname = 'linear K';
case {'polynomial','p'}
	kname = sprintf('polyn degree %d',s);
case {'sigmoid','s'}
	kname = sprintf('sigmoid s=%.2f',s);
case {'city-block','c'}
	kname = 'cityblock K';
case {'minkowski','m'}
	kname = sprintf('minkowski p=%d',s);
case {'exponential','e'}
	kname = sprintf('exp.Kernel p=%.2f',s);
case {'radial_basis','r'}
	kname = sprintf('RBF.Kernel s=%.2f',s);
case {'distance','d'}
	kname = sprintf('Eucl.Kernel d=%f',s(1));
case {'gower', 'g'} 
	kname = 'Gower K';
otherwise
	kname = 'Myproxm';
end

return
