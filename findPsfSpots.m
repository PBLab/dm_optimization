function spots = findPsfSpots(img, threshold, width, expectedElems)
% Finds all the PSF spots in a given image
img_size = size(img);
% Find a value that separates the spots from the backround
numElemsFound = inf;
while numElemsFound > expectedElems
    topPercentile = prctile(img(:),threshold);
    % Create a binary image in which spots are 1 and background is 0
    binaryImage = im2bw(img,topPercentile);
    % Morphologically open the binary image
    openedImage = imopen(binaryImage, strel('disk',width));
    % Label each spot with a number
    labeled = bwlabel(openedImage);
    numElemsFound = max(labeled(:));
    if numElemsFound == 0
        threshold = threshold * 0.9;
        numElemsFound = inf;
    elseif numElemsFound > expectedElems
        threshold = threshold * 1.1;
    end
end
% Find the indices of each spot by iterating over them. If they're located
% on the edge of the image, i.e. they have an index < 4 or IMAGE_MAX_PIX -
% 4 in their connected components, we'll throw them away.
spots = struct();
for elem=1:numElemsFound
    indicesName = ['SpotIndices_' num2str(elem)];
    [x, y] = find(labeled == elem);
    if (min(x) < 4) || (max(x) > (img_size(1) - 4)) ...
            || (min(y) < 4) || (max(y) > (img_size(2) - 4))
        continue
    end
    spots.(indicesName)(:,1) = x;
    spots.(indicesName)(:,2) = y;
end
end