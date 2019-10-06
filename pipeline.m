function [newPop, savedPop]=pipeline(frameNum,img,pop,genesNum,popSize)
% Assigns fitness value to each Zernike vector and sends the next Zernike
% vector to the mirror
    newPop=pop;
    if mod(frameNum,popSize)~=0
        newPop(mod(frameNum,popSize),genesNum+1)=fitnessFun(img);
        savedPop=newPop;
        if mod(frameNum+1,popSize)~=0
            MirrorCommand(newPop(mod(frameNum+1,popSize),1:genesNum));
            fprintf('Command sent\n');
        else
            MirrorCommand(newPop(popSize,1:genesNum));
            fprintf('Command sent\n');
        end
    else
         newPop(popSize,genesNum+1)=fitnessFun(img);
         savedPop=newPop;
         disp(savedPop)
         % Call genetic algorithm to recieve new population
         newPop = geneticAlgorithm(newPop,genesNum,popSize);
         MirrorCommand(newPop(1,1:genesNum));
         fprintf('Command sent\n');            
    end
end