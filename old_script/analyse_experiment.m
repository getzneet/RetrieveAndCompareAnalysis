close all
clear all

addpath './'
addpath './plot'

%------------------------------------------------------------------------
% Set parameters
%------------------------------------------------------------------------
conf = 'interleaved';
feedback = 'incomplete';
folder = 'data';
name = sprintf('%s_%s', conf, feedback);
data_filename = sprintf('%s/%s', folder, name);

folder = 'data/';
data_filename = name;
fit_folder = 'data/fit/';
fit_filename = name;
quest_filename = sprintf('data/questionnaire_%s', name);

optimism = 0;
rtime_threshold = 100000;
catch_threshold = 1;
n_best_sub = 0;
allowed_nb_of_rows = [258, 288, 255, 285, 376, 326, 470];
displayfig = 'on';
colors = [0.3963    0.2461    0.3405;...
    1 0 0;...
    0.7875    0.1482    0.8380;...
    0.4417    0.4798    0.7708;...
    0.5992    0.6598    0.1701;...
    0.7089    0.3476    0.0876;...
    0.2952    0.3013    0.3569;...
    0.1533    0.4964    0.2730];
blue_color = [0.0274 0.427 0.494];
blue_color_min = [0 0.686 0.8];

% create a default color map ranging from blue to dark blue
len = 8;
blue_color_gradient = zeros(len, 3);
blue_color_gradient(:, 1) = linspace(blue_color_min(1),blue_color(1),len)';
blue_color_gradient(:, 2) = linspace(blue_color_min(2),blue_color(2),len)';
blue_color_gradient(:, 3) = linspace(blue_color_min(3),blue_color(3),len)';


%------------------------------------------------------------------------
[data, sub_ids, exp, sim] = DataExtraction.get_data(...
    sprintf('%s/%s', folder, data_filename));

%------------------------------------------------------------------------
% Exclude subjects and retrieve data 
%------------------------------------------------------------------------
[sub_ids, corr_catch] = DataExtraction.exclude_subjects(...
    data, sub_ids, exp, catch_threshold, rtime_threshold, n_best_sub,...
    allowed_nb_of_rows...
);

nsub = length(sub_ids);
fprintf('N = %d \n', nsub);
fprintf('Catch threshold = %.2f \n', catch_threshold);

[cho1, out1, cfout1, corr1, con1, p11, p21, rew] = ...
    DataExtraction.extract_learning_data(data, sub_ids, exp);



[corr3, cho3, out3, p13, p23, ev13, ev23, ctch3, cont13, cont23, dist3] = ...
    DataExtraction.extract_elicitation_data(data, sub_ids, exp, 2);

% ------------------------------------------------------------------------
% Split depending on optimism tendency
% -----------------------------------------------------------------------
if optimism
    data2 = load(sprintf('%s%s', fit_folder, fit_filename));
    parameters = data2.data('parameters');
    delta_alpha = parameters(:, 2, 2) - parameters(:, 3, 2);
    [sorted, idx_order] = sort(delta_alpha);    
end

%------------------------------------------------------------------------
% Compute corr choice rate learning
%------------------------------------------------------------------------
% corr_rate_learning = zeros(size(corr1, 1), size(corr1, 2)/4, 4);
% 
% for sub = 1:size(corr1, 1)
%     for t = 1:size(corr1, 2)/4
%         for j = 1:4
%             d = corr1(sub, con1(sub, :) == j);
%             corr_rate_learning(sub, t, j) = mean(d(1:t));
%             
%             corr_rate(sub, t, j) = d(t);
%         end
%     end
% end

%------------------------------------------------------------------------
% Compute corr choice rate elicitation
%------------------------------------------------------------------------
% corr_rate_elicitation = zeros(size(corr, 1), 1);
% corr_rate_elicitation_sym = zeros(size(corr, 1), 8);
% dist_ordered = zeros(size(corr, 1), 8);
% 
% for sub = 1:size(corr, 1)
%     mask_equal_ev = logical(ev1(sub, :) ~= ev2(sub, :));
%     d = corr(sub, mask_equal_ev);
%     corr_rate_elicitation(sub) = mean(d);
%     i = 1;
%     for p = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9]
%         mask_p = logical(p1(sub, :) == p);
%         d = corr(sub, logical(mask_p.*mask_equal_ev));
%         corr_rate_elicitation_sym(sub, i) = mean(d);
%         dist_ordered(sub, i) = dist3(sub, p13(sub, :) == p);
%         i = i + 1;
%     end
% end

