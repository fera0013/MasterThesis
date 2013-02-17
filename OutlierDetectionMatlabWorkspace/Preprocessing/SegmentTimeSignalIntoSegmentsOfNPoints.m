function signalFrames = SegmentTimeSignalIntoSegmentsOfNPoints(signal,numberOfDataPointsPerFrame )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
numberOfFrames = ceil(size(signal,1)/numberOfDataPointsPerFrame);
dilatedSignalSize = numberOfFrames*numberOfDataPointsPerFrame;
dilatedSignal = zeros(dilatedSignalSize,1);
dilatedSignal(1:size(signal),1)=signal;
signalFrames = reshape(dilatedSignal,numberOfDataPointsPerFrame,numberOfFrames);
end
