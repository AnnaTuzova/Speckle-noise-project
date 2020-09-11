function  [optim_params, research_result] = FindingTwoOptimalParameter(varargin)
%% Parsing input variable
    defaultParallelComputing = 'on';
    expectedOnOff = {'on','off'};
    
    p = inputParser;
    addRequired(p, 'ReferenceImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NoiseImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addRequired(p, 'FirstFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addRequired(p, 'SecondFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addRequired(p, 'Metrics', @(x) isstring(x))
    addRequired(p, 'MetricsInteraction', @(x) any(validatestring(x, expectedOnOff)))
    addRequired(p, 'kThershold', @(x) isnumeric(x))
    addParameter(p, 'WindowSize', @(x) (isnumeric(x) && all(x(:) >= 0)) || (isstruct(x)))
    addParameter(p, 'ThirdParameter',  @(x) isnumeric(x) || (isstruct(x)))
    addParameter(p, 'ParallelComputing', defaultParallelComputing, @(x) any(validatestring(x, expectedOnOff)))
    
    parse(p, varargin{:});    
%% Two variable parameter research 
    test_image = p.Results.ReferenceImage;
    noise_image = p.Results.NoiseImage;
    filter_name = p.Results.NameOfFilter;
    win_size = p.Results.WindowSize;
    param1_range = p.Results.FirstFilterParameterRange;
    param2_range = p.Results.SecondFilterParameterRange;
    metric_names = p.Results.Metrics;
    metric_names_len = length(metric_names);
    k_thershold = p.Results.kThershold;
    third_parameter = p.Results.ThirdParameter;
    
    if (isstruct(win_size) || isstruct(third_parameter))
        if (isstruct(win_size))
            field_names         = fieldnames(win_size)';
        else
            field_names         = fieldnames(third_parameter)';
        end
        opt_params_fields = GetOptimalParametersFields(field_names);
    else
        opt_params_fields = 1;
    end
    
    len_param1 = length(param1_range);
    len_param2 = length(param2_range);

    if(isnumeric(win_size) || isstruct(win_size))
        research_result.FirstParamRange     = param1_range;
        research_result.SecondParamRange	= param2_range;
    elseif(isnumeric(third_parameter) || isstruct(third_parameter))
        research_result.SecondParamRange     = param1_range;
        research_result.ThirdParamRange      = param2_range;
    end
    metrcis_vals_table = zeros(len_param1, len_param2);

    counter = reshape(1:length(param1_range)*length(param2_range), length(param2_range), length(param1_range)).';
    fprintf(strcat("Finding for optimal ", filter_name, " parameters...\n")); 
    tic
    if (strcmp(p.Results.ParallelComputing, 'on'))
        warning('Parralel computing are on, the iteration order may be violated.');
        for k = 1:metric_names_len
            parfor i = 1:len_param1
                metric_names_tmp = metric_names;    
                if(isnumeric(win_size) || isnumeric(third_parameter))
                    for j = 1:len_param2
                        if (isnumeric(win_size))
                            filt_img = feval(filter_name, noise_image, ...
                                win_size,  param1_range(i), param2_range(j)); %%filtering 
                        elseif (isnumeric(third_parameter))
                            filt_img = feval(filter_name, noise_image, ...
                            third_parameter, param1_range(i), param2_range(j)); %%filtering 
                        end
                        metrcis_vals_table(i,j) = feval(metric_names_tmp{k}, filt_img, test_image);
                        fprintf('%d iteration of %d\n', counter(i,j), length(param1_range)*length(param2_range));
                    end
                elseif (isstruct(win_size) || isstruct(third_parameter))
                    opt_params_fields_tmp = opt_params_fields;
                    for j = 1:len_param2
                        if (isstruct(win_size))
                            filt_img = feval(filter_name, noise_image, ...
                                [win_size.(opt_params_fields_tmp{k})(1) win_size.(opt_params_fields_tmp{k})(1)],...
                                param1_range(i), param2_range(j)); %%filtering 
                        elseif (isstruct(third_parameter))
                             filt_img = feval(filter_name, noise_image, ...
                                third_parameter.(opt_params_fields_tmp{k})(1),...
                                param1_range(i), param2_range(j)); %%filtering 
                        end
                        metrcis_vals_table(i,j) = feval(metric_names_tmp{k}, filt_img, test_image);
                        fprintf('%d iteration of %d\n', counter(i,j), length(param1_range)*length(param2_range));
                    end
                else
                    error('Error: wrong win_size variable structure.');
                end
            end
            research_result.(metric_names{k}) = metrcis_vals_table;
        end
        toc
    else
        for k = 1:metric_names_len
            for i = 1:len_param1
                if(isnumeric(win_size) || isnumeric(third_parameter))
                    for j = 1:len_param2
                        if (isnumeric(win_size))
                            filt_img = feval(filter_name, noise_image, ...
                                win_size,  param1_range(i), param2_range(j)); %%filtering 
                        elseif (isnumeric(third_parameter))
                            filt_img = feval(filter_name, noise_image, ...
                            third_parameter, param1_range(i), param2_range(j)); %%filtering 
                        end
                        metrcis_vals_table(i,j) = feval(metric_names{k}, filt_img, test_image);
                        fprintf('%d iteration of %d\n', counter(i,j), length(param1_range)*length(param2_range));
                    end
                elseif (isstruct(win_size) || isstruct(third_parameter))
                    for j = 1:len_param2
                        if (isstruct(win_size))
                            filt_img = feval(filter_name, noise_image, ...
                                [win_size.(opt_params_fields{k})(1) win_size.(opt_params_fields{k})(1)],...
                                param1_range(i), param2_range(j)); %%filtering 
                        elseif (isstruct(third_parameter))
                             filt_img = feval(filter_name, noise_image, ...
                                third_parameter.(opt_params_fields{k})(1),...
                                param1_range(i), param2_range(j)); %%filtering 
                        end
                        metrcis_vals_table(i,j) = feval(metric_names{k}, filt_img, test_image);
                        fprintf('%d iteration of %d\n', counter(i,j), length(param1_range)*length(param2_range));
                    end
                else
                    error('Error: wrong win_size variable structure.');
                end
            end
            research_result.(metric_names{k}) = metrcis_vals_table;
        end
        toc        
    end
    
    if(isnumeric(win_size) || isstruct(win_size))
        optim_params = GetOptimalParamsByInterval(research_result, k_thershold, p.Results.MetricsInteraction);
    elseif(isnumeric(third_parameter) || isstruct(third_parameter))
        optim_params_tmp = GetOptimalParamsByInterval(research_result, k_thershold, p.Results.MetricsInteraction);
        optim_params_tmp_field_names = fieldnames(optim_params_tmp);
        for k = 1:metric_names_len
            field_opt = strcat('OptimalFirstAndSecondAndThirdParamAnd', metric_names{k});
            if (isnumeric(third_parameter))
                optim_params.(field_opt) = [third_parameter, ...
                    optim_params_tmp.(optim_params_tmp_field_names{k})];
            elseif (isstruct(third_parameter))
                optim_params.(field_opt) = [third_parameter.(opt_params_fields{k})(1),...
                    optim_params_tmp.(optim_params_tmp_field_names{k})];
            end  
        end    
    end
    
    research_result = catstruct(research_result, optim_params); 
end