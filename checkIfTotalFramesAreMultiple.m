function finalFrames = checkIfTotalFramesAreMultiple(totalFrames, framesPerSlice)
% If the number of total frames, as written in the SI GUI isn't an integer
% division of the totalFrames variable we will truncate the total number of
% acquired frames.

if mod(framesPerSlice, totalFrames) ~= 0
   numberOfGenerations = fix(framesPerSlice / totalFrames);
   finalFrames = numberOfGenerations * totalFrames;
else
    finalFrames = framesPerSlice;
end

end

