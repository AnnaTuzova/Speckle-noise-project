clc;clear;close all;
addpath(genpath('filters'));
addpath(genpath('metrics'));   
addpath(genpath('filtering_images_and_tabel'));
addpath(genpath('pic'));
addpath(genpath('real images for testing filter'));

%% Load test image for finding optimal parameters
test_image = mat2gray(rgb2gray(imread('fig2.png')));

%% Settings 
noise_type = 'Rayleigh';
plotting_set = 'on'; 
saving_plot_set = 'on';
research_condition = 'on'; %%'on' - finding for optimal parameters; 'off' - load existing optimal parameters
%% Finding optimal parameters
names_of_filters = {'MedianFilter', 'LeeFilter', 'MAPFilter', 'FrostFilter', 'KuanFilter', 'BilateralFilter',...
         'AnisotropicDiffusionExp', 'AnisotropicDiffusionQuad'};
if (strcmp(research_condition, 'on'))
    [median_optimal_params, ~] = FindingOptimalParameters(test_image, 'MedianFilter',...
        'NoiseType', noise_type, 'Plotting', plotting_set, 'SavingPlot', saving_plot_set); %%Median

    [Lee_optimal_params, ~] = FindingOptimalParameters(test_image, 'LeeFilter',...
        'NoiseType', noise_type, 'Plotting', plotting_set, 'SavingPlot', saving_plot_set); %%Lee

    [MAP_optimal_params, ~] = FindingOptimalParameters(test_image, 'MAPFilter',...
        'NoiseType', noise_type, 'Plotting', plotting_set, 'SavingPlot', saving_plot_set); %%MAP

    Frost_parameter_range = 0:0.5:25;
    [Frost_optimal_params, ~] = FindingOptimalParameters(test_image, 'FrostFilter', ...
        'FirstFilterParameterRange', Frost_parameter_range,...
        'NoiseType', noise_type, 'Plotting', plotting_set, 'SavingPlot', saving_plot_set); %%Frost

    Kuan_parameter_range = -0.9:0.2:5;
    [Kuan_optimal_params, ~] = FindingOptimalParameters(test_image, 'KuanFilter', ...
        'FirstFilterParameterRange', Kuan_parameter_range,...
        'NoiseType', noise_type, 'Plotting', plotting_set, 'SavingPlot', saving_plot_set); %%Kuan

    bilat_first_parameter_range = 1:2:15; 
    bilat_second_parameter_range = 1:2:70; 
    [bilaterial_optimal_params, ~] = FindingOptimalParameters(test_image, 'BilateralFilter', ...
        'FirstFilterParameterRange', bilat_first_parameter_range, 'SecondFilterParameterRange', bilat_second_parameter_range,...
        'NoiseType', noise_type, 'Plotting', plotting_set, 'SavingPlot', saving_plot_set); %%Bilaterial

    anisotrop_first_parameter_range = 1:1:50; %%t
    anisotrop_second_parameter_range = 0.1:0.1:1; %%k
    anisotrop_third_parameter_range = 0:0.01:0.25; %%delta_t     
    [anisotropExp_optimal_params, ~] = FindingOptimalParameters(test_image, 'AnisotropicDiffusionExp', ...
        'FirstFilterParameterRange', anisotrop_first_parameter_range, 'SecondFilterParameterRange', anisotrop_second_parameter_range,...
        'ThirdFilterParameterRange', anisotrop_third_parameter_range, ...
        'NoiseType', noise_type, 'Plotting', plotting_set, 'SavingPlot', saving_plot_set); %%anisotropic diffusion with exponential g(x)
    [anisotropQuad_optimal_params, ~] = FindingOptimalParameters(test_image, 'AnisotropicDiffusionQuad', ...
        'FirstFilterParameterRange', anisotrop_first_parameter_range, 'SecondFilterParameterRange', anisotrop_second_parameter_range,...
        'ThirdFilterParameterRange', anisotrop_third_parameter_range,...
        'NoiseType', noise_type, 'Plotting', plotting_set, 'SavingPlot', saving_plot_set); %%anisotropic diffusion with quadratic g(x)

    optimal_parameters_of_filters = names_of_filters;
    optimal_parameters_of_filters{2,1} = median_optimal_params;
    optimal_parameters_of_filters{2,2} = Lee_optimal_params;
    optimal_parameters_of_filters{2,3} = MAP_optimal_params;
    optimal_parameters_of_filters{2,4} = Frost_optimal_params;
    optimal_parameters_of_filters{2,5} = Kuan_optimal_params;
    optimal_parameters_of_filters{2,6} = bilaterial_optimal_params;
    optimal_parameters_of_filters{2,7} = anisotropExp_optimal_params;
    optimal_parameters_of_filters{2,8} = anisotropQuad_optimal_params;
    save(strcat('research results\OptimalParametersOfFilters_with_', noise_type, 'Noise.mat'), 'optimal_parameters_of_filters');
else
    if (exist(strcat('OptimalParametersOfFilters_with_', noise_type, 'Noise.mat'), 'file'))
        load(strcat('research results\OptimalParametersOfFilters_with_', noise_type, 'Noise.mat'));
    else
        error("Error: File with optimal parameters of filters is not found.")
    end
end


