%ROADSIGNS Roadsigns as a datafile
%
% A = ROADSIGNS
%
% These are road images containing some roadsigns
%
% See also DATAFILES

function a = roadsigns

prdatafiles('roadsigns',215);
pathname = fileparts(which(mfilename));
a = datafile(fullfile(pathname,mfilename));
a = setname(a,'Roadsigns');
