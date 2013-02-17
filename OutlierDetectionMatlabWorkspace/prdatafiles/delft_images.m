%DELFT_IMAGES A set of Delft images as a datafile
%
% A = DELFT_IMAGES
%
% See also DATAFILES

function a = delft_images

prdatafiles('delft_images',40);
pathname = fileparts(which(mfilename));
a = datafile(fullfile(pathname,mfilename));
a = setname(a,'Delft Images');
user.desc = ['This is a set of Delft images in 1999.'];
a = setuser(a,user);