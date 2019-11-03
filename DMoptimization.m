function DMoptimization (src,evt,varargin)
% User function for ScanImage, performs after pressing "Start" button
hSI = src.hSI;
genesNum=30;    % Number of genes (Zernike modes)
popSize=10;     % Population size (number of Zernike vectors), 
                % must be an even number

persistent pop
persistent returnedPop
persistent dm
persistent Z2C

switch evt.EventName
    case {'acqModeStart'}
        % Initialize Zernike vectors population and send command to the
        % mirror
        fileName=getappdata(0,'fileName');
        filePath=getappdata(0,'filePath');
        mirrorSN = 'BAX278';
        [dm, Z2C] = initMirror(mirrorSN);
        if fileName==0
            disp('No initial population was selected');
            pop = initialize (popSize,genesNum);
        else
            pop=importdata([filePath fileName]);
        end
        disp(pop)

    case {'frameAcquired'}
        frameNum=hSI.hDisplay.lastFrameNumber;
        img=hSI.hDisplay.lastFrame{1, 1};
        individualNum = mod(frameNum, popSize);
        
        % During the popSize'th frame we're both updating the population
        % vector and running the algorithm. Otherwise we're just updating
        % the vector.
        if mod(frameNum, popSize) ~= 0
            [pop, returnedPop] = fillFitnessValue(individualNum, img, pop, genesNum, dm, Z2C);
        else
            % Call pipeline to create new generations, apply genetic algorithm
            % and send mirror commands
            [pop, returnedPop] = runAlgorithm(img, pop, genesNum, popSize, dm, Z2C);
        end
        graphParams(frameNum, fitnessFun(img));
        
    case {'acqDone'}
        % Find the best Zernike vector in the final population and send it
        % to the mirror
        [row,~]=find(returnedPop(:,genesNum+1)==max(returnedPop(:,genesNum+1)));
        MirrorCommand(dm, pop(row(1),1:genesNum), Z2C)
end
end