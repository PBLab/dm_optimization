function [child]=mutation(parent, pm,genesNum)
child=parent;
% Find a random mutation point
mPoints=find(rand(1,genesNum) < pm);
% The mutated gene is replaced by a random Zernike mode
% from a uniform distribution
child(mPoints)=GenerateRandVec(length(mPoints),-0.9,0.1,0.9);
% if ismember(1,mPoints) 
%     child(1)=GenerateRandVec(1,-10,0.1,10); % minimize the range (Tip)
% end
% if ismember(2,mPoints)
%     child(2)=GenerateRandVec(2,-10,0.1,10); % minimize the range (Tilt)
% end
end