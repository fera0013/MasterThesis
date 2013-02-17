function signalFrames = PartitionTimeSignal(signal,rpm,sampleFrequency,frameSizeInRotations )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
rps=rpm/60;
numberOfDataPointsPerRotation = sampleFrequency/rps;
numberOfDataPointsPerFrame = floor(numberOfDataPointsPerRotation *frameSizeInRotations);
signalFrames=PartitionTimeSignalByNumberOfDataPointsPerFrame(signal,numberOfDataPointsPerFrame);
end

function PartitionTimeSignalByTimePerFrame()
%numberOfDataPointsPerFrame = sampleFrequency*frameSizeInTime;
%signalFrames = PartitionTimeSignalByNumberOfDataPointsPerFrame(signal,numberOfDataPointsPerFrame);
end

function signalFrames = PartitionTimeSignalByNumberOfDataPointsPerFrame(signal,numberOfDataPointsPerFrame )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
numberOfFrames = ceil(size(signal,1)/numberOfDataPointsPerFrame);
dilatedSignalSize = numberOfFrames*numberOfDataPointsPerFrame;
dilatedSignal = zeros(dilatedSignalSize,1);
dilatedSignal(1:size(signal),1)=signal;
signalFrames = reshape(dilatedSignal,numberOfDataPointsPerFrame,numberOfFrames);
end
