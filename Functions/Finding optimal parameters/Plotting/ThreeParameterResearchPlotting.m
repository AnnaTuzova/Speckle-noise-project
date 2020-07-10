function ThreeParameterResearchPlotting(research_result, filter_name)
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
        
%         plot(research_result{2,3}, research_result{2,4}(k,:), '.-', 'color', color_line(2*k,:),'LineWidth', 2, 'MarkerSize', 17)
        
        legend_names_first_plot{k} = ['Second parameter = ' num2str(research_result{2,2}(k))]; 
    end
    set(gca,'FontSize',12);	grid on;
    axis([min(research_result{2,3}) max(research_result{2,3})...
        min(research_result{2,4}(:)) max(research_result{2,4}(:))]);
    stem(research_result{2,7}(3), research_result{2,7}(4), '*r', 'LineWidth', 2)
    xlabel(strcat("Third variable parameter of ", filter_name)); ylabel('SSIM');
    title(strcat("With first parameter = ", num2str(research_result{2,7}(1))))
    legend_names_first_plot = [legend_names_first_plot strcat("SSIM_{max} = ", num2str(research_result{2,7}(4), '%0.3f'),...
        " at ", num2str(research_result{2,7}(3)))];
    legend(legend_names_first_plot, 'Location', 'bestoutside') 

    pos2 = [0.55 0.55 0.3 0.3];
    subplot('Position',pos2)
    stem(research_result{2,8}(1), research_result{2,8}(4), '*r','LineWidth', 2)
    hold on
    plot(research_result{2,1}, research_result{2,5}, '.-k', 'LineWidth', 2, 'MarkerSize', 17)
    grid on;    
    axis([min(research_result{2,1}) max(research_result{2,1})...
        min(research_result{2,5}) max(research_result{2,5})]);
    set(gca,'FontSize',12)
    xlabel(strcat("First variable parameter of ", filter_name)); ylabel('SSIM');
    legend(strcat("SSIM_{max} = ", num2str(research_result{2,8}(4), '%0.3f'),...
        	" at ", num2str(research_result{2,8}(1), '%d')), 'Location', 'best')
    title(strcat("With second parameter =  " , num2str(research_result{2,8}(2)) ,...
        " and third parameter = " , num2str(research_result{2,8}(3))))
    
    pos3 = [0.35 0.1 0.3 0.3];
    subplot('Position', pos3)
    for k = 1:length(research_result{2,2})
        hold on;
        y_vals = research_result{2,6}(k,:);
        plot(research_result{2,3}, y_vals, '-', 'color', color_line(2*k,:),'LineWidth', 1, 'HandleVisibility','off')
        plot(research_result{2,3}(1:4:end), y_vals(1:4:end), ...
            markers_plot(k), 'color', color_line(2*k,:), 'MarkerSize', 5)
        
%         plot(research_result{2,3}, research_result{2,6}(k,:), '.-', 'color', color_line(2*k,:),'LineWidth', 2, 'MarkerSize', 17)
        
        legend_names_second_plot{k} = ['Second parameter = ' num2str(research_result{2,2}(k))]; 
    end
    set(gca,'FontSize',12);	grid on;
    axis([min(research_result{2,3}) max(research_result{2,3})...
        min(research_result{2,6}(:)) max(research_result{2,6}(:))]);
    stem(research_result{2,9}(3), research_result{2,9}(4), '*r', 'LineWidth', 2)
    xlabel(strcat("Third variable parameter of ", filter_name)); ylabel('SSIM');
    title(strcat("With first parameter = " , num2str(research_result{2,9}(1))))
    legend_names_second_plot = [legend_names_second_plot strcat("SSIM_{max} = ", num2str(research_result{2,9}(4), '%0.3f'),...
        " at ", num2str(research_result{2,9}(3)))];
    legend(legend_names_second_plot, 'Location', 'bestoutside') 
            
end