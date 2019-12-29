function [newPop] = fillFitnessValue(individualNum, img, pop, genesNum, dm, Z2C)
% Runs whenever we only want to add another fitness value to the population,
% but not run the actual alogrithm.
newPop = pop;
fitness = fitnessFun(img);
newPop(individualNum, genesNum + 1)= fitness;
newIndividualNum = individualNum + 1;
MirrorCommand(dm, newPop(newIndividualNum,1:genesNum), Z2C);
fprintf('Command sent\n');  
end
