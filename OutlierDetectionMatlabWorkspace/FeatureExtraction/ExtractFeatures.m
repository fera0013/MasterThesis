function features = ExtractFeatures(frame,sampleFrequency,numberOfSequences)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
feature = struct('mfd',[],'mfcc',[]);
features = repmat( feature, 1, numberOfSequences);
kurtosisFeature = kurtosis(frame);
sequences = PartitionTimeSignalIntoFrames(frame,numberOfSequences);
for j=1:size(sequences,2)
    features(1,j).mfd=hfd(sequences(:,j),10); 
    features(1,j).mfcc=melfcc(sequences(:,j),sampleFrequency);
    features(1,j).kurtosis=kurtosisFeature;
end
end

 
