function [optim_params, window_research_result] = FindingOptimalWindowSize(varargin)
%% Parsing input variable
    defaultParallelComputing = 'on';
    expectedOnOff = {'on','off'};
    
    p = inputParser;
    addRequired(p, 'ReferenceImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NoiseImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addRequired(p, 'Metrics', @(x) isstring(x))
    addRequired(p, 'MetricsInteraction', @(x) any(validatestring(x, expectedOnOff)))
    addRequired(p, 'kThershold', @(x) isnumeric(x))
    addParameter(p, 'ResearchResult', @(x) isstruct(x))
    addParameter(p, 'ParallelComputing', defaultParallelComputing, @(x) any(validatestring(x, expectedOnOff)))
 
    parse(p, varargin{:});
    
 %% Window size research   
    test_image = p.Results.ReferenceImage;
    noise_image = p.Results.NoiseImage;
    filter_name = p.Results.NameOfFilter;
    metric_names = p.Results.Metrics;
    metric_names_len = length(metric_names);
    k_thershold = p.Results.kThershold;
    research_result = p.Results.ResearchResult;
    if (isstruct(research_result))
        field_names = fieldnames(research_result)'; 
        opt_params_fields = GetOptimalParametersFields(field_names);
    end
        
    win_size_var = 3:2:45; 
    num_win_size = numel(win_size_var);
    window_research_result.WindowSideSizeVals = win_size_var;
    metrcis_vals_table = zeros(metric_names_len, length(win_size_var));
    
    tic
    fprintf(strcat("Finding for optimal window size of ", filter_name, "...\n"));
    if (strcmp(p.Results.ParallelComputing, 'on'))
        warning('Parralel computing are on, the iteration order may be violated.');
        if (~isstruct(research_result))
            parfor idx = 1:num_win_size 
                metric_names_tmp = metric_names;
                win_size_var_tmp = win_size_var;
                i = win_size_var_tmp(idx);
                win_size = [i,i]; 
                for k = 1:metric_names_len
                    filt_img = feval(filter_name, noise_image, win_size); %%filtering 
                    metrcis_vals_table(k,idx) = feval(metric_names_tmp(k), filt_img, test_image);     
                end
                fprintf('%d iteration of %d\n', idx, length(win_size_var_tmp));
            end
            toc
        elseif (size(research_result.(opt_params_fields{1}), 2) == 2)
            parfor idx = 1:num_win_size 
                research_result_tmp = research_result;
                opt_params_fields_tmp = opt_params_fields;
                metric_names_tmp = metric_names;
                win_size_var_tmp = win_size_var;
                i = win_size_var_tmp(idx);
                win_size = [i,i]; 
                for k = 1:metric_names_len
                    filt_img = feval(filter_name, noise_image, ...
                        win_size, research_result_tmp.(opt_params_fields_tmp{k})(1)); %%filtering 
                    metrcis_vals_table(k,idx) = feval(metric_names_tmp(k), filt_img, test_image);     
                end
                fprintf('%d iteration of %d\n', idx, length(win_size_var_tmp));
            end
            toc
        elseif (size(research_result.(opt_params_fields{1}), 2) == 3)
            parfor idx = 1:num_win_size 
                research_result_tmp = research_result;
                opt_params_fields_tmp = opt_params_fields;
                metric_names_tmp = metric_names;
                win_size_var_tmp = win_size_var;
                i = win_size_var_tmp(idx);
                win_size = [i,i]; 
                for k = 1:metric_names_len
                    filt_img = feval(filter_name, noise_image, win_size, ...
                        research_result_tmp.(opt_params_fields_tmp{k})(1), ...
                        research_result_tmp.(opt_params_fields_tmp{k})(2)); %%filtering 
                    metrcis_vals_table(k,idx) = feval(metric_names_tmp(k), filt_img, test_image);     
                end
                fprintf('%d iteration of %d\n', idx, length(win_size_var_tmp));
            end
            toc
        elseif (size(research_result.(opt_params_fields{1}), 2) == 4)
            parfor idx = 1:num_win_size 
                research_result_tmp = research_result;
                opt_params_fields_tmp = opt_params_fields;
                metric_names_tmp = metric_names;
                win_size_var_tmp = win_size_var;
                i = win_size_var_tmp(idx);
                win_size = [i,i]; 
                for k = 1:metric_names_len
                    filt_img = feval(filter_name, noise_image, win_size, ...
                        research_result_tmp.(opt_params_fields_tmp{k})(1), ...
                        research_result_tmp.(opt_params_fields_tmp{k})(2), ...
                        research_result_tmp.(opt_params_fields_tmp{k})(3)); %%filtering 
                    metrcis_vals_table(k,idx) = feval(metric_names_tmp(k), filt_img, test_image);     
                end
                fprintf('%d iteration of %d\n', idx, length(win_size_var_tmp));
            end
            toc
        end
        for k = 1:metric_names_len
            window_research_result.(metric_names(k)) = metrcis_vals_table(k,:);
        end    
    else
        if (~isstruct(research_result))
            for idx = 1:num_win_size 
                i = win_size_var(idx);
                win_size = [i,i]; 
                for k = 1:metric_names_len
                    filt_img = feval(filter_name, noise_image, win_size); %%filtering 
                    window_research_result.(metric_names(k))(idx) = ...
                        feval(metric_names(k), filt_img, test_image);      
                end
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        elseif (size(research_result.(opt_params_fields{1}), 2) == 2)
            for idx = 1:num_win_size 
                i = win_size_var(idx);
                win_size = [i,i]; 
                for k = 1:metric_names_len
                    filt_img = feval(filter_name, noise_image, ...
                        win_size, research_result.(opt_params_fields{k})(1)); %%filtering 
                    window_research_result.(metric_names(k))(idx) = ...
                        feval(metric_names(k), filt_img, test_image);      
                end
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        elseif (size(research_result.(opt_params_fields{1}), 2) == 3)
            for idx = 1:num_win_size 
                i = win_size_var(idx);
                win_size = [i,i]; 
                for k = 1:metric_names_len
                    filt_img = feval(filter_name, noise_image, win_size, ...
                        research_result.(opt_params_fields{k})(1), ...
                        research_result.(opt_params_fields{k})(2)); %%filtering 
                    window_research_result.(metric_names(k))(idx) = ...
                        feval(metric_names(k), filt_img, test_image);      
                end
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        elseif (size(research_result.(opt_params_fields{1}), 2) == 4)
            for idx = 1:num_win_size 
                i = win_size_var(idx);
                win_size = [i,i]; 
                for k = 1:metric_names_len
                    filt_img = feval(filter_name, noise_image, win_size, ...
                        research_result.(opt_params_fields{k})(1), ...
                        research_result.(opt_params_fields{k})(2), ...
                        research_result.(opt_params_fields{k})(3)); %%filtering 
                    window_research_result.(metric_names(k))(idx) = ...
                        feval(metric_names(k), filt_img, test_image);      
                end
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        end
    end
    optim_params = GetOptimalParamsByInterval(window_research_result, k_thershold, p.Results.MetricsInteraction);
    window_research_result = catstruct(window_research_result, optim_params); 
end