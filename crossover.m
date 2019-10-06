function [child1, child2]=crossover(parent1, parent2, pc,genesNum)
% Crossover between two parents produces two children
if (rand<pc)
    ub = genesNum - 1;
    lb = 1;
    % Random crossover point
    cpoint=round ((ub - lb) *rand() + lb);
    child1=[parent1(1,1:cpoint) parent2(1,cpoint+1:genesNum) 0];
    child2=[parent2(1,1:cpoint) parent1(1,cpoint+1:genesNum) 0];
else
    child1=parent1;
    child2=parent2;
end
end