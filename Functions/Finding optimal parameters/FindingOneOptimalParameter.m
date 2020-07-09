function research_result = FindingOneOptimalParameter(varargin)
%% Parsing input variable
    defaultParallelComputing = 'on';
    expectedOnOff = {'on','off'};
    
    p = inputParser;
    addRequired(p, 'ReferenceImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NoiseImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addRequired(p, 'WindowSize', @(x) isnumeric(x) && all(x(:) >= 0))
    addRequired(p, 'FirstFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'ParallelComputing', defaultParallelComputing, @(x) any(validatestring(x, expectedOnOff)))
    
    parse(p, varargin{:});
%% One variable parameter research 
    test_image = p.Results.ReferenceImage;
    noise_image = p.Results.NoiseImage;
    filter_name = p.Results.NameOfFilter;
    win_size = p.Results.WindowSize;
    param_range = p.Results.FirstFilterParameterRange;
    
    ssim_vals = zeros([1, length(param_range)]);    
    tic
    fprintf(strcat("Finding for optimal ", filter_name, " parameters...\n")); 
    if (strcmp(p.Results.ParallelComputing, 'on'))
        warning('Parralel computing are on, the iteration order may be violated.');
        len_param = length(param_range);
        parfor i = 1:len_param
            filt_img = feval(filter_name, noise_image, win_size,  param_range(i)); %%filtering 
            ssim_vals(i) = ssim(filt_img, test_image); %%metric
            fprintf('%d iteration of %d\n', i, length(param_range));
        end
        toc
    else
        for i = 1:length(param_range)
            filt_img = feval(filter_name, noise_image, win_size, param_range(i)); %%filtering 
            ssim_vals(i) = ssim(filt_img, test_image); %%metric
            fprintf('%d iteration of %d\n', i, length(param_range));
        end
        toc
    end
    ssim_optimal_param = [param_range(ssim_vals == max(ssim_vals)) max(ssim_vals)];
    
    research_result = {'ParameterRange','SSIMVals','OptimalParameterValAndSSIM';...
            param_range, ssim_vals, ssim_optimal_param};    

end