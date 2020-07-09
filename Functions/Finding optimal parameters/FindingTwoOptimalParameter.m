function  research_result = FindingTwoOptimalParameter(varargin)
%% Parsing input variable
    defaultParallelComputing = 'on';
    expectedOnOff = {'on','off'};
    
    p = inputParser;
    addRequired(p, 'ReferenceImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NoiseImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addRequired(p, 'WindowSize', @(x) isnumeric(x) && all(x(:) >= 0))
    addRequired(p, 'FirstFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addRequired(p, 'SecondFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'ParallelComputing', defaultParallelComputing, @(x) any(validatestring(x, expectedOnOff)))
    
    parse(p, varargin{:});    
%% Two variable parameter research 
    test_image = p.Results.ReferenceImage;
    noise_image = p.Results.NoiseImage;
    filter_name = p.Results.NameOfFilter;
    win_size = p.Results.WindowSize;
    param1_range = p.Results.FirstFilterParameterRange;
    param2_range = p.Results.SecondFilterParameterRange;
    
    ssim_vals = zeros([length(param1_range), length(param2_range)]);
    counter = reshape(1:length(param1_range)*length(param2_range), length(param2_range), length(param1_range)).';
    tic
    fprintf(strcat("Finding for optimal ", filter_name, " parameters...\n")); 
    if (strcmp(p.Results.ParallelComputing, 'on'))
        warning('Parralel computing are on, the iteration order may be violated.');
        len_param1 = length(param1_range);
        len_param2 = length(param2_range);
        parfor i = 1:len_param1
            for j = 1:len_param2
                filt_img = feval(filter_name, noise_image, win_size,  param1_range(i), param2_range(j)); %%filtering 
                ssim_vals(i,j) = ssim(filt_img, test_image);
                fprintf('%d iteration of %d\n', counter(i,j), length(param1_range)*length(param2_range));
            end
        end
        toc
    else
        for i = 1:length(param1_range)
            for j = 1:length(param2_range)
                filt_img = feval(filter_name, noise_image, win_size,  param1_range(i), param2_range(j)); %%filtering 
                ssim_vals(i,j) = ssim(filt_img, test_image);
                fprintf('%d iteration of %d\n', counter(i,j), length(param1_range)*length(param2_range));
            end
        end
        toc        
    end
    [row, col] = find(ssim_vals == max(max(ssim_vals)));
    ssim_optimal_param = [param1_range(row) param2_range(col) max(max(ssim_vals))];
    
    research_result = {'Parameter1Range','Parameter2Range','SSIMVals','OptimalParametersValAndSSIM';...
            param1_range, param2_range, ssim_vals, ssim_optimal_param};           
end