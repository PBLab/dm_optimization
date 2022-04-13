function pop = initialize (popSize,genesNum)
% Initializes population for the first generation if the user
% didn't load a population.mat file.
    pop = zeros(popSize, genesNum);
    for i=2:popSize
        pop(i,1:genesNum)= GenerateRandVec(genesNum,-0.9,0.1,0.9);
    end
end