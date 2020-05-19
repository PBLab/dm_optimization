function [ meanFWHM ] = calcFinalFWHM( horizontalSig, verticalSig )
%CALCFINALFWHM Returns the mean FWHM for the given point, or NaN if FWHM
%wasn't calculated properly.

    meanFWHM = mean([extractFWHM(horizontalSig,'transpose',1)...
         extractFWHM(verticalSig)]);
    if ismembertol(meanFWHM, 0)
        meanFWHM = inf;
    end
end