%------------------------------------------------------------------------
% Compute sampling
%------------------------------------------------------------------------
% for sub = 1:nsub
%     i = 1;
%     for p = [.1, .2, .3, .4]
% 
%             sampling_mean(sub, i) = ...
%                 mean([...
%                     cfout1(sub, logical(...
%                         (cho1(sub, :) == 1) .* (p21(sub, :) == p))),...
%                     out1(sub, logical(...
%                         (cho1(sub, :) == 2) .* (p21(sub, :) == p)))...
%        
%                     ], 'all');
% 
%              sampling_sum(sub, i) = ...
%                 sum([...
%                     cfout1(sub, logical(...
%                         (cho1(sub, :) == 1) .* (p21(sub, :) == p))),...
%                     out1(sub, logical(...
%                         (cho1(sub, :) == 2) .* (p21(sub, :) == p)))...
%        
%                     ], 'all');
%             i = i + 1;
%     end
%     for p = [.6, .7, .8, .9]
%             
%                 mean([...
%                     out1(sub, logical(...
%                         (cho1(sub, :) == 1) .* (p11(sub, :) == p))),...
%                     cfout1(sub, logical(...
%                         (cho1(sub, :) == 2) .* (p11(sub, :) == p)))...
%        
%                     ], 'all');
% 
%              sampling_sum(sub, i) = ...
%                 sum([...
%                     out1(sub, logical(...
%                         (cho1(sub, :) == 1) .* (p11(sub, :) == p))),...
%                     cfout1(sub, logical(...
%                         (cho1(sub, :) == 2) .* (p11(sub, :) == p)))...
%        
%                     ], 'all');
%             i = i + 1;
%     end
% end
% % ------------------------------------------------------------------------
% % Compute sampling
% % ------------------------------------------------------------------------
% i = 1;
% pwin = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];
% 
% for cond = 1:4
%     
%     d1 = cho1(con1 == cond);
%     
%     for c = 1:2
%         
%         p_exp(i) = mean(d1 == c);
%         
%         d2 = cho(pwin(i) == p1);
%         p_desc(i) = mean(d2 == 1);
%         
% %          sampling_mean(i) = ...
% %              mean(out1(sub, logical((cho1 == c) .* (con1 == cond))) == 1);
% %         sampling_median(sub, i) = ...
% %             mean(out1(sub, logical((cho1(sub, :) == c) .* (con1(sub, :) == cond))));
% %         sampling_sum(sub, i) = ...
% %             sum(out1(sub, logical((cho1(sub, :) == c) .* (con1(sub, :) == cond))));
%         i = i + 1;
%     end
%     
% end
[ev, evorder] = sort([0.8, -0.8, 0.6, -0.6, 0.4, -0.4, 0.2, -0.2]);
% 
% X = reshape(con1, [], 1);
% Y = reshape(cho1 == 1, [], 1);
% 
% [logitCoef, dev] = glmfit(...
%     X, Y, 'binomial','logit');
% 
% pp_exp_1 = glmval(logitCoef, unique(con1), 'logit');
% pp_exp = reshape(horzcat(pp_exp_1, zeros(4, 1)), [], 1);
% for i = 1:length(pp_exp)
%     disp(i);
%     pp_exp(i + 2) = pp_exp_1(i + 1);
%     pp_exp(i + 1) = 1-pp_exp_1(i);
% end
% plot(pwin, pp_exp(evorder));
% return

% surfaceplot(...
%         corr_rate(:, :, cond)',...
%         ones(3) * 0.5,...
%         [0.4660    0.6740    0.1880],...
%         1,...
%         0.38,...
%         -0.01,...
%         1.01,...
%         15,...
%         titles{cond},...
%         'trials',...
%         'correct choice rate' ...
%     );

% 
% figure('Renderer', 'painters', 'Position', [326,296,1064,691], 'visible', displayfig)
% skylineplot(...
%     sampling_sum(:, :)', colors,...
%     -35, 35, 13, '' , 'Expected Utility',...
%     'outcome sum', ev...
% );
% yline(0, 'LineStyle', ':');
% saveas(gcf, sprintf('fig/exp/%s/average_outcome.png', name));
% 
% 
% figure('Renderer', 'painters', 'Position', [326,296,1064,691], 'visible', displayfig)
% skylinemedianplot(...
%     sampling_sum(:, :)', colors,...
%     -35, 35, 13, '' , 'Expected Utility',...
%     'outcome sum (median and quartiles)', ev...
% );
% yline(0, 'LineStyle', ':');
% saveas(gcf, sprintf('fig/exp/%s/median_outcome.png', name));

