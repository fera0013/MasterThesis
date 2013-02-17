%TRAINED_MAPPING Define untrained or fixed mapping
%
%   W = TRAINED_CLASSIFIER(A,DATA)
%
% INPUT
%   A      - Dataset used for training
%   DATA   - Data (cell array or structure) to be stored in the data-field
%            of the mapping in order to transfer it to the execution part
%
% OUTPUT
%   W       - Classifier
%
% SEE ALSO
% MAPPINGS, MAPPING

% Copyright: Robert P.W. Duin, prtools@rduin.nl

function w = trained_classifier(varargin)

  [a,data] = setdefaults(varargin);
  fname = callername;
  classfname = getname(feval(fname));
  [m,k,c] = getsize(a);
  w = mapping(fname,'trained',data,getlablist(a),k,c);
  w = setname(w,classfname);

return

%CALLERNAME
%
%	NAME = CALLERNAME
%
% Returns the name the calling function 

function name = callername


[ss ,i] = dbstack;
if length(ss) < 3
	name = [];
else
	name = ss(3).name;
end
    