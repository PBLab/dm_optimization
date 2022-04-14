function params = FWHM(img)
% For a given image, calculates the mean FWHM (fitness) of all PSF spots in 
% the image
% Extract only the spots from the image


% HARDCODED VALUES - MOVE UP TO GUI
%threshold = 75; % The percentile below which there's a backround 
%width = 6; % Radius used to create a disk-shaped structuring element
%expectedElems = 4;
threshold =  getappdata(0,'treshold');
width = getappdata(0,'width');
expectedElems = getappdata(0,'expect_elem');

filtImage = imgaussfilt(img, 1);
spots = findPsfSpots(filtImage, threshold, width, expectedElems);
numSpotsFound = length(fieldnames(spots));
% For each spot, calculate mean FWHM of its horizontal and vertical signals
fields = fieldnames(spots);
FWHMs = zeros(1,numSpotsFound);
for i = 1:numSpotsFound
    [horizontalSig,verticalSig] = extractSignal(filtImage,spots.(fields{i}));
    FWHMs(i) = calcFinalFWHM(horizontalSig, verticalSig);
end
% Calculate mean FWHM of all spots, if there are no spots in the image
% params will be NaN 
params = mean(FWHMs);
end