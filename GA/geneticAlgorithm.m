function newPop = geneticAlgorithm(oldPop,genesNum,popSize)
% A new population is generated by Genetic Algorithm 
    
    pc=0.95;    % Default crossover probability
    pm=0.01;    % Default mutation probability 
    newPop = zeros(popSize, genesNum);
    for k = 1: 2: popSize
        % Selection
        [ parent1, parent2] = selection(oldPop,popSize,genesNum);
        
        % Crossover
        [child1 , child2] = crossover(parent1 , parent2, pc,genesNum);
        
        % Mutation
        [child1] = mutation(child1,pm,genesNum);
        [child2] = mutation(child2,pm,genesNum);
        
        newPop(k,:)= child1;
        newPop(k+1,:)= child2;
    end

end