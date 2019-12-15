myStruct = function findPsfSpots(img, threshold, width_)

hist = histImage(img);
topPercentile = getPerctile(hist, threshold);
binaryImage = img(img > topPercentile);
openedImage = imopen(binaryImage, width_);
labeled = bwlabel(openedImage);
numOfElements = unique(labeled);
for elem=1:numOfElements
    myStruct.indices = find(labeled == elem)
    myStruct.image = img(find(labeled == elem));
end

gaussEqn = 'a*exp(-((x-b)/c)^2)+d'

% a is approximately the maximal value of data
% b is the centerpoint of our linspace
% c is the std, which can be converted to FWHM
% d is the offset value, approximately the minimal value of our data
startVals = [a, b, c, d]
f = fit(linspace(0, 100)', data.', gaussEqn, 'Start', startVals)
