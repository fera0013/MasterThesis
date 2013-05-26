Data =[2.5 2.4;0.5 0.7;2.2 2.9;1.9 2.2;3.1 3.0;2.3 2.7;2 1.6;1 1.1;1.5 1.6;1.1 0.9];
DataAdjust = [0.69 0.49;-1.31 -1.21;0.39 0.99;0.09 0.29;1.29 1.09;0.49 0.79;0.19 -0.31;...
-0.81 -0.81;-0.31 -0.31;-0.71 -1.01];
Dataset=(Data);
DatasetAdjust=(DataAdjust);
scatterd(Dataset);title('Original dataset');
scatterd(Dataset);title('Adjust dataset');
twoVectorTransform = pca(Dataset,1);
transformedSet =DatasetAdjust*twoVectorTransform;
scatterd(transformedSet);


