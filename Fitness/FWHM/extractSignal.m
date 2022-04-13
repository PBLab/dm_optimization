function [horizontalSig,verticalSig] = extractSignal(image,spot)
% Extracts the horizontal and vertical gaussian signals from a PSF spot

rows = spot(:,1);
cols = spot(:,2);
horizontalSig = image(floor(mean(rows)),min(cols):max(cols));
verticalSig = image(min(rows):max(rows),floor(mean(cols)));
% Padding to make sure the gaussian fit will succeed
horizontalSig = padarray(horizontalSig, [0, 5], min(horizontalSig));
verticalSig = padarray(verticalSig, [5, 0], min(verticalSig));
end