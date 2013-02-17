%FLOWERS The 17FLOWER database 
%
% A = FLOWERS
%
% There are 17 flower classes, represented by 80 pictures each. 
% Images have different sizes.
%
% REFERENCE
% Nilsback, M-E. and Zisserman, A.
% A Visual Vocabulary for Flower Classification
% Proc. of the IEEE Conference on Computer Vision and Pattern Recognition (2006)
%
% See also DATAFILES

function a = flowers

prdatafiles('17flower',60);
pathname = fileparts(which(mfilename));
a = datafile(fullfile(pathname,'17flower'));
a = setname(a,'17flower');
user.desc = ['This set contains images of flowers belonging to 17 different categories.' ...
'The images were acquired by searching the web and taking pictures. There are' ...
'80 images for each category.' ...
' ' ...
'The database was used in:' ...
' ' ...
'Nilsback, M-E. and Zisserman, A.  A Visual Vocabulary for Flower Classification' ...
'Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (2006) ' ...
'http://www.robots.ox.ac.uk/~vgg/publications/papers/nilsback06.{pdf,ps.gz}.'];
user.link = 'http://www.robots.ox.ac.uk/~vgg/data/flowers/';
a = setuser(a,user);