function [horizontalSig,verticalSig] = extractSignal(image,spot,varargin)
% Extracts the horizontal and vertical gaussian signals from a PSF spot

rows = spot(:,1);
cols = spot(:,2);
horizontalSig = image(floor(mean(rows)),min(cols):max(cols));
verticalSig = image(min(rows):max(rows),floor(mean(cols)));
% Optional- apply gaussian filter
f1=find(strcmp('filter',varargin));
if ~isempty(f1)
    filterFlag = varargin{f1+1};
else
    filterFlag = 0;
end
if filterFlag == 1
    horizontalSig = smoothdata(horizontalSig,'gaussian',20);
    verticalSig = smoothdata(verticalSig,'gaussian',20);
end
end