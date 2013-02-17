%ISDOUBLE Test on doubles

function n = isint(m)

	prtrace(mfilename);
	
	if isa(m,'double')
		n = 1;
	else
		n = 0;
	end

	return
