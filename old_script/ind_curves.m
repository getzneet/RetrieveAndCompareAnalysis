init;

titles = {...
    'Exp. 1', 'Exp. 2', 'Exp. 3', 'Exp. 4', 'Exp. 5 Sess. 1', 'Exp. 5 Sess. 2'};
exp_num = 1;

for f = {filenames{:}, filenames{end}}
    if exp_num == 6
        session = 1;
    else
        session = 0;
    end
    name = char(f);
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(data, sub_ids, idx, session);
    
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    pcue = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
    psym = [0.1, 0.9];
    chose_symbol = zeros(size(cho, 1), length(pcue), length(psym));
    for i = 1:size(cho, 1)
        for j = 1:length(pcue)
            for k = 1:length(psym)
                temp = cho(i, logical((p2(i, :) == pcue(j)) .* (p1(i, :) == psym(k))));
                chose_symbol(i, j, k) = temp == 1;
            end
        end
    end
    
    
    nsub = size(cho, 1);
    % ----------------------------------------------------------------------
    % PLOT P(learnt value) vs Described Cue
    % ------------------------------------------------------------------------
    
    k = 1:nsub;
    
    
    prop = zeros(length(psym), length(pcue));
    temp1 = cho(k, :);
    for j = 1:length(pcue)
        for l = 1:length(psym)
            temp = temp1(...
                logical((p2(k, :) == pcue(j)) .* (p1(k, :) == psym(l))));
            prop(l, j) = mean(temp == 1);
        end
    end
    
    X = reshape(...
        repmat(pcue, size(k, 2), 1), [], 1....
        );
    pp = zeros(length(psym), length(pcue));
    
    for i = 1:length(psym)
        Y = reshape(chose_symbol(k, :, i), [], 1);
        [logitCoef, dev] = glmfit(...
            X, Y, 'binomial','logit');
        pp(i, :) = glmval(logitCoef, pcue', 'logit');
    end
    
    figure(...
        'Renderer', 'painters',...
        'Position', [961, 1, 960, 1090],...
        'visible', displayfig)
    
    pwin = [0.1, 0.9];
    
    for i = 1:length(psym)
        
        subplot(2, 1, i)
        lin1 = plot(...
            linspace(0, 1, 12), ones(12)*0.5, 'LineStyle', ':', 'Color', [0, 0, 0]);
        
        hold on
        lin2 = plot(...
            ones(10)*pwin(i),...
            linspace(0.1, 0.9, 10),...
            'LineStyle', '--', 'Color', [0, 0, 0], 'LineWidth', 2);
        
        hold on
        % [0.4660    0.6740    0.1880]
        lin3 = plot(...
            pcue,  pp(i, :),... %'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
            'Color', blue_color, 'LineWidth', 3.5 ...
            );
        
        hold on
        sc1 = scatter(pcue, prop(i, :), 130,...
            'MarkerEdgeColor', 'w',...
            'MarkerFaceColor', blue_color);
        s.MarkerFaceAlpha = 0.5;
        
        hold on
        ind_point = interp1(lin3.YData, lin3.XData, 0.5);
        sc2 = scatter(ind_point, 0.5, 150, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'w');
        
        if mod(i, 2) ~= 0 || ismember(i, [1, 2])
            ylabel('P(choose experienced cue)', 'FontSize', 26);
        end
        if ismember(i, [7, 8]) || ismember(i, [2])
            xlabel('Described cue win probability', 'FontSize', 26);
        end
        
        if pwin(i) < 0.6
            text(pwin(i)+0.03, 0.8, sprintf('P(win experienced cue) = %0.1f', pwin(i)), 'FontSize', 20);
        else
            
            text(pwin(i)-0.68, 0.8, sprintf('P(win experienced cue) = %0.1f', pwin(i)), 'FontSize', 20);
        end
        
        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
        
        text(ind_point + 0.05, .55, sprintf('%.2f', ind_point), 'Color', 'r', 'FontSize', 25);
        box off
        set(gca, 'Fontsize', 23);
    end
    
    s1 = suptitle(titles{exp_num});
    set(s1, 'Fontsize', 40)

    saveas(gcf, sprintf('fig/exp/all/ind_curve_%s_%d.png', name, session));
    exp_num = exp_num + 1;
    
    
end
