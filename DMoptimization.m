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

global best_image
global highest_fit_value 
rows = generationsNum * popSize;
fitness_vec = zeros(rows,1);

mirrorSN = 'BAX278';
[dm, Z2C] = initMirror(mirrorSN);

switch evt.EventName
    case {'acqModeStart'}
        clc
        fprintf('Start of DM optimization cycle\n');        
        
        vecName=getappdata(0,'vecName'); % loaded vector for mirror update
        vecPath=getappdata(0,'vecPath');
        if vecName ~=0
            % Send loaded vector to the mirror, if exists
            vecToSend = importdata([vecPath vecName]);
            MirrorCommand(dm, vecToSend, Z2C)
            fprintf('Initial population command sent\n'); %here we're talking to the mirror, when we start the acquisition
        else
            % Initialize Zernike vectors population and send command to the
            % mirror
            fileName=getappdata(0,'fileName');
            filePath=getappdata(0,'filePath');
            if fileName==0
                disp('No initial population was selected. Generating population');
                pop = initialize (popSize,genesNum);
            else
                pop=importdata([filePath fileName]);
                MirrorCommand(dm, pop(1,1:genesNum), Z2C)
                fprintf('Command sent\n');
            end
            img_array = zeros(hSI.hRoiManager.linesPerFrame,hSI.hRoiManager.pixelsPerLine,framesPerImg);
            hSI.hStackManager.framesPerSlice = generationsNum * popSize * framesPerImg;
            hSI.hStackManager.framesPerSlice = checkIfTotalFramesAreMultiple(framesPerImg * popSize, hSI.hStackManager.framesPerSlice);
            %fprint(hSI.hStackManager.framesPerSlice);
            
        end
    case {'frameAcquired'}
       % vecName=getappdata(0,'vecName'); % loaded vector for mirror update
        %         if vecName ==0
        
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
            plot_data(img,fitness,imgNum)
            graphParams(imgNum, fitness);
            %time_str = datestr(now,'YYYYmmdd');
            %fitness_vec(imgNum,1) = time_str;
            %fitness_vec(imgNum) = fitness;
            %save(sprintf('%s_fitness_values.mat',time_str),'fitness_vec')
            
            
        end
       % end
        %time_str = datestr(now,'YYYYmmdd');
        %save(sprintf('%s_fitness_values.mat',time_str),'fitness_vec')
    case {'acqDone'}
        % Find the best Zernike vector in the final population and send it
        % to the mirror
        [row,~]=find(returnedPop(:,genesNum+1)==min(returnedPop(:,genesNum+1)));
        bestVec = returnedPop(row(1),1:genesNum);
        MirrorCommand(dm, bestVec, Z2C)
        time_str = datestr(now,'yyyy-mm-dd_HH:MM');
        save(sprintf('%s_best_vec.mat',time_str),'bestVec')
        save(sprintf('%s_final_pop.mat',time_str),'returnedPop')
        save(sprintf('%s_best_image.fig',time_str),'best_image')
        save(sprintf('%s_highest_fit_value.mat',time_str),'highest_fit_value')
        
        fprintf('Command sent\n');
        
end
end