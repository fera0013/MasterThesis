%Equally divides <signal> into <numberOfFrame> frames containing the same
%number of data points each
%applies zero padding to last frame
function signalFrames = SegmentTimeSignalIntoNSegments(signal,numberOfSegments)
originalSignalSize = size(signal,1);
sizeOfDilatedSignal = originalSignalSize+numberOfSegments-mod(originalSignalSize,numberOfSegments);
dilatedSignal=zeros(sizeOfDilatedSignal,1);
dilatedSignal(1:originalSignalSize,1) = signal;
numberOfDataPointsPerFrame = size(dilatedSignal,1)/numberOfSegments;
signalFrames=SegmentTimeSignalIntoSegmentsOfNPoints(signal,numberOfDataPointsPerFrame);
end