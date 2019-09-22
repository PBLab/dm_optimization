function newParams = pipeline(img, oldParams,oldZernike,olderZernike)
% Mock pipeline for operating the Alpao mirror
    % Extract relevant parameters from the image
    newParams = extractParams(img);
    fprintf('The new params are: %s\n', newParams);
    newZernike = testIfHigher(oldParams, newParams,oldZernike,olderZernike);
    % Compares the old and new parameters of the images
    % and sends an appropriate command to the mirror.
    MirrorCommand(newZernike);
    fprintf('Command sent\n');
end
