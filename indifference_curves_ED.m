%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [8];

displayfig = 'on';

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)

num = 0;
for exp_num = selected_exp
    num = num + 1;
    
    data = de.extract_ED(exp_num);
    
    nsub = data.nsub;
    p1 = data.p1;
    p2 = data.p2;
    cho = data.cho;
   
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
   
    pcue = unique(p2)';
    psym = unique(p1)';
   
    chose_symbol = zeros(nsub, length(pcue), length(psym));
    for i = 1:nsub
        for j = 1:length(pcue)
            for k = 1:length(psym)
                temp = ...
                    cho(i, logical((p2(i, :) == pcue(j)) .* (p1(i, :) == psym(k))));
            
            end
        end
    end
   
    nsub = size(cho, 1);
    k = 1:nsub;
   
    prop = zeros(length(psym), length(pcue));
    temp1 = cho(k, :);
    for j = 1:length(pcue)
        for l = 1:length(psym)
            temp = temp1(...
                logical((p2(k, :) == pcue(j)) .* (p1(k, :) == psym(l))));
            prop(l, j) = mean(temp == 1);
            err_prop(l, j) = std(temp == 1)./sqrt(length(temp));
           
        end
    end
   
    X = reshape(...
        repmat(pcue, size(k, 2), size(chose_symbol, 4)), [], 1....
        );
   
    pp = zeros(length(psym), length(pcue));
   
    for i = 1:length(psym)
        Y = reshape(chose_symbol(k, :, i, :), [], 1);
        [logitCoef, dev] = glmfit(...
            X, Y, 'binomial','logit');
        pp(i, :) = glmval(logitCoef, pcue', 'logit');
    end
   
    subplot(1, length(selected_exp), num);
   
    pwin = psym;
    %alpha = [fliplr(linspace(.4, .9, length(psym)/2)), linspace(.4, .9, length(psym)/2)];
    alpha = linspace(.15, .95, length(psym));
    lin1 = plot(...
        linspace(psym(1)*100, psym(end)*100, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
   
    for i = 1:length(pwin)
       
        hold on
       
       
        lin3 = plot(...
            pcue.*100,  prop(i, :).*100,...
            'Color', orange, 'LineWidth', 1.5 ...% 'LineStyle', '--' ...
            );
       
       
        lin3.Color(4) = alpha(i);
       
        hold on      
       
        [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
       
        sc2 = scatter(xout, yout, 15, 'MarkerFaceColor', lin3.Color,...
            'MarkerEdgeColor', 'w');
        sc2.MarkerFaceAlpha = alpha(i);
       
        if num == 1
            ylabel('P(choose symbol) (%)');
        end
        xlabel('Lottery p(win) (%)');
       
        ylim([-0.08*100, 1.08*100]);
        xlim([-0.08*100, 1.08*100]);
       
        box off
    end
   
    
    set(gca,'TickDir','out')
    set(gca, 'FontSize', fontsize);
    xticks([0:20:100])
    %axis equal

    clear pp pcue psym temp err_prop prop i
   
end
mkdir('fig/exp', 'ind_curves_bhv');
saveas(gcf, ...
    sprintf('fig/exp/ind_curves_bhv/full_ED.svg'));
