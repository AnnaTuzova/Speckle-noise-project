function research_result = FindingThreeOptimalParameter(varargin)
%% Parsing input variable
    defaultParallelComputing = 'on';
    expectedOnOff = {'on','off'};
    
    p = inputParser;
    addRequired(p, 'ReferenceImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NoiseImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))  
    addRequired(p, 'FirstFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addRequired(p, 'SecondFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addRequired(p, 'ThirdFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addRequired(p, 'Metrics', @(x) isstring(x))
    addParameter(p, 'MetricAveraging', @(x) any(validatestring(x, expectedOnOff)))
    addParameter(p, 'ParallelComputing', defaultParallelComputing, @(x) any(validatestring(x, expectedOnOff)))
    
    parse(p, varargin{:});    
    
    %% Three variable parameter without window research 
    global test_image
    global noise_image
    global filter_name
    global param1_range 
    global param2_range 
    global param3_range
    global parallel_computing
    global metric_names
    global metric_averaging
    global metric_names_len
    test_image = p.Results.ReferenceImage;
    noise_image = p.Results.NoiseImage;
    filter_name = p.Results.NameOfFilter;
    param1_range = p.Results.FirstFilterParameterRange;
    param2_range = p.Results.SecondFilterParameterRange;
    param3_range = p.Results.ThirdFilterParameterRange;
    parallel_computing = p.Results.ParallelComputing;
    metric_names = p.Results.Metrics;
    metric_averaging = p.Results.MetricAveraging;
    metric_names_len = length(metric_names);
    
    %%Fix param1 and find optimal values of param2 and param3 
    param1_init_const = (param1_range(10));
    metrcis_vals_stage1 = FindingParameters23(param1_init_const);
    
    optimal_params_stage1 = zeros(metric_names_len, 4);
    for k = 1:metric_names_len
        if (strcmp(metrcis_vals_stage1{1,k}, 'ssim') || strcmp(metrcis_vals_stage1{1,k}, 'DetermCoeffMetric') || ...
                strcmp(metrcis_vals_stage1{1,k}, 'psnrMetric') || strcmp(metrcis_vals_stage1{1,k}, 'uqiMetric'))
            [row_stage1, col_stage1] = find(metrcis_vals_stage1{2,k} == max(max(metrcis_vals_stage1{2,k})));
            optimal_params_stage1(k,:) = [param1_init_const param2_range(row_stage1(1)) param3_range(col_stage1(1))...
                max(max(metrcis_vals_stage1{2,k}))];  
        elseif (strcmp(metrcis_vals_stage1{1,k}, 'mseMetric') || strcmp(metrcis_vals_stage1{1,k}, 'gmsdMetric') || ...
                strcmp(metrcis_vals_stage1{1,k}, 'maeMetric'))
            [row_stage1, col_stage1] = find(metrcis_vals_stage1{2,k} == min(min(metrcis_vals_stage1{2,k})));
            optimal_params_stage1(k,:) = [param1_init_const param2_range(row_stage1(1)) param3_range(col_stage1(1))...
                min(min(metrcis_vals_stage1{2,k}))]; 
        end
    end
    
    research_result_stage1 = cell(2, 3 + 2*metric_names_len);
    research_result_stage1{1,1} = 'FirstParamRange';
    research_result_stage1{2,1} = param1_range;
    research_result_stage1{1,2} = 'SecondParamRange';
    research_result_stage1{2,2} = param2_range;
    research_result_stage1{1,3} = 'ThirdParamRange';
    research_result_stage1{2,3} = param3_range;
    for k = 1:metric_names_len 
        research_result_stage1{1,k+3} = strcat(metric_names(k),'Vals');
        research_result_stage1{1,k+3+metric_names_len} = strcat('OptimalFirstParamValAnd',metric_names(k));
        research_result_stage1{2,k+3} = metrcis_vals_stage1{2,k};
        research_result_stage1{2,k+3+metric_names_len} = optimal_params_stage1(k,:);
    end    
    
%     [row_1, col_1] = find(ssim_vals_first_step == max(max(ssim_vals_first_step)));
%     ssim_optimal_param_first_step = [param1_init_const param2_range(row_1) param3_range(col_1) max(max(ssim_vals_first_step))];
%     
    %%Fix param2 and param3 and find optimal value of param1 
    len_param1 = length(param1_range);
    metrcis_vals_satge2 = cell(2, metric_names_len);
    metrcis_vals_satge2(1,:) = cellstr(metric_names);
    metrcis_vals_table_satge2 = zeros(metric_names_len, len_param1);
    
    param2_aver_const = 0;
    param3_aver_const= 0;
        for k = 1:metric_names_len
            param2_aver_const = param2_aver_const + research_result_stage1{2,k+3+metric_names_len}(2); 
            param3_aver_const = param3_aver_const + research_result_stage1{2,k+3+metric_names_len}(3); 
        end
    param2_aver_const = param2_aver_const/metric_names_len;
    param3_aver_const = param3_aver_const/metric_names_len;
    
%     param2_const = optimal_params_stage1(2);
%     param3_const = optimal_params_stage1(3);
    
    
%     ssim_vals_second_step = zeros([1, length(param1_range)]);    
    tic
    fprintf(strcat("Finding for first optimal parameter of ", filter_name, " filter...\n")); 
    if (strcmp(p.Results.ParallelComputing, 'on'))
        warning('Parralel computing are on, the iteration order may be violated.');
        parfor i = 1:len_param1
            if(strcmp(p.Results.MetricAveraging, 'on'))
                filt_img = feval(filter_name, noise_image, param1_range(i), ...
                    param2_aver_const, param3_aver_const); %%filtering 
                for k = 1:metric_names_len
                    metrcis_vals_table_satge2(k,i) = feval(metric_names(k), filt_img, test_image);
                end
%                 ssim_vals_second_step(i) = ssim(filt_img, test_image); %%metric
            elseif(strcmp(p.Results.MetricAveraging, 'off'))
                for k = 1:metric_names_len
                    filt_img = feval(filter_name, noise_image, param1_range(i), ...
                        research_result_stage1{2,k+3+metric_names_len}(2),...
                        research_result_stage1{2,k+3+metric_names_len}(3)); %%filtering 
                    metrcis_vals_table_satge2(k,i) = feval(metric_names(k), filt_img, test_image);
                end
            else
                error("Error: MetricAveraging-option is not specified.")
            end
            fprintf('%d iteration of %d\n', i, len_param1);
        end
        toc
        for k = 1:metric_names_len
            metrcis_vals_satge2{2,k} = metrcis_vals_table_satge2(k,:);
        end
    else
        for i = 1:length(param1_range)
            if(strcmp(p.Results.MetricAveraging, 'on'))
                filt_img = feval(filter_name, noise_image, param1_range(i), ...
                    param2_aver_const, param3_aver_const); %%filtering 
                for k = 1:metric_names_len
                    metrcis_vals_table_satge2(k,i) = feval(metric_names(k), filt_img, test_image);
                end
            elseif(strcmp(p.Results.MetricAveraging, 'off'))
                for k = 1:metric_names_len
                    filt_img = feval(filter_name, noise_image, param1_range(i), ...
                        research_result_stage1{2,k+3+metric_names_len}(2),...
                        research_result_stage1{2,k+3+metric_names_len}(3)); %%filtering 
                    metrcis_vals_table_satge2(k,i) = feval(metric_names(k), filt_img, test_image);
                end
            else
                error("Error: MetricAveraging-option is not specified.")
            end
            fprintf('%d iteration of %d\n', i, length(param1_range));
        end
        toc
        for k = 1:metric_names_len
            metrcis_vals_satge2{2,k} = metrcis_vals_table_satge2(k,:);
        end
    end
    
    optimal_params_stage2 = zeros(metric_names_len, 4);
    for k = 1:metric_names_len
        if (strcmp(metrcis_vals_satge2{1,k}, 'ssim') || strcmp(metrcis_vals_satge2{1,k}, 'DetermCoeffMetric') || ...
                strcmp(metrcis_vals_satge2{1,k}, 'psnrMetric') || strcmp(metrcis_vals_satge2{1,k}, 'uqiMetric'))
            optim_param_satge2 = param1_range(metrcis_vals_satge2{2,k} == max(metrcis_vals_satge2{2,k}));
            if(strcmp(p.Results.MetricAveraging, 'on'))
                optimal_params_stage2(k,:) = [optim_param_satge2(1), param2_aver_const, param3_aver_const,...
                    max(metrcis_vals_satge2{2,k})];
            elseif(strcmp(p.Results.MetricAveraging, 'off'))
                optimal_params_stage2(k,:) = [optim_param_satge2(1), ...
                    research_result_stage1{2,k+3+metric_names_len}(2), research_result_stage1{2,k+3+metric_names_len}(3),...
                    max(metrcis_vals_satge2{2,k})];
            end       
        elseif (strcmp(metrcis_vals_satge2{1,k}, 'mseMetric') || strcmp(metrcis_vals_satge2{1,k}, 'gmsdMetric') || ...
                strcmp(metrcis_vals_satge2{1,k}, 'maeMetric'))
            optim_param_satge2 = param1_range(metrcis_vals_satge2{2,k} == min(metrcis_vals_satge2{2,k}));
            if(strcmp(p.Results.MetricAveraging, 'on'))
                optimal_params_stage2(k,:) = [optim_param_satge2(1), param2_aver_const, param3_aver_const,...
                    min(metrcis_vals_satge2{2,k})];
            elseif(strcmp(p.Results.MetricAveraging, 'off'))
                optimal_params_stage2(k,:) = [optim_param_satge2(1), ...
                    research_result_stage1{2,k+3+metric_names_len}(2), research_result_stage1{2,k+3+metric_names_len}(3),...
                    min(metrcis_vals_satge2{2,k})];
            end  
        end
    end
    
    research_result_stage2 = cell(2, 3 + 2*metric_names_len);
    research_result_stage2{1,1} = 'FirstParamRange';
    research_result_stage2{2,1} = param1_range;
    research_result_stage2{1,2} = 'SecondParamRange';
    research_result_stage2{2,2} = param2_range;
    research_result_stage2{1,3} = 'ThirdParamRange';
    research_result_stage2{2,3} = param3_range;
    for k = 1:metric_names_len 
        research_result_stage2{1,k+3} = strcat(metric_names(k),'Vals');
        research_result_stage2{1,k+3+metric_names_len} = strcat('OptimalFirstParamValAnd',metric_names(k));
        research_result_stage2{2,k+3} = metrcis_vals_satge2{2,k};
        research_result_stage2{2,k+3+metric_names_len} = optimal_params_stage2(k,:);
    end  
    
%     ssim_optimal_param_second_step = [param1_range(ssim_vals_second_step == max(ssim_vals_second_step)) param2_const param3_const max(ssim_vals_second_step)];
    
    %%Fix param1 and clarifying optimal value of param2 and param3 
    param1_aver_const = 0;
        for k = 1:metric_names_len
            param1_aver_const = param1_aver_const + research_result_stage2{2,k+3+metric_names_len}(1); 
        end
    param1_aver_const = param1_aver_const/metric_names_len;
    
    if(strcmp(p.Results.MetricAveraging, 'on'))
        metrcis_vals_stage3 = FindingParameters23(param1_aver_const);
    elseif(strcmp(p.Results.MetricAveraging, 'off'))
        param1_const = [];
        for k = 1:metric_names_len
            param1_const = [param1_const research_result_stage2{2,k+3+metric_names_len}(1)];
        end
        metrcis_vals_stage3 = FindingParameters23(param1_const);
    else
        error("Error: MetricAveraging-option is not specified.")
    end
    
    optimal_params_stage3 = zeros(metric_names_len, 4);
    for k = 1:metric_names_len
        if (strcmp(metrcis_vals_stage3{1,k}, 'ssim') || strcmp(metrcis_vals_stage3{1,k}, 'DetermCoeffMetric') || ...
                strcmp(metrcis_vals_stage3{1,k}, 'psnrMetric') || strcmp(metrcis_vals_stage3{1,k}, 'uqiMetric'))
            if(strcmp(p.Results.MetricAveraging, 'on'))
                [row_stage3, col_stage3] = find(metrcis_vals_stage3{2,k} == max(max(metrcis_vals_stage3{2,k})));
                optimal_params_stage3(k,:) = [param1_aver_const param2_range(row_stage3(1)) param3_range(col_stage3(1))...
                    max(max(metrcis_vals_stage3{2,k}))];  
            elseif(strcmp(p.Results.MetricAveraging, 'off'))
                [row_stage3, col_stage3] = find(metrcis_vals_stage3{2,k} == max(max(metrcis_vals_stage3{2,k})));
                optimal_params_stage3(k,:) = [param1_const(k) param2_range(row_stage3(1)) param3_range(col_stage3(1))...
                    max(max(metrcis_vals_stage3{2,k}))]; 
            end  
        elseif (strcmp(metrcis_vals_stage3{1,k}, 'mseMetric') || strcmp(metrcis_vals_stage3{1,k}, 'gmsdMetric') || ...
                strcmp(metrcis_vals_stage3{1,k}, 'maeMetric'))
            if(strcmp(p.Results.MetricAveraging, 'on'))
                [row_stage3, col_stage3] = find(metrcis_vals_stage3{2,k} == min(min(metrcis_vals_stage3{2,k})));
                optimal_params_stage3(k,:) = [param1_aver_const param2_range(row_stage3(1)) param3_range(col_stage3(1))...
                    min(min(metrcis_vals_stage3{2,k}))];  
            elseif(strcmp(p.Results.MetricAveraging, 'off'))
                [row_stage3, col_stage3] = find(metrcis_vals_stage3{2,k} == min(min(metrcis_vals_stage3{2,k})));
                    optimal_params_stage3(k,:) = [param1_const(k) param2_range(row_stage3(1)) param3_range(col_stage3(1))...
                    min(min(metrcis_vals_stage3{2,k}))]; 
            end 
        end
    end
    
    research_result_stage3 = cell(2, 3 + 2*metric_names_len);
    research_result_stage3{1,1} = 'FirstParamRange';
    research_result_stage3{2,1} = param1_range;
    research_result_stage3{1,2} = 'SecondParamRange';
    research_result_stage3{2,2} = param2_range;
    research_result_stage3{1,3} = 'ThirdParamRange';
    research_result_stage3{2,3} = param3_range;
    for k = 1:metric_names_len 
        research_result_stage3{1,k+3} = strcat(metric_names(k),'Vals');
        research_result_stage3{1,k+3+metric_names_len} = strcat('OptimalFirstParamValAnd',metric_names(k));
        research_result_stage3{2,k+3} = metrcis_vals_stage3{2,k};
        research_result_stage3{2,k+3+metric_names_len} = optimal_params_stage3(k,:);
    end    

    research_result = {'ResearchResultStage1', 'ResearchResultStage2', 'ResearchResultStage3';
            research_result_stage1, research_result_stage2, research_result_stage3};         
end

function metrcis_vals = FindingParameters23(param1_const)
    global test_image
    global noise_image
    global filter_name
    global param1_range 
    global param2_range 
    global param3_range
    global parallel_computing
    global metric_names
    global metric_names_len
    
    metrcis_vals = cell(2, metric_names_len);
    metrcis_vals(1,:) = cellstr(metric_names);
    metrcis_vals_table23 = zeros([length(param2_range), length(param3_range)]);
    
%     ssim_vals23 = zeros([length(param2_range), length(param3_range)]);
    counter = reshape(1:length(param2_range)*length(param3_range), length(param3_range), length(param2_range)).';
    tic
    fprintf(strcat("Finding for second and third optimal parameters of ", filter_name, " filter...\n")); 
    if (strcmp(parallel_computing, 'on'))
        warning('Parralel computing are on, the iteration order may be violated.');
        len_param2 = length(param2_range);
        len_param3 = length(param3_range);
        for k = 1:metric_names_len
            parfor i = 1:len_param2
                for j = 1:len_param3
                    if (size(param1_const,1) == 1 &&  size(param1_const,2) == 1)
                        filt_img = feval(filter_name, noise_image, ...
                            param1_const, param2_range(i), param3_range(j)); %%filtering 
                        metrcis_vals_table23(i,j) = feval(metric_names(k), filt_img, test_image);
                    else
                        filt_img = feval(filter_name, noise_image, ...
                            param1_const(k), param2_range(i), param3_range(j)); %%filtering 
                        metrcis_vals_table23(i,j) = feval(metric_names(k), filt_img, test_image);
                    end
    %                 ssim_vals23(i,j) = ssim(filt_img, test_image);
                    fprintf('%d iteration of %d\n', counter(i,j), length(param1_range)*length(param2_range));
                end
            end
            metrcis_vals{2,k} = metrcis_vals_table23;
        end
        toc
    else
        for k = 1:metric_names_len
            for i = 1:length(param2_range)
                for j = 1:length(param3_range)
                    if (size(param1_const,1) == 1 &&  size(param1_const,2) == 1)
                        filt_img = feval(filter_name, noise_image, ...
                            param1_const, param2_range(i), param3_range(j)); %%filtering 
                        metrcis_vals_table23(i,j) = feval(metric_names(k), filt_img, test_image);
                    else
                        filt_img = feval(filter_name, noise_image, ...
                            param1_const(k), param2_range(i), param3_range(j)); %%filtering 
                        metrcis_vals_table23(i,j) = feval(metric_names(k), filt_img, test_image);
                    end
                    fprintf('%d iteration of %d\n', counter(i,j), length(param1_range)*length(param2_range));
                end
            end
            metrcis_vals{2,k} = metrcis_vals_table23;
        end
        toc        
    end
end