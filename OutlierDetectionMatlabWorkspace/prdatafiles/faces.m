%FACES Read Olivetti face database
%
%	A = FACES(SUBJECTS,PHOTOS)
%
% This creates a dataset A containing the desired photos (92*112 pixels)
% of the desired subjects (1 <= SUBJECTS <= 40). For each subject 10
% photos are available (1 <= PHOTOS <= 10). SUBJECTS and PHOTOS may
% be vectors.
% The size of A is (LENGTH(SUBJECTS)*LENGTH(PHOTOS),92*112).
% The stored photos can be displayed by SHOW(A).
%
% FACES first reads a datafile ORL and then converts it to a dataset.
% In case ORL is not available, it may be automatically downloaded
% and installed. If this fails an error is generated.
%
% When using these images, please give credit to Olivetti Research Laboratory.
% A convenient reference is the face recognition work which uses some of
% these images:
%
% F. Samaria and A. Harter
%   "Parameterisation of a stochastic model for human face identification",
%   2nd IEEE Workshop on Applications of Computer Vision
%   December 1994, Sarasota (Florida).
%
% The paper is available via anonymous ftp from quince.cam-orl.co.uk and is
% stored in pub/users/fs/IEEE_workshop.ps.Z
%
% If you have any question, please email Ferdinando Samaria: fs@cam-orl.co.uk
%
% see also DATASETS, SHOW, ORL

% $Id: faces.m,v 1.1.1.1 2003/05/16 11:20:35 bob Exp $

function a = faces(subjects,photos)

if nargin < 2 | isempty(photos)
	photos = [1:10];
end
if nargin < 1 | isempty(subjects)
	subjects = [1:40];
end

if any(subjects > 40) | any(subjects < 1) | any(photos > 10) | any(photos < 1)
	error('Requested photograph out of range')
end
a = [];

a = dataset(seldat(orl,subjects));

J = repmat(photos(:),1,length(subjects)) + repmat([0:length(subjects)-1]*10,length(photos),1);

a = dataset(a(J,:));

