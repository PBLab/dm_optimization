function updateMirror(oldParams, newParams,oldZernike,olderZernike)
% Following a comparison of the old and new image parameters,
% decides on the best course of action for the mirror.
    
    newZernike = testIfHigher(oldParams, newParams,oldZernike,olderZernike);
    % Send command to mirror
    MirrorCommand(newZernike);
    fprintf('Command sent\n');
end