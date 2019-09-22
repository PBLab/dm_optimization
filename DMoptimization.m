function DMoptimization (src,evt,varargin)
% User function for ScanImage, performs whenever a frame is acquired
hSI=src.hSI;
x=hSI.hDisplay.lastFrameNumber;
if x==1
    % Initialize data for pipeline
    oldParams = zeros(1);
    olderZernike=zeros(1,30);
    oldZernike=GenerateRandVec(30,-10,0.1,10);
else
    % Import data for pipeline 
    oldParams=importdata('oldParams.mat');
    olderZernike=importdata('olderZernike.mat');
    oldZernike=importdata('oldZernike.mat');
end
% Call pipeline to recieve new image parameters
newParams = pipeline(oldParams,oldZernike,olderZernike);
% Plot the new parameters for each frame taken
graphParams(x,newParams);
% Update image parameters
save('oldParams.mat','newParams')
end