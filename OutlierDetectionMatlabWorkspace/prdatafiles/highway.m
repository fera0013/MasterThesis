%HIGHWAY The highway database as a datafile
%
%  A = HIGHWAY(N)
%
% The HIGHWAY database consist of 100 observations of a highway situation
% made from the same position. Every observation is given by 6 images:
% 1. Red
% 2. Green
% 3. Blue
% 4. A feature value for every pixel, being the mean of the 20 gray values
%    of that pixel in the 20 most recent video frames minus its present gray
%    value.
% 5. A feature value for every pixel, being the standard dev. of the 20 
%    gray values of that pixel in the 20 most recent video frames.
% 6. A hand labeled image of vehicles.
%
% The images have a size of 288*384 = 110592 pixels.
% N should be a vector pointing to the desired set of images per
% observation. Consequently A has a size of 100 observations x
% (110592*length(N)) features.
%
% Default N: load all 6 images per observation.
%
% This database has been made available by Jasper van Huis and Jan Baan of
% the Dutch TNO organisation for Industry and Technology
%
% See also DATAFILES

function A = highway(N)

prdatafiles('highway',45);
pathname = fileparts(which(mfilename));
a = datafile(fullfile(pathname,'highway'));
k = size(a,2);
if nargin < 1
	A = a;
else
	J = [0 110592, 221184, 331776, 442368, 552960, 663552];
	A = a*featsel(k,[J(N(1))+1:J(N(1)+1)]);
	if length(N) > 1
		for j=2:length(N)
			A = [A a*featsel(k,[J(N(j))+1:J(N(j)+1)])];
		end
	end
	A = setfeatsize(A,[288 384 length(N)]);
end
A = setname(A,'Highway');


return