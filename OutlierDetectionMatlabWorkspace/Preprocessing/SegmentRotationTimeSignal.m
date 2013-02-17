%Partitions a time rotating machine time signal into segments with
%<numberOfResolutions> resolutions per segment
function signalFrames = SegmentRotationTimeSignal(signal,rpm,sampleFrequency,numberOfResolutions )
rps=rpm/60;
numberOfDataPointsPerRotation = sampleFrequency/rps;
numberOfDataPointsPerFrame = floor(numberOfDataPointsPerRotation *numberOfResolutions);
signalFrames=SegmentTimeSignalIntoSegmentsOfNPoints(signal,numberOfDataPointsPerFrame);
end



