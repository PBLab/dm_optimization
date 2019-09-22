function DMoptimization (src,evt,varargin)
% User function for ScanImage, performs whenever a frame is acquired
hSI = src.hSI;
persistent optimizationParams
persistent oldZernikeVec
persistent olderZernikeVec

switch evt.EventName
    case {'acqModeStart'}
        % Initialize data for pipeline
        optimizationParams = zeros(1);
        olderZernikeVec = zeros(1,30);
        oldZernikeVec = GenerateRandVec(30,-10,0.1,10);   
        
    case {'frameAcquired'}
        % Call pipeline to recieve new image parameters
        optimizationParams = pipeline(optimizationParams, oldZernikeVec, olderZernikeVec);
        % Plot the new parameters for each frame taken
        graphParams(hSI.hDisplay.lastFrameNumber, optimizationParams);
end
end