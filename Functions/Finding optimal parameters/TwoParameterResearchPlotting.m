function TwoParameterResearchPlotting(research_result, filter_name, win_size)
    color_line = hsv(2*(length(research_result{2,1}) + 1));
    for k = 1:length(research_result{2,1})
        plot(research_result{2,2}, research_result{2,3}(k,:),'.-', 'color', color_line(2*k,:),'LineWidth', 2, 'MarkerSize', 17)
        hold on;
        legend_names{k} = ['First parameter = ' num2str(research_result{2,1}(k))]; 
    end
    set(gca,'FontSize',12);     grid on;
    axis([min(research_result{2,2}) max(research_result{2,2})...
        min(research_result{2,3}(:)) max(research_result{2,3}(:))]);
    stem(research_result{2,4}(2), research_result{2,4}(3), '*r','LineWidth', 2)
    xlabel(strcat("Second variable parameter of ", filter_name)); ylabel('SSIM');
    legend_names = [legend_names strcat("SSIM_{max} = ", num2str(research_result{2,4}(3), '%0.3f'),...
                " at ", num2str(research_result{2,4}(2)), ...
                ", ", num2str(win_size(1), '%d'), "\times" , num2str(win_size(2), '%d')), 'Location', 'bestoutside'];
    legend(legend_names)       
end