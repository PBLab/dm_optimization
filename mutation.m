function [child]=mutation(parent, pm,genesNum)
child=parent;
% Find a random mutation point
mPoints=find(rand(1,genesNum) < pm);
% The mutated gene is replaced by a random Zernike mode
% from a uniform distribution
child(mPoints)=GenerateRandVec(length(mPoints),-1,0.1,1);

child(3) = 0; % Defocus mode is not changed 
% if ismember(1,mPoints) 
%     child(1)=GenerateRandVec(1,-10,0.1,10); % minimize the range (Tip)
% end
% if ismember(2,mPoints)
%     child(2)=GenerateRandVec(2,-10,0.1,10); % minimize the range (Tilt)
% end
end