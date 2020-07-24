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
    defaultWindowAvailability = 'on';
    defaultWindowInitialSize = [11,11];
    defaultPlotting = 'off';
    defaultParallelComputing = 'on';
    defaultFigureType = 'SubplotFigures';
    expectedNoiseType = {'Normal', 'Rayleigh', 'CorrelatedRayleigh'};
    existingNameOfFilter = {'MedianFilter', 'LeeFilter', 'MAPFilter', 'FrostFilter', 'KuanFilter', 'BilateralFilter',...
         'AnisotropicDiffusionExp', 'AnisotropicDiffusionQuad'};
    expectedOnOff = {'on','off'};
    expectedFigureType = {'SubplotFigures','SeparateFigures'};
    
	p = inputParser;
    addRequired(p, 'TestImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addParameter(p, 'NoiseType', defaultNoiseType, @(x) any(validatestring(x, expectedNoiseType)))
    addParameter(p, 'WindowAvailability', defaultWindowAvailability, @(x) any(validatestring(x, expectedOnOff)))
    addParameter(p, 'WindowInitialSize', defaultWindowInitialSize, ...
        @(x) isnumeric(x) && ~isempty(x) && all(size(x) == [1,2]) && all(x > 0))
    addParameter(p, 'FirstFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'NameOfFirstFilterParameter', @(x) ischar(x))
    addParameter(p, 'SecondFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'NameOfSecondFilterParameter', @(x) ischar(x))
    addParameter(p, 'ThirdFilterParameterRange', @(x) isnumeric(x) && all(x(:) ~= Inf) && all(~isnan(x(:))))
    addParameter(p, 'NameOfThirdFilterParameter', @(x) ischar(x))
    addParameter(p, 'Plotting', defaultPlotting, @(x) any(validatestring(x, expectedOnOff)))
    addParameter(p, 'SavingPlot', defaultPlotting, @(x) any(validatestring(x, expectedOnOff)))
    addParameter(p, 'FigureType', defaultFigureType, @(x) any(validatestring(x, expectedFigureType)))
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
            fig = figure('Name', strcat(filter_name, " research"));
            OneParameterResearchPlotting(window_research_result, filter_name);
            
            if (strcmp(p.Results.SavingPlot, 'on')) 
                plot_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '.png');
                print(fig, plot_filename,'-dpng','-r500');
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
            if(strcmp(p.Results.FigureType, 'SubplotFigures'))
                fig = figure('Name', strcat(filter_name, " research"));
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                pos1 = [0.15 0.55 0.3 0.3];
                subplot('Position',pos1)
                if(ischar(p.Results.NameOfFirstFilterParameter))
                    OneParameterResearchPlotting(one_optimal_parameter_with_init_win_size, ...
                        filter_name, 'WindowSize', win_init_size, 'NameOfFirstFilterParameter', p.Results.NameOfFirstFilterParameter)
                else
                    OneParameterResearchPlotting(one_optimal_parameter_with_init_win_size, ...
                        filter_name, 'WindowSize', win_init_size)
                end

                pos2 = [0.55 0.55 0.3 0.3];
                subplot('Position',pos2)
                OneParameterResearchPlotting(window_research_result, filter_name)

                pos3 = [0.35 0.1 0.3 0.3];
                subplot('Position',pos3)
                if(ischar(p.Results.NameOfFirstFilterParameter))
                    OneParameterResearchPlotting(one_optimal_parameter_with_optimal_win_size, ...
                        filter_name, 'WindowSize', [window_research_result{2,3}(1), window_research_result{2,3}(1)],...
                        'NameOfFirstFilterParameter', p.Results.NameOfFirstFilterParameter)
                else
                    OneParameterResearchPlotting(one_optimal_parameter_with_optimal_win_size,...
                        filter_name, 'WindowSize', [window_research_result{2,3}(1), window_research_result{2,3}(1)]) 
                end
                
                if (strcmp(p.Results.SavingPlot, 'on')) 
                    plot_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '.png');
                    print(fig, plot_filename,'-dpng','-r500');
                end
            else
                fig_stage1 = figure('Name', strcat(filter_name, " research. Stage 1"));
                if(ischar(p.Results.NameOfFirstFilterParameter))
                    OneParameterResearchPlotting(one_optimal_parameter_with_init_win_size, ...
                        filter_name, 'WindowSize', win_init_size, 'NameOfFirstFilterParameter', p.Results.NameOfFirstFilterParameter)
                else
                    OneParameterResearchPlotting(one_optimal_parameter_with_init_win_size, ...
                        filter_name, 'WindowSize', win_init_size)
                end
                
                fig_stage2 = figure('Name', strcat(filter_name, " research. Stage 2"));
                OneParameterResearchPlotting(window_research_result, filter_name)

                fig_stage3 = figure('Name', strcat(filter_name, " research. Stage 3"));
                if(ischar(p.Results.NameOfFirstFilterParameter))
                    OneParameterResearchPlotting(one_optimal_parameter_with_optimal_win_size, ...
                        filter_name, 'WindowSize', [window_research_result{2,3}(1), window_research_result{2,3}(1)],...
                        'NameOfFirstFilterParameter', p.Results.NameOfFirstFilterParameter)
                else
                    OneParameterResearchPlotting(one_optimal_parameter_with_optimal_win_size,...
                        filter_name, 'WindowSize', [window_research_result{2,3}(1), window_research_result{2,3}(1)]) 
                end 
                
                if (strcmp(p.Results.SavingPlot, 'on')) 
                    stage1_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_stage1.png');
                    stage2_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_stage2.png');
                    stage3_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_stage3.png');
                    print(fig_stage1, stage1_filename,'-dpng','-r500');
                    print(fig_stage2, stage2_filename,'-dpng','-r500');
                    print(fig_stage3, stage3_filename,'-dpng','-r500');
                end
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
            if(strcmp(p.Results.FigureType, 'SubplotFigures'))    
                fig = figure('Name', strcat(filter_name, " research"));
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                pos1 = [0.15 0.55 0.3 0.3];
                subplot('Position',pos1)
                if(ischar(p.Results.NameOfFirstFilterParameter) && ischar(p.Results.NameOfSecondFilterParameter))
                    TwoParameterResearchPlotting(two_optimal_parameter_with_init_win_size, filter_name,...
                        win_init_size, 'NameOfFirstFilterParameter', p.Results.NameOfFirstFilterParameter, ...
                        'NameOfSecondFilterParameter', p.Results.NameOfSecondFilterParameter) 
                else
                    TwoParameterResearchPlotting(two_optimal_parameter_with_init_win_size, filter_name, win_init_size) 
                end
                
                pos2 = [0.55 0.55 0.3 0.3];
                subplot('Position',pos2)
                OneParameterResearchPlotting(window_research_result, filter_name)

                pos3 = [0.35 0.1 0.3 0.3];
                subplot('Position',pos3)
                if(ischar(p.Results.NameOfFirstFilterParameter) && ischar(p.Results.NameOfSecondFilterParameter))
                    TwoParameterResearchPlotting(two_optimal_parameter_with_optimal_win_size, filter_name,...
                        [window_research_result{2,3}(1), window_research_result{2,3}(1)],...
                        'NameOfFirstFilterParameter', p.Results.NameOfFirstFilterParameter, ...
                        'NameOfSecondFilterParameter', p.Results.NameOfSecondFilterParameter) 
                else
                    TwoParameterResearchPlotting(two_optimal_parameter_with_optimal_win_size, ...
                        filter_name, [window_research_result{2,3}(1), window_research_result{2,3}(1)]) 
                end
                
                if (strcmp(p.Results.SavingPlot, 'on')) 
                    plot_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '.png');
                    print(fig, plot_filename,'-dpng','-r500');
                end
            else
                fig_stage1 = figure('Name', strcat(filter_name, " research. Stage 1"));
                if(ischar(p.Results.NameOfFirstFilterParameter) && ischar(p.Results.NameOfSecondFilterParameter))
                    TwoParameterResearchPlotting(two_optimal_parameter_with_init_win_size, filter_name,...
                        win_init_size, 'NameOfFirstFilterParameter', p.Results.NameOfFirstFilterParameter, ...
                        'NameOfSecondFilterParameter', p.Results.NameOfSecondFilterParameter) 
                else
                    TwoParameterResearchPlotting(two_optimal_parameter_with_init_win_size, filter_name, win_init_size) 
                end
                
                fig_stage2 = figure('Name', strcat(filter_name, " research. Stage 2"));
                OneParameterResearchPlotting(window_research_result, filter_name)

                fig_stage3 = figure('Name', strcat(filter_name, " research. Stage 3"));
                if(ischar(p.Results.NameOfFirstFilterParameter) && ischar(p.Results.NameOfSecondFilterParameter))
                    TwoParameterResearchPlotting(two_optimal_parameter_with_optimal_win_size, filter_name,...
                        [window_research_result{2,3}(1), window_research_result{2,3}(1)],...
                        'NameOfFirstFilterParameter', p.Results.NameOfFirstFilterParameter, ...
                        'NameOfSecondFilterParameter', p.Results.NameOfSecondFilterParameter) 
                else
                    TwoParameterResearchPlotting(two_optimal_parameter_with_optimal_win_size, ...
                        filter_name, [window_research_result{2,3}(1), window_research_result{2,3}(1)]) 
                end
                
                if (strcmp(p.Results.SavingPlot, 'on')) 
                    stage1_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_stage1.png');
                    stage2_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_stage2.png');
                    stage3_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_stage3.png');
                    print(fig_stage1, stage1_filename,'-dpng','-r500');
                    print(fig_stage2, stage2_filename,'-dpng','-r500');
                    print(fig_stage3, stage3_filename,'-dpng','-r500');
                end
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
            if(ischar(p.Results.NameOfFirstFilterParameter) && ischar(p.Results.NameOfSecondFilterParameter) && ...
                    ischar(p.Results.NameOfThirdFilterParameter))
                ThreeParameterResearchPlotting(research_result, filter_name, noise_type,...
                    'NameOfFirstFilterParameter', p.Results.NameOfFirstFilterParameter, ...
                    'NameOfSecondFilterParameter', p.Results.NameOfSecondFilterParameter,...
                    'NameOfThirdFilterParameter', p.Results.NameOfThirdFilterParameter,...
                    'SavingPlot', p.Results.SavingPlot, 'FigureType', p.Results.FigureType);
            else
                ThreeParameterResearchPlotting(research_result, filter_name, noise_type,...
                    'SavingPlot', p.Results.SavingPlot, 'FigureType', p.Results.FigureType);
            end 
        end       
	end      
end