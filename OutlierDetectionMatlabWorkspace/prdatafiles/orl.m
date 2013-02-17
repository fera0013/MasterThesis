%ORL Read Olivetti ORL face database (now ATT)
%
%	A = ORL
%
% This creates a datafile A pointing to the ORL (now AT&T) database of
% faces. There are 400 images of size 92*112 of 40 individuals, 10 for each
% of them. They are stored as 40 classes with each 10 objects.
%
% The command FACES returns a dataset of the same images.
%
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
% See also DATAFILES, SHOW, FACES

function a = orl

prdatafiles('orl',4);
pathname = fileparts(which(mfilename));
a = datafile(fullfile(pathname,mfilename));
a = setname(a,'ORL faces');
user.desc = ['This database contains a set of faces taken between April 1992' ...
		'and April 1994 at the Olivetti Research Laboratory in Cambridge, UK. ' ...
    'There are 10 different images of 40 distinct subjects. For some of the ' ...
    'subjects, the images were taken at different times, varying lighting ' ...
    'slightly, facial expressions (open/closed eyes, smiling/non-smiling) ' ...
    'and facial details (glasses/no-glasses).  All the images are taken ' ...
    'against a dark homogeneous background and the subjects are in ' ...
    'up-right, frontal position (with tolerance for some side movement).'];
user.link = 'http://www.cl.cam.ac.uk/research/dtg/attarchive/facedatabase.html';
a = setuser(a,user);