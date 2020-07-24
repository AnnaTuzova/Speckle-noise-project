function ThreeParameterResearchPlotting(varargin)
%% Parsing input variable
    defaultNameOfFirstFilterParameter = "First variable parameter";
    defaultNameOfSecondFilterParameter = "Second variable parameter";
    defaultNameOfThirdFilterParameter = "Third variable parameter";

    p = inputParser;
    addRequired(p, 'ResearchResult', @(x) iscell(x))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addRequired(p,'NoiseType', @(x) ischar(x))
    addParameter(p,'NameOfFirstFilterParameter', defaultNameOfFirstFilterParameter, @(x) ischar(x))
    addParameter(p,'NameOfSecondFilterParameter', defaultNameOfSecondFilterParameter, @(x) ischar(x))
    addParameter(p,'NameOfThirdFilterParameter', defaultNameOfThirdFilterParameter, @(x) ischar(x))
    addParameter(p, 'SavingPlot', @(x) ischar(x))
    addParameter(p, 'FigureType', @(x) ischar(x))
    parse(p, varargin{:});
    
    research_result = p.Results.ResearchResult;
    filter_name = p.Results.NameOfFilter;
    noise_type = p.Results.NameOfFilter;
    
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
    if(strcmp(p.Results.FigureType, 'SubplotFigures'))
        fig = figure('Name', strcat(filter_name, " research"));
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
        
        pos1 = [0.15 0.55 0.3 0.3];
        subplot('Position', pos1)
        color_line = hsv(2*(length(research_result{2,2}) + 1));
        markers_plot = ['o', '+', '*', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'];
        if (length(research_result{2,2}) > length(markers_plot))
            markers_plot = [markers_plot markers_plot(1:(length(research_result{2,2}) - length(markers_plot)))];
        end

        for k = 1:length(research_result{2,2})
            hold on;
            y_vals = research_result{2,4}(k,:);
            plot(research_result{2,3}, y_vals, '-', 'color', color_line(2*k,:),'LineWidth', 1, 'HandleVisibility','off')
            plot(research_result{2,3}(1:4:end), y_vals(1:4:end), ...
                markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
            legend_names_first_plot{k} = strcat(name_of_2nd_param, " = ", num2str(research_result{2,2}(k)));
        end
        set(gca,'FontSize',12);	grid on;
        axis([min(research_result{2,3}) max(research_result{2,3})...
            round((min(research_result{2,4}(:))-0.02),2) round((max(research_result{2,4}(:))+0.02),2)]);
        stem(research_result{2,7}(3), research_result{2,7}(4), '*r', 'LineWidth', 2)
        if strcmp(p.Results.NameOfThirdFilterParameter, defaultNameOfThirdFilterParameter)
            xlabel(strcat(name_of_3rd_param," of ", filter_name)); 
        else
            xlabel(name_of_3rd_param);
        end
        ylabel('SSIM');
        title(strcat("With ", name_of_1st_param, " = ", num2str(research_result{2,7}(1))))
        legend_names_first_plot = [legend_names_first_plot strcat("SSIM_{max} = ", ...
            num2str(research_result{2,7}(4), '%0.3f'), " at ", num2str(research_result{2,7}(3)))];
        legend(legend_names_first_plot, 'Location', 'bestoutside') 

        pos2 = [0.55 0.55 0.3 0.3];
        subplot('Position',pos2)
        stem(research_result{2,8}(1), research_result{2,8}(4), '*r','LineWidth', 2)
        hold on
        plot(research_result{2,1}, research_result{2,5}, '.-k', 'LineWidth', 2, 'MarkerSize', 17)
        grid on;    
        axis([min(research_result{2,1}) max(research_result{2,1})...
            round((min(research_result{2,5})-0.02),2) round((max(research_result{2,5})+0.02),2)]);
        set(gca,'FontSize',12)
        if strcmp(p.Results.NameOfFirstFilterParameter, defaultNameOfFirstFilterParameter)
            xlabel(strcat(name_of_1st_param," of ", filter_name)); 
        else
            xlabel(name_of_1st_param);
        end  
        ylabel('SSIM');
        legend(strcat("SSIM_{max} = ", num2str(research_result{2,8}(4), '%0.3f'),...
                " at ", num2str(research_result{2,8}(1), '%d')), 'Location', 'best')
        title(strcat("With ", name_of_2nd_param, " =  " , num2str(research_result{2,8}(2)) ,...
            " and ", name_of_3rd_param, " = " , num2str(research_result{2,8}(3))))

        pos3 = [0.35 0.1 0.3 0.3];
        subplot('Position', pos3)
        for k = 1:length(research_result{2,2})
            hold on;
            y_vals = research_result{2,6}(k,:);
            plot(research_result{2,3}, y_vals, '-', 'color', color_line(2*k,:),'LineWidth', 1, 'HandleVisibility','off')
            plot(research_result{2,3}(1:4:end), y_vals(1:4:end), ...
                markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
            legend_names_second_plot{k} = strcat(name_of_2nd_param, " = ", num2str(research_result{2,2}(k)));
        end
        set(gca,'FontSize',12);	grid on;
        axis([min(research_result{2,3}) max(research_result{2,3})...
            round((min(research_result{2,6}(:))-0.02),2) round((max(research_result{2,6}(:))+0.02),2)]);
        stem(research_result{2,9}(3), research_result{2,9}(4), '*r', 'LineWidth', 2)
        if strcmp(p.Results.NameOfThirdFilterParameter, defaultNameOfThirdFilterParameter)
            xlabel(strcat(name_of_3rd_param," of ", filter_name)); 
        else
            xlabel(name_of_3rd_param);
        end
        ylabel('SSIM');
        title(strcat("With ", name_of_1st_param, " = ", num2str(research_result{2,9}(1))))
        legend_names_second_plot = [legend_names_second_plot strcat("SSIM_{max} = ", num2str(research_result{2,9}(4), '%0.3f'),...
            " at ", num2str(research_result{2,9}(3)))];
        legend(legend_names_second_plot, 'Location', 'bestoutside') 
        
        if (strcmp(p.Results.SavingPlot, 'on')) 
            plot_filename = strcat('Output\Graphics\', filter_name, '_', noise_type, '.png');
            print(fig, plot_filename,'-dpng','-r500');
        end
            
    else
        fig_stage1 = figure('Name', strcat(filter_name, " research. Stage 1"));

        color_line = hsv(2*(length(research_result{2,2}) + 1));
        markers_plot = ['o', '+', '*', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'];
        if (length(research_result{2,2}) > length(markers_plot))
            markers_plot = [markers_plot markers_plot(1:(length(research_result{2,2}) - length(markers_plot)))];
        end

        for k = 1:length(research_result{2,2})
            hold on;
            y_vals = research_result{2,4}(k,:);
            plot(research_result{2,3}, y_vals, '-', 'color', color_line(2*k,:),'LineWidth', 1, 'HandleVisibility','off')
            plot(research_result{2,3}(1:4:end), y_vals(1:4:end), ...
                markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
            legend_names_first_plot{k} = strcat(name_of_2nd_param, " = ", num2str(research_result{2,2}(k)));
        end
        set(gca,'FontSize',12);	grid on;
        axis([min(research_result{2,3}) max(research_result{2,3})...
            round((min(research_result{2,4}(:))-0.02),2) round((max(research_result{2,4}(:))+0.02),2)]);
        stem(research_result{2,7}(3), research_result{2,7}(4), '*r', 'LineWidth', 2)
        if strcmp(p.Results.NameOfThirdFilterParameter, defaultNameOfThirdFilterParameter)
            xlabel(strcat(name_of_3rd_param," of ", filter_name)); 
        else
            xlabel(name_of_3rd_param);
        end
        ylabel('SSIM');
        title(strcat("With ", name_of_1st_param, " = ", num2str(research_result{2,7}(1))))
        legend_names_first_plot = [legend_names_first_plot strcat("SSIM_{max} = ", ...
            num2str(research_result{2,7}(4), '%0.3f'), " at ", num2str(research_result{2,7}(3)))];
        legend(legend_names_first_plot, 'Location', 'bestoutside') 

        fig_stage2 = figure('Name', strcat(filter_name, " research. Stage 2"));
        stem(research_result{2,8}(1), research_result{2,8}(4), '*r','LineWidth', 2)
        hold on
        plot(research_result{2,1}, research_result{2,5}, '.-k', 'LineWidth', 2, 'MarkerSize', 17)
        grid on;    
        axis([min(research_result{2,1}) max(research_result{2,1})...
            round((min(research_result{2,5})-0.02),2) round((max(research_result{2,5})+0.02),2)]);
        set(gca,'FontSize',12)
        if strcmp(p.Results.NameOfFirstFilterParameter, defaultNameOfFirstFilterParameter)
            xlabel(strcat(name_of_1st_param," of ", filter_name)); 
        else
            xlabel(name_of_1st_param);
        end  
        ylabel('SSIM');
        legend(strcat("SSIM_{max} = ", num2str(research_result{2,8}(4), '%0.3f'),...
                " at ", num2str(research_result{2,8}(1), '%d')), 'Location', 'best')
        title(strcat("With ", name_of_2nd_param, " =  " , num2str(research_result{2,8}(2)) ,...
            " and ", name_of_3rd_param, " = " , num2str(research_result{2,8}(3))))

        fig_stage3 = figure('Name', strcat(filter_name, " research. Stage 3"));
        for k = 1:length(research_result{2,2})
            hold on;
            y_vals = research_result{2,6}(k,:);
            plot(research_result{2,3}, y_vals, '-', 'color', color_line(2*k,:),'LineWidth', 1, 'HandleVisibility','off')
            plot(research_result{2,3}(1:4:end), y_vals(1:4:end), ...
                markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
            legend_names_second_plot{k} = strcat(name_of_2nd_param, " = ", num2str(research_result{2,2}(k)));
        end
        set(gca,'FontSize',12);	grid on;
        axis([min(research_result{2,3}) max(research_result{2,3})...
            round((min(research_result{2,6}(:))-0.02),2) round((max(research_result{2,6}(:))+0.02),2)]);
        stem(research_result{2,9}(3), research_result{2,9}(4), '*r', 'LineWidth', 2)
        if strcmp(p.Results.NameOfThirdFilterParameter, defaultNameOfThirdFilterParameter)
            xlabel(strcat(name_of_3rd_param," of ", filter_name)); 
        else
            xlabel(name_of_3rd_param);
        end
        ylabel('SSIM');
        title(strcat("With ", name_of_1st_param, " = ", num2str(research_result{2,9}(1))))
        legend_names_second_plot = [legend_names_second_plot strcat("SSIM_{max} = ", num2str(research_result{2,9}(4), '%0.3f'),...
            " at ", num2str(research_result{2,9}(3)))];
        legend(legend_names_second_plot, 'Location', 'bestoutside') 
        
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