%KIMIA_IMAGES Datafile with the KIMIA database of silhouettes
%
% A = KIMIA_IMAGES
%
% There are 216 binary images, 18 classes with 12 objects each.
% They have variable sizes up to 146 x 156.
% The images are taken from:
% http://www.lems.brown.edu/vision/researchAreas/SIID/
%
% See also DATAFILES

function a = kimia_images

prdatafiles('kimia_images',1);
labs = {'bone' 'van' 'elephant' 'head' 'fork' 'fountain' ...
	'hammer' 'key' 'ray' 'turtle' 'glass' 'heart' 'misk' ...
	'bird' 'brick' 'camel' 'car' 'children'};
pathname = fileparts(which(mfilename));
a = datafile(fullfile(pathname,mfilename));
a = setname(a,'KIMIA silhouettes');
a = setlablist(a,labs);
a = setfeatsize(a,0);
user.desc = ['This database contains a set of silhouettes taken from' ...
		'http://www.lems.brown.edu/vision/researchAreas/SIID/'];
user.link = 'http://www.lems.brown.edu/vision/researchAreas/SIID/';
a = setuser(a,user);
