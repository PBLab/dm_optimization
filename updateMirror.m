function updateMirror(oldParams, newParams)
% Following a comparison of the old and new image parameters,
% decides on the best course of action for the mirror.

    newZernike = testIfHigher(oldParams, newParams);
    MirrorCommand(newZernike);

end