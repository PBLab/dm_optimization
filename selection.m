function [parent1, parent2]=selection(oldPop,popSize,genesNum)
% Performs tournament parent selection
k=2;    % Number of parents competing
parents = zeros(2,genesNum);
for i=1:2
    bestInd=[];
    for j=1:k
        ind=oldPop(randi([1 popSize],1,1),:);
        if isempty(bestInd) || bestInd(1,genesNum+1)>ind(1,genesNum+1)
            bestInd=ind;
        end
    end
    parents(i,:)=bestInd;
end
parent1 = parents(1,:);
parent2 = parents(2,:);
end
