function pop = initialize (popSize,genesNum)
% Initializes population for the first generation and sends
% the first Zernike vector to the mirror to recieve the first frame
    for i=1:popSize
        pop(i,1:genesNum)= GenerateRandVec(genesNum,-10,0.1,10);
    end
    MirrorCommand(pop(1,1:genesNum));
    fprintf('Command sent\n');
end