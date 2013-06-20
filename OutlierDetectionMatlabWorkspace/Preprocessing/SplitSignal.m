%Partitions a time rotating machine time signal into segments with
%<numberOfResolutions> resolutions per segment
function signalFrames = SplitSignal(signal,rpm,sampleFrequency,numberOfResolutions )
rps=rpm/60;
numberOfDataPointsPerRotation = sampleFrequency/rps;
numberOfDataPointsPerFrame = floor(numberOfDataPointsPerRotation *numberOfResolutions);
signalFrames=SplitSignalByNumberOfPoints(signal,numberOfDataPointsPerFrame);
signalFrames = transpose(signalFrames);
end



