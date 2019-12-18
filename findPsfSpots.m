function spots = findPsfSpots(img, threshold, width)
% Finds all the PSF spots in a given image

% Find a value that separates the spots from the backround
topPercentile = prctile(img(:),threshold);
% Create a binary image in which spots are 1 and background is 0
binaryImage = im2bw(img,topPercentile);
% Morphologically open the binary image
openedImage = imopen(binaryImage, strel('disk',width));
% Label each spot with a number
labeled = bwlabel(openedImage);
% Find the indices of each spot
for elem=1:max(max(labeled))
    indicesName = ['SpotIndices_' num2str(elem)];
    [spots.(indicesName)(:,1),spots.(indicesName)(:,2)] = find(labeled == elem);
end
end