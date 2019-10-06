function [child]=mutation(parent, pm,genesNum)
child=parent;
% Find a random mutation point
mPoints=find(rand(1,genesNum) < pm);
% The mutated gene is replaced by a random Zernike mode
% from a uniform distribution
child(mPoints)=GenerateRandVec(length(mPoints),-10,0.1,10);
end