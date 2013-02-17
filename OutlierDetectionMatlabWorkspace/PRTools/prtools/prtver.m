%PRTVER Get PRTools version
%
%This routine is intended for internal use in PRTools only

function prtversion = prtver

persistent PRTVERSION
if ~isempty (PRTVERSION)
	prtversion = PRTVERSION;
else
  prtversion = {ver('prtools') datestr(now)};
  PRTVERSION = prtversion;
end
