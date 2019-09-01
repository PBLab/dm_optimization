function image = captureImage(hSI)
% Take the last image recorded in ScanImage and load it into memory (into "image").
% The last image is located inside the hSI object.
    hSI.grabFrame(1);
    image = hSI.hDisplay{1}(:);

end