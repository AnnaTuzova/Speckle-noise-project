clc;clear;close all;
addpath(genpath('Functions'));
addpath(genpath('Input'));   
addpath(genpath('Output'));

%% Load test image for finding optimal parameters
test_image = mat2gray(rgb2gray(imread('ref_img_1.png'))); %%ref_img_1

%% Settings  
research_condition          = 'off'; %%'on' - finding for optimal parameters; 'off' - load existing optimal parameters
plotting_graphics_set       = 'off';
filtering_condition         = 'on';
oneD_slices_condition       = 'off';

%%Settings for finding optimal parameters
noise_type          = 'Rayleigh';
window_size_init	= [11,11]; 
metric_names        = ["ssim", "gmsdMetric", "uqiMetric", "mseMetric", "psnrMetric"];
%["ssim", "gmsdMetric", "uqiMetric", "mseMetric", "psnrMetric"]; 
%%"ssim", "gmsdMetric", "mseMetric", "DetermCoeffMetric", "maeMetric",
%%"psnrMetric", "uqiMetric"
metric_names_len	= length(metric_names);

finding_settings.ParallelComputing	= 'on';
finding_settings.MetricsInteraction	= 'on'; 
finding_settings.kThershold         = 0.001;

plotting_settings.SavingPlot              = 'on'; 
plotting_settings.FigureType              = 'SeparateFigures'; %%'SubplotFigures','SeparateFigures'
plotting_settings.MetricsPlotting         = 'MultipleAxes'; %'MultipleAxes', 'MultipleFigures', 'OnePlotNormalization'
plotting_settings.AxisFontSize            = 13;

%%Settings for filtering
imshowing_set               = 'off'; 
imsaving_set                = 'on';
title_condition             = 'off';
showing_metric_maps_set     = 'off';
showing_differ_img          = 'on';
nerual_network_set          = 'on';

%%Settings for 1D slices
slice_type                  = 'OneFilterAllMetrics'; %% 'OneMetricAllFilters', 'OneFilterAllMetrics'
slice_level                 = 0.335;
plot_spacing_coefficient	= 0.2;
nerual_network_1D_slice     = 'on';
%% Finding optimal parameters
names_of_filters = {'MedianFilter', 'LeeFilter', 'MAPFilter', 'FrostFilter', 'KuanFilter', 'BilateralFilter',...
         'AnisotropicDiffusionExp', 'AnisotropicDiffusionQuad'};
if (strcmp(research_condition, 'on'))  
     [MedianFilter_optimal_params, MedianFilter_research_result] = FindingOptimalParameters(test_image, 'MedianFilter',...
        'NoiseType', noise_type, 'Metrics', metric_names, 'WindowInitialSize', window_size_init,...
        'Settings', finding_settings); %%Median

    [LeeFilter_optimal_params, LeeFilter_research_result] = FindingOptimalParameters(test_image, 'LeeFilter',...
        'NoiseType', noise_type, 'Metrics', metric_names, 'WindowInitialSize', window_size_init,...
        'Settings', finding_settings); %%Lee

    [MAPFilter_optimal_params, MAPFilter_research_result] = FindingOptimalParameters(test_image, 'MAPFilter',...
        'NoiseType', noise_type, 'Metrics', metric_names, 'WindowInitialSize', window_size_init,...
        'Settings', finding_settings); %%MAP

%     Frost_parameter_range = 0:0.5:25;
    Frost_parameter_range = -5:0.2:50;
    [FrostFilter_optimal_params, FrostFilter_research_result] = FindingOptimalParameters(test_image, 'FrostFilter',...
        'NoiseType', noise_type, 'Metrics', metric_names, 'WindowInitialSize', window_size_init,...
        'FirstFilterParameterRange', Frost_parameter_range, ...
        'Settings', finding_settings);

%     Kuan_parameter_range = -0.9:0.2:5;
    Kuan_parameter_range = -0.9:0.1:10;
    [KuanFilter_optimal_params, KuanFilter_research_result] = FindingOptimalParameters(test_image, 'KuanFilter', ...
        'NoiseType', noise_type, 'Metrics', metric_names, 'WindowInitialSize', window_size_init,... 
        'FirstFilterParameterRange', Kuan_parameter_range, ...
        'Settings', finding_settings); %%Kuan

