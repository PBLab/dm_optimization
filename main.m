%% Create an array of images
folder = 'C:\Users\Nitzan\Google Drive\senior year\wavefront project\img';
filePattern = fullfile(folder, '*.tif');
f=dir(filePattern);
baseName='img_';
files={f.name};
for k=1:numel(files)
  fullFileName = fullfile(folder,[baseName,num2str(k),'.tif']);
  ArrayOfImg{k}=imread(fullFileName);
  %imshow(ArrayOfImages{k});
end
%% Main Algorithm
Z2C=importdata('BAX278-Z2C.mat');
nZern = size(Z2C, 1);
% Original zernike vector for the first image
OriginZern=GenerateRandVec(nZern,-10,0.1,10);   
% Second zernike vector for the second image
AddVec=zeros(1,nZern);
for n=1:nZern
    AddVec(n)=GenerateRandVec(1,-10-OriginZern(n),0.1,10-OriginZern(n));
end
zernikeVector = OriginZern+AddVec;
% Update mirror
DMvec = MirrorCommand(OriginZern,nZern,Z2C);
DMvec = MirrorCommand(zernikeVector,nZern,Z2C);
% Store all zernike vectors in a matrix
ZernMat=zeros(length(ArrayOfImg)+1,nZern);
ZernMat(1,:)=OriginZern;
ZernMat(2,:)=zernikeVector;
% Iterative optimization
for i=2:length(ArrayOfImg)
    if mean(mean(ArrayOfImg{i}))>= mean(mean(ArrayOfImg{i-1}))
        equal=find(ZernMat(i,:)==ZernMat(i-1,:));   % Keep equal zernike values
        ZernMat(i+1,equal)=ZernMat(i,equal);
        pos=find(ZernMat(i,:)>ZernMat(i-1,:));  % Check which zernike modes increased
        if ismember(1,pos)==1
            ZernMat(i+1,1)=ZernMat(i,1)+0.1;    % Add 0.1 to Tip & Tilt
        end
        if ismember(2,pos)==1
            ZernMat(i+1,2)=ZernMat(i,2)+0.1;
        end
        nextModes=pos(pos~=1 & pos~=2);
        ZernMat(i+1,nextModes)=ZernMat(i,nextModes)+0.4;    % Add 0.4 to the rest
        neg=find(ZernMat(i,:)<ZernMat(i-1,:));  % Check which zernike modes deccreased
        if ismember(1,neg)==1
            ZernMat(i+1,1)=ZernMat(i,1)-0.1;    % Subtract 0.1 from Tip & Tilt
        end
        if ismember(2,neg)==1
            ZernMat(i+1,2)=ZernMat(i,2)-0.1;
        end
        nextModes=neg(neg~=1 & neg~=2);
        ZernMat(i+1,nextModes)=ZernMat(i,nextModes)-0.4;    % Subtract 0.4 from the rest
        Min=find(ZernMat(i+1,:)<-10);   % Keep zernike from -10 to 10
        ZernMat(i+1,Min)=-10;
        Max=find(ZernMat(i+1,:)>10);
        ZernMat(i+1,Max)=10;
        DMvec = MirrorCommand(ZernMat(i+1,:),nZern,Z2C);    % Update mirror
    else
        equal=find(ZernMat(i-1,:)==ZernMat(i-2,:));   % Keep equal zernike values
        ZernMat(i+1,equal)=ZernMat(i-1,equal);
        pos=find(ZernMat(i-1,:)>ZernMat(i-2,:));    % Check which zernike modes increased in the previous iteration
        if ismember(1,pos)==1
            ZernMat(i+1,1)=ZernMat(i-1,1);    % Set Tip & Tilt as previous iteration
        end
        if ismember(2,pos)==1
            ZernMat(i+1,2)=ZernMat(i-1,2);
        end
        nextModes=pos(pos~=1 & pos~=2);
        ZernMat(i+1,nextModes)=ZernMat(i-1,nextModes)+0.1;    % Add 0.1 to the rest
        neg=find(ZernMat(i-1,:)<ZernMat(i-2,:));    % Check which zernike modes decreased in the previous iteration
        if ismember(1,neg)==1
            ZernMat(i+1,1)=ZernMat(i-1,1);    % Set Tip & Tilt as previous iteration
        end
        if ismember(2,neg)==1
            ZernMat(i+1,2)=ZernMat(i-1,2);
        end       
        nextModes=neg(neg~=1 & neg~=2);
        ZernMat(i+1,nextModes)=ZernMat(i-1,nextModes)-0.1;    % Subtract 0.1 from the rest
        Min=find(ZernMat(i+1,:)<-10);   % Keep zernike from -10 to 10
        ZernMat(i+1,Min)=-10;
        Max=find(ZernMat(i+1,:)>10);
        ZernMat(i+1,Max)=10;
        DMvec = MirrorCommand(ZernMat(i+1,:),nZern,Z2C);    % Update mirror
        ZernMat(i,:)=ZernMat(i-1,:);    % Set the current Zernike vector as the previous one
    end                  
end