function OneDimensionSlice(varargin)
% OneDimensionSlice builds one-dimensional slices.
%
% Mandatory input arguments:
% ReferanceImage - reference image for displaying with a slice line.
% 
% NoiseImage - image with noise.
%
% OptimalParametersOfFilters - cell with with optimal parameters found.
%
% You can use name-value arguments for additional settings of the function.
% 
% ('SliceLevel', value) - sets the level at which the slice in the image
% will pass. It must be a number between 0 and 1.
% The default value is 0.5 (half image). 
% 
% ('PlotSpacingCoefficient', value) - sets the spacing of one-dimensional
% slices so that they do not overlap each other on the graph. 
% The default value is 1.
% 
% ('SavingPlot', value) - enable or disable saving graph. 
% Possible values are: 'on', 'off'. The default value is: 'off'.

  %% Input parsing
    defaultSliceLevel = 0.5;
    defaultPlotSpacingCoefficient = 0.1;
    defaultSavinfPlot = 'off';
    expectedOnOff = {'on','off'};
    
    p = inputParser;
    addRequired(p, 'ReferanceImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'NoiseImage', @(x) isnumeric(x) && all(x(:) >= 0) && all(x(:) <= 1))
    addRequired(p, 'OptimalParametersOfFilters', @(x) iscell(x))
    addParameter(p, 'SliceLevel', defaultSliceLevel, @(x) isnumeric(x) && (x >= 0) && (x <= 1))
    addParameter(p, 'PlotSpacingCoefficient', defaultPlotSpacingCoefficient, @(x) isnumeric(x) && (x >= 0))
    addParameter(p, 'SavingPlot', defaultSavinfPlot, @(x) any(validatestring(x, expectedOnOff)))
    
    parse(p, varargin{:});    
    
    
    ref_img = p.Results.ReferanceImage;
    noise_img = p.Results.NoiseImage;
    optimal_parameters_of_filters = p.Results.OptimalParametersOfFilters;
    slice_level = p.Results.SliceLevel;
    plot_spacing_coeff = p.Results.PlotSpacingCoefficient;
    
%% Plotting 1D slices
    indices = 1:1:size(ref_img,2);
    slice_row = round(size(ref_img,1)*slice_level);
    names_of_filters = optimal_parameters_of_filters(1,1:end);
    
    d1_slice_ref_img = figure('Name', 'Refernce image for 1D slices');
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    imshow(padarray(ref_img, [1,1],0))
    hold on
    plot(indices,slice_row.*ones(length(indices)),'-r','LineWidth',2.5)
    title('Image without noise with 1D slice designation')
    set(gca,'FontSize',12); 
    
    d1_slice_filters = figure('Name', '1D slices');
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    plot(indices, ref_img(slice_row,:),'-k','LineWidth', 2)
    hold on;
    plot(indices,noise_img(slice_row,:),'-.r','LineWidth', 0.5)   
    color_line = hsv(2*(length(names_of_filters) + 1));
    markers_plot = ['o', '+', '*', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'];
    if (length(names_of_filters) > length(markers_plot))
        markers_plot = [markers_plot markers_plot(1:(length(names_of_filters) - length(markers_plot)))];
    end
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
        
        y_vals = filt_image(slice_row,:) + plot_spacing_coeff*i;
        plot(indices, y_vals, '-', 'color', color_line(2*i,:),'LineWidth', 1.1, 'HandleVisibility','off')
        plot(indices(1:10:end), y_vals(1:10:end),markers_plot(i), 'color', color_line(2*i,:), 'MarkerSize', 6)
        legend_names{i} = names_of_filters{i}; 
    end
    
    legend_names = ['Image without noise' 'Image with noise' legend_names];
    legend(legend_names, 'Location', 'bestoutside');  
    axis([0 length(indices) -0.1 (1 + plot_spacing_coeff*(length(names_of_filters) + 2))]);
    grid on; set(gca,'FontSize',12); 
    xlabel('Pixel indices along a 1D slice'); 
    ylabel('Pixel intensity values along the 1D slice');  
    
    
    if (strcmp(p.Results.SavingPlot, 'on'))
        d1_slice_ref_img_filename = 'Output\Graphics\reference_image_for_slices.png';
        d1_slice_filters_filename = 'Output\Graphics\1D_slices.svg'; 
        print(d1_slice_ref_img, d1_slice_ref_img_filename, '-dpng', '-r500'); 
        print(d1_slice_filters, d1_slice_filters_filename, '-dsvg');
    end
end