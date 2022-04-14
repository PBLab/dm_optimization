<<<<<<< Updated upstream
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
=======
function DMoptimization_v2 (src,evt,varargin)
% User function for ScanImage, performs after pressing "Start" button
%
%

%local copy of hSI
hSI = src.hSI;

%% #HARCODED values
GENES_IN_POP = 30; % Number of genes (Zernike modes) #HARDCODED
INIT_INTERVAL_LEN_SEC = 10;% this is an initial guess of how it takes to acquire AND process each generation

%% parameters from GUI
generations_to_run = getappdata(0,'generationsNum'); %Number of generations
pop_size = getappdata(0,'popSize'); % Population size (number of Zernike vectors), must be even
frames_per_image = getappdata(0,'framesPerImg');
channel_num = getappdata(0,'channel');

%% Define persistent variables, used as a mechanism for data sharing between
%function calls
persistent pop %current population
% persistent new population to update mirror after computing fitness for all individuals
persistent dm
persistent Z2C
% persistent img_array
persistent data_stream %structure of size [popSize * generations] with fields gen_num, img, fitness, genes
persistent generation_counter
persistent fitness_function_handle
persistent curr_gen_best_img
persistent prev_gen_best_img
persistent T0
persistent highest_fitness



%% initialize mirror
mirrorSN = 'BAX278';
[dm, Z2C] = initMirror(mirrorSN);

%%
switch evt.EventName
    case {'acqModeStart'}
        %set up SI acquisition parameters based on user parameters. We will
        %opt for a loop mode such that each "generation" will go into a
        %separate loop, there is heavier processing at this time that we
        %need to time in order to avoid loosing frames.
        clc
        T0=clock;
        fprintf('Start of DM optimization cycle\n');
        
        %% setup loop acquisition parameters
        
        %in each loop, we acquire popSize images
        hSI.acqsPerLoop = generations_to_run;
        
        %set the average display to match framesPerImg and then use the
        %already averaged image to save processing.
        %              hSI.hDisplay.displayRollingAverageFactor = framesPerImg;
        %set the average display to match framesPerImg and then use the already averaged image to save processing.
        hSI.hDisplay.displayRollingAverageFactor = frames_per_image;
        
        %set the number of frames to acquire in each loop (i.e. generation) as popSize * framesPerImg;
        hSI.hStackManager.framesPerSlice = pop_size * frames_per_image;
        hSI.hStackManager.framesPerSlice = checkIfTotalFramesAreMultiple(frames_per_image * pop_size, hSI.hStackManager.framesPerSlice);
    
        %set timer - could be better estimated but good enough to beging
        hSI.loopAcqInterval = INIT_INTERVAL_LEN_SEC;
        %% initialize data structure and population counter
        data_stream = struct('gen_num',[],'img_num',[],'zernike_vals',[],...
            'img_data',[],'fitness_val',[],'ismax',[],'time_stamp',[]); 
        
        %initialize persistent values
        generation_counter = 1;
        highest_fitness = -Inf;
        
        %clear plots
        cla(getappdata(0,'axes_fitness'));
        cla(getappdata(0,'axes_image_data'));
        cla(getappdata(0,'axes_image_best'));
        cla(getappdata(0,'axes_image_diff'));

        %turn off warnings
        warning off
        %% populate mirror with random population or the one selected by user
        
        %load pop from file
        
        %create random 
        pop = initialize (pop_size,GENES_IN_POP);
        
        %send first individual (zernike modes) to mirror
        MirrorCommand(dm, pop(1,1:GENES_IN_POP), Z2C)
        
<<<<<<< Updated upstream:DMoptimization_v2.m
        %define fitness_function_handle to use based on user choise
        fitness_function_handle = @fitnessFun; %not implemented yet....
    
=======
        %         %define fitness_function_handle to use based on user choise
        fitness_function_handle = getappdata(0,'selected_fitness_function');
        fprintf('\nGeneration %d',generation_counter);
>>>>>>> Stashed changes:DMoptimization.m
    case {'frameAcquired'}
        
        frame_num=hSI.hDisplay.lastFrameNumber;
        %check if we have a new averaged image
        if mod(frame_num,frames_per_image)== 0
            %store averaged frame each time that frames_per_img where acquired data
            
            img_num = frame_num/frames_per_image;
            img =  hSI.hDisplay.lastAveragedFrame{1, channel_num};
            data_stream(img_num) = struct('gen_num',generation_counter,...
                'img_num',img_num,...
                'zernike_vals',pop(img_num,1:GENES_IN_POP),...
                'img_data',img,...
                'fitness_val',-inf,... %we flag -inf so fitness function will work on it
                'ismax',0,...
                'time_stamp',hSI.hDisplay.lastFrameTimestamp);
            %send next zernike to mirror make sure not to go beyond pop
            %size, this indicates that we finished a generation
