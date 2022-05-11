function best_zernike_modes = write_data_strem(session_id,output_dir_name,data_stream,success_flag)
%function write output files to directory and returns best zernike modes so
%mirror can be updated.
%call function with session_id = 0 to append 'unfinished' to session name.


t_save = clock;

if success_flag == 0
    session_id = [session_id '_unfinished'];
end
   
%% Create directory with session ID
path_to_dir = fullfile(output_dir_name,session_id);
status = mkdir(path_to_dir);
if status < 1
    error("Couldn't create output dir %s",path_to_dir);
end

%% gather some data to save
[~, best_fitness_ind] = max([data_stream.fitness_val]);
best_zernike_modes =  data_stream(best_fitness_ind).zernike_vals;

%% save
%data_strea
save(fullfile(path_to_dir,'data_stream.mat'),'data_stream');
%zernike modes
save(fullfile(path_to_dir,'best_individual_zernike.mat'),...
    'best_zernike_modes');
%best image
imwrite(data_stream(best_fitness_ind).img_data,...
    fullfile(path_to_dir,'best_individual_image.png'));
%%
fprintf('\n\nSaved data in %.4f\n',etime(clock,t_save));
