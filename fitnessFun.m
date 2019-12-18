function params = fitnessFun(image)
% For a given image, calculates the mean FWHM (fitness) of all PSF spots in 
% the image

% Extract only the spots from the image
threshold = 70; % The percentile below which there's a backround 
width = 40; % Radius used to create a disk-shaped structuring element
spots = findPsfSpots(image, threshold, width);

% For each spot, calculate mean FWHM of its horizontal and vertical signals
fields = fieldnames(spots);
FWHMs = zeros(1,length(fields));
for i = 1:length(fields)
    [horizontalSig,verticalSig] = extractSignal(image,spots.(fields{i}));
    FWHMs(i) = mean([extractFWHM(horizontalSig,'transpose',1)...
        extractFWHM(verticalSig)]);
end
% Claculate mean FWHM of all spots 
params = mean(FWHMs);
end