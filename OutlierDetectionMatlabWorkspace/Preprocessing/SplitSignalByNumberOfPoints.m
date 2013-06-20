function signalFrames = SplitSignalByNumberOfPoints(signal,numberOfDataPointsPerFrame )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
numberOfFrames = ceil(size(signal,1)/numberOfDataPointsPerFrame);
paddedSignalSize = numberOfFrames*numberOfDataPointsPerFrame;
paddedSignal = zeros(paddedSignalSize,1);
paddedSignal(1:size(signal),1)=signal;
signalFrames = reshape(paddedSignal,numberOfDataPointsPerFrame,numberOfFrames);
end
