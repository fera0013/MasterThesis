%DD_VERSION Version information for dd_tools
%
%        VER = DD_VERSION
%
% Returns the string VER containing the version number of the currently
% loaded dd_tools. 
% When the Java virtual machine is running also the most up-to-date
% version of dd_tools is shown.
%
%        VER = DD_VERSION UPGRADE
% When you request for an 'upgrade', the user is asked for a directory,
% and the newest version is downloaded in that place.

function ver = dd_version(dodownload)
if nargin<1
	dodownload = '';
end

%
newver = [];
newl = sprintf('\n');
p = which('gauss_dd');
ddpath = fileparts(p);
% find dd_tools directory name:
I = findstr(ddpath,filesep);
if isempty(I)
	dddir = ddpath;
else
	dddir = ddpath(I(end)+1:end);
end
% open the Contents file and find the current version:
h = help(dddir);
I = findstr(h,'Version');
h = h(I(1)+8:end);
I = findstr(h,' ');
ver = h(1:I(1)-1);

% now go to the standard webpage and extract the URL
if usejava('jvm')
	ddpage = urlread('http://prlab.tudelft.nl/david-tax/dd_tools.html');
	I = strfind(ddpage,'DD_DOWNLOAD');
	ddurl = ddpage(I(1):I(1)+150);
	I = strfind(ddurl,'"');
	ddurl = ddurl(I(1)+1:I(2)-1);

	% now find the version of this .zip...
	I = strfind(ddurl,'_');
	Idot = strfind(ddurl,'.');
	newver = sprintf('%s.%s.%s',ddurl(I(end-2)+1:I(end-1)-1),...
	ddurl(I(end-1)+1:I(end)-1),ddurl(I(end)+1:Idot(end)-1));

	% shall we update?
	if strcmp(dodownload,'upgrade')
		I = strfind(ddurl,'/');
		ddfile = ddurl(I(end)+1:end);
		[ddname,ddplace] = uiputfile('*','Select place to save dd_tools',ddfile);
		urlwrite(ddurl,fullfile(ddplace,ddfile));
		fprintf('Success!: %s is saved in %s.\n',ddfile,ddplace);
		fprintf('Unzip the file and add the path to your matlab path.\n');
		return
	end
else
	if strcmp(dodownload,'upgrade')
		error('Java Virtual Machine is not running. Please download from http://prlab.tudelft.nl/david-tax/dd_tools.html');
	end
end


if nargout==0
	fprintf('Currently installed version is dd_tools %s.\n',ver);
	if ~isempty(newver)
		if newver>ver
			fprintf('The newest version is %s.\n',newver);
		elseif ver==newver
			fprintf('You are up to date.\n');
		else
			fprintf('You have a dd_tools from the future! (current version %s)\n',...
			newver);
		end
	end

	clear ver;
end

