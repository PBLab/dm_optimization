function newParams = pipeline(oldParams,oldZernike,olderZernike)
% Mock pipeline for operating the Alpao mirror
    hSI = evalin('base','hSI'); 
    % Take the first frame and load it into memory
    img = captureImage(hSI);
    % Extract relevant parameters from the image
    newParams = extractParams(img);
    fprintf("The new params are: %s", newParams);
    fprintf('\n');
    % Compares the old and new parameters of the images
    % and sends an appropriate command to the mirror.
    updateMirror(oldParams, newParams,oldZernike,olderZernike);

end
