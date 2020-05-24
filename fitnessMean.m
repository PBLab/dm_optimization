function [ value ] = fitnessMean( image )
%Calculates the mean image value
image = image - min(image(:));
value = 1/mean(image(:));

end

