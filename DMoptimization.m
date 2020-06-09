function DMoptimization (src,evt,varargin)
% User function for ScanImage, performs after pressing "Start" button
hSI = src.hSI;    
genesNum = 30; % Number of genes (Zernike modes)
generationsNum = getappdata(0,'generationsNum'); %Number of generations
popSize = getappdata(0,'popSize'); % Population size (number of Zernike vectors), must be even
framesPerImg = getappdata(0,'framesPerImg');
channel = getappdata(0,'channel');

persistent pop
persistent returnedPop
persistent dm
persistent Z2C
persistent img_array

mirrorSN = 'BAX278';
[dm, Z2C] = initMirror(mirrorSN);

switch evt.EventName
    case {'acqModeStart'}
        vecName=getappdata(0,'vecName'); % loaded vector for mirror update
        vecPath=getappdata(0,'vecPath');
        if vecName ~=0
            % Send loaded vector to the mirror, if exists 
            vecToSend = importdata([vecPath vecName]);
            MirrorCommand(dm, vecToSend, Z2C)
            fprintf('Command sent\n'); 
        else
            % Initialize Zernike vectors population and send command to the
            % mirror
            fileName=getappdata(0,'fileName');
            filePath=getappdata(0,'filePath');
            if fileName==0
                disp('No initial population was selected');
                pop = initialize (popSize,genesNum);
            else
                pop=importdata([filePath fileName]);
                MirrorCommand(dm, pop(1,1:genesNum), Z2C)
                fprintf('Command sent\n'); 
            end
            img_array = zeros(hSI.hRoiManager.linesPerFrame,hSI.hRoiManager.pixelsPerLine,framesPerImg);
            hSI.hStackManager.framesPerSlice = generationsNum * popSize * framesPerImg;
            hSI.hStackManager.framesPerSlice = checkIfTotalFramesAreMultiple(framesPerImg * popSize, hSI.hStackManager.framesPerSlice);
        end
    case {'frameAcquired'}
        vecName=getappdata(0,'vecName'); % loaded vector for mirror update
        if vecName ==0
            % Run algorithm if no single vector was loaded
            frameNum=hSI.hDisplay.lastFrameNumber;
            if mod(frameNum,framesPerImg)~= 0 
                img_array(:,:,mod(frameNum,framesPerImg)) = hSI.hDisplay.lastFrame{1, channel};
            else
                img = mean(img_array, 3);
                imgNum = floor(frameNum / framesPerImg);
                individualNum = mod(imgNum, popSize);
                % During the popSize'th frame we're both updating the population
                % vector and running the algorithm. Otherwise we're just updating
                % the vector.
                if mod(imgNum, popSize) ~= 0 
                    [pop, fitness] = fillFitnessValue(individualNum, img, pop, genesNum, dm, Z2C);
                else
                    % Call pipeline to create new generations, apply genetic algorithm
                    % and send mirror commands
                    disp('Running algorithm for last frames');
                    [pop, returnedPop, fitness] = runAlgorithm(img, pop, genesNum, popSize, dm, Z2C);
                    if imgNum == popSize
                        save('first_pop.mat','returnedPop')
                    end
                end
                graphParams(imgNum, fitness);
            end
        end
    case {'acqDone'}
        % Find the best Zernike vector in the final population and send it
        % to the mirror
        [row,~]=find(returnedPop(:,genesNum+1)==min(returnedPop(:,genesNum+1)));
        bestVec = returnedPop(row(1),1:genesNum);
        MirrorCommand(dm, bestVec, Z2C)
        save('best_vec.mat','bestVec')
        save('final_pop.mat','returnedPop')
        fprintf('Command sent\n');  
        
end
end