%     bilat_first_parameter_range = 1:2:15; %%sig_r
%     bilat_second_parameter_range = 1:2:70; %%sig_d
    bilat_first_parameter_range = [-3:0.8:3]; %%sig_r
    bilat_second_parameter_range = [-5:0.1:-0.1 0.1:0.1:5]; %%sig_d
    
    [BilateralFilter_optimal_params, BilateralFilter_research_result] = FindingOptimalParameters(test_image, 'BilateralFilter',...
        'NoiseType', noise_type, 'Metrics', metric_names, 'WindowInitialSize', window_size_init,...
        'FirstFilterParameterRange', bilat_first_parameter_range, ...
        'SecondFilterParameterRange', bilat_second_parameter_range,...
        'Settings', finding_settings);
    
    anisotrop_first_parameter_range = 1:1:50; %%t
    anisotrop_second_parameter_range = [0.01 0.05:0.05:0.5]; %%k
    anisotrop_third_parameter_range = 0:0.01:0.25; %%delta_t     
    [AnisotropicDiffusionExp_optimal_params, AnisotropicDiffusionExp_research_result] = FindingOptimalParameters(test_image, 'AnisotropicDiffusionExp',...
        'NoiseType', noise_type, 'MetricsNames', metric_names, ...
        'FirstFilterParameterRange', anisotrop_first_parameter_range, ...
        'SecondFilterParameterRange', anisotrop_second_parameter_range, ...
        'ThirdFilterParameterRange', anisotrop_third_parameter_range, ...
        'FirstFilterParameterInitialVal', anisotrop_first_parameter_range(10), 'Settings', finding_settings); %%anisotropic diffusion with exponential g(x)
    
    [AnisotropicDiffusionQuad_optimal_params, AnisotropicDiffusionQuad_research_result] = FindingOptimalParameters(test_image, 'AnisotropicDiffusionQuad',...
        'NoiseType', noise_type, 'Metrics', metric_names,  ......
        'FirstFilterParameterRange', anisotrop_first_parameter_range, ...
        'SecondFilterParameterRange', anisotrop_second_parameter_range, ...
        'ThirdFilterParameterRange', anisotrop_third_parameter_range, ...
        'FirstFilterParameterInitialVal', anisotrop_first_parameter_range(10), 'Settings', finding_settings); %%anisotropic diffusion with quadratic g(x)

   %% Create optimal values and research result structurs
   for i = 1:length(names_of_filters)
       optimal_parameters.(names_of_filters{i}) = eval(strcat(names_of_filters{i}, '_optimal_params'));
       research_results.(names_of_filters{i}) = eval(strcat(names_of_filters{i}, '_research_result'));
   end
    
    save(strcat('Output\Research results\OptimalParameters\OptimalParameters_with_', noise_type, 'Noise,',...
        finding_settings.MetricsInteraction, 'MetricsInteraction,', ...
        num2str(finding_settings.kThershold), '_kThershold', '.mat'), 'optimal_parameters');
    save(strcat('Output\Research results\OptimalParameters\ResearchResults_with_', noise_type, 'Noise,',...
        finding_settings.MetricsInteraction, 'MetricsInteraction,', ...
        num2str(finding_settings.kThershold), '_kThershold', '.mat'), 'research_results');
else
    if (exist(strcat('Output\Research results\OptimalParameters\OptimalParameters_with_', noise_type, 'Noise,',...
        finding_settings.MetricsInteraction, 'MetricsInteraction,', ...
        num2str(finding_settings.kThershold), '_kThershold', '.mat'), 'file') &&...
        exist(strcat('Output\Research results\OptimalParameters\ResearchResults_with_', noise_type, 'Noise,',...
        finding_settings.MetricsInteraction, 'MetricsInteraction,', ...
        num2str(finding_settings.kThershold), '_kThershold', '.mat'), 'file'))
    
        load(strcat('Output\Research results\OptimalParameters\OptimalParameters_with_', noise_type, 'Noise,',...
        finding_settings.MetricsInteraction, 'MetricsInteraction,', ...
        num2str(finding_settings.kThershold), '_kThershold', '.mat'));
        
        load(strcat('Output\Research results\OptimalParameters\ResearchResults_with_', noise_type, 'Noise,',...
        finding_settings.MetricsInteraction, 'MetricsInteraction,', ...
        num2str(finding_settings.kThershold), '_kThershold', '.mat'));
    else
        error("Error: File with optimal parameters of filters is not found.")
    end
