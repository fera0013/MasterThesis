%CHICKENPIECES The original chickenpieces silhouettes
%
% A = CHICKENPIECES
%
% There are 446 binary images of 5 classes. Images have different sizes
% of about 750 x 750 pixels.
%
% This dataset has been taken from:
% http://algoval.essex.ac.uk/data/sequence/chicken/
%
% This command inverts the original images in order to make it consistent
% with other binary images (0: background, 1: object).
%
% REFERENCE
% G. Andreu, A. Crespo and J.M. Valiente, 
% "Selecting the Toroidal Self-Organizing Feature Maps (TSOFM) Best 
% Organized to Object Recognition". Proceedings of ICNN´97, vol. 2, 
% pp. 1341--1346, Houston, Texas (USA). IEEE. June, 1997.
%
% See also DATAFILES

function a = chickenpieces

prdatafiles('chickenpieces',1);
pathname = fileparts(which(mfilename));
a = 1-datafile(fullfile(pathname,mfilename));
a = setname(a,'Chickenpieces');
user.desc = ['This dataset is composed by 446 images from chicken pieces. Each ' ...
	'piece belongs to one of five categories, which represent specific ' ...
	'parts of the chicken: wing (117 samples), back (76), drumstick (96), ' ... 
	'thigh and back (61), and breast (96). Each image is in binary format ' ... 
	'containing a silhouette from a particular piece. Pieces were placed ' ... 
	'in a natural way without considering orientation.'];
user.link = 'http://algoval.essex.ac.uk/data/sequence/chicken/';
user.ref = ['G. Andreu, A. Crespo and J.M. Valiente, ' ...
	'"Selecting the Toroidal Self-Organizing Feature Maps (TSOFM) Best ' ...
	'Organized to Object Recognition". Proceedings of ICNN´97, vol. 2, ' ... 
	'pp. 1341--1346, Houston, Texas (USA). IEEE. June, 1997. '];
a = setuser(a,user);
labs = genlab([117,76,96,61,96],char('wing','back','drumstick','thigh and back','breast'));
a = setlabels(a,labs);