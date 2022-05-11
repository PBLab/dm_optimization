function pop = initialize (params)
%initialize population based on user selected init mode
%inputs in params structure
% .pop_size - number of individuals in each generation
% .num_of_genes - this has to match the nubmer of zernike modes in DM
% .init_pop_mode - a user selected mode
%   'Random pop' - fully random with Hardcoded range 
%   'Random from best' - add random variance around best, requires
%   .variance and .best
%   'Random from last' - same as 'Random from best'

%%

switch params.init_pop_mode
    case 'Random pop'
        pop = zeros(params.pop_size, params.num_of_genes);
        for ii=2:params.pop_size
            pop(ii,1:params.num_of_genes)= GenerateRandVec(...
                params.num_of_genes,...
            -params.variance_rand,0.1,params.variance_rand);
        end
        
    case {'Random from best','Random from last'}
        pop = zeros(params.pop_size, params.num_of_genes);
        for ii=1:params.pop_size
            pop(ii,1:params.num_of_genes)= GenerateRandVec(...
                params.num_of_genes,...
            -params.variance_best,0.1,params.variance_best);
        end
        pop = pop + params.best;
end