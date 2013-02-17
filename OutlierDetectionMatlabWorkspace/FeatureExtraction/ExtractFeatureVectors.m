function features = ExtractFeatureVectors(frames,sampleFrequency)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
features = [size(frames,1),2];
for j=1:size(frames,2)
    frame=frames(:,j);
    features(j,1)= hfd(frame,10); 
    %mfccFeatures=melfcc(frame,sampleFrequency);
    features(j,2)= kurtosis(frame);
end
end

 
