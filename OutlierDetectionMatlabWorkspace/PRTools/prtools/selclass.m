%SELCLASS Select a single class from a dataset
%
%	[B,J] = SELCLASS(A,CLASS,LABLISTNAME)
%	 B    = A*SELCLASS([],CLASS,LABLISTNAME)
%
% INPUT
%   A   Dataset
%   CLASS  Integer: Indices of desired classes in CLASSNAMES(A)
%          String array:  Class names
%   NAME   Integer: Index of desired labeling, see GETLABLISTNAMES
%          String:  Name of desired labeling, see GETLABLISTNAMES
%          Default: actual LABLIST
%	
% OUTPUT
%   B   Subset of the dataset A
%   J   Indices of returned objects in dataset A: B = A(J,:)
%
% DESCRIPTION
% B is a subset of the dataset A defined by the set of classes (CLASS). In
% case of a multi-labeling system (see MULTI_LABELING) the desired CLAS
% should refer to the label list given in LABLISTNAME.
%
% In case A is soft labeled or is a target dataset by B = SELDAT(A,CLASS)
% the entire dataset is returned, but the labels or targets are reduced to
% the selected class (target) CLASS.
%
% SEE ALSO
% DATASETS, SELDAT, CLASSNAMES, GENDAT, GETLABLIST, GETCLASSI, REMCLASS,
% GETLABLISTNAMES, MULTI_LABELING

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: seldat.m,v 1.13 2009/02/19 12:27:10 duin Exp $

function [b,J] = selclass(a,clas,lablist)

		prtrace(mfilename);
    
  if nargin < 3, lablist = []; end
  if nargin < 2, clas = []; end
  
  if isempty(a), b = mapping(mfilename,'fixed',clas, lablist); return; end
  
  if ~isempty(lablist)
    curn = curlablist(a);
    a = changelablist(a,lablist);
    b = feval(mfilename,a,clas);
    b = changelablist(b,curn);
  else
    b = seldat(a,clas);
  end