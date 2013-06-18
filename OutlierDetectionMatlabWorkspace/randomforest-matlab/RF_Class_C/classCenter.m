function xdat = classCenter(x, label, prox, nNbr)
% classCenter <- function(x, label, prox, nNbr = min(table(label))-1) {
if ~exist('nNbr','var')
    nNbr = min(table_label(label))-1;
end

%     label <- as.character(label)
%     clsLabel <- unique(label)
clsLabel = unique(label);

%     ## Find the nearest nNbr neighbors of each case
%     ## (including the case itself). 
%     idx <- t(apply(prox, 1, order, decreasing=TRUE)[1:nNbr,])
% e.g.  prox<-rbind(c(3,2,1),c(2,3,4),c(4,2,8))
%       t(apply(prox,1,order,decreasing=TRUE))
%RESULT
%    [,1] [,2] [,3]
%[1,]    1    2    3
%[2,]    3    2    1
%[3,]    3    1    2

OrderedProximityMatrix = [];
for i=1:size(prox,1)
    %OrderedProximityMatrix = Order the values of each row of the proximity matrix in decreasing order
    %save sort order rather than the original values
    [unused,OrderedProximityMatrix(i,:)] = sort(prox(i,:),'descend');
end
%ReducedOrderedProximityMatrix = first nNbr rows of the OrderedProximityMatrix  
idx = OrderedProximityMatrix(:,1:nNbr);

%     ## Find the class labels of the neighbors.
%     cls <- label[idx]
%     dim(cls) <- dim(idx)
cls = label(idx);

%     ## Count the number of neighbors in each class for each case.
%     ncls <- sapply(clsLabel, function(x) rowSums(cls == x))
ncls = [];
for i=1:size(cls,1)
    for j=1:length(clsLabel)
        ncls(i,j)=length(find(clsLabel(j)== cls(i,:)));
    end
end
%     ## For each class, find the case(s) with most neighbors in that class.
%     clsMode <- max.col(t(ncls)) 
% find the class index that had the maximum counts
if length(clsLabel) > 1
    [unused,clsMode] = max(ncls');
else
    clsMode = ones(1,length(ncls));
end
clsMode = clsLabel(clsMode); %mapping to the original labels

% for debug purposes, look at [ncls label]
% the neighbors of label should ideally have higher counts than
% rest of class

%     ## Identify the neighbors of the class modes that are of the target class.
%     nbrList <- mapply(function(cls, m) idx[m,][label[idx[m,]] == cls],
%                       clsLabel, clsMode, SIMPLIFY=FALSE)
%     ## Get the X data for the neighbors of the class `modes'.
%     xdat <- t(sapply(nbrList, function(i) apply(x[i,,drop=FALSE], 2,
%                                                   median)))
%     xdat
% Ralph: can you make sure that i am doing it correctly.
% I loop the clsLabel (unique labels) and then for each label find all
% clsMode examples that have the same label and then do
xdat = [];
for i=1:length(clsLabel)
    nbrList = find(clsLabel(i)==clsMode);
    if length(nbrList) > 1
        xdat(i,:) = median(x(nbrList,:));
    else
        xdat(i,:) = (x(nbrList,:));
    end
end

end


function val = table_label(label)
    %emulate table(label)
    %find the counts of the number of times a label is unique
    unique_label = unique(label);
    val = [];
    for i=1:length(unique_label)
        val(i) = length(find(unique_label(i)==label));
    end
end