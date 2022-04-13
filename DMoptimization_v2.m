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

%% Dpersistent variables, used as a mechanism for data sharing between
%function calls
persistent pop %current population
% persistent new population to update mirror after computing fitness for all individuals
persistent dm
persistent Z2C
% persistent img_array
persistent data_stream %structure of size [popSize * generations] with fields gen_num, img, fitness, genes
persistent generation_counter
persistent fitness_function_handle
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
        
        generation_counter = 1;
        
        %% populate mirror with random population or the one selected by user
        
        %load pop from file
        
        %create random 
        pop = initialize (pop_size,GENES_IN_POP);
        
        %send first individual (zernike modes) to mirror
        MirrorCommand(dm, pop(1,1:GENES_IN_POP), Z2C)
        
        %define fitness_function_handle to use based on user choise
        fitness_function_handle = @fitnessFun; %not implemented yet....
    
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

                
            end
        end
        
        
    
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
        
    case {'acqAbort'}
        %clean up
end
end