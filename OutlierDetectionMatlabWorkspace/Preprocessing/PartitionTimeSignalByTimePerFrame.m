function signalFrames = PartitionTimeSignalByTimePerFrame(signal,frequency,timeInSeconds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
numberOfDataPointsPerFrame=frequency*timeInSeconds;
signalFrames=PartitionTimeSignalByNumberOfDataPointsPerFrame(signal,numberOfDataPointsPerFrame);
end

