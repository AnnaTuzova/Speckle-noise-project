function ThreeParameterResearchPlotting(varargin)
%% Parsing input variable
    defaultNameOfFirstFilterParameter = "First variable parameter";
    defaultNameOfSecondFilterParameter = "Second variable parameter";
    defaultNameOfThirdFilterParameter = "Third variable parameter";
    defaultMetricsPlottingType = 'MultipleFigures';
    defaultFigureType = 'SeparateFigures';
    
    p = inputParser;
    addRequired(p, 'ResearchResult', @(x) iscell(x))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addRequired(p, 'NoiseType', @(x) ischar(x))
    addRequired(p, 'Metrics', @(x) isstring(x))
    addParameter(p,'NameOfFirstFilterParameter', defaultNameOfFirstFilterParameter, @(x) ischar(x))
    addParameter(p,'NameOfSecondFilterParameter', defaultNameOfSecondFilterParameter, @(x) ischar(x))
    addParameter(p,'NameOfThirdFilterParameter', defaultNameOfThirdFilterParameter, @(x) ischar(x))
    addParameter(p, 'SavingPlot', @(x) ischar(x))
    addParameter(p, 'FigureType', defaultFigureType, @(x) ischar(x))
    addParameter(p, 'MetricsPlottingType', defaultMetricsPlottingType, @(x) ischar(x))
    parse(p, varargin{:});
    
    research_result = p.Results.ResearchResult;
    filter_name = p.Results.NameOfFilter;
    noise_type = p.Results.NameOfFilter;
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
    if ~strcmp(p.Results.NameOfFirstFilterParameter, defaultNameOfFirstFilterParameter)
        name_of_1st_param = p.Results.NameOfFirstFilterParameter;
    end
    
    if ~strcmp(p.Results.NameOfSecondFilterParameter, defaultNameOfSecondFilterParameter)
        name_of_2nd_param = p.Results.NameOfSecondFilterParameter;
    end
    
    if ~strcmp(p.Results.NameOfThirdFilterParameter, defaultNameOfThirdFilterParameter)
        name_of_3rd_param = p.Results.NameOfThirdFilterParameter;
    end

 %% Plotting 
	if((strcmp(p.Results.FigureType, 'SubplotFigures') && ...
        ~strcmp(p.Results.MetricsPlottingType, 'MultipleFigures')) ||...
        (strcmp(p.Results.FigureType, 'SeparateFigures') && ...
        ~strcmp(p.Results.MetricsPlottingType, 'MultipleFigures') &&...
        ~strcmp(p.Results.MetricsPlottingType, 'MultipleAxes')))
            error("It is not possible to plot curves with multiple metrics when researching a filter with two variable parameters. Please choose either ('FigureType', 'SubplotFigures') and ('MetricsPlottingType', 'MultipleFigures') or ('FigureType', 'SubplotFigures') and ('SeparateFigures', 'MultipleFigures').");           
	elseif((strcmp(p.Results.FigureType, 'SubplotFigures') && ...
                    strcmp(p.Results.MetricsPlottingType, 'MultipleFigures')))      
        axis_font_size = 10;
        for i = 1:metric_names_len
            fig = figure('Name', strcat(filter_name, " research. ", metric_names(i)));
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

            pos1 = [0.15 0.55 0.3 0.3];
            subplot('Position', pos1)
            stage1_with_one_metric = [research_result{2,1}(:,1) ...
                    research_result{2,1}(:,2) research_result{2,1}(:,3)...
                    research_result{2,1}(:,i+3) research_result{2,1}(:,i+3+metric_names_len)];  

            color_line = hsv(2*(length(stage1_with_one_metric{2,2}) + 1));
            markers_plot = ['o', '+', '*', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'];
            if (length(stage1_with_one_metric{2,2}) > length(markers_plot))
                markers_plot = [markers_plot markers_plot(1:(length(stage1_with_one_metric{2,2}) - length(markers_plot)))];
            end

            for k = 1:length(stage1_with_one_metric{2,2})
                hold on;
                y_vals = stage1_with_one_metric{2,4}(k,:);
                plot(stage1_with_one_metric{2,3}, y_vals, '-', 'color', color_line(2*k,:),...
                    'LineWidth', 1, 'HandleVisibility','off')
                plot(stage1_with_one_metric{2,3}(1:4:end), y_vals(1:4:end), ...
                    markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
                legend_names_first_plot{k} = strcat(name_of_2nd_param, " = ", num2str(stage1_with_one_metric{2,2}(k)));
            end
            set(gca,'FontSize', axis_font_size);	
            grid on;
            axis([min(stage1_with_one_metric{2,3}) max(stage1_with_one_metric{2,3})...
                min(stage1_with_one_metric{2,4}(:)) - (abs(max(stage1_with_one_metric{2,4}(:)) - min(stage1_with_one_metric{2,4}(:)))/10)...
                max(stage1_with_one_metric{2,4}(:)) + (abs(max(stage1_with_one_metric{2,4}(:)) - min(stage1_with_one_metric{2,4}(:)))/10)]);
            stem(stage1_with_one_metric{2,5}(3), stage1_with_one_metric{2,5}(4), '*r', 'LineWidth', 2)

            if strcmp(p.Results.NameOfThirdFilterParameter, defaultNameOfThirdFilterParameter)
                xlabel(strcat(name_of_3rd_param," of ", filter_name)); 
            else
                xlabel(name_of_3rd_param);
            end

            ylabel(metric_name_for_plot(i));
            title(strcat("With ", name_of_1st_param, " = ", num2str(stage1_with_one_metric{2,5}(1))))

            if (stage1_with_one_metric{2,5}(4) < 0.01 ) 
                if (floor(stage1_with_one_metric{2,5}(3)) == stage1_with_one_metric{2,5}(3))
                    legend_names_first_plot = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_first_plot  = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            else
                if (floor(stage1_with_one_metric{2,5}(3)) == stage1_with_one_metric{2,5}(3))
                    legend_names_first_plot = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_first_plot = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            end 
            legend(legend_names_first_plot, 'Location', 'bestoutside') 

            pos2 = [0.55 0.55 0.3 0.3];
            subplot('Position',pos2)
            stage2_with_one_metric = [research_result{2,2}(:,1) ...
                    research_result{2,2}(:,2) research_result{2,2}(:,3)...
                    research_result{2,2}(:,i+3) research_result{2,2}(:,i+3+metric_names_len)]; 

            stem(stage2_with_one_metric{2,5}(1), stage2_with_one_metric{2,5}(4), '*r','LineWidth', 2)
            hold on
            plot(stage2_with_one_metric{2,1}, stage2_with_one_metric{2,4}, '.-k', 'LineWidth', 2, 'MarkerSize', 17)
            grid on;    
            axis([min(stage2_with_one_metric{2,1}) max(stage2_with_one_metric{2,1})...
                min(stage2_with_one_metric{2,4}) - (abs(max(stage2_with_one_metric{2,4}) - min(stage2_with_one_metric{2,4}))/10)...
                max(stage2_with_one_metric{2,4}) + (abs(max(stage2_with_one_metric{2,4}) - min(stage2_with_one_metric{2,4}))/10)]);
            set(gca,'FontSize', axis_font_size)
            if strcmp(p.Results.NameOfFirstFilterParameter, defaultNameOfFirstFilterParameter)
                xlabel(strcat(name_of_1st_param," of ", filter_name)); 
            else
                xlabel(name_of_1st_param);
            end  
            ylabel(metric_name_for_plot(i));
            if (stage2_with_one_metric{2,5}(4) < 0.01 ) 
                if (floor(stage2_with_one_metric{2,5}(3)) == stage2_with_one_metric{2,5}(3))
                    legend(strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage2_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage2_with_one_metric{2,5}(1), '%d'))); 
                else
                    legend(strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage2_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage2_with_one_metric{2,5}(1), '%0.2f'))); 
                end
            else
                if (floor(stage2_with_one_metric{2,5}(3)) == stage2_with_one_metric{2,5}(3))
                    legend(strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage2_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage2_with_one_metric{2,5}(1), '%d'))); 
                else
                    legend(strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage2_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage2_with_one_metric{2,5}(1), '%0.2f'))); 
                end
            end 
            title(strcat("With ", name_of_2nd_param, " =  " , num2str(stage1_with_one_metric{2,5}(2)) ,...
                " and ", name_of_3rd_param, " = " , num2str(stage1_with_one_metric{2,5}(3))))

            
            pos3 = [0.35 0.1 0.3 0.3];
            subplot('Position', pos3)
            stage3_with_one_metric = [research_result{2,3}(:,1) ...
                    research_result{2,3}(:,2) research_result{2,3}(:,3)...
                    research_result{2,3}(:,i+3) research_result{2,3}(:,i+3+metric_names_len)]; 
                
            for k = 1:length(stage3_with_one_metric{2,2})
                hold on;
                y_vals = stage3_with_one_metric{2,4}(k,:);
                plot(stage3_with_one_metric{2,3}, y_vals, '-', 'color', color_line(2*k,:),...
                    'LineWidth', 1, 'HandleVisibility','off')
                plot(stage3_with_one_metric{2,3}(1:4:end), y_vals(1:4:end), ...
                    markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
                legend_names_second_plot{k} = strcat(name_of_2nd_param, " = ", num2str(stage3_with_one_metric{2,2}(k)));
            end
            set(gca,'FontSize', axis_font_size);	
            grid on;
            axis([min(stage3_with_one_metric{2,3}) max(stage3_with_one_metric{2,3})...
                min(stage3_with_one_metric{2,4}(:)) - (abs(max(stage3_with_one_metric{2,4}(:)) - min(stage3_with_one_metric{2,4}(:)))/10)...
                max(stage3_with_one_metric{2,4}(:)) + (abs(max(stage3_with_one_metric{2,4}(:)) - min(stage3_with_one_metric{2,4}(:)))/10)]);
            stem(stage3_with_one_metric{2,5}(3), stage3_with_one_metric{2,5}(4), '*r', 'LineWidth', 2)

            if strcmp(p.Results.NameOfThirdFilterParameter, defaultNameOfThirdFilterParameter)
                xlabel(strcat(name_of_3rd_param," of ", filter_name)); 
            else
                xlabel(name_of_3rd_param);
            end

            ylabel(metric_name_for_plot(i));
            title(strcat("With ", name_of_1st_param, " = ", num2str(stage3_with_one_metric{2,5}(1))))

            if (stage3_with_one_metric{2,5}(4) < 0.01 ) 
                if (floor(stage3_with_one_metric{2,5}(3)) == stage3_with_one_metric{2,5}(3))
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            else
                if (floor(stage3_with_one_metric{2,5}(3)) == stage3_with_one_metric{2,5}(3))
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            end 
            legend(legend_names_second_plot, 'Location', 'bestoutside') 

            if (strcmp(p.Results.SavingPlot, 'on')) 
                plot_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, ...
                            '_' ,metric_names(i),'.png');
                print(fig, plot_filename,'-dpng','-r500');
            end
        end      
    elseif((strcmp(p.Results.FigureType, 'SeparateFigures') && ...
                    strcmp(p.Results.MetricsPlottingType, 'MultipleFigures')))   
        axis_font_size = 12;
        for i = 1:metric_names_len   
            fig_stage1 = figure('Name', strcat(filter_name, " research. Stage 1. ", metric_names(i)));

            stage1_with_one_metric = [research_result{2,1}(:,1) ...
                    research_result{2,1}(:,2) research_result{2,1}(:,3)...
                    research_result{2,1}(:,i+3) research_result{2,1}(:,i+3+metric_names_len)];  

            color_line = hsv(2*(length(stage1_with_one_metric{2,2}) + 1));
            markers_plot = ['o', '+', '*', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'];
            if (length(stage1_with_one_metric{2,2}) > length(markers_plot))
                markers_plot = [markers_plot markers_plot(1:(length(stage1_with_one_metric{2,2}) - length(markers_plot)))];
            end
            legend_names_first_plot = cell(1,size(stage1_with_one_metric{2,2},2));
            for k = 1:length(stage1_with_one_metric{2,2})
                hold on;
                y_vals = stage1_with_one_metric{2,4}(k,:);
                plot(stage1_with_one_metric{2,3}, y_vals, '-', 'color', color_line(2*k,:),...
                    'LineWidth', 1, 'HandleVisibility','off')
                plot(stage1_with_one_metric{2,3}(1:4:end), y_vals(1:4:end), ...
                    markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
                legend_names_first_plot{k} = strcat(name_of_2nd_param, " = ", num2str(stage1_with_one_metric{2,2}(k)));
            end
            set(gca,'FontSize', axis_font_size);	
            grid on;
            axis([min(stage1_with_one_metric{2,3}) max(stage1_with_one_metric{2,3})...
                min(stage1_with_one_metric{2,4}(:)) - (abs(max(stage1_with_one_metric{2,4}(:)) - min(stage1_with_one_metric{2,4}(:)))/10)...
                max(stage1_with_one_metric{2,4}(:)) + (abs(max(stage1_with_one_metric{2,4}(:)) - min(stage1_with_one_metric{2,4}(:)))/10)]);
            stem(stage1_with_one_metric{2,5}(3), stage1_with_one_metric{2,5}(4), '*r', 'LineWidth', 2)

            if strcmp(p.Results.NameOfThirdFilterParameter, defaultNameOfThirdFilterParameter)
                xlabel(strcat(name_of_3rd_param," of ", filter_name)); 
            else
                xlabel(name_of_3rd_param);
            end

            ylabel(metric_name_for_plot(i));
            title(strcat("With ", name_of_1st_param, " = ", num2str(stage1_with_one_metric{2,5}(1))))

            if (stage1_with_one_metric{2,5}(4) < 0.01 ) 
                if (floor(stage1_with_one_metric{2,5}(3)) == stage1_with_one_metric{2,5}(3))
                    legend_names_first_plot = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_first_plot = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            else
                if (floor(stage1_with_one_metric{2,5}(3)) == stage1_with_one_metric{2,5}(3))
                    legend_names_first_plot = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_first_plot = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            end 
            legend(legend_names_first_plot, 'Location', 'bestoutside') 

            fig_stage2 = figure('Name', strcat(filter_name, " research. Stage 2. ", metric_names(i)));
            stage2_with_one_metric = [research_result{2,2}(:,1) ...
                    research_result{2,2}(:,2) research_result{2,2}(:,3)...
                    research_result{2,2}(:,i+3) research_result{2,2}(:,i+3+metric_names_len)]; 

            hold on
            plot(stage2_with_one_metric{2,1}, stage2_with_one_metric{2,4}, '.-k', 'LineWidth', 2, 'MarkerSize', 17,...
                 'HandleVisibility','off')
            plot(stage2_with_one_metric{2,5}(1),...
               stage2_with_one_metric{2,5}(4), 'sr', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
            grid on;    
            axis([min(stage2_with_one_metric{2,1}) max(stage2_with_one_metric{2,1})...
                min(stage2_with_one_metric{2,4}) - round(abs(max(stage2_with_one_metric{2,4}) - min(stage2_with_one_metric{2,4}))/10,2)...
                max(stage2_with_one_metric{2,4}) + round(abs(max(stage2_with_one_metric{2,4}) - min(stage2_with_one_metric{2,4}))/10,2)]);
            set(gca,'FontSize', axis_font_size)
            if strcmp(p.Results.NameOfFirstFilterParameter, defaultNameOfFirstFilterParameter)
                xlabel(strcat(name_of_1st_param," of ", filter_name)); 
            else
                xlabel(name_of_1st_param);
            end  
            ylabel(metric_name_for_plot(i));
            if (stage2_with_one_metric{2,5}(4) < 0.01 ) 
                if (floor(stage2_with_one_metric{2,5}(3)) == stage2_with_one_metric{2,5}(3))
                    legend(strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage2_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage2_with_one_metric{2,5}(1), '%d'))); 
                else
                    legend(strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage2_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage2_with_one_metric{2,5}(1), '%0.2f'))); 
                end
            else
                if (floor(stage2_with_one_metric{2,5}(3)) == stage2_with_one_metric{2,5}(3))
                    legend(strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage2_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage2_with_one_metric{2,5}(1), '%d'))); 
                else
                    legend(strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage2_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage2_with_one_metric{2,5}(1), '%0.2f'))); 
                end
            end 
            title(strcat("With ", name_of_2nd_param, " =  " , num2str(stage1_with_one_metric{2,5}(2)) ,...
                " and ", name_of_3rd_param, " = " , num2str(stage1_with_one_metric{2,5}(3))))
            
            
            fig_stage3 = figure('Name', strcat(filter_name, " research. Stage 3. ", metric_names(i)));
            stage3_with_one_metric = [research_result{2,3}(:,1) ...
                    research_result{2,3}(:,2) research_result{2,3}(:,3)...
                    research_result{2,3}(:,i+3) research_result{2,3}(:,i+3+metric_names_len)]; 
            legend_names_second_plot = cell(1,size(stage3_with_one_metric{2,2},2));   
            for k = 1:length(stage3_with_one_metric{2,2})
                hold on;
                y_vals = stage3_with_one_metric{2,4}(k,:);
                plot(stage3_with_one_metric{2,3}, y_vals, '-', 'color', color_line(2*k,:),...
                    'LineWidth', 1, 'HandleVisibility','off')
                plot(stage3_with_one_metric{2,3}(1:4:end), y_vals(1:4:end), ...
                    markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
                legend_names_second_plot{k} = strcat(name_of_2nd_param, " = ", num2str(stage3_with_one_metric{2,2}(k)));
            end
            set(gca,'FontSize', axis_font_size);	
            grid on;
            axis([min(stage3_with_one_metric{2,3}) max(stage3_with_one_metric{2,3})...
                min(stage3_with_one_metric{2,4}(:)) - (abs(max(stage3_with_one_metric{2,4}(:)) - min(stage3_with_one_metric{2,4}(:)))/10)...
                max(stage3_with_one_metric{2,4}(:)) + (abs(max(stage3_with_one_metric{2,4}(:)) - min(stage3_with_one_metric{2,4}(:)))/10)]);
            stem(stage3_with_one_metric{2,5}(3), stage3_with_one_metric{2,5}(4), '*r', 'LineWidth', 2)

            if strcmp(p.Results.NameOfThirdFilterParameter, defaultNameOfThirdFilterParameter)
                xlabel(strcat(name_of_3rd_param," of ", filter_name)); 
            else
                xlabel(name_of_3rd_param);
            end

            ylabel(metric_name_for_plot(i));
            title(strcat("With ", name_of_1st_param, " = ", num2str(stage3_with_one_metric{2,5}(1))))

            if (stage3_with_one_metric{2,5}(4) < 0.01 ) 
                if (floor(stage3_with_one_metric{2,5}(3)) == stage3_with_one_metric{2,5}(3))
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            else
                if (floor(stage3_with_one_metric{2,5}(3)) == stage3_with_one_metric{2,5}(3))
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            end 
            legend(legend_names_second_plot, 'Location', 'bestoutside') 

            if (strcmp(p.Results.SavingPlot, 'on')) 
                stage1_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_' ,metric_names(i), '_stage1.png');
                stage2_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_' ,metric_names(i), '_stage2.png');
                stage3_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_' ,metric_names(i), '_stage3.png');
                print(fig_stage1, stage1_filename,'-dpng','-r500');
                print(fig_stage2, stage2_filename,'-dpng','-r500');
                print(fig_stage3, stage3_filename,'-dpng','-r500');
            end    
        end
    elseif((strcmp(p.Results.FigureType, 'SeparateFigures') && ...
                strcmp(p.Results.MetricsPlottingType, 'MultipleAxes'))) 
        axis_font_size = 12;
        for i = 1:metric_names_len   
            fig_stage1 = figure('Name', strcat(filter_name, " research. Stage 1. ", metric_names(i)));

            stage1_with_one_metric = [research_result{2,1}(:,1) ...
                    research_result{2,1}(:,2) research_result{2,1}(:,3)...
                    research_result{2,1}(:,i+3) research_result{2,1}(:,i+3+metric_names_len)];  

            color_line = hsv(2*(length(stage1_with_one_metric{2,2}) + 1));
            markers_plot = ['o', '+', '*', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'];
            if (length(stage1_with_one_metric{2,2}) > length(markers_plot))
                markers_plot = [markers_plot markers_plot(1:(length(stage1_with_one_metric{2,2}) - length(markers_plot)))];
            end
            legend_names_first_plot = cell(1,size(stage1_with_one_metric{2,2},2));
            for k = 1:length(stage1_with_one_metric{2,2})
                hold on;
                y_vals = stage1_with_one_metric{2,4}(k,:);
                plot(stage1_with_one_metric{2,3}, y_vals, '-', 'color', color_line(2*k,:),...
                    'LineWidth', 1, 'HandleVisibility','off')
                plot(stage1_with_one_metric{2,3}(1:4:end), y_vals(1:4:end), ...
                    markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
                legend_names_first_plot{k} = strcat(name_of_2nd_param, " = ", num2str(stage1_with_one_metric{2,2}(k)));
            end
            set(gca,'FontSize', axis_font_size);	
            grid on;
            axis([min(stage1_with_one_metric{2,3}) max(stage1_with_one_metric{2,3})...
                min(stage1_with_one_metric{2,4}(:)) - (abs(max(stage1_with_one_metric{2,4}(:)) - min(stage1_with_one_metric{2,4}(:)))/10)...
                max(stage1_with_one_metric{2,4}(:)) + (abs(max(stage1_with_one_metric{2,4}(:)) - min(stage1_with_one_metric{2,4}(:)))/10)]);
            stem(stage1_with_one_metric{2,5}(3), stage1_with_one_metric{2,5}(4), '*r', 'LineWidth', 2)

            if strcmp(p.Results.NameOfThirdFilterParameter, defaultNameOfThirdFilterParameter)
                xlabel(strcat(name_of_3rd_param," of ", filter_name)); 
            else
                xlabel(name_of_3rd_param);
            end

            ylabel(metric_name_for_plot(i));
            title(strcat("With ", name_of_1st_param, " = ", num2str(stage1_with_one_metric{2,5}(1))))

            if (stage1_with_one_metric{2,5}(4) < 0.01 ) 
                if (floor(stage1_with_one_metric{2,5}(3)) == stage1_with_one_metric{2,5}(3))
                    legend_names_first_plot = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_first_plot = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            else
                if (floor(stage1_with_one_metric{2,5}(3)) == stage1_with_one_metric{2,5}(3))
                    legend_names_first_plot = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_first_plot = [legend_names_first_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage1_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage1_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            end 
            legend(legend_names_first_plot, 'Location', 'bestoutside') 

            fig_stage3 = figure('Name', strcat(filter_name, " research. Stage 3. ", metric_names(i)));
            stage3_with_one_metric = [research_result{2,3}(:,1) ...
                    research_result{2,3}(:,2) research_result{2,3}(:,3)...
                    research_result{2,3}(:,i+3) research_result{2,3}(:,i+3+metric_names_len)]; 
            legend_names_second_plot = cell(1,size(stage3_with_one_metric{2,2},2));   
            for k = 1:length(stage3_with_one_metric{2,2})
                hold on;
                y_vals = stage3_with_one_metric{2,4}(k,:);
                plot(stage3_with_one_metric{2,3}, y_vals, '-', 'color', color_line(2*k,:),...
                    'LineWidth', 1, 'HandleVisibility','off')
                plot(stage3_with_one_metric{2,3}(1:4:end), y_vals(1:4:end), ...
                    markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
                legend_names_second_plot{k} = strcat(name_of_2nd_param, " = ", num2str(stage3_with_one_metric{2,2}(k)));
            end
            set(gca,'FontSize', axis_font_size);	
            grid on;
            axis([min(stage3_with_one_metric{2,3}) max(stage3_with_one_metric{2,3})...
                min(stage3_with_one_metric{2,4}(:)) - (abs(max(stage3_with_one_metric{2,4}(:)) - min(stage3_with_one_metric{2,4}(:)))/10)...
                max(stage3_with_one_metric{2,4}(:)) + (abs(max(stage3_with_one_metric{2,4}(:)) - min(stage3_with_one_metric{2,4}(:)))/10)]);
            stem(stage3_with_one_metric{2,5}(3), stage3_with_one_metric{2,5}(4), '*r', 'LineWidth', 2)

            if strcmp(p.Results.NameOfThirdFilterParameter, defaultNameOfThirdFilterParameter)
                xlabel(strcat(name_of_3rd_param," of ", filter_name)); 
            else
                xlabel(name_of_3rd_param);
            end

            ylabel(metric_name_for_plot(i));
            title(strcat("With ", name_of_1st_param, " = ", num2str(stage3_with_one_metric{2,5}(1))))

            if (stage3_with_one_metric{2,5}(4) < 0.01 ) 
                if (floor(stage3_with_one_metric{2,5}(3)) == stage3_with_one_metric{2,5}(3))
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            else
                if (floor(stage3_with_one_metric{2,5}(3)) == stage3_with_one_metric{2,5}(3))
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%d'))]; 
                else
                    legend_names_second_plot = [legend_names_second_plot strcat(metric_name_for_plot(i), "_{opt} = ", ...
                        num2str(stage3_with_one_metric{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage3_with_one_metric{2,5}(3), '%0.2f'))]; 
                end
            end 
            legend(legend_names_second_plot, 'Location', 'bestoutside') 

            if (strcmp(p.Results.SavingPlot, 'on')) 
                stage1_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_' ,metric_names(i), '_stage1.png');
                stage3_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_' ,metric_names(i), '_stage3.png');
                print(fig_stage1, stage1_filename,'-dpng','-r500');
                print(fig_stage3, stage3_filename,'-dpng','-r500');
            end    
        end
        
        fig_stage2 = figure('Name', strcat(filter_name, " research. Stage 2. MultipleAxes"));
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
        stage2_with_one_metric_1plot = [research_result{2,2}(:,1) ...
                research_result{2,2}(:,2) research_result{2,2}(:,3)...
                research_result{2,2}(:,1+3) research_result{2,2}(:,1+3+metric_names_len)]; 
        
        plot(stage2_with_one_metric_1plot{2,1}, stage2_with_one_metric_1plot{2,4}, '.-k', 'LineWidth', 2, ...
               'MarkerSize', 17)
        addaxisplot(stage2_with_one_metric_1plot{2,5}(1),...
               stage2_with_one_metric_1plot{2,5}(4), 1, 'sr', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
        addaxislabel(1, metric_name_for_plot(1));
        legend_names{1} = metric_name_for_plot(1);
        if (stage2_with_one_metric_1plot{2,5}(4) < 0.01 ) 
            if (floor(stage2_with_one_metric_1plot{2,5}(1)) == stage2_with_one_metric_1plot{2,5}(1))
                legend_names{2} = strcat(metric_name_for_plot(1), "_{opt} = ", ...
                    num2str(stage2_with_one_metric_1plot{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage2_with_one_metric_1plot{2,5}(1), '%d')); 
            else
                legend_names{2} = strcat(metric_name_for_plot(1), "_{opt} = ", ...
                    num2str(stage2_with_one_metric_1plot{2,5}(4), '%0.3e'), ...
                        " at ", num2str(stage2_with_one_metric_1plot{2,5}(1), '%0.1f')); 
            end
        else
            if (floor(stage2_with_one_metric_1plot{2,5}(1)) == stage2_with_one_metric_1plot{2,5}(1))
                legend_names{2} = strcat(metric_name_for_plot(1), "_{opt} = ", ...
                    num2str(stage2_with_one_metric_1plot{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage2_with_one_metric_1plot{2,5}(1), '%d')); 
            else
                legend_names{2} = strcat(metric_name_for_plot(1), "_{opt} = ", ...
                    num2str(stage2_with_one_metric_1plot{2,5}(4), '%0.3f'), ...
                        " at ", num2str(stage2_with_one_metric_1plot{2,5}(1), '%0.1f')); 
            end
        end
        
        if (metric_names_len > 1)
            for k = 1:metric_names_len - 1
                stage2_with_one_metric = [research_result{2,2}(:,1) ...
                    research_result{2,2}(:,2) research_result{2,2}(:,3)...
                    research_result{2,2}(:,k+1+3) research_result{2,2}(:,k+1+3+metric_names_len)]; 
                
                color_line_curve = hsv(2*(metric_names_len - 1) + 1);
                color_line_point = jet(2*(metric_names_len - 1) + 1);
                markers_plot = ['o', '+', '*', 'x', 'd', '^', 'v', '>', '<', 'p', 'h'];
                if (metric_names_len > length(markers_plot))
                    markers_plot = [markers_plot markers_plot(1:(metric_names_len - length(markers_plot)))];
                end
                addaxis(stage2_with_one_metric{2,1},stage2_with_one_metric{2,4}, strcat(markers_plot(k),'-'),...
                    'color', color_line_curve(2*k,:),'LineWidth', 2, 'MarkerSize', 8);
                addaxisplot(stage2_with_one_metric{2,5}(1),...
                    stage2_with_one_metric{2,5}(4), k + 1, 's', ...
                    'MarkerFaceColor', color_line_point(2*k,:), ...
                    'MarkerEdgeColor', color_line_point(2*k,:), 'MarkerSize', 15);
                addaxislabel(k + 1, metric_name_for_plot(k+1));
                legend_names{k*2 + 1} = metric_name_for_plot(k+1);
                if (stage2_with_one_metric{2,5}(4) < 0.01 ) 
                    if (floor(stage2_with_one_metric{2,5}(1)) == stage2_with_one_metric{2,5}(1))
                        legend_names{k*2 + 2} = strcat(metric_name_for_plot(k+1), "_{opt} = ", ...
                            num2str(stage2_with_one_metric{2,5}(4), '%0.3e'), ...
                                " at ", num2str(stage2_with_one_metric{2,5}(1), '%d')); 
                    else
                        legend_names{k*2 + 2} = strcat(metric_name_for_plot(k+1), "_{opt} = ", ...
                            num2str(stage2_with_one_metric{2,5}(4), '%0.3e'), ...
                                " at ", num2str(stage2_with_one_metric{2,5}(1), '%0.1f')); 
                    end
                else
                    if (floor(stage2_with_one_metric{2,5}(1)) == stage2_with_one_metric{2,5}(1))
                        legend_names{k*2 + 2} = strcat(metric_name_for_plot(k+1), "_{opt} = ", ...
                            num2str(stage2_with_one_metric{2,5}(4), '%0.3f'), ...
                                " at ", num2str(stage2_with_one_metric{2,5}(1), '%d')); 
                    else
                        legend_names{k*2 + 2} = strcat(metric_name_for_plot(k+1), "_{opt} = ", ...
                            num2str(stage2_with_one_metric{2,5}(4), '%0.3f'), ...
                                " at ", num2str(stage2_with_one_metric{2,5}(1), '%0.1f')); 
                    end
                end
            end  
        elseif (metric_names_len == 1)
            axis([min(stage2_with_one_metric_1plot{2,1}) max(stage2_with_one_metric_1plot{2,1})...
                min(stage2_with_one_metric_1plot{2,4}) - round(abs(max(stage2_with_one_metric_1plot{2,4}) - min(stage2_with_one_metric_1plot{2,4}))/10,2)...
                max(stage2_with_one_metric_1plot{2,4}) + round(abs(max(stage2_with_one_metric_1plot{2,4}) - min(stage2_with_one_metric_1plot{2,4}))/10,2)]);
        end
        grid on;
        legend(legend_names, 'Location', 'best');
        AX = findall(0,'type','axes');
        for i = 1:size(AX, 1)
            set(AX(i),'FontSize', axis_font_size)
        end

        if strcmp(p.Results.NameOfFirstFilterParameter, defaultNameOfFirstFilterParameter)
            xlabel(strcat(name_of_1st_param," of ", filter_name)); 
        else
            xlabel(name_of_1st_param);
        end  

        if (strcmp(p.Results.SavingPlot, 'on')) 
            stage2_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '_stage2.png');
            print(fig_stage2, stage2_filename,'-dpng','-r500');
        end          
	end
end