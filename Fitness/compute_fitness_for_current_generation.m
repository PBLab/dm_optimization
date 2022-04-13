function [data_stream,fittest_ind_id] = compute_fitness_for_current_generation(data_stream,fitness_function_handle)



%% find images wiht -Inf fitness
idx = find([data_stream.fitness_val]==-Inf);

for idx_i = idx
    fitness = fitness_function_handle(data_stream(idx_i).img_data);
    data_stream(idx_i).fitness_val = fitness;
end


%% find fittest
[~,max_i] = max([data_stream(idx).fitness_val]);
fittest_ind_id = idx(max_i);