% ------------------------------------------------------------------------
% Correlate corr choice rate vs quest
% -----------------------------------------------------------------------
% quest_data = load(quest_filename);
% quest_data = quest_data.data;
% 
% for i = 1:length(sub_ids)
%     sub = sub_ids(i);
%     mask_quest = arrayfun(@(x) x==-7, quest_data{:, 'quest'});
%     mask_sub = arrayfun(...
%         @(x) strcmp(sprintf('%.f', x), sprintf('%.f', sub)),...
%         quest_data{:, 'sub_id'});
%     crt_scores(i) = sum(...
%         quest_data{logical(mask_quest .* mask_sub), 'val'});
% end

%------------------------------------------------------------------------
% Plot CRT predict performance 
% -----------------------------------------------------------------------
% x = unique(crt_scores./14);
% y = zeros(length(x), 1); 
% j = 1;
% for i = x
%     y(j) = mean(corr_rate_elicitation(crt_scores./14 == i));
%     j = j + 1;
% end
% [logitCoef, dev] = glmfit(...
%            crt_scores./14, corr_rate_elicitation', 'normal', 'link', 'identity');
% p = glmval(logitCoef, linspace(0, 1, 20), 'identity');
% figure
% plot(linspace(0, 1, 20), p);
% hold on
% scatter(x, y);
% return

%------------------------------------------------------------------------
% Plot correlations 
% -----------------------------------------------------------------------
% LEARNING PHASE
% -----------------------------------------------------------------------
% figure('visible', displayfig)
% scatterCorr(...
%     mean(corr_rate_learning, [2, 3])',...
%     crt_scores./14,...
%     [0.4660    0.6740    0.1880],...
%     0.6,...
%     2,...
%     2,...
%     'w');
% ylabel('CRT Score');
% xlabel('Correct choice rate learning');
% saveas(gcf, sprintf('fig/exp/%s/corr_learning_crt.png', name));
% 
%------------------------------------------------------------------------
% ELICITATION PHASE
% -----------------------------------------------------------------------
% figure('Position', [753,720,492,371], 'visible', displayfig)
% scatterCorr(...
%     corr_rate_elicitation',...
%     crt_scores./14,...
%     blue_color,...
%     0.6,...
%     2,...
%     2....
%    );
% %ylabel('CRT Score');
% xlabel('Correct choice rate (Description vs Experience)');
% box off
% saveas(gcf, sprintf('fig/exp/%s/corr_elicitation_crt.png', name));
% % return
% 
% %------------------------------------------------------------------------
% % ELICITATION VS LEARNING 
% % -----------------------------------------------------------------------
% figure('visible', displayfig)
% scatterCorr(...
%     corr_rate_elicitation',...
%     mean(corr_rate_learning, [2, 3])',...
%     [0.4660    0.6740    0.1880],...
%     0.6,...
%     2,...
%     2,...
%     'w');
% ylabel('Correct choice rate learning');
% xlabel('Correct choice rate elicitation');
% saveas(gcf, sprintf('fig/exp/%s/corr_elicitation_learning.png', name));
% 
% %------------------------------------------------------------------------
% % ELICITATION 1 VS ELICITATION 2 
% % -----------------------------------------------------------------------
% figure('Renderer', 'painters', 'Position', [961, 1, 960, 1090], 'visible', displayfig)
% pwin = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];
% for i = 1:8
%     subplot(4, 2, i);
%              
%     scatterCorr(...
%         corr_rate_elicitation_sym(:, i)',...
%         dist_ordered(:, i)',...
%         [0.4660    0.6740    0.1880],...
%         0.6,...
%         2,...
%         2,...
%         'w');
%     if mod(i, 2) ~= 0
%         ylabel('Distance');
%     end
%     if ismember(i, [7, 8])
%         xlabel('Correct choice rate elicitation');
%     end
%     ylim([-0.08, 1.08]);
%     title(sprintf('P(win) = %.1f', pwin(i)));
%     
% end
% saveas(gcf, sprintf('fig/exp/%s/corr_elicitation_1_dist.png', name));
% 
% %------------------------------------------------------------------------
% % PLOT
% %------------------------------------------------------------------------
% %i = 1;
% titles = {'0.9 vs 0.1', '0.8 vs 0.2', '0.7 vs 0.3', '0.6 vs 0.4'};
% figure('Renderer', 'painters', 'Position', [42,124,2320,900], 'visible', displayfig)
% 
% for cond = 1:4
%     subplot(1, 4, cond)
% 
%     surfaceplot(...
%         corr_rate(:, :, cond)',...
%         ones(3) * 0.5,...
%         [0.4660    0.6740    0.1880],...
%         1,...
%         0.38,...
%         -0.01,...
%         1.01,...
%         15,...
%         titles{cond},...
%         'trials',...
%         'correct choice rate' ...
%     );
% 
%     i = i + 1;
% end
% saveas(gcf, sprintf('fig/exp/%s/learning_curve.png', name));




[corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
    DataExtraction.extract_elicitation_data(data, sub_ids, exp, 0);

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

if optimism
    titles = {'Low \Delta\alpha', 'High \Delta\alpha', 'All'};
else
    titles = {'Low tier group', 'Best tier group', 'All'};
end

tt = 0;
nsub = size(cho, 1);
nsub_divided = ceil(nsub/2);
% ----------------------------------------------------------------------
% PLOT P(learnt value) vs Described Cue
% ------------------------------------------------------------------------
for k = {1:nsub_divided, nsub_divided+1:nsub, 1:nsub}
    
    k = k{:};
    tt = tt + 1;
    
    if exist('idx_order')
        k = idx_order(k)';
    end
    
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
    
    %suptitle(titles{tt});
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
            'Color', blue_color, 'LineWidth', 2 ...
            );
        
        hold on
        sc1 = scatter(pcue, prop(i, :), 80,...
            'MarkerEdgeColor', 'w',...
            'MarkerFaceColor', blue_color);
        s.MarkerFaceAlpha = 0.5;
        
        hold on 
        ind_point = interp1(lin3.YData, lin3.XData, 0.5);
        sc2 = scatter(ind_point, 0.5, 100, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'w');
       
        if mod(i, 2) ~= 0 || ismember(i, [1, 2])
            ylabel('P(choose experienced value)', 'FontSize', 26);
        end
        if ismember(i, [7, 8]) || ismember(i, [2])
            xlabel('Described cue win probability', 'FontSize', 26);
        end
       
        if pwin(i) < 0.6
            text(pwin(i)+0.03, 0.8, sprintf('P(win experienced value) = %0.1f', pwin(i)), 'FontSize', 20);
        else

            text(pwin(i)-0.68, 0.8, sprintf('P(win experienced value) = %0.1f', pwin(i)), 'FontSize', 20);
        end

        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
       
        text(ind_point + 0.05, .55, sprintf('%.2f', ind_point), 'Color', 'r', 'FontSize', 25);
        box off
        set(gca, 'Fontsize', 23);

    end
    saveas(gcf, sprintf('fig/exp/%s/explicite_implicite%d.png', name, tt));

end


% ----------------------------------------------------------------------
% Plot violins
% % --------------------------------------------------------------------
%[corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
%    DataExtraction.extract_elicitation_data(data, sub_ids, exp, 2);
c = 0;
for k = {1:nsub_divided, nsub_divided+1:nsub, 1:nsub}
    c = c + 1;
    k = k{:};
    mn = zeros(8, length(k));

    pwin = [1:9]./10;
    pwin(5) = [];
    i = 1;
    temp1 = cho3(k, :);
    for p = pwin
        mn(i, :) = temp1(p13(k, :) == p)./100;
        i = i + 1;
    end

    figure('Renderer', 'painters', 'Position', [326,296,1064,691], 'visible', displayfig)
    skylineplot(...
        mn, blue_color_gradient,...
        -0.08, 1.08, 20, '', 'P(win of learnt value)',...
        'Estimated probability', pwin...
    );
    yline(0.5, 'LineStyle', ':');

    %ylim([-0.005, 1.08]);
    %xlim([-0.08, 1.08]);
    saveas(gcf, sprintf('fig/exp/%s/slider%d.png', name, c));
end
