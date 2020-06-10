function coordinates = findROI (hSI,pix_ratio, SCALE,ROIindex)
% The function returns the coordinates of a selected ROI as a 2X2 marix
% where the first column is X and the second is Y
zoom=hSI.hRoiManager.scanZoomFactor(1,1);
center_x = (((hSI.hIntegrationRoiManager.roiGroup.rois(1,ROIindex).scanfields.centerXY(1,1)) * zoom)+SCALE/2);
center_y = (((hSI.hIntegrationRoiManager.roiGroup.rois(1,ROIindex).scanfields.centerXY(1,2)) * zoom)+SCALE/2);
width = hSI.hIntegrationRoiManager.roiGroup.rois(1,ROIindex).scanfields.sizeXY(1,1) * zoom;
height = hSI.hIntegrationRoiManager.roiGroup.rois(1,ROIindex).scanfields.sizeXY(1,2) * zoom;
up_left = [center_x,center_y] - 0.5*[width,height];
up_left(1,1) = max(0,up_left(1,1));
up_left(1,2) = max(0,up_left(1,2));
down_right = [center_x,center_y] + 0.5*[width,height];
down_right(1,1) = min(SCALE,down_right(1,1));
down_right(1,2) = min(SCALE,down_right(1,2));
start_x = up_left(1,1) * pix_ratio;
start_y = up_left(1,2) * pix_ratio;
stop_x = down_right(1,1) * pix_ratio;
stop_y = down_right(1,2) * pix_ratio;

coordinates = int16([ start_x, start_y; stop_x, stop_y]);