end
%% Plotting research results
    if (strcmp(plotting_graphics_set, 'on'))
        PlottingResearches(research_results.MedianFilter, 'MedianFilter', noise_type, ...
            'Settings', plotting_settings);
        close all;
        PlottingResearches(research_results.LeeFilter, 'LeeFilter', noise_type, ...
            'Settings', plotting_settings);
        close all;
        PlottingResearches(research_results.MAPFilter, 'MAPFilter', noise_type, ...
            'Settings', plotting_settings); 
        close all;
        PlottingResearches(research_results.FrostFilter, 'FrostFilter', noise_type, ...
            'NameOfFirstFilterParameter', 'D', 'Settings', plotting_settings);
        close all;
        PlottingResearches(research_results.KuanFilter, 'KuanFilter', noise_type, ...
            'NameOfFirstFilterParameter', 'A', 'Settings', plotting_settings);
        close all;
         PlottingResearches(research_results.BilateralFilter, 'BilateralFilter', noise_type, ...
            'NameOfFirstFilterParameter', '\sigma_{r}',...
            'NameOfSecondFilterParameter', '\sigma_{d}', 'Settings', plotting_settings);
        close all;
        PlottingResearches(research_results.AnisotropicDiffusionExp, 'AnisotropicDiffusionExp', noise_type, ...
            'NameOfFirstFilterParameter', 't', 'NameOfSecondFilterParameter', 'k', ...
            'NameOfThirdFilterParameter', '\Deltat', 'Settings', plotting_settings);
        close all;
        PlottingResearches(research_results.AnisotropicDiffusionQuad, 'AnisotropicDiffusionQuad', noise_type, ...
            'NameOfFirstFilterParameter', 't', 'NameOfSecondFilterParameter', 'k', ...
            'NameOfThirdFilterParameter', '\Deltat', 'Settings', plotting_settings);
        close all;
    end

