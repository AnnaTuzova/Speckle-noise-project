clc;clear;close all;
addpath(genpath('Functions'));
addpath(genpath('Input'));   
addpath(genpath('Output'));

%% Load test image for finding optimal parameters
test_image = mat2gray(rgb2gray(imread('fig2.png')));

%% Settings 
%%Settings for finding optimal parameters
noise_type = 'Rayleigh';
plotting_set = 'on'; 
saving_plot_set = 'on';
research_condition = 'off'; %%'on' - finding for optimal parameters; 'off' - load existing optimal parameters
%%Settings for filtering
filtering_condition = 'off';
imshowing_set = 'on'; 
imsaving_set = 'off';
title_condition = 'on';
oneD_slices_condition = 'on';

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
    save(strcat('Output\Research results\OptimalParametersOfFilters_with_', noise_type, 'Noise.mat'), 'optimal_parameters_of_filters');
else
    if (exist(strcat('OptimalParametersOfFilters_with_', noise_type, 'Noise.mat'), 'file'))
        load(strcat('Output\Research results\OptimalParametersOfFilters_with_', noise_type, 'Noise.mat'));
    else
        error("Error: File with optimal parameters of filters is not found.")
    end
end

%% Filtering
noise_img = AddSpeckle(test_image, noise_type);
ref_img = ConvertRefrenceImage(test_image, noise_type);
if (strcmp(filtering_condition, 'on'))
    if (strcmp(imshowing_set, 'on'))
        ref_img_fig = figure('Name', 'Image without noise');  
        imshow(padarray(ref_img,[1,1],0)); 
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
        if (strcmp(title_condition, 'on')) 
            title("Reference image (without noise)");
        end

        noise_img_fig = figure('Name', 'Image with noise');  
        imshow(padarray(noise_img,[1,1],0));
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
        if (strcmp(title_condition, 'on')) 
            title(strcat("Image with ", noise_type, " noise"));
        end

        if (strcmp(imsaving_set, 'on'))
            ref_img_filename = strcat('Output\Filtering images and tabel\0_ref_img.png');
            print(ref_img_fig, ref_img_filename,'-dpng','-r500');  

            noise_img_filename = strcat('Output\Filtering images and tabel\1_img_with_',...
                    noise_type,'_noise.png');
            print(noise_img_fig, noise_img_filename,'-dpng','-r500');  
        end
    end

    ssim_vals = zeros(1, length(names_of_filters) + 1);
    ssim_vals(1) = ssim(noise_img, ref_img);  
    
    for i = 1:length(names_of_filters) 
        if (size(optimal_parameters_of_filters{2,i}, 2) == 2) %%Only window size is variable
            filt_image = feval(names_of_filters{i}, noise_img, ...
                [optimal_parameters_of_filters{2,i}{2,1} optimal_parameters_of_filters{2,i}{2,1}]); 
        elseif (size(optimal_parameters_of_filters{2,i}, 2) == 3) %%One variable parameter and window size
            filt_image = feval(names_of_filters{i}, noise_img, ...
                [optimal_parameters_of_filters{2,i}{2,1} optimal_parameters_of_filters{2,i}{2,1}], ...
                optimal_parameters_of_filters{2,i}{2,2}); 
        elseif (size(optimal_parameters_of_filters{2,i}, 2) == 4 && ...
                strcmp(optimal_parameters_of_filters{2,i}{1,1}, 'WindowSideSize')) %%Two variable parameter and window size
            filt_image = feval(names_of_filters{i}, noise_img, ...
                [optimal_parameters_of_filters{2,i}{2,1} optimal_parameters_of_filters{2,i}{2,1}], ...
                optimal_parameters_of_filters{2,i}{2,2}, optimal_parameters_of_filters{2,i}{2,3});
        elseif (size(optimal_parameters_of_filters{2,i}, 2) == 4 && ...
                ~strcmp(optimal_parameters_of_filters{2,i}{1,1}, 'WindowSideSize')) %%Three variable parameter without window size
            filt_image = feval(names_of_filters{i}, noise_img, ...
                optimal_parameters_of_filters{2,i}{2,1}, ...
                optimal_parameters_of_filters{2,i}{2,2}, optimal_parameters_of_filters{2,i}{2,3});    
        end

        ssim_vals(i + 1) = ssim(filt_image, ref_img);

        if (strcmp(imshowing_set, 'on'))
            filt_img_fig = figure('Name', 'Image after filtering');  
            imshow(padarray(filt_image,[1,1],0)); 
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            if (strcmp(title_condition, 'on')) 
                title(strcat("Image after ", names_of_filters{i}));
            end

            if (strcmp(imsaving_set, 'on'))
                filt_img_filename = strcat('Output\Filtering images and tabel\', num2str(i),...
                    '_img_with_', noise_type, '_noise_after_', names_of_filters{i}, '.png');
                print(filt_img_fig, filt_img_filename,'-dpng','-r500');
            end
        end   
    end

    %%Table of metric values
    table_metric = table(['No filter'; names_of_filters'], ssim_vals');
    table_metric.Properties.VariableNames = {'Filters' 'SSIM'}
    table_name = strcat('Output\Filtering images and tabel\',noise_type,'_noise_metric_table.csv');
    writetable(table_metric,table_name);
end
%% 1D slices
if (strcmp(oneD_slices_condition, 'on'))
    ref_img_for_slices = mat2gray(rgb2gray(imread('test_img_for_slices.png')));
    noise_img_for_slices = AddSpeckle(ref_img_for_slices, noise_type);
    ref_img_for_slices = ConvertRefrenceImage(ref_img_for_slices, noise_type);

    OneDimensionSlice(ref_img_for_slices, noise_img_for_slices, optimal_parameters_of_filters,...
        'SavingPlot', imsaving_set);    
end

