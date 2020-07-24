function TwoParameterResearchPlotting(varargin)
%% Parsing input variable
    defaultNameOfFirstFilterParameter = "First variable parameter";
    defaultNameOfSecondFilterParameter = "Second variable parameter of ";
    
    p = inputParser;
    addRequired(p, 'ResearchResult', @(x) iscell(x))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addRequired(p, 'WindowSize', @(x) isnumeric(x) && all(x(:) >= 0))
    addParameter(p,'NameOfFirstFilterParameter', defaultNameOfFirstFilterParameter, @(x) ischar(x))
    addParameter(p,'NameOfSecondFilterParameter', defaultNameOfSecondFilterParameter, @(x) ischar(x))
    parse(p, varargin{:});
    
    research_result = p.Results.ResearchResult;
    filter_name = p.Results.NameOfFilter;
    win_size = p.Results.WindowSize;
    
    if ~strcmp(p.Results.NameOfFirstFilterParameter, defaultNameOfFirstFilterParameter)
        name_of_1st_param = p.Results.NameOfFirstFilterParameter;
    end

    if strcmp(p.Results.NameOfSecondFilterParameter, defaultNameOfSecondFilterParameter)
        name_of_2nd_param = strcat(p.Results.NameOfFirstFilterParameter, filter_name);
    else
        name_of_2nd_param = p.Results.NameOfSecondFilterParameter;
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
    set(gca,'FontSize',12);     grid on;
    axis([min(research_result{2,2}) max(research_result{2,2})...
        round((min(research_result{2,3}(:))-0.02),2) round((max(research_result{2,3}(:))+0.02),2)]);
    stem(research_result{2,4}(2), research_result{2,4}(3), '*r','LineWidth', 2)
    xlabel(name_of_2nd_param); ylabel('SSIM');
    legend_names = [legend_names strcat("SSIM_{max} = ", num2str(research_result{2,4}(3), '%0.3f'),...
                " at ", num2str(research_result{2,4}(2)), ...
                ", ", num2str(win_size(1), '%d'), "\times" , num2str(win_size(2), '%d'))];
    legend(legend_names, 'Location', 'bestoutside')       
end