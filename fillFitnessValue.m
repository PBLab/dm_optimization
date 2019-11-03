function [newPop, savedPop] = fillFitnessValue(individualNum, img, pop, genesNum, dm, Z2C)
% Runs whenever we only we to add another fitness value to the population,
% but not run the actual alogrithm.
newPop=pop;
newPop(individualNum, genesNum + 1)=fitnessFun(img);
savedPop = newPop;
newIndividualNum = individualNum + 1;
MirrorCommand(dm, newPop(newIndividualNum,1:genesNum), Z2C);
