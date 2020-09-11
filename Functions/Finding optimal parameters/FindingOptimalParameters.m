function [optimal_params, research_result] = FindingOptimalParameters(varargin)
% FindingOptimalParameters performs an automatic search for optimal
% parameters for a given filter of speckle noise.
% 
% The output arguments of the function are cells: optimal_params and 
% research_result. 
% The cell optimal_params includes the final optimal 
% filter parameters. The cell research_result includes all the intermediate
% matrices of the study. This may be necessary if you need to build your 
% own plots (if the built-in ploting does not suit you for some reason). 
% For a detailed description of the cell fields, see the research manual.
% 
% Mandatory input arguments to the function are the TestImage, with the 
% help of which research will be conducted, and the NameOfFilter. 
% The test image should be in grayscale, the intensity values of its pixels
% should be in the range from 0 to 1. The name of the filter must
% completely repeat the name of the function in which this filter 
% is implemented.
%
% You can use name-value arguments for additional settings of the function.
% 
% ('NoiseType', value) - allows you to choose the type of noise that will
% be superimposed on the test image. Possible values are: 'Normal',
% 'Rayleigh', 'CorrelatedRayleigh'. The default value is: 'Rayleigh'.
% ('WindowAvailability', value) - allows to enable or disable the presence 
% of a sliding window at the filter. Possible values are: 'on',
% 'off'. The default value is: 'on'. When using an anisotropic diffusion
% filter, this parameter is turned off automatically.
% 
% ('WindowInitialSize', value) - allows to set the initial size of the
% filter sliding window. The value of this parameter should be a 1 by 2 
% vector of positive numbers. The default value is: [11 11]. 
%
% ('FirstFilterParameterRange', value); 
% ('SecondFilterParameterRange', value); 
% ('ThirdFilterParameterRange', value) - set the range of values for
% the first, second and third filter parameters. 
% Must be a vector of numbers.
% 
% ('NameOfFirstFilterParameter', value); 
% ('NameOfSecondFilterParameter', value); 
% ('NameOfThirdFilterParameter', value) - allows you to add designations 
% of filter parameters to be displayed on charts. If these parameters are 
% not set, then the graphs will display the "first variable parameter",
% "second variable parameter" and "third variable parameter".
%
% ('Plotting', value); ('SavingPlot', value) - enable or disable plotting
% and saving graphs. Possible values are: 'on', 'off'. 
% The default value is: 'off'.
% 
% ('FigureType', value) - allows you to select the type of plotting: 
% all stages of the study on one figure or each stage on a separate figure.
% Possible values are: 'SubplotFigures', 'SeparateFigures'. 
% The default value is: 'SubplotFigures'.
%
% ('ParallelComputing', value) - enable or disable parallel computing. 
% Possible values are: 'on', 'off'. The default value is: 'on'.

%% Parsing input variable
    defaultNoiseType = 'Rayleigh';
    defaultWindowInitialSize = [11,11];
    defaultMetric = "ssim";
    defaultFirstFilterParameterInitialVal = 10;
    defaultSettings.ParallelComputing       = 'on';
    defaultSettings.MetricsInteraction      = 'off'; 
    defaultSettings.kThershold              = 0.002;
    
    existingNameOfFilter = {'MedianFilter', 'LeeFilter', 'MAPFilter', 'FrostFilter', 'KuanFilter', 'BilateralFilter',...
         'AnisotropicDiffusionExp', 'AnisotropicDiffusionQuad'};
     
	p = inputParser;
    addRequired(p, 'TestImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NameOfFilter', @(x) validateNameOfFilter(x))
    addParameter(p, 'NoiseType', defaultNoiseType, @(x) validateNoiseType(x))
    addParameter(p, 'MetricsNames', defaultMetric, @(x) validateMetricsNames(x))
    addParameter(p, 'WindowInitialSize', defaultWindowInitialSize, ...
        @(x) isnumeric(x) && ~isempty(x) && all(size(x) == [1,2]) && all(x > 0))
    addParameter(p, 'FirstFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'SecondFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'ThirdFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'FirstFilterParameterInitialVal', defaultFirstFilterParameterInitialVal, @(x) isnumeric(x))
    addParameter(p, 'Settings', defaultSettings, @(x) isstruct(x))
    parse(p, varargin{:});

    %% Variables initialize
    noise_type = p.Results.NoiseType;
    test_image = p.Results.TestImage;
    filter_name = p.Results.NameOfFilter;
    win_size_init = p.Results.WindowInitialSize;
    metric_names = p.Results.MetricsNames;
    settings = p.Results.Settings;

    if (strcmp(filter_name, 'AnisotropicDiffusionExp') || strcmp(filter_name, 'AnisotropicDiffusionQuad'))
        window_availability = 'off';
    else
        window_availability = 'on';  
    end
    
    noise_image = AddSpeckle(test_image, noise_type);
    test_image = ConvertRefrenceImage(test_image, noise_type);
    
    %% Research  
    %%Only window size is variable 
    if (strcmp(window_availability, 'on') && ~isnumeric(p.Results.FirstFilterParameterRange) && ...
             ~isnumeric(p.Results.SecondFilterParameterRange) && ~isnumeric(p.Results.ThirdFilterParameterRange)) 
        if (strcmp(filter_name, existingNameOfFilter{4}) || strcmp(filter_name, existingNameOfFilter{5}) || ...
                strcmp(filter_name, existingNameOfFilter{6}) || strcmp(filter_name, existingNameOfFilter{7}) ||...
                strcmp(filter_name, existingNameOfFilter{8}))
            error(strcat("Error. Not enough variable parameters for ", filter_name, "!"));
        end
        [optimal_params, research_result] = FindingOptimalWindowSize(test_image, noise_image, ...
            filter_name, metric_names, settings.MetricsInteraction,...
            settings.kThershold, 'ParallelComputing', settings.ParallelComputing);
    %%One variable parameter and variable window size
    elseif (strcmp(window_availability, 'on') && isnumeric(p.Results.FirstFilterParameterRange) && ...
             ~isnumeric(p.Results.SecondFilterParameterRange) && ~isnumeric(p.Results.ThirdFilterParameterRange))
        if (strcmp(filter_name, existingNameOfFilter{1}) || strcmp(filter_name, existingNameOfFilter{2}) || ...
                strcmp(filter_name, existingNameOfFilter{3}))
            error(strcat("Error. Too many variable parameters for ", filter_name, "!"));
        elseif (strcmp(filter_name, existingNameOfFilter{6}) || strcmp(filter_name, existingNameOfFilter{7}) || ...
                strcmp(filter_name, existingNameOfFilter{8}))
            error(strcat("Error. Not enough variable parameters for ", filter_name, "!"));
        end
        
        [~, research_result_init_win_size] = FindingOneOptimalParameter(test_image,...
            noise_image, filter_name, p.Results.FirstFilterParameterRange, ...
            metric_names, settings.MetricsInteraction,...
            settings.kThershold, 'WindowSize', win_size_init, 'ParallelComputing', settings.ParallelComputing);
        [optim_win_size, window_research_result] = FindingOptimalWindowSize(test_image, noise_image, ...
            filter_name, metric_names, settings.MetricsInteraction, ...
            settings.kThershold,  'ResearchResult', research_result_init_win_size,...
            'ParallelComputing', settings.ParallelComputing);
        [optimal_first_params, research_result_opt_win_size] =  FindingOneOptimalParameter(test_image,...
            noise_image, filter_name, p.Results.FirstFilterParameterRange,...
            metric_names, settings.MetricsInteraction, settings.kThershold, ...
            'WindowSize', window_research_result, 'ParallelComputing', settings.ParallelComputing);
        
        optimal_params = CovertOptimParams(optim_win_size, optimal_first_params, metric_names);
        research_result.FirstStage	= research_result_init_win_size;
        research_result.SecondStage	= window_research_result;
        research_result.ThirdStage	= research_result_opt_win_size;    
 %%Two variable parameter and variable window size
    elseif (strcmp(window_availability, 'on') && isnumeric(p.Results.FirstFilterParameterRange) && ...
             isnumeric(p.Results.SecondFilterParameterRange) && ~isnumeric(p.Results.ThirdFilterParameterRange))
        if (strcmp(filter_name, existingNameOfFilter{1}) || strcmp(filter_name, existingNameOfFilter{2}) || ...
                strcmp(filter_name, existingNameOfFilter{3}))
            error(strcat("Error. Too many variable parameters for ", filter_name, "!"));
        elseif (strcmp(filter_name, existingNameOfFilter{7}) || ...
                strcmp(filter_name, existingNameOfFilter{8}))
            error(strcat("Error. Not enough variable parameters for ", filter_name, "!"));
        end
        [~, research_result_init_win_size] = FindingTwoOptimalParameter(test_image,...
            noise_image, filter_name, p.Results.FirstFilterParameterRange, p.Results.SecondFilterParameterRange,...
            metric_names, settings.MetricsInteraction,...
            settings.kThershold, 'WindowSize', win_size_init, 'ParallelComputing', settings.ParallelComputing);
        [optim_win_size, window_research_result] = FindingOptimalWindowSize(test_image, noise_image, ...
            filter_name, metric_names, settings.MetricsInteraction, ...
            settings.kThershold,  'ResearchResult', research_result_init_win_size,...
            'ParallelComputing', settings.ParallelComputing);
        [optimal_first_and_second_params, research_result_opt_win_size] = FindingTwoOptimalParameter(test_image,...
            noise_image, filter_name, ...
            p.Results.FirstFilterParameterRange, p.Results.SecondFilterParameterRange,...
            metric_names, settings.MetricsInteraction, settings.kThershold, ...
            'WindowSize', window_research_result, 'ParallelComputing', settings.ParallelComputing);
        
        optimal_params = CovertOptimParams(optim_win_size, optimal_first_and_second_params, metric_names);
        research_result.FirstStage	= research_result_init_win_size;
        research_result.SecondStage	= window_research_result;
        research_result.ThirdStage	= research_result_opt_win_size;   
 %%Three variable parameter without variable window size        
    elseif (strcmp(window_availability, 'off') && isnumeric(p.Results.FirstFilterParameterRange) && ...
             isnumeric(p.Results.SecondFilterParameterRange) && isnumeric(p.Results.ThirdFilterParameterRange))
        if (strcmp(filter_name, existingNameOfFilter{1}) || strcmp(filter_name, existingNameOfFilter{2}) || ...
                strcmp(filter_name, existingNameOfFilter{3}) || strcmp(filter_name, existingNameOfFilter{4}) || ...
                strcmp(filter_name, existingNameOfFilter{5}) || strcmp(filter_name, existingNameOfFilter{6}))
            error(strcat("Error. Too many variable parameters for ", filter_name, "!"));
        end
        param1_init = p.Results.FirstFilterParameterInitialVal;
        [~, research_result_init_param1] = FindingTwoOptimalParameter(test_image, noise_image, filter_name,....
            p.Results.SecondFilterParameterRange, p.Results.ThirdFilterParameterRange, ...
            metric_names, settings.MetricsInteraction, settings.kThershold,...
            'ThirdParameter', param1_init, 'ParallelComputing', settings.ParallelComputing);
        [~, one_param_research_result] = FindingOneOptimalParameter(test_image, noise_image, filter_name,....
            p.Results.FirstFilterParameterRange, metric_names, settings.MetricsInteraction, settings.kThershold,...
            'SecondAndThirdParametersResearch', research_result_init_param1, 'ParallelComputing', settings.ParallelComputing);
        [optimal_params, research_result_opt_param1] = FindingTwoOptimalParameter(test_image, noise_image, filter_name,....
            p.Results.SecondFilterParameterRange, p.Results.ThirdFilterParameterRange, ...
            metric_names, settings.MetricsInteraction, settings.kThershold,...
            'ThirdParameter', one_param_research_result, 'ParallelComputing', settings.ParallelComputing);
        
        research_result.FirstStage	= research_result_init_param1;
        research_result.SecondStage	= one_param_research_result;
        research_result.ThirdStage	= research_result_opt_param1; 
	end      
end