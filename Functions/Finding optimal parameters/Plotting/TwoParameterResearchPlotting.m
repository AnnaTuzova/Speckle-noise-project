function TwoParameterResearchPlotting(varargin)
%% Parsing input variable
    defaultNameOfFirstFilterParameter = "First variable parameter";
    defaultNameOfSecondFilterParameter = "Second variable parameter of ";
    defaultAxisFontSize = 12;
    
    p = inputParser;
    addRequired(p, 'ResearchResult', @(x) iscell(x))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addRequired(p, 'Metrics', @(x) isstring(x))
    addParameter(p,'NameOfFirstFilterParameter', defaultNameOfFirstFilterParameter, @(x) ischar(x))
    addParameter(p,'NameOfSecondFilterParameter', defaultNameOfSecondFilterParameter, @(x) ischar(x))
    addParameter(p,'AxisFontSize', defaultAxisFontSize, @(x) isnumeric(x))
    parse(p, varargin{:});
    
    research_result = p.Results.ResearchResult;
    filter_name = p.Results.NameOfFilter;
    axis_font_size = p.Results.AxisFontSize;
    
    if ~strcmp(p.Results.NameOfFirstFilterParameter, defaultNameOfFirstFilterParameter)
        name_of_1st_param = p.Results.NameOfFirstFilterParameter;
    end

    if strcmp(p.Results.NameOfSecondFilterParameter, defaultNameOfSecondFilterParameter)
        name_of_2nd_param = strcat(p.Results.NameOfFirstFilterParameter, filter_name);
    else
        name_of_2nd_param = p.Results.NameOfSecondFilterParameter;
    end
    
    metric_name = p.Results.Metrics;
    if (strcmp(metric_name,"ssim"))
        metric_name_for_plot = upper(metric_name);
    elseif (strcmp(metric_name,"DetermCoeffMetric"))
        metric_name_for_plot = "R^2";
    else
        metric_name_split = split(metric_name, 'Metric');
        metric_name_for_plot = upper(metric_name_split(1));
    end

    
 %% Plotting 
    color_line = hsv(2*(length(research_result{2,1}) + 1));
    markers_plot = ['o', '+', '*', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'];
    if (length(research_result{2,1}) > length(markers_plot))
        markers_plot = [markers_plot markers_plot(1:(length(research_result{2,1}) - length(markers_plot)))];
    end
    
    for k = 1:length(research_result{2,1})
        hold on;
        y_vals = research_result{2,3}(k,:);
        plot(research_result{2,2}, y_vals, '-', 'color', color_line(2*k,:),'LineWidth', 1, 'HandleVisibility','off')
        plot(research_result{2,2}(1:4:end), y_vals(1:4:end), ...
            markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
        legend_names{k} = strcat(name_of_1st_param, " = ", num2str(research_result{2,1}(k))); 
    end
    set(gca,'FontSize', axis_font_size);     
    grid on;
    axis([min(research_result{2,2}) max(research_result{2,2})...
        min(research_result{2,3}(:)) - (abs(max(research_result{2,3}(:)) - min(research_result{2,3}(:)))/10)...
        max(research_result{2,3}(:)) + (abs(max(research_result{2,3}(:)) - min(research_result{2,3}(:)))/10)]);
    stem(research_result{2,4}(2), research_result{2,4}(3), '*r','LineWidth', 2)
    xlabel(name_of_2nd_param); 
    ylabel(metric_name_for_plot);
    if (research_result{2,4}(3) < 0.01 ) 
        if (floor(research_result{2,4}(2)) == research_result{2,4}(2))
            legend_names{k+1} = strcat(metric_name_for_plot, "_{opt} = ", ...
                num2str(research_result{2,4}(3), '%0.3e'), ...
                " at ", num2str(research_result{2,4}(2), '%d')); 
        else
            legend_names{k+1} = strcat(metric_name_for_plot, "_{opt} = ", ...
                num2str(research_result{2,4}(3), '%0.3e'), ...
                " at ", num2str(research_result{2,4}(2), '%0.1f')); 
        end
    else
        if (floor(research_result{2,4}(2)) == research_result{2,4}(2))
            legend_names{k+1} = strcat(metric_name_for_plot, "_{opt} = ", ...
                num2str(research_result{2,4}(3), '%0.3f'), ...
                " at ", num2str(research_result{2,4}(2), '%d')); 
        else
            legend_names{k+1} = strcat(metric_name_for_plot, "_{opt} = ", ...
                num2str(research_result{2,4}(3), '%0.3f'), ...
                " at ", num2str(research_result{2,4}(2), '%0.1f')); 
        end
    end 
 
    legend(legend_names, 'Location', 'bestoutside')       
end