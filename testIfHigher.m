function newZernike = testIfHigher(oldParams, newParams,oldZernike,olderZernike)
    % Compares between old zernike vector to the older one
    % and creates a new zernike vector 
    if newParams >= oldParams
        equal=find(oldZernike==olderZernike);   % Check which zernike modes remained the same    
        newZernike(equal)=oldZernike(equal);    % Keep equal zernike values    
        pos=find(oldZernike > olderZernike);    % Check which zernike modes increased
        if ismember(1,pos)==1
            newZernike(1)=oldZernike(2)+0.1;    % Add 0.1 to Tip & Tilt
        end
        if ismember(2,pos)==1
            newZernike(2)=oldZernike(2)+0.1;
        end
        nextModes=pos(pos~=1 & pos~=2);
        newZernike(nextModes)=oldZernike(nextModes)+0.4;    % Add 0.4 to the rest
        neg=find(oldZernike < olderZernike);  % Check which zernike modes deccreased
        if ismember(1,neg)==1
            newZernike(1)=oldZernike(1)-0.1;    % Subtract 0.1 from Tip & Tilt
        end
        if ismember(2,neg)==1
            newZernike(2)=oldZernike(2)-0.1;
        end
        nextModes=neg(neg~=1 & neg~=2);
        newZernike(nextModes)=oldZernike(nextModes)-0.4;    % Subtract 0.4 from the rest
        Min=find(newZernike < -10);   % Keep zernike from -10 to 10
        newZernike(Min)=-10;
        Max=find(newZernike > 10);
        newZernike(Max)=10;
    else
        newZernike=GenerateRandVec(30,-10,0.1,10);
        fprintf("Image was not improved")
        fprintf('\n');
    end
end