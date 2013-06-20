%Equally divides <signal> into <numberOfFrame> frames containing the same
%number of data points each
%applies zero padding to last frame
function signalFrames = SplitSignalNTimes(signal,numberOfSegments)
originalSignalSize = size(signal,2);
sizeOfPaddedSignal = originalSignalSize+numberOfSegments-mod(originalSignalSize,numberOfSegments);
paddedSignal=zeros(sizeOfPaddedSignal,1);
paddedSignal(1:originalSignalSize,1) = signal;
numberOfDataPointsPerFrame = size(paddedSignal,1)/numberOfSegments;
signalFrames=reshape(paddedSignal,numberOfSegments,numberOfDataPointsPerFrame);
end