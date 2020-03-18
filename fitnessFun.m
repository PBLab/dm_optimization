function params = fitnessFun(image)
% For a given image, calculates the mean FWHM (fitness) of all PSF spots in 
% the image

% Extract only the spots from the image
threshold = 85; % The percentile below which there's a backround 
width = 4; % Radius used to create a disk-shaped structuring element
filtImage = imgaussfilt(image, 1);
spots = findPsfSpots(filtImage, threshold, width);
% For each spot, calculate mean FWHM of its horizontal and vertical signals
fields = fieldnames(spots);
FWHMs = zeros(1,length(fields));
for i = 1:length(fields)
    [horizontalSig,verticalSig] = extractSignal(filtImage,spots.(fields{i}));
    FWHMs(i) = mean([extractFWHM(horizontalSig,'transpose',1)...
        extractFWHM(verticalSig)]);
end
% Claculate mean FWHM of all spots, if there are no spots in the image
% params will be NaN 
params = mean(FWHMs);
end