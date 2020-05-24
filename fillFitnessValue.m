function [newPop, fitness] = fillFitnessValue(individualNum, img, pop, genesNum, dm, Z2C)
% Runs whenever we only want to add another fitness value to the population,
% but not run the actual alogrithm.
newPop = pop;
fitness = fitnessMean(img);
% Since the fit can return a NaN value (== no spots were found) we use the
% previous' individual vector for the current one. This might pose an error
% if the first individual returns NaN, but that is very unlikely since the
% user who is running this app probably started it with some points clearly
% visible in the image.
if isnan(fitness)
    newPop(individualNum, 1:genesNum + 1) = newPop(individualNum - 1, 1:genesNum + 1);
else
    newPop(individualNum, genesNum + 1)= fitness;
end
newIndividualNum = individualNum + 1;
MirrorCommand(dm, newPop(newIndividualNum,1:genesNum), Z2C);
end
