% --------------------------------------------------------------------
% This script 
% computes correct choice rate then plots the article figs
% --------------------------------------------------------------------
init;
% filenames{6}= 'block_complete_mixed_2s';
% filenames{8}= 'block_complete_mixed_2s_amb_final';
% filenames{7}= 'block_complete_mixed_2s_amb';

selected_exp = 7;
filenames = {filenames{1:3}};
%------------------------------------------------------------------------
% Plot fig
%------------------------------------------------------------------------
if length(filenames) > 1
    to_add = '_all';
else
    to_add = sprintf('_exp_%d', selected_exp);
end
% plot_bar_plot_corr_choice_rate_contingencies(d, idx, blue_color_gradient, filenames)
% mkdir('fig/exp', 'bar_plot_correct_choice_rate');
% saveas(gcf, ...
%     sprintf('fig/exp/bar_plot_correct_choice_rate/fig_cond_%s.png', to_add));
% 
plot_bar_plot_correct_choice_rate_exp(d, idx,  blue_color_gradient, filenames)
saveas(gcf,...
    sprintf('fig/exp/bar_plot_correct_choice_rate/fig_exp_1_2_3.png', to_add));


function plot_bar_plot_correct_choice_rate_exp(...
    d, idx,  blue_color_gradient, exp_names)
   
    titles = {'Exp. 1', 'Exp. 2', 'Exp. 3',...
        'Exp. 4', 'Exp. 5', 'Exp. 6 (failed)', 'Exp. 6', 'Exp. 7'};
    
    n_exp = length(exp_names);
    i = 1;

    sub = 1;
    nsub = 0;
    colors = blue_color_gradient(1:8, :, :);
    
    figure('Position', [1,1,1650,1200]);
         
    for exp_name = {exp_names{:}}
        session = [0, 1];
        exp_name = char(exp_name);
     
        [cho, out, cfout, corr, con, p1, p2, rew, rtime] = ...
            DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);
        
        nsub = nsub + size(cho, 1);

        for isub = 1:size(cho, 1)
            corr_rate{i}(isub) = mean(corr(isub, :));
            reac_time{i}(isub) = median(rtime(isub, :));
        end
        
        i = i + 1;

    end
    
    for j = 1:length(corr_rate)
        mn_corr(j) = mean(corr_rate{j});
        err_corr(j) = std(corr_rate{j})/sqrt(size(corr_rate{j}, 2));
    end

    for j = 1:length(reac_time)
        mn_rt(j) = mean(reac_time{j});
        err_rt(j) = std(reac_time{j})/sqrt(size(reac_time{j}, 2));
    end
    y_label = {'Correct choice rate', 'Reaction times (ms)'};
    y_lim = {[0, 1.07], [0, 3500]};
    for j = [1]
        if j == 1
            mn = mn_corr;
            err = err_corr;
            dd = corr_rate;
        else
            mn = mn_rt;
            err = err_rt;
            dd = reac_time;
        end
        
        b = bar(mn, 'EdgeColor', 'k', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
        b.CData(:, :) = colors(1:n_exp, :, :);
        hold on

        ax1 = gca;
        set(gca, 'XTickLabel', titles);

        ylim(y_lim{j})
        ylabel(y_label{j});
        e = errorbar(mn, err, 'LineStyle', 'none',...
            'LineWidth', 3, 'Color', 'k', 'HandleVisibility','off');
        set(gca, 'Fontsize', 18);

        for j = 1:n_exp

            ax(j) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
                'YAxisLocation','right','Color','none','XColor','k','YColor','k');

            hold(ax(j), 'all');
            nsub = length(dd{j});
            X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
            s = scatter(...
                X + (j-1),...
                dd{j}, 110,...
                'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75,...
                'MarkerEdgeAlpha', 1,...
                'MarkerFaceColor', b.CData(j, :),...
                'MarkerEdgeColor', 'w');
            box off

            set(gca, 'xtick', []);
            set(gca, 'box', 'off');
            set(ax(j), 'box', 'off');

            set(gca, 'ytick', []);
            ylim([0, 1.15]);

            box off
        end
        box off
        uistack(e, 'top');
    end
    
end

function plot_bar_plot_corr_choice_rate_contingencies(...
    d, idx, blue_color_gradient, exp_names)

    i = 1;
    sub = 1;
    nsub = 0;
    colors = blue_color_gradient(2:2:8, :, :);
    
    figure('Position', [1,1,1300,900]);
         
    for exp_name = {exp_names{:}}
        session = [0 , 1];
        
        exp_name = char(exp_name);
     
        [cho, out, cfout, corr, con, p1, p2, rew, rtime] = ...
            DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);
        
        nsub = nsub + size(cho, 1);

        for isub = 1:size(cho, 1)
            for icond = 1:4
                corr_rate(sub, icond) = mean(corr(isub, (con(isub, :) == icond)));
                reac_time(sub, icond) = median(rtime(isub, (con(isub, :) == icond)));

            end
            sub = sub+1;
        end
        i = i + 1;
    end
    
    
    corr_rate = fliplr(corr_rate);
    reac_time = fliplr(reac_time);
    y_label = {'Correct choice rate', 'Reaction times (ms)'};
    y_lim = {[0, 1.07], [0, 3500]};
    dd =  {corr_rate, reac_time};
    for k = [1]
        mn = mean(dd{k}, 1);
        err = std(dd{k}, 1)/sqrt(size(dd{k}, 1));


        b = bar(mn, 'EdgeColor', 'k', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
        b.CData(:, :) = colors;
        hold on

        ax1 = gca;
        set(gca, 'XTickLabel', {'60/40', '70/30','80/20','90/10'});

        ylim(y_lim{k})
        ylabel(y_label{k});
        e = errorbar(mn, err, 'LineStyle', 'none',...
            'LineWidth', 3, 'Color', 'k', 'HandleVisibility','off');
        set(gca, 'Fontsize', 18);

        for j = 1:4
            ax(j) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
                'YAxisLocation','right','Color','none','XColor','k','YColor','k');

            hold(ax(j), 'all');

            X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
            s = scatter(...
                X + (j-1),...
                dd{k}(:, j), 110,...
                'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75,...
                'MarkerEdgeAlpha', 1,...
                'MarkerFaceColor', b.CData(j, :),...
                'MarkerEdgeColor', 'w');
            box off

            set(gca, 'xtick', []);
            set(gca, 'box', 'off');
            set(ax(j), 'box', 'off');

            set(gca, 'ytick', []);

            box off
        end
        box off
        uistack(e, 'top');

        clear corr_rate
        clear reac_time
    end
     
end

