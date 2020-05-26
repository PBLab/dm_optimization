function [ value ] = fitnessMean( image )
%Calculates the mean of top 10% image intensity values
image = image - min(image(:));
threshold = prctile(image(:),90);
topPixels = image(image > threshold);
value = 1/mean(topPixels(:));
end