function OneParameterResearchPlotting(varargin)
    %% Parsing input variable
    defaultNameOfFirstFilterParameter = "Variable parameter of ";
    defaultMetricsPlottingType = 'MultipleAxes';
    defaultFigureCondition = 'on';
    defaultAxisFontSize = 12;
    expectedOnOff = {'on','off'};
    
    p = inputParser;
    addRequired(p, 'ResearchResult', @(x) iscell(x))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addRequired(p,'NoiseType', @(x) ischar(x))
    addRequired(p, 'Metrics', @(x) isstring(x))
    addParameter(p, 'MetricsPlottingType', defaultMetricsPlottingType);
    addParameter(p, 'FigureCondition', defaultFigureCondition, @(x) any(validatestring(x, expectedOnOff)));
    addParameter(p, 'SavingPlot', @(x) ischar(x))
    addParameter(p,'NameOfFirstFilterParameter', defaultNameOfFirstFilterParameter, @(x) ischar(x))
    addParameter(p,'AxisFontSize', defaultAxisFontSize, @(x) isnumeric(x))
    
    parse(p, varargin{:});
    research_result = p.Results.ResearchResult;
    filter_name = p.Results.NameOfFilter;
    noise_type = p.Results.NoiseType;
    axis_font_size = p.Results.AxisFontSize;
    
    if strcmp(p.Results.NameOfFirstFilterParameter, defaultNameOfFirstFilterParameter)
        name_of_param = strcat(p.Results.NameOfFirstFilterParameter, filter_name);
    else
        name_of_param = p.Results.NameOfFirstFilterParameter;
    end
    
    metric_names = p.Results.Metrics;
    metric_names_len = length(metric_names);
    for k = 1:metric_names_len
        if (strcmp(metric_names(k),"ssim"))
            metric_name_for_plot(k) = upper(metric_names(k));
        elseif (strcmp(metric_names(k),"DetermCoeffMetric"))
            metric_name_for_plot(k) = "R^2";
        else
            metric_name_split = split(metric_names(k), 'Metric');
            metric_name_for_plot(k) = upper(metric_name_split(1));
        end
    end
    
    %% Plotting
    step_plot = floor(length(research_result{2,1})/50);
    if (step_plot == 0)
        step_plot = 1;
    end
    color_line_curve = hsv(2*(metric_names_len - 1) + 1);
    color_line_point = jet(2*(metric_names_len - 1) + 1);
    markers_plot = ['o', '+', '*', 'x', 'd', '^', 'v', '>', '<', 'p', 'h'];
    if (metric_names_len > length(markers_plot))
        markers_plot = [markers_plot markers_plot(1:(metric_names_len - length(markers_plot)))];
    end
    switch p.Results.MetricsPlottingType
        case 'MultipleAxes'
            if (strcmp(p.Results.FigureCondition, 'on'))
                fig = figure('Name', strcat(filter_name, " research"));
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            end
            plot(research_result{2,1}, research_result{2,2}, '.-k', 'LineWidth', 2, ...
                'MarkerIndices',1:step_plot:length(research_result{2,2}), 'MarkerSize', 17)
            addaxisplot(research_result{2,1+metric_names_len+1}(1),...
               research_result{2,1+metric_names_len+1}(2), 1, 'sr', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
            addaxislabel(1, metric_name_for_plot(1));
            legend_names{1} = metric_name_for_plot(1);
            if (research_result{2,1+metric_names_len+1}(2) < 0.01 ) 
                if (floor(research_result{2,1+metric_names_len+1}(1)) == research_result{2,1+metric_names_len+1}(1))
                    legend_names{2} = strcat(metric_name_for_plot(1), "_{opt} = ", ...
                        num2str(research_result{2,1+metric_names_len+1}(2), '%0.3e'), ...
                            " at ", num2str(research_result{2,1+metric_names_len+1}(1), '%d')); 
                else
                    legend_names{2} = strcat(metric_name_for_plot(1), "_{opt} = ", ...
                        num2str(research_result{2,1+metric_names_len+1}(2), '%0.3e'), ...
                            " at ", num2str(research_result{2,1+metric_names_len+1}(1), '%0.1f')); 
                end
            else
                if (floor(research_result{2,1+metric_names_len+1}(1)) == research_result{2,1+metric_names_len+1}(1))
                    legend_names{2} = strcat(metric_name_for_plot(1), "_{opt} = ", ...
                        num2str(research_result{2,1+metric_names_len+1}(2), '%0.3f'), ...
                            " at ", num2str(research_result{2,1+metric_names_len+1}(1), '%d')); 
                else
                    legend_names{2} = strcat(metric_name_for_plot(1), "_{opt} = ", ...
                        num2str(research_result{2,1+metric_names_len+1}(2), '%0.3f'), ...
                            " at ", num2str(research_result{2,1+metric_names_len+1}(1), '%0.1f')); 
                end
            end
            
            if (metric_names_len > 1)
                for k = 1:metric_names_len - 1
                    addaxis(research_result{2,1}, research_result{2,k + 2}, strcat(markers_plot(k),'-'),...
                        'MarkerIndices',1:step_plot:length(research_result{2,k + 2}),...
                        'color', color_line_curve(2*k,:),'LineWidth', 2, 'MarkerSize', 8);
                    addaxisplot(research_result{2,k+2+metric_names_len}(1),...
                        research_result{2,k+2+metric_names_len}(2), k + 1, 's', ...
                            'MarkerFaceColor', color_line_point(2*k,:), ...
                            'MarkerEdgeColor', color_line_point(2*k,:), 'MarkerSize', 15);
                    addaxislabel(k + 1, metric_name_for_plot(k+1));
                    legend_names{k*2 + 1} = metric_name_for_plot(k+1);
                    if (research_result{2,k+2+metric_names_len}(2) < 0.01 ) 
                        if (floor(research_result{2,k+2+metric_names_len}(1)) == research_result{2,k+2+metric_names_len}(1))
                            legend_names{k*2 + 2} = strcat(metric_name_for_plot(k+1), "_{opt} = ", ...
                            num2str(research_result{2,k+2+metric_names_len}(2), '%0.3e'), ...
                            " at ", num2str(research_result{2,k+2+metric_names_len}(1), '%d'));
                        else
                            legend_names{k*2 + 2} = strcat(metric_name_for_plot(k+1), "_{opt} = ", ...
                                num2str(research_result{2,k+2+metric_names_len}(2), '%0.3e'), ...
                                " at ", num2str(research_result{2,k+2+metric_names_len}(1), '%0.1f'));  
                        end
                    else
                        if (floor(research_result{2,k+2+metric_names_len}(1)) == research_result{2,k+2+metric_names_len}(1))
                            legend_names{k*2 + 2} = strcat(metric_name_for_plot(k+1), "_{opt} = ", ...
                            num2str(research_result{2,k+2+metric_names_len}(2), '%0.3f'), ...
                            " at ", num2str(research_result{2,k+2+metric_names_len}(1), '%d'));
                        else
                            legend_names{k*2 + 2} = strcat(metric_name_for_plot(k+1), "_{opt} = ", ...
                                num2str(research_result{2,k+2+metric_names_len}(2), '%0.3f'), ...
                                " at ", num2str(research_result{2,k+2+metric_names_len}(1), '%0.1f'));  
                        end
                    end  
                end  
            elseif (metric_names_len == 1)
                axis([min(research_result{2,1}) max(research_result{2,1})...
                    min(research_result{2,2}) - (abs(max(research_result{2,2}) - min(research_result{2,2}))/10) ...
                    max(research_result{2,2}) + (abs(max(research_result{2,2}) - min(research_result{2,2}))/10)]);
            end
            grid on;
            legend(legend_names, 'Location', 'best');
            AX = findall(0,'type','axes');
            for i = 1:size(AX, 1)
                set(AX(i),'FontSize', axis_font_size)
            end
            
            if (strcmp(research_result{1,1}, 'WindowSideSizeVals'))
                xlabel('Window side size');  
            else
                xlabel(name_of_param); 
            end
            
            if (strcmp(p.Results.SavingPlot, 'on') && strcmp(p.Results.FigureCondition, 'on')) 
                plot_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '.png');
                print(fig, plot_filename,'-dpng','-r500');
            end
        case 'MultipleFigures'
            for k = 1:metric_names_len
                fig = figure('Name', strcat(filter_name, " research. Metric: ", metric_name_for_plot(k))); 
                hold on
                plot(research_result{2,1}, research_result{2,k + 1}, '.-k', 'LineWidth', 2,...
                    'MarkerIndices',1:step_plot:length(research_result{2,k + 1}), 'MarkerSize', 17);
                stem(research_result{2,k+1+metric_names_len}(1),...
                    research_result{2,k+1+metric_names_len}(2), '*r','LineWidth', 2)
                grid on; 
                axis([min(research_result{2,1}) max(research_result{2,1})...
                    min(research_result{2,k + 1}) - (abs(max(research_result{2,k + 1}) - min(research_result{2,k + 1}))/10) ...
                    max(research_result{2,k + 1}) + (abs(max(research_result{2,k + 1}) - min(research_result{2,k + 1}))/10)]);
                set(gca,'FontSize',12)
                ylabel(metric_name_for_plot(k));
                if (strcmp(research_result{1,1}, 'WindowSideSizeVals'))
                    xlabel('Window side size'); 
                else
                    xlabel(name_of_param); 
                end
                
                legend_names{1} = metric_name_for_plot(k);
                if (research_result{2,k+1+metric_names_len}(2) < 0.01 ) 
                    if (floor(research_result{2,k+1+metric_names_len}(1)) == research_result{2,k+1+metric_names_len}(1))
                        legend_names{2} = strcat(metric_name_for_plot(k), "_{opt} = ", ...
                            num2str(research_result{2,k+1+metric_names_len}(2), '%0.3e'), ...
                            " at ", num2str(research_result{2,k+1+metric_names_len}(1), '%d')); 
                    else
                        legend_names{2} = strcat(metric_name_for_plot(k), "_{opt} = ", ...
                            num2str(research_result{2,k+1+metric_names_len}(2), '%0.3e'), ...
                            " at ", num2str(research_result{2,k+1+metric_names_len}(1), '%0.1f')); 
                    end
                else
                    if (floor(research_result{2,k+1+metric_names_len}(1)) == research_result{2,k+1+metric_names_len}(1))
                        legend_names{2} = strcat(metric_name_for_plot(k), "_{opt} = ", ...
                            num2str(research_result{2,k+1+metric_names_len}(2), '%0.3f'), ...
                            " at ", num2str(research_result{2,k+1+metric_names_len}(1), '%d')); 
                    else
                        legend_names{2} = strcat(metric_name_for_plot(k), "_{opt} = ", ...
                            num2str(research_result{2,k+1+metric_names_len}(2), '%0.3f'), ...
                            " at ", num2str(research_result{2,k+1+metric_names_len}(1), '%0.1f')); 
                    end
                end 
                
                legend(legend_names, 'Location', 'best')
                if (strcmp(p.Results.SavingPlot, 'on')) 
                    plot_filename = strcat('Output\Graphics\', filter_name, '_', noise_type,'_metric_', metric_name_for_plot(k), '.png');
                    print(fig, plot_filename,'-dpng','-r500');
                end
            end
        case 'OnePlotNormalization'
            if (strcmp(p.Results.FigureCondition, 'on'))
                fig = figure('Name', strcat(filter_name, " research. Normalization"));
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            end
            ylabel_name = [];
           
            if (metric_names_len > 1)
                for k = 1:metric_names_len
                    new_metric_vals = (research_result{2,k + 1} - min(research_result{2,k + 1}))./...
                        (max(research_result{2,k + 1}) - min(research_result{2,k + 1}));
                    new_opt_val = (research_result{2,k+1+metric_names_len}(2) - min(research_result{2,k + 1}))./...
                        (max(research_result{2,k + 1}) - min(research_result{2,k + 1}));

                    hold on
                    plot(research_result{2,1}, new_metric_vals, strcat(markers_plot(k),'-'),...
                       'MarkerIndices',1:step_plot:length(new_metric_vals),...
                       'color', color_line_curve(2*k,:),'LineWidth', 2, 'MarkerSize', 8);
                    plot(research_result{2,k+1+metric_names_len}(1), new_opt_val, 's', ...
                            'MarkerFaceColor', color_line_point(2*k,:), ...
                            'MarkerEdgeColor', color_line_point(2*k,:), 'MarkerSize', 15);

                    if (k ~= metric_names_len)
                        ylabel_name = strcat(ylabel_name, metric_name_for_plot(k), ", ");
                    else
                        ylabel_name = strcat(ylabel_name, metric_name_for_plot(k));
                    end
                    legend_names{k*2 - 1} = metric_name_for_plot(k);
                    if (floor(research_result{2,k+1+metric_names_len}(1)) == research_result{2,k+1+metric_names_len}(1))
                            legend_names{k*2} = strcat(metric_name_for_plot(k), "_{opt} = ", ...
                                num2str(new_opt_val, '%0.3f'), " at ",...
                                num2str(research_result{2,k+1+metric_names_len}(1), '%d'));  
                        else
                            legend_names{k*2} = strcat(metric_name_for_plot(k), "_{opt} = ", ...
                                num2str(new_opt_val, '%0.3f'), " at ",...
                                num2str(research_result{2,k+1+metric_names_len}(1), '%0.1f'));
                    end          
                end
            end
            grid on; 
            axis([min(research_result{2,1}) max(research_result{2,1})...
                min(new_metric_vals) - (abs(max(new_metric_vals) - min(new_metric_vals))/10) ...
                max(new_metric_vals) + (abs(max(new_metric_vals) - min(new_metric_vals))/10)]);
            set(gca,'FontSize', axis_font_size)
            ylabel(ylabel_name);
            if (strcmp(research_result{1,1}, 'WindowSideSizeVals'))
                xlabel('Window side size'); 
            else
                xlabel(name_of_param); 
            end
            legend(legend_names, 'Location', 'best');
            
            if (strcmp(p.Results.SavingPlot, 'on') && strcmp(p.Results.FigureCondition, 'on')) 
                plot_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '.png');
                print(fig, plot_filename,'-dpng','-r500');
            end
    end
end