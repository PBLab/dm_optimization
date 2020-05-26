function [newPop, savedPop, fitness] = runAlgorithm(img, pop, genesNum, popSize, dm, Z2C)
% Once every "popSize" frames, after all of the population was given its
% fitness value, we can run the new generation of the genetic algorithm.
newPop=pop;
func = getappdata(0,'func');
temp = sprintf('fitness%s',func);
funcName = sprintf(strcat(temp,'%s'),'(img)');
fitness = eval(funcName);
%fitness = fitnessMean(img);
newPop(popSize,genesNum+1) = fitness;
savedPop=newPop;
% Call genetic algorithm to recieve new population
newPop = geneticAlgorithm(newPop,genesNum,popSize);
MirrorCommand(dm, newPop(1,1:genesNum), Z2C);
fprintf('Command sent\n');  
end
