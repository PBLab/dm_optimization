function params = fitnessFun(image)
% For a given image, calculates the mean FWHM (fitness) of all PSF spots in 
% the image

% Extract only the spots from the image
spots = pickSpot(image);
fields = fieldnames(spots);
% For each spot, calculate FWHM of its horizontal signal (identical to the
% vertical)
FWHMs = zeros(1,length(fields));
for i = 1:length(fields)
[horizontalSig,verticalSig] = extractSignal(image,spots.(fields{i}));
FWHMs(i) = extractFWHM(horizontalSig);
end
params = mean(FWHMs);
end