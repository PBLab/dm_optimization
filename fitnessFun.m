function params = fitnessFun(image)
% Calculates the signal to background ratio (fitness) of a given image.
% Higher SNR indicates a better fitness.

% Find a threshold using Sobel edge detection method 
[~,threshold] = edge(image,'sobel');
% Create a binary mask
BWs = edge(image,'sobel',threshold);
% Create two perpindicular linear structuring elements
se90 = strel('line',3,90);
se0 = strel('line',3,0);
% Dilate the binary mask
BWsdil = imdilate(BWs,[se90 se0]);
% Fill interior gaps
BWdfill = imfill(BWsdil,'holes');
% Smooth the object by eroding the image twice with a diamond structuring 
% element
seD = strel('diamond',1);
BWfinal = imerode(BWdfill,seD);
BWfinal = imerode(BWfinal,seD);

% Compute SBR
signal =sum(image(BWfinal == 1));
background =sum(image(BWfinal == 0));
params = signal/background;
end