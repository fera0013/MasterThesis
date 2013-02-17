%DELFT_IDB Delft Image Database

function a = delft_idb

prdatafiles('delft_idb',15);
pathname = fileparts(which(mfilename));
a = datafile(fullfile(pathname,mfilename));
a = setname(a,'Delft Image Database');
user.desc = ['This is the Delft Image Database. It is collected in 1999 by Eric van der Werf ' ...
		'and Olaf Lemmers for an MSc student project.'];
a = setuser(a,user);