<<<<<<< Updated upstream:DMoptimization_v2.m
            if img_num < pop_size
                MirrorCommand(dm, pop(img_num,1:GENES_IN_POP), Z2C);
                fprintf('\n Next ind sent to mirror')
            else
                %evaluate current population
                fprintf('\n\t Computing fitness values')
                   [data_stream,fittest_ind_id] = ...
                    compute_fitness_for_current_generation(data_stream,fitness_function_handle);
                %assignin('base','data_stream',data_stream);%DEV
                
                %send best individual to mirror
                MirrorCommand(dm, pop(img_num,1:GENES_IN_POP), Z2C);
                
                %run GA
                fittest_ind_id = fittest_ind_id - pop_size*(gene
                 pop = geneticAlgorithm(pop,GENES_IN_POP,pop_size);

                
=======
            if ind_num < pop_size
                MirrorCommand(dm, pop(ind_num,1:GENES_IN_POP), Z2C);
                %fprintf('\n Next ind sent to mirror')
            else
                
                try
                    %% evaluate current population
                    fprintf('\n\tComputing fitness...')
                    t = clock;
                    [data_stream,fittest_ind_id] = ...
                        compute_fitness_for_current_generation(data_stream,fitness_function_handle);
                    if data_stream(fittest_ind_id).fitness_val > highest_fitness
                        highest_fitness = data_stream(fittest_ind_id).fitness_val;
                        curr_gen_best_img = data_stream(fittest_ind_id).img_data;
                    end
                    fprintf('done in %.4fs',etime(clock, t));
                   
                    %send best individual to mirror
                    MirrorCommand(dm, data_stream(fittest_ind_id).zernike_vals, Z2C);
                    
                    %append fitness values as one column after the zernike
                    %values... this is how pop is expected in the GA
                    %implementation
                    idx_in_current_generation = [data_stream.gen_num]==generation_counter;
                    img_nums_in_current_generation = [data_stream(idx_in_current_generation).img_num]';
                    fitness_vals = [data_stream(idx_in_current_generation).fitness_val]';
                    %set NaN to zero... no the best approach but is a safegard
                    fitness_vals(isnan(fitness_vals))=0;
                    pop = [pop fitness_vals];
                    
                    %% Update display
                    plot_fitness(img_nums_in_current_generation, fitness_vals)
                   
                    if isempty(prev_gen_best_img);prev_gen_best_img=curr_gen_best_img;end %first gen
                    plot_images(prev_gen_best_img, curr_gen_best_img)

                    %% run GA
                    t = clock;
                    fprintf('\n\tRunning GA...')
                   
                    pop = geneticAlgorithm(pop,GENES_IN_POP,pop_size);
                    fprintf('done in %.4fs',etime(clock, t));
                    
                    
                    %prepare next gen
                    prev_gen_best_img = curr_gen_best_img;
                    generation_counter = generation_counter + 1;
                    fprintf('\nGeneration %d',generation_counter);
                    
                catch
                    fprintf('\nABORT! \nCaught error %s',lasterr)
                    evalin('base','hSI.abort');
                end
>>>>>>> Stashed changes:DMoptimization.m
            end
        end
        
        
<<<<<<< Updated upstream:DMoptimization_v2.m
    
    case {'acqDone'}
        % Find the best Zernike vector in the final population and send it
        %         % to the mirror
        %         [row,~]=find(returnedPop(:,genesNum+1)==min(returnedPop(:,genesNum+1)));
        %         bestVec = returnedPop(row(1),1:genesNum);
        %         MirrorCommand(dm, bestVec, Z2C);
        %         time_str = datestr(now,'yyyy-mm-dd_HH:MM');
        %         save(sprintf('%s_best_vec.mat',time_str),'bestVec');
        %         save(sprintf('%s_final_pop.mat',time_str),'returnedPop');
        %         save(sprintf('%s_data.mat',time_str),'iteration_log');
        
        fprintf('Command sent\n');
=======
        
    case {'acqModeDone'}
        % Find the best Zernike vector in the final population and send it
        %restore warnings
        warning on       
        assignin('base','data_stream',data_stream);%DEV
        assignin('base','pop',pop);%DEV
        fprintf('\n\nCompleted DM optimization in %.4f\n',etime(clock,T0));
>>>>>>> Stashed changes:DMoptimization.m
        
    case {'acqAbort'}
        %clean up
        assignin('base','data_stream',data_stream);%DEV
        assignin('base','pop',pop);%DEV
        
        %restore warnings
        warning on
end
>>>>>>> Stashed changes
end