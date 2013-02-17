function [ output_args ] = Untitled( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


end

function signalFrames = PartitionTimeSignal(signal,rpm,sampleFrequency,frameSizeInRotations )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
rps=rpm/60;
numberOfDataPointsPerRotation = sampleFrequency/rps;
numberOfDataPointsPerFrame = floor(numberOfDataPointsPerRotation *frameSizeInRotations);
signalFrames = PartitionTimeSignalByNumberOfDataPointsPerFrame(signal,numberOfDataPointsPerFrame);
end

function signalFrames = PartitionTimeSignalByTimePerFrame(signal,sampleFrequency,frameSizeInTime)
signalFrames = PartitionTimeSignalByNumberOfDataPointsPerFrame(signal,sampleFrequency*frameSizeInTime );
end

function signalFrames = PartitionTimeSignalByNumberOfDataPointsPerFrame(signal,numberOfDataPointsPerFrame )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
dilatedSignalSize = size(signal,1) +  mod(size(signal,1), numberOfDataPointsPerFrame);
dilatedSignal = zeros(dilatedSignalSize,1);
dilatedSignal(1:size(signal),1)=signal;
numberOfFrames = dilatedSignal /numberOfDataPointsPerFrame;
signalFrames = reshape(signal,numberOfDataPointsPerFrame,numberOfFrames);
end

function signalFrames = PartitionTimeSignalOrig(signal,rpm,sampleFrequency,frameSizeInRotations )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
rps=rpm/60;
numberOfDataPointsPerRotation = sampleFrequency/rps;
numberOfDataPointsPerFrame = floor(numberOfDataPointsPerRotation *frameSizeInRotations);
signalLength = size(signal,1);
numberOfFrames = floor(signalLength/numberOfDataPointsPerFrame);
completeNumberOfDataPoints = numberOfFrames*numberOfDataPointsPerFrame;
tayloredSignal = signal(1:completeNumberOfDataPoints,1);
signalFrames = reshape(tayloredSignal,numberOfDataPointsPerFrame,numberOfFrames);
end
