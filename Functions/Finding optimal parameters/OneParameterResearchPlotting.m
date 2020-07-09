function OneParameterResearchPlotting(varargin)
    %% Parsing input variable     
    p = inputParser;
    addRequired(p, 'ResearchResult', @(x) iscell(x))
    addRequired(p, 'NameOfFilter', @(x) ischar(x))
    addParameter(p, 'WindowSize', @(x) isnumeric(x) && all(x(:) >= 0))
    
    parse(p, varargin{:});
    research_result = p.Results.ResearchResult;
    filter_name = p.Results.NameOfFilter;
    if (isnumeric(p.Results.WindowSize))
        win_size = p.Results.WindowSize;
    end
    
    %% Plotting
    stem(research_result{2,3}(1), research_result{2,3}(2), '*r','LineWidth', 2)
    hold on
    plot(research_result{2,1}, research_result{2,2}, '.-k', 'LineWidth', 2, 'MarkerSize', 17)
    grid on; axis([min(research_result{2,1}) max(research_result{2,1})...
        min(research_result{2,2}) max(research_result{2,2})]);
    set(gca,'FontSize',12)
    if (strcmp(research_result{1,1}, 'WindowSideSize'))
        xlabel('Window side size'); ylabel('SSIM');
        legend(strcat("SSIM_{max} = ", num2str(research_result{2,3}(2), '%0.3f'),...
        	" at ", num2str(research_result{2,3}(1), '%d')), 'Location', 'best')
    else
        xlabel(strcat("Variable parameter of ", filter_name)); ylabel('SSIM');
        legend(strcat("SSIM_{max} = ", num2str(research_result{2,3}(2), '%0.3f'),...
            " at ", num2str(research_result{2,3}(1)), ...
            ", ", num2str(win_size(1), '%d'), "\times" , num2str(win_size(2), '%d')), 'Location', 'best') 
    end
end