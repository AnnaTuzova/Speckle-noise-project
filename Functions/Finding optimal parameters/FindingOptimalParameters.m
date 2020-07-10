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
% The test image should be in grayscale, the intensity values ??of its pixels
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
% ('Plotting', value); ('SavingPlot', value) - enable or disable plotting
% and saving graphs. Possible values are: 'on', 'off'. 
% The default value is: 'off'.
% 
% ('ParallelComputing', value) - enable or disable parallel computing. 
% Possible values are: 'on', 'off'. The default value is: 'on'.

%% Parsing input variable
    defaultNoiseType = 'Rayleigh';
    defaultWindowAvailability = 'on';
    defaultWindowInitialSize = [11,11];
    defaultPlotting = 'off';
    defaultParallelComputing = 'on';
    expectedNoiseType = {'Normal', 'Rayleigh', 'CorrelatedRayleigh'};
    existingNameOfFilter = {'MedianFilter', 'LeeFilter', 'MAPFilter', 'FrostFilter', 'KuanFilter', 'BilateralFilter',...
         'AnisotropicDiffusionExp', 'AnisotropicDiffusionQuad'};
    expectedOnOff = {'on','off'};

	p = inputParser;
    addRequired(p, 'TestImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addParameter(p, 'NoiseType', defaultNoiseType, @(x) any(validatestring(x, expectedNoiseType)))
    addParameter(p, 'WindowAvailability', defaultWindowAvailability, @(x) any(validatestring(x, expectedOnOff)))
    addParameter(p, 'WindowInitialSize', defaultWindowInitialSize, ...
        @(x) isnumeric(x) && ~isempty(x) && all(size(x) == [1,2]) && all(x > 0))
    addParameter(p, 'FirstFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'SecondFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'ThirdFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'Plotting', defaultPlotting, @(x) any(validatestring(x, expectedOnOff)))
    addParameter(p, 'SavingPlot', defaultPlotting, @(x) any(validatestring(x, expectedOnOff)))
    addParameter(p, 'ParallelComputing', defaultParallelComputing, @(x) any(validatestring(x, expectedOnOff)))
    
    parse(p, varargin{:});

    %% Noise Overlay
    noise_type = p.Results.NoiseType;
    test_image = p.Results.TestImage;
    filter_name = p.Results.NameOfFilter;
    window_availability = p.Results.WindowAvailability;
    if(isnumeric(p.Results.WindowInitialSize))
        win_init_size = p.Results.WindowInitialSize;
    end
    
    switch noise_type
        case 'Normal' 
            E = 0.3566; 
            D = 0.0201; 
            noise_image = AddSpeckle(test_image, noise_type); 
            test_image = test_image.*(1 + E);
            test_image = max(min(test_image, 1), 0);
        case 'Rayleigh'
            sigma = 0.2707; 
            noise_image = AddSpeckle(test_image, noise_type); 
            test_image = test_image.*(1 + sqrt(pi/2)*sigma);
            test_image = max(min(test_image, 1), 0);    
        case 'CorrelatedRayleigh'
            sigma = 0.2707; 
            noise_image = AddSpeckle(test_image, noise_type); 
            test_image = test_image.*(1 + sqrt(pi/2)*sigma);
            test_image = max(min(test_image, 1), 0);
    end
    
    %% Research
    if (strcmp(filter_name, 'AnisotropicDiffusionExp') || strcmp(filter_name, 'AnisotropicDiffusionQuad'))
        window_availability = 'off';
    end
    %%Only window size is variable 
    if (strcmp(window_availability, 'on') && ~isnumeric(p.Results.FirstFilterParameterRange) && ...
             ~isnumeric(p.Results.SecondFilterParameterRange) && ~isnumeric(p.Results.ThirdFilterParameterRange)) 
        if (strcmp(filter_name, existingNameOfFilter{4}) || strcmp(filter_name, existingNameOfFilter{5}) || ...
                strcmp(filter_name, existingNameOfFilter{6}) || strcmp(filter_name, existingNameOfFilter{7}) ||...
                strcmp(filter_name, existingNameOfFilter{8}))
            error(strcat("Error. Not enough variable parameters for ", filter_name, "!"));
        end
        window_research_result = FindingOptimalWindowSize(test_image, noise_image, filter_name);
        optimal_params = {'WindowSideSize', 'SSIM'; window_research_result{2,3}(1), window_research_result{2,3}(2)};
        research_result = {'WindowSizeVals', 'SSIM(WindowSizeVals)'; 
            window_research_result{2,1}, window_research_result{2,2}};
        
        if (strcmp(p.Results.Plotting, 'on'))
            fig = figure('Name', 'WindowResearch');
            OneParameterResearchPlotting(window_research_result, filter_name);
            
            if (strcmp(p.Results.SavingPlot, 'on')) 
                plot_filename = strcat('Output\Output\Graphics\', filter_name, '_', noise_type, '.svg');
                print(fig, plot_filename,'-dsvg');
            end
        end
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
        
        one_optimal_parameter_with_init_win_size = FindingOneOptimalParameter(test_image,...
            noise_image, filter_name, win_init_size, p.Results.FirstFilterParameterRange);
        window_research_result = FindingOptimalWindowSize(test_image, noise_image, ...
            filter_name, 'FirstFilterParameterRange', one_optimal_parameter_with_init_win_size{2,3}(1)); 
        one_optimal_parameter_with_optimal_win_size = FindingOneOptimalParameter(test_image,...
            noise_image, filter_name, [window_research_result{2,3}(1), window_research_result{2,3}(1)],....
            p.Results.FirstFilterParameterRange);
        optimal_params = {'WindowSideSize', 'FirstParameterValue', 'SSIM'; ...
            window_research_result{2,3}(1), one_optimal_parameter_with_optimal_win_size{2,3}(1), one_optimal_parameter_with_optimal_win_size{2,3}(2)};
        research_result = {'OneParameterValsWithInitWinSize', 'SSIM(OneParameterValsWithInitWinSize)',...
            'WindowSizeVals', 'SSIM(WindowSizeVals)', ...
            'OneParameterValsWithOptimalWinSize', 'SSIM(OneParameterValsWithOptimalWinSize)'; ...
            one_optimal_parameter_with_init_win_size{2,1}, one_optimal_parameter_with_init_win_size{2,2},...
            window_research_result{2,1}, window_research_result{2,2},...
            one_optimal_parameter_with_optimal_win_size{2,1}, one_optimal_parameter_with_optimal_win_size{2,2}};
        
        if (strcmp(p.Results.Plotting, 'on'))
            fig = figure('Name', 'OneParameterResearch');
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            pos1 = [0.15 0.55 0.3 0.3];
            subplot('Position',pos1)
            OneParameterResearchPlotting(one_optimal_parameter_with_init_win_size, filter_name, 'WindowSize', win_init_size)
            
            pos2 = [0.55 0.55 0.3 0.3];
            subplot('Position',pos2)
            OneParameterResearchPlotting(window_research_result, filter_name)
            
            pos3 = [0.35 0.1 0.3 0.3];
            subplot('Position',pos3)
            OneParameterResearchPlotting(one_optimal_parameter_with_optimal_win_size, filter_name, 'WindowSize', [window_research_result{2,3}(1), window_research_result{2,3}(1)])
            
            if (strcmp(p.Results.SavingPlot, 'on')) 
                plot_filename = strcat('Output\Output\Graphics\', filter_name, '_', noise_type, '.svg');
                print(fig, plot_filename,'-dsvg');
            end
        end
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
        
        two_optimal_parameter_with_init_win_size = FindingTwoOptimalParameter(test_image,...
            noise_image, filter_name, win_init_size, ....
            p.Results.FirstFilterParameterRange, p.Results.SecondFilterParameterRange);
        window_research_result = FindingOptimalWindowSize(test_image, noise_image, ...
            filter_name, 'FirstFilterParameterRange', two_optimal_parameter_with_init_win_size{2,4}(1),...
            'SecondFilterParameterRange', two_optimal_parameter_with_init_win_size{2,4}(2)); 
        two_optimal_parameter_with_optimal_win_size = FindingTwoOptimalParameter(test_image,...
            noise_image, filter_name, [window_research_result{2,3}(1), window_research_result{2,3}(1)],....
            p.Results.FirstFilterParameterRange, p.Results.SecondFilterParameterRange);
        optimal_params = {'WindowSideSize', 'FirstParameterValue', 'SecondParameterValue', 'SSIM'; ...
             window_research_result{2,3}(1), two_optimal_parameter_with_optimal_win_size{2,4}(1), two_optimal_parameter_with_optimal_win_size{2,4}(2),...
            two_optimal_parameter_with_optimal_win_size{2,4}(3)};
        research_result = {'WindowSideSize', 'FirstParameterValsWithInitWinSize', 'SecondParameterValsWithInitWinSize',...
            'SSIM(SecondParameterValsWithInitWinSize)',...
            'WindowSizeVals', 'SSIM(WindowSizeVals)', ...
            'FirstParameterValsWithOptimalWinSize', 'SecondParameterValsWithOptimalWinSize',...
            'SSIM(SecondParameterValsWithOptimalWinSize)'; ...
            window_research_result{2,3}(1), two_optimal_parameter_with_init_win_size{2,1}, two_optimal_parameter_with_init_win_size{2,2},...
            two_optimal_parameter_with_init_win_size{2,3},...
            window_research_result{2,1}, window_research_result{2,2},...
            two_optimal_parameter_with_optimal_win_size{2,1}, two_optimal_parameter_with_optimal_win_size{2,2},...
            two_optimal_parameter_with_optimal_win_size{2,3}};
        
        if (strcmp(p.Results.Plotting, 'on'))
            fig = figure('Name', 'TwoParameterResearch');
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            pos1 = [0.15 0.55 0.3 0.3];
            subplot('Position',pos1)
            TwoParameterResearchPlotting(two_optimal_parameter_with_init_win_size, filter_name, win_init_size)
            
            pos2 = [0.55 0.55 0.3 0.3];
            subplot('Position',pos2)
            OneParameterResearchPlotting(window_research_result, filter_name)
            
            pos3 = [0.35 0.1 0.3 0.3];
            subplot('Position',pos3)
            TwoParameterResearchPlotting(two_optimal_parameter_with_optimal_win_size, filter_name, [window_research_result{2,3}(1), window_research_result{2,3}(1)])
            
            if (strcmp(p.Results.SavingPlot, 'on')) 
                plot_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '.svg');
                print(fig, plot_filename,'-dsvg');
            end
        end       
 %%Three variable parameter without variable window size        
    elseif (strcmp(window_availability, 'off') && isnumeric(p.Results.FirstFilterParameterRange) && ...
             isnumeric(p.Results.SecondFilterParameterRange) && isnumeric(p.Results.ThirdFilterParameterRange))
        if (strcmp(filter_name, existingNameOfFilter{1}) || strcmp(filter_name, existingNameOfFilter{2}) || ...
                strcmp(filter_name, existingNameOfFilter{3}) || strcmp(filter_name, existingNameOfFilter{4}) || ...
                strcmp(filter_name, existingNameOfFilter{5}) || strcmp(filter_name, existingNameOfFilter{6}))
            error(strcat("Error. Too many variable parameters for ", filter_name, "!"));
        end
        research_result = FindingThreeOptimalParameter(test_image, noise_image, filter_name,....
            p.Results.FirstFilterParameterRange, p.Results.SecondFilterParameterRange, p.Results.ThirdFilterParameterRange); 
        optimal_params = {'FirstParameterValue', 'SecondParameterValue', 'ThirdParameterValue', 'SSIM'; ...
            research_result{2,9}(1), research_result{2,9}(2),...
            research_result{2,9}(3), research_result{2,9}(4)};
        
         if (strcmp(p.Results.Plotting, 'on'))
            fig = figure('Name', 'ThreeParameterResearch');
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            ThreeParameterResearchPlotting(research_result, filter_name);
            
            if (strcmp(p.Results.SavingPlot, 'on')) 
                plot_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '.svg');
                print(fig, plot_filename,'-dsvg');
            end
        end       
    end      
end