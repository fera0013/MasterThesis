h=0.5;
expectedFractalDimension=2-h;
x=Wei(h);
dimension = hfd(x,5);
%round to first behin komma
roundHiguchiDimension=round(dimension*10)/10;
if roundHiguchiDimension~=expectedFractalDimension,
    throw(MException('Higuchi dimension not correct!'));
end