%% Filtering
noise_img = AddSpeckle(test_image, noise_type);
ref_img = ConvertRefrenceImage(test_image, noise_type);
if (strcmp(filtering_condition, 'on'))  
    date = strrep(datestr(datetime('now')), ':','-');
    path_name = ['Output\Filtering images\', date];
    mkdir(path_name)
    path_name = [path_name, '\'];
    path_differ = [path_name, 'Differ images'];
    mkdir(path_differ)
    path_differ = [path_differ, '\'];
                
	if (strcmp(imshowing_set, 'on'))
        ref_img_fig = figure('Name', 'Image without noise');
        ImageShowing(ref_img, title_condition, "Reference image (without noise)");

        noise_img_fig = figure('Name', 'Image with noise');  
        ImageShowing(noise_img, title_condition, strcat("Image with ", noise_type, " noise"));

        ImageSaving(imsaving_set, ref_img_fig, strcat(path_name,'0_ref_img.png'));
        ImageSaving(imsaving_set, noise_img_fig, strcat(path_name, '1_img_with_',...
                    noise_type,'_noise.png'));
        close all;
	end
    
    metric_names_for_plot = GetMetricsNamesForPlotting(metric_names);
    for j = 1:metric_names_len
        metrcis_vals.NoFilter.(metric_names{j}) = feval(metric_names{j}, noise_img, ref_img);
    end

    for i = 1:length(names_of_filters)
        for j = 1:metric_names_len
            field_names = fieldnames(optimal_parameters.(names_of_filters{i}));
            filt_image = FilteringByOptimalParameters(noise_img, ...
                optimal_parameters, (names_of_filters{i}), (field_names{j}), metric_names{j});
            
            if (strcmp(imshowing_set, 'on'))
                filt_img_fig = figure('Name',  strcat("Image after ", names_of_filters{i}, ...
                    " with optimal parameters by ", metric_names{j})); 
                ImageShowing(filt_image, title_condition, strcat("Image after ", names_of_filters{i}, ...
                    " with optimal parameters by ", metric_names_for_plot{j}))
                ImageSaving(imsaving_set, filt_img_fig, ...
                    strcat(path_name, num2str(i), '_', num2str(j),...
                    '_img_with_', noise_type, '_noise_after_', names_of_filters{i}, '_by_', metric_names{j}, '.png')); 
                close all;
            end
            
            if (strcmp(showing_differ_img, 'on')) 
                diff_img = abs(ref_img - filt_image);
                imwrite(diff_img, strcat(path_differ, num2str(i), '_', num2str(j),...
                    '_differ_img_with_', noise_type, '_noise_after_',...
                    names_of_filters{i}, '_by_', metric_names{j}, '.png'));
            end
            
            if ((strcmp(metric_names{j}, 'ssim') ||...
            	strcmp(metric_names{j}, 'gmsdMetric') || ...
            	strcmp(metric_names{j}, 'uqiMetric')) && ...
                (strcmp(showing_metric_maps_set, 'on')))
                [metrcis_vals.(names_of_filters{i}).(metric_names{j}), ...
                    quality_map] = feval(metric_names{j}, filt_image, ref_img); 
                quality_map_fig = figure('Name', strcat(metric_names{j}, " quality map for ", names_of_filters{i}));  
                ImageShowing(quality_map, title_condition, strcat(metric_names_for_plot{j},...
                            " quality map for ", names_of_filters{i}))
                ImageSaving(imsaving_set, quality_map_fig, ...
                    strcat(path_name, metric_names{j},...
                    '_QualityMap_', names_of_filters{i}, '.png')); 
                close all;
            else
                metrcis_vals.(names_of_filters{i}).(metric_names{j}) = ...
                    feval(metric_names{j}, filt_image, ref_img);
            end
        end  
    end
    
    %% Denoise Nerual Network
    if (strcmp(nerual_network_set, 'on'))
    %         names_of_filters = [names_of_filters, 'NerualNetwork'];
        net = denoisingNetwork('DnCNN');
        NN_filt_image = denoiseImage(noise_img, net);
        if (strcmp(imshowing_set, 'on'))
            NN_filt_img_fig = figure('Name', "Image after nerual network"); 
            ImageShowing(NN_filt_image, title_condition, "Image after neural network")
            ImageSaving(imsaving_set, NN_filt_img_fig, ...
                strcat(path_name, 'Image after neural network.png')); 
            close all;
        end

        if (strcmp(showing_differ_img, 'on'))
            NN_diff_img = abs(ref_img - NN_filt_image);
            imwrite(NN_diff_img, strcat(path_differ, 'Difference image after neural network.png'));
        end

        for j = 1:metric_names_len
            if ((strcmp(metric_names{j}, 'ssim') ||...
                strcmp(metric_names{j}, 'gmsdMetric') || ...
                strcmp(metric_names{j}, 'uqiMetric')) && ...
                (strcmp(showing_metric_maps_set, 'on')))
                [metrcis_vals.NerualNetwork.(metric_names{j}), ...
                    quality_map_NN] = feval(metric_names{j}, NN_filt_image, ref_img); 
                quality_map_NN_fig = figure('Name', strcat(metric_names{j}, " quality map for nerual network"));  
                ImageShowing(quality_map_NN, title_condition, strcat(metric_names_for_plot{j},...
                            " quality map for nerual network"))
                ImageSaving(imsaving_set, quality_map_NN_fig, ...
                    strcat(path_name, metric_names{j},...
                    '_QualityMap_NerualNetwork.png'));        
                close all;
            else
                metrcis_vals.NerualNetwork.(metric_names{j}) = ...
                    feval(metric_names{j}, NN_filt_image, ref_img);
            end
        end
    end
    %%
    if (strcmp(showing_differ_img, 'on'))
        ContrastChange(path_differ);
    end
    
    %% Table of metric values
    if (strcmp(nerual_network_set, 'on'))
        names_of_filters_for_table = ['NoFilter' names_of_filters 'NerualNetwork'];
    else
        names_of_filters_for_table = ['NoFilter' names_of_filters];
    end
    metrics_vals_table = zeros(length(names_of_filters_for_table), metric_names_len);
    for i = 1:length(names_of_filters_for_table) 
        for j = 1:metric_names_len
            metrics_vals_table(i,j) = ...
                metrcis_vals.(names_of_filters_for_table{i}).(metric_names{j});     
        end
    end

    table_metric = array2table(metrics_vals_table,...
        'VariableNames', cellstr(metric_names))
    table_metric.Properties.RowNames = [names_of_filters_for_table']
    table_name = strcat('Output\Research results\Tabels\Metrics_table_with_',...
        noise_type, 'Noise,', finding_settings.MetricsInteraction, 'MetricsInteraction,', ...
        num2str(finding_settings.kThershold), '_kThershold','.csv');
    writetable(table_metric, table_name, 'WriteRowNames',true);
end   


%% 1D slices
if (strcmp(oneD_slices_condition, 'on'))
    ref_img_for_slices = mat2gray(rgb2gray(imread('test_img_for_slices.png')));
    noise_img_for_slices = AddSpeckle(ref_img_for_slices, noise_type);
    ref_img_for_slices = ConvertRefrenceImage(ref_img_for_slices, noise_type);
    OneDimensionSlice(ref_img, noise_img, optimal_parameters,...
        metric_names, names_of_filters, 'SliceType', slice_type, ...
        'SliceLevel', slice_level, 'PlotSpacingCoefficient', plot_spacing_coefficient, ...
        'SavingPlot', imsaving_set, 'NerualNetwork', nerual_network_1D_slice,...
        'PlotsLanguage', 'eng');
    close all;
end

