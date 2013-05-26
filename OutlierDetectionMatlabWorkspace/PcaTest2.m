load cities
figure() 
boxplot(ratings,'orientation','horizontal','labels',categories)
[wcoeff,score,latent,tsquared] = princomp(zscore(ratings));
newVectors=zscore(ratings)*wcoeff;
figure()
plot(score(:,1),score(:,2),'+')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')