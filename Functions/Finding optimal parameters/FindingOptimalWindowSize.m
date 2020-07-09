function window_research_result = FindingOptimalWindowSize(varargin)
%% Parsing input variable
    defaultParallelComputing = 'on';
    expectedOnOff = {'on','off'};
    
    p = inputParser;
    addRequired(p, 'ReferenceImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NoiseImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addParameter(p, 'FirstFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'SecondFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'ThirdFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:)))) 
    addParameter(p, 'ParallelComputing', defaultParallelComputing, @(x) any(validatestring(x, expectedOnOff)))
    
    parse(p, varargin{:});
    
 %% Window size research   
    test_image = p.Results.ReferenceImage;
    noise_image = p.Results.NoiseImage;
    filter_name = p.Results.NameOfFilter;

    win_size_var = 3:2:40;
    ssim_vals = [];
    
    if (~isnumeric(p.Results.FirstFilterParameterRange) && ...
             ~isnumeric(p.Results.SecondFilterParameterRange) && ...
             ~isnumeric(p.Results.ThirdFilterParameterRange)) 
        tic
        fprintf(strcat("Finding for optimal window size of ", filter_name, "...\n"));
        if (strcmp(p.Results.ParallelComputing, 'on'))
            warning('Parralel computing are on, the iteration order may be violated.');
            num_win_size = numel(win_size_var);
            parfor idx = 1:num_win_size
                i = win_size_var(idx);
                win_size = [i,i]; 
                filt_img = feval(filter_name, noise_image, win_size); %%filtering 
                ssim_vals = [ssim_vals ssim(filt_img,test_image)]; %%metric
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        else
            for idx = 1:numel(win_size_var)
                i = win_size_var(idx);
                win_size = [i,i]; 
                filt_img = feval(filter_name, noise_image, win_size); %%filtering 
                ssim_vals = [ssim_vals ssim(filt_img,test_image)]; %%metric
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        end
        ssim_optimal_param = [win_size_var(ssim_vals == max(ssim_vals)) max(ssim_vals)];
        window_research_result = {'WindowSideSize','SSIMVals','OptimalParameterValAndSSIM';...
            win_size_var, ssim_vals, ssim_optimal_param};
    elseif (isnumeric(p.Results.FirstFilterParameterRange) && ...
             ~isnumeric(p.Results.SecondFilterParameterRange) && ...
             ~isnumeric(p.Results.ThirdFilterParameterRange))
        tic
        fprintf(strcat("Finding for optimal window size of ", filter_name, "...\n"));
        if (strcmp(p.Results.ParallelComputing, 'on'))
            warning('Parralel computing are on, the iteration order may be violated.');
            num_win_size = numel(win_size_var);
            parfor idx = 1:num_win_size
                i = win_size_var(idx);
                win_size = [i,i]; 
                filt_img = feval(filter_name, noise_image, win_size, p.Results.FirstFilterParameterRange); %%filtering 
                ssim_vals = [ssim_vals ssim(filt_img,test_image)]; %%metric
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        else
            for idx = 1:numel(win_size_var)
                i = win_size_var(idx);
                win_size = [i,i]; 
                filt_img = feval(filter_name, noise_image, win_size, p.Results.FirstFilterParameterRange); %%filtering 
                ssim_vals = [ssim_vals ssim(filt_img,test_image)]; %%metric
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        end
        ssim_optimal_param = [win_size_var(ssim_vals == max(ssim_vals)) max(ssim_vals)];
        window_research_result = {'WindowSideSize','SSIMVals','OptimalParameterValAndSSIM';...
            win_size_var, ssim_vals, ssim_optimal_param};  
    elseif (isnumeric(p.Results.FirstFilterParameterRange) && ...
             isnumeric(p.Results.SecondFilterParameterRange) && ...
             ~isnumeric(p.Results.ThirdFilterParameterRange))
        tic
        fprintf(strcat("Finding for optimal window size of ", filter_name, "...\n"));
        if (strcmp(p.Results.ParallelComputing, 'on'))
            warning('Parralel computing are on, the iteration order may be violated.');
            num_win_size = numel(win_size_var);
            parfor idx = 1:num_win_size
                i = win_size_var(idx);
                win_size = [i,i]; 
                filt_img = feval(filter_name, noise_image, win_size, ...
                    p.Results.FirstFilterParameterRange, p.Results.SecondFilterParameterRange); %%filtering 
                ssim_vals = [ssim_vals ssim(filt_img,test_image)]; %%metric
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        else
            for idx = 1:numel(win_size_var)
                i = win_size_var(idx);
                win_size = [i,i]; 
                filt_img = feval(filter_name, noise_image, win_size, ....
                    p.Results.FirstFilterParameterRange, p.Results.SecondFilterParameterRange); %%filtering 
                ssim_vals = [ssim_vals ssim(filt_img,test_image)]; %%metric
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        end
        ssim_optimal_param = [win_size_var(ssim_vals == max(ssim_vals)) max(ssim_vals)];
        window_research_result = {'WindowSideSize','SSIMVals','OptimalParameterValAndSSIM';...
            win_size_var, ssim_vals, ssim_optimal_param};   
    elseif (isnumeric(p.Results.FirstFilterParameterRange) && ...
             isnumeric(p.Results.SecondFilterParameterRange) && ...
             isnumeric(p.Results.ThirdFilterParameterRange))
        tic
        fprintf(strcat("Finding for optimal window size of ", filter_name, "...\n"));
        if (strcmp(p.Results.ParallelComputing, 'on'))
            warning('Parralel computing are on, the iteration order may be violated.');
            num_win_size = numel(win_size_var);
            parfor idx = 1:num_win_size
                i = win_size_var(idx);
                win_size = [i,i]; 
                filt_img = feval(filter_name, noise_image, win_size, ...
                    p.Results.FirstFilterParameterRange, p.Results.SecondFilterParameterRange,...
                    p.Results.ThirdFilterParameterRange); %%filtering 
                ssim_vals = [ssim_vals ssim(filt_img,test_image)]; %%metric
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        else
            for idx = 1:numel(win_size_var)
                i = win_size_var(idx);
                win_size = [i,i]; 
                filt_img = feval(filter_name, noise_image, win_size, ....
                    p.Results.FirstFilterParameterRange, p.Results.SecondFilterParameterRange,...
                    p.Results.ThirdFilterParameterRange); %%filtering 
                ssim_vals = [ssim_vals ssim(filt_img,test_image)]; %%metric
                fprintf('%d iteration of %d\n', idx, length(win_size_var));
            end
            toc
        end
        ssim_optimal_param = [win_size_var(ssim_vals == max(ssim_vals)) max(ssim_vals)];
        window_research_result = {'WindowSideSize','SSIMVals','OptimalParameterValAndSSIM';...
            win_size_var, ssim_vals, ssim_optimal_param};            
    end

end