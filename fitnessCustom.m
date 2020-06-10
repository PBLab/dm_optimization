function params = fitnessCustom(image)
%Returns the fitness based on the SBR of a background ROI and one or more
%signal ROIs.
% The first defined integration field ROI is taken as the background, while
% all others are considered to be signal, and are averaged together. The
% SBR calculation is mean(pct(signal, 90)) / mean(background);

hSI = evalin('base', 'hSI');
SCALE = 18;  % volts
pix_ratio = size(image,1)/SCALE;
ROISnum = size(hSI.hIntegrationRoiManager.roiGroup.rois,2);
if ROISnum < 2
    warning ('Not enough ROIs')
    params = nan;
    return
end
image = image - min(image(:));
coor_background = findROI(hSI, pix_ratio, SCALE , 1);
bgroi = image(...
        coor_background(1, 1):coor_background(2, 1),...
        coor_background(1, 2):coor_background(2, 2)...
    );
mean_background = mean(bgroi(:));
mean_signal = zeros(ROISnum - 1, 1);
for i = 2:ROISnum 
    coor_signal = findROI(hSI, pix_ratio, SCALE , i);
    current_roi = image(...
        coor_signal(1, 1):coor_signal(2, 1),...
        coor_signal(1, 2):coor_signal(2, 2)...
    );
    pct = prctile(current_roi(:), 90);
    mean_signal(i-1, 1) = mean(current_roi(current_roi > pct)); 
end
mean_signal = mean(mean_signal(:));
params = 1 / (mean_signal / mean_background);