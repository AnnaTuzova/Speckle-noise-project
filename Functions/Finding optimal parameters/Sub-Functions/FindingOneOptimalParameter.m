function [optim_params, research_result] = FindingOneOptimalParameter(varargin)
%% Parsing input variable
    defaultParallelComputing = 'on';
    expectedOnOff = {'on','off'};
    
    p = inputParser;
    addRequired(p, 'ReferenceImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NoiseImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NameOfFilter', @(x) ischar(x)) 
    addRequired(p, 'FirstFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addRequired(p, 'Metrics', @(x) isstring(x))
    addRequired(p, 'MetricsInteraction', @(x) any(validatestring(x, expectedOnOff)))
    addRequired(p, 'kThershold', @(x) isnumeric(x))
    addParameter(p, 'WindowSize', @(x) (isnumeric(x) && all(x(:) >= 0)) || (isstruct(x)))
    addParameter(p, 'SecondAndThirdParametersResearch',  @(x) (isstruct(x)))
    addParameter(p, 'ParallelComputing', defaultParallelComputing, @(x) any(validatestring(x, expectedOnOff)))
    
    parse(p, varargin{:});
%% One variable parameter research 
    test_image = p.Results.ReferenceImage;
    noise_image = p.Results.NoiseImage;
    filter_name = p.Results.NameOfFilter;
    win_size = p.Results.WindowSize;
    param_range = p.Results.FirstFilterParameterRange;
    metric_names = p.Results.Metrics;
    metric_names_len = length(metric_names);
    k_thershold = p.Results.kThershold;
    second_third_research = p.Results.SecondAndThirdParametersResearch;

    if (isstruct(win_size) || isstruct(second_third_research))
         if (isstruct(win_size))
            field_names = fieldnames(win_size)';
        
        elseif (isstruct(second_third_research))
            field_names  = fieldnames(second_third_research)';
        end
        opt_params_fields = GetOptimalParametersFields(field_names);
    else
        opt_params_fields = 1;
    end

    len_param = length(param_range);
    research_result.FirstParamRange = param_range;
    metrcis_vals_table = zeros(metric_names_len, len_param);

    fprintf(strcat("Finding for optimal ", filter_name, " parameters...\n")); 
    tic
    if (strcmp(p.Results.ParallelComputing, 'on'))
        warning('Parralel computing are on, the iteration order may be violated.');         
        parfor i = 1:len_param
            metric_names_tmp = metric_names;
            if(isnumeric(win_size))
                filt_img = feval(filter_name, noise_image, win_size,  param_range(i)); %%filtering 
                for k = 1:metric_names_len
                    metrcis_vals_table(k,i) = feval(metric_names_tmp{k}, filt_img, test_image);
                end
            elseif (isstruct(win_size) || isstruct(second_third_research))
                for k = 1:metric_names_len
                    if (isstruct(win_size))
                        filt_img = feval(filter_name, noise_image, ...
                            [win_size.(opt_params_fields{k})(1) win_size.(opt_params_fields{k})(1)],...
                            param_range(i)); %%filtering 
                    elseif (isstruct(second_third_research))
                        filt_img = feval(filter_name, noise_image, param_range(i), ...
                            second_third_research.(opt_params_fields{k})(2),...
                            second_third_research.(opt_params_fields{k})(3)); %%filtering 
                    end
                    metrcis_vals_table(k,i) = feval(metric_names_tmp{k}, filt_img, test_image);
                end
            else
                error('Error: wrong win_size variable structure.');
            end
            fprintf('%d iteration of %d\n', i, length(param_range));
        end
        toc
        for k = 1:metric_names_len
            research_result.(metric_names{k}) = metrcis_vals_table(k,:);
        end         
    else
        for i = 1:length(param_range)
            if(isnumeric(win_size))
                filt_img = feval(filter_name, noise_image, win_size,  param_range(i)); %%filtering 
                for k = 1:metric_names_len
                    research_result.(metric_names{k})(i) = ...  
                        feval(metric_names{k}, filt_img, test_image);
                end
            elseif (isstruct(win_size) || isstruct(second_third_research))
                for k = 1:metric_names_len
                    if (isstruct(win_size))
                        filt_img = feval(filter_name, noise_image, ...
                            [win_size.(opt_params_fields{k})(1) win_size.(opt_params_fields{k})(1)],...
                            param_range(i)); %%filtering 
                    elseif (isstruct(second_third_research))
                        filt_img = feval(filter_name, noise_image, param_range(i), ...
                            second_third_research.(opt_params_fields{k})(2),...
                            second_third_research.(opt_params_fields{k})(3)); %%filtering 
                    end
                    research_result.(metric_names{k})(i) = feval(metric_names{k}, filt_img, test_image);
                end
            else
                error('Error: wrong win_size variable structure.');
            end
            fprintf('%d iteration of %d\n', i, length(param_range));
        end
        toc
    end 
    
    if(isnumeric(win_size) || isstruct(win_size))
        optim_params = GetOptimalParamsByInterval(research_result, k_thershold, p.Results.MetricsInteraction);
    elseif(isstruct(second_third_research))
        optim_params_tmp = GetOptimalParamsByInterval(research_result, k_thershold, p.Results.MetricsInteraction);
        optim_params_tmp_field_names = fieldnames(optim_params_tmp);
        for k = 1:metric_names_len
            field_opt = strcat('OptimalFirstAndSecondAndThirdParamAnd', metric_names{k});
            optim_params.(field_opt) = [optim_params_tmp.(optim_params_tmp_field_names{k})(1),...
                second_third_research.(opt_params_fields{k})(2), ...
                second_third_research.(opt_params_fields{k})(3),...
                optim_params_tmp.(optim_params_tmp_field_names{k})(2)];
        end    
    end

    research_result = catstruct(research_result, optim_params); 
end