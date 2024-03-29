function [newPop, savedPop, fitness] = runAlgorithm(img, pop, genesNum, popSize, dm, Z2C)
% Once every "popSize" frames, after all of the population was given its
% fitness value, we can run the new generation of the genetic algorithm.
 newPop=pop;
 fitness = fitnessFun(img);
 newPop(popSize,genesNum+1) = fitness;
 savedPop=newPop;
 % Call genetic algorithm to recieve new population
 newPop = geneticAlgorithm(newPop,genesNum,popSize);
 MirrorCommand(dm, newPop(1,1:genesNum), Z2C);
 fprintf('Command sent\n');  
end
