function DMoptimization (src,evt,varargin)
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
        
        %define fitness_function_handle to use based on user choise
        fitness_function_handle = getappdata(0,'selected_fitness_function');
        fprintf('\nGeneration %d',generation_counter);
        
    case {'frameAcquired'}
        
        frame_num=hSI.hDisplay.lastFrameNumber;
        %check if we have a new averaged image
        if mod(frame_num,frames_per_image)== 0
            %store averaged frame each time that frames_per_img where acquired data
            
            img_num = frame_num/frames_per_image;
            ind_num = img_num - pop_size*(generation_counter-1);
            img =  hSI.hDisplay.lastAveragedFrame{1, channel_num};
            data_stream(img_num) = struct('gen_num',generation_counter,...
                'img_num',img_num,...
                'zernike_vals',pop(ind_num,1:GENES_IN_POP),...
                'img_data',img,...
                'fitness_val',-inf,... %we flag -inf so fitness function will work on it
                'ismax',0,...
                'time_stamp',hSI.hDisplay.lastFrameTimestamp);
            %send next zernike to mirror make sure not to go beyond pop
            %size, this indicates that we finished a generation
            
            if ind_num < pop_size
                MirrorCommand(dm, pop(ind_num,1:GENES_IN_POP), Z2C);
                fprintf('\n Next ind sent to mirror')
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
                end %try/catch
                
            end
        end
        
        
        
    case {'acqModeDone'}
        % Find the best Zernike vector in the final population and send it
        %restore warnings
        warning on
        assignin('base','data_stream',data_stream);%DEV
        assignin('base','pop',pop);%DEV
        fprintf('\n\nCompleted DM optimization in %.4f\n',etime(clock,T0));
        
        
    case {'acqAbort'}
        %clean up
        assignin('base','data_stream',data_stream);%DEV
        assignin('base','pop',pop);%DEV
        
        %restore warnings
        warning on
end
