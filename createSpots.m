function [psfImage,spot_data]=createSpots(imageSize,spotsNum,FWHM,varargin)
% Generates an image with specific number of PSF spots and specific FWHM
% values to each spot

% Optional- define mean intensity, intensity standard deviation and/or spot 
% position
f1=find(strcmp('meanInt',varargin));
f2=find(strcmp('stdInt',varargin));
f3=find(strcmp('spotPos',varargin));

if ~isempty(f1)
    meanInt=varargin{f1+1};
    if meanInt<0
        error('The mean spot intensity must be positive.')
    end
else
    meanInt=ones(1,spotsNum);
end

if ~isempty(f2)
    stdInt=varargin{f2+1};
    if stdInt<0
        error('The spot intensity standard deviation must be positive.')
    end
else
    stdInt=zeros(1,spotsNum);
end

if ~isempty(f3)
    spotPos=varargin{f3+1};
    posq=1;
else
    posq=0;
end

% Compute position matrices
Xpos = ones(imageSize(1),1)*(1:imageSize(2));
Ypos = (1:imageSize(1))'*ones(1,imageSize(2));  
% Create centroid list
if posq==0
    spot_data.Xcent=imageSize(2)*rand(1,spotsNum);
    spot_data.Ycent=imageSize(1)*rand(1,spotsNum);
else
    spot_data.Xcent=spotPos(:,1);
    spot_data.Ycent=spotPos(:,2);
    spotsNum=size(spotPos,1);
end
% Generate intensities
spot_data.ints=abs(normrnd(meanInt,stdInt));
% Generate standard deviations
spot_data.stds = FWHM./(2*sqrt(2*log(2)));
% Create basal image
psfImage=zeros(imageSize);
% Construct output image based on 2D gaussian formula
for i=1:spotsNum
    tempImage=spot_data.ints(i)*exp(-((Xpos-spot_data.Xcent(i)).^2....
        +(Ypos-spot_data.Ycent(i)).^2)/(2*spot_data.stds(i)^2));
    psfImage=psfImage+tempImage;
end

end           