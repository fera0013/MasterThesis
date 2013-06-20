function features = ExtractFeatures(dataSegments, sampleFrequency)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
features=[]; 
for i=1:size(dataSegments,1),
    segment=dataSegments(i,:);
    kurtosisFeature= kurtosis(segment);
    %Separate segment into 15 frames by STFT and calcualte 13 MFCs per
    %frame
    mfccFeatures=melfcc(segment,sampleFrequency);
    numberOfFramesPerSegment=size(mfccFeatures,2);
    numberOfMfccPerFrame=size(mfccFeatures,1);
    %Partition segment into <numberOfFramesPerSegment> frames to perform 
    %HFD
    frames = SplitSignalNTimes(segment,numberOfFramesPerSegment);
    for j=1:numberOfFramesPerSegment,
        hfdFeatures=zeros(1,numberOfMfccPerFrame);
        %Calculate <numberOfMfccPerFrame> HFD values for k parameters 
        %varying from 4 to <4+numberOfMfccPerFrame>
        for k=4:(3+numberOfMfccPerFrame),
            hfdFeatures(k-3)= hfd(frames(j,:),k);
        end
        %Combine Feature Vector for current frame
        frameMfccFeatures = mfccFeatures(:,j)';
        featureVector= cat(2,frameMfccFeatures,hfdFeatures,kurtosisFeature);
        %Add feature vector to feature matrix
        features=...
            [features;featureVector];
    end
features(any(isnan( features),2),:)=[];
end

end

