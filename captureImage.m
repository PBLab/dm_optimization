function image = captureImage(hSI)
% Take the last image recorded in ScanImage and load it into memory (into "image").
% The last image is located inside the hSI object.
    image = hSI.hDisplay.lastFrame{1,1};
end