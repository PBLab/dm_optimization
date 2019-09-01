function newParams = pipeline(oldParams)
% Mock pipeline for operating the Alpao mirror

    % Take the first frame and load it into memory
    img = captureImage(hSI);

    % Extract relevant parameters from the image
    newParams = extractParams(img);

    % Compare the old and new parameters of the images
    % and sends an appropriate command to the mirror.
    updateMirror(oldParams, newParams);

end
