function DMoptimization (src,evt,varargin)
% User function for ScanImage, performs after pressing "Start" button
hSI = src.hSI;
genesNum=30;    % Number of genes (Zernike modes)
popSize=10;     % Population size (number of Zernike vectors), 
                % must be an even number

persistent pop
persistent returnedPop

switch evt.EventName
    case {'acqModeStart'}
        % Initialize Zernike vectors population and send command to the
        % mirror
        fileName=getappdata(0,'fileName');
        filePath=getappdata(0,'filePath');
        
        if fileName==0
            disp('No initial population was selected');
            pop = initialize (popSize,genesNum);
            disp(pop)
        else
            pop=importdata([filePath fileName]);
            MirrorCommand(pop(1,1:genesNum));
            fprintf('Command sent\n');
            disp(pop)
        end

    case {'frameAcquired'}
        frameNum=hSI.hDisplay.lastFrameNumber;
        fprintf('Frame number: %d\n',frameNum)
        img=hSI.hDisplay.lastFrame{1, 1};
        % Call pipeline to create new generations, apply genetic algorithm
        % and send mirror commands
        [pop, returnedPop]=pipeline(frameNum,img,pop,genesNum,popSize);
        % Plot the new parameters for each frame taken
        graphParams(frameNum, fitnessFun(img));
        
    case {'acqDone'}
        % Find the best Zernike vector in the final population and send it
        % to the mirror
        [row,~]=find(returnedPop(:,genesNum+1)==max(returnedPop(:,genesNum+1)));
        MirrorCommand(pop(row(1),1:genesNum))
end
end