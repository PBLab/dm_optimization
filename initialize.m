function pop = initialize (popSize,genesNum)
% Initializes population for the first generation if the user
% didn't load a population.mat file.
    pop = zeros(popsize, genesNum);
    for i=1:popSize
        pop(i,1:genesNum)= GenerateRandVec(genesNum,-10,0.1,10);
    end
end