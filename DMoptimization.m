function DMoptimization (src,evt,varargin)
% User function for ScanImage, performs after pressing "Start" button
hSI = src.hSI;
genesNum=30;    % Number of genes (Zernike modes)
popSize=10;     % Population size (number of Zernike vectors), 
                % must be an even number
framesPerImg = 30;          

persistent pop
persistent returnedPop
persistent dm
persistent Z2C
persistent img_array

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
            MirrorCommand(dm, pop(1,1:genesNum), Z2C)
            fprintf('Command sent\n'); 
        end
        disp(pop)
        img_array = zeros(hSI.hRoiManager.linesPerFrame,hSI.hRoiManager.pixelsPerLine,framesPerImg);
        
    case {'frameAcquired'}
        frameNum=hSI.hDisplay.lastFrameNumber;
        fprintf('Frame number: %d\n',frameNum)
        if mod(frameNum,framesPerImg)~= 0 
            img_array(:,:,mod(frameNum,framesPerImg)) = hSI.hDisplay.lastFrame{1, 1};
        else
            img = mean(img_array, 3);
            imgNum = floor(frameNum / framesPerImg);
            individualNum = mod(imgNum, popSize);
            img = normalize_image(img);
            % During the popSize'th frame we're both updating the population
            % vector and running the algorithm. Otherwise we're just updating
            % the vector.
            if mod(imgNum, popSize) ~= 0
                [pop] = fillFitnessValue(individualNum, img, pop, genesNum, dm, Z2C);
            else
                if any(isnan(pop(:,genesNum+1)))
                    warning('No spots were found in the image')
                    hSI.abort();
                else
                    % Call pipeline to create new generations, apply genetic algorithm
                    % and send mirror commands
                    [pop, returnedPop] = runAlgorithm(img, pop, genesNum, popSize, dm, Z2C);
                end
            end
            graphParams(imgNum, fitnessFun(img));
        end
    case {'acqDone'}
        % Find the best Zernike vector in the final population and send it
        % to the mirror
        [row,~]=find(returnedPop(:,genesNum+1)==max(returnedPop(:,genesNum+1)));
        MirrorCommand(dm, pop(row(1),1:genesNum), Z2C)
        fprintf('Command sent\n');  
end
end