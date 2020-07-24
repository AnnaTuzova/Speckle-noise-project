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
    test_image = p.Results.ReferenceImage;
    noise_image = p.Results.NoiseImage;
    filter_name = p.Results.NameOfFilter;
    param1_range = p.Results.FirstFilterParameterRange;
    param2_range = p.Results.SecondFilterParameterRange;
    param3_range = p.Results.ThirdFilterParameterRange;
    parallel_computing = p.Results.ParallelComputing;
    
    %%Fix param1 and find optimal values of param2 and param3 
    param1_init_const = (param1_range(10));
    ssim_vals_first_step = FindingParameters23(param1_init_const);
    [row_1, col_1] = find(ssim_vals_first_step == max(max(ssim_vals_first_step)));
    ssim_optimal_param_first_step = [param1_init_const param2_range(row_1) param3_range(col_1) max(max(ssim_vals_first_step))];
    
    %%Fix param2 and param3 and find optimal value of param1 
    param2_const = ssim_optimal_param_first_step(2);
    param3_const = ssim_optimal_param_first_step(3);
    ssim_vals_second_step = zeros([1, length(param1_range)]);    
    tic
    fprintf(strcat("Finding for first optimal parameter of ", filter_name, " filter...\n")); 
    if (strcmp(p.Results.ParallelComputing, 'on'))
        warning('Parralel computing are on, the iteration order may be violated.');
        len_param1 = length(param1_range);
        parfor i = 1:len_param1
            filt_img = feval(filter_name, noise_image, param1_range(i), param2_const, param3_const); %%filtering 
            ssim_vals_second_step(i) = ssim(filt_img, test_image); %%metric
            fprintf('%d iteration of %d\n', i, len_param1);
        end
        toc
    else
        for i = 1:length(param1_range)
            filt_img = feval(filter_name, noise_image, param1_range(i), param2_const, param3_const); %%filtering 
            ssim_vals_second_step(i) = ssim(filt_img, test_image); %%metric
            fprintf('%d iteration of %d\n', i, length(param1_range));
        end
        toc
    end
    ssim_optimal_param_second_step = [param1_range(ssim_vals_second_step == max(ssim_vals_second_step)) param2_const param3_const max(ssim_vals_second_step)];
    
    %%Fix param1 and clarifying optimal value of param2 and param3 
    param1_const = ssim_optimal_param_second_step(1);
    ssim_vals_third_step = FindingParameters23(param1_const);
    [row_2, col_2] = find(ssim_vals_third_step == max(max(ssim_vals_third_step)));
    ssim_optimal_param_third_step = [param1_const param2_range(row_2) param3_range(col_2) max(max(ssim_vals_third_step))];
    
    research_result = {'Parameter1Range','Parameter2Range','Parameter3Range',...
        'SSIMValsFirstStep(Parameter3Range)', 'SSIMValsSecondStep(Parameter1Range)', 'SSIMValsThirdStep(Parameter3Range)',... 
        'OptimalParametersValAndSSIMFirstStep', 'OptimalParametersValAndSSIMSecondStep', 'OptimalParametersValAndSSIMThirdStep';...
            param1_range, param2_range, param3_range, ...
            ssim_vals_first_step, ssim_vals_second_step, ssim_vals_third_step, ....
            ssim_optimal_param_first_step, ssim_optimal_param_second_step, ssim_optimal_param_third_step};         
end

function ssim_vals23 = FindingParameters23(param1_const)
    global test_image
    global noise_image
    global filter_name
    global param1_range 
    global param2_range 
    global param3_range
    global parallel_computing
    
    ssim_vals23 = zeros([length(param2_range), length(param3_range)]);
    counter = reshape(1:length(param2_range)*length(param3_range), length(param3_range), length(param2_range)).';
    tic
    fprintf(strcat("Finding for second and third optimal parameters of ", filter_name, " filter...\n")); 
    if (strcmp(parallel_computing, 'on'))
        warning('Parralel computing are on, the iteration order may be violated.');
        len_param2 = length(param2_range);
        len_param3 = length(param3_range);
        parfor i = 1:len_param2
            for j = 1:len_param3
                filt_img = feval(filter_name, noise_image, param1_const, param2_range(i), param3_range(j)); %%filtering 
                ssim_vals23(i,j) = ssim(filt_img, test_image);
                fprintf('%d iteration of %d\n', counter(i,j), length(param1_range)*length(param2_range));
            end
        end
        toc
    else
        for i = 1:length(param2_range)
            for j = 1:length(param3_range)
                filt_img = feval(filter_name, noise_image, param1_init_const, param2_range(i), param3_range(j)); %%filtering 
                ssim_vals23(i,j) = ssim(filt_img, test_image);
                fprintf('%d iteration of %d\n', counter(i,j), length(param1_range)*length(param2_range));
            end
        end
        toc        
    end
end