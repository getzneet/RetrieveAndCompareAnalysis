clear all
close all

init;

titles = {'Exp. 6', 'Exp. 7'};
exp_num = 1;

%sub_plot = [1, 3, 2, 4];


for f = {filenames{[6,7]}}
    
    figure(...
    'Position', [961, 1, 900, 550],...
    'visible', displayfig)

    %subplot(2, 1, 1);
    session = [0, 1];
    name = char(f);
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_amb_post_test(data, sub_ids, idx, session);
    
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    pcue = unique(p2)';
    psym = unique(p1)';
    for i = 1:size(cho, 1)
        for j = 1:length(pcue)
            temp = cho(i, logical((p1(i, :) == psym(j))));
            
            chose_symbol(i, j, :) = temp == 1;
        end
    end
    
    
    nsub = size(cho, 1);
    % ----------------------------------------------------------------------
    % PLOT P(learnt value) vs Described Cue
    % ------------------------------------------------------------------------
    
    k = 1:nsub;
    
    temp1 = cho(k, :);
    for l = 1:length(psym)
        temp = temp1(...
            logical((p1(k, :) == psym(l))...
            ));
        prop(l) = mean(temp == 1);
    end
    
    X = reshape(...
        repmat(psym, size(k, 2), 4), [], 1....
        );
    Y = reshape(chose_symbol(k, :, :), [], 1);
    [logitCoef, dev] = glmfit(...
        X, Y, 'binomial','logit');
    pp = glmval(logitCoef, pcue', 'logit');
    
    lin1 = plot(...
        linspace(0, 1, 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    hold on
    
    lin3 = plot(...
        pcue,  pp,... %'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
        'Color', green_color, 'LineWidth', 3 ...
        );
    
    
    %lin3.Color(4) = 0.7;
    hold on
    sc1 = scatter(pcue, prop, 180,...
        'MarkerEdgeColor', 'w',...
        'MarkerFaceColor', green_color, 'MarkerFaceAlpha', 0.6);
    
    %s.MarkerFaceAlpha = alpha(i);
    
    hold on
    ind_point = interp1(lin3.YData, lin3.XData, 0.5);
    
    sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
        'MarkerEdgeColor', 'w');
    
    %sc2.MarkerFaceAlpha = alpha(i);
    
    ylabel('P(choose experienced cue)', 'FontSize', 26);
    
    xlabel('Experienced cue win probability', 'FontSize', 26);
    
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    text(ind_point + (0.05), .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
    
    box off
    set(gca, 'Fontsize', 16);
    set(gca,'TickDir','out')
    title(titles{exp_num});
    
    mkdir('fig/exp', 'ambiguity_curves');
    saveas(gcf, sprintf('fig/exp/ambiguity_curves/symbol_exp_%d.png', exp_num));

    
    %subplot(2, 1, 2);
    
    figure(...
    'Position', [961, 1, 900, 550],...
    'visible', displayfig)
    
    name = char(f);
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_lot_vs_amb_post_test(data, sub_ids, idx, session);
    
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    clear chose_symbol
    clear pp
    clear prop
    pcue = unique(p2)';
    psym = unique(p1)';
    for i = 1:size(cho, 1)
        for j = 1:length(pcue)
            temp = cho(i, logical((p1(i, :) == psym(j))));
            chose_symbol(i, j, :) = temp == 1;
        end
    end
    
    nsub = size(cho, 1);
    % ----------------------------------------------------------------------
    % PLOT P(learnt value) vs Described Cue
    % ------------------------------------------------------------------------
    
    k = 1:nsub;
    
    temp1 = cho(k, :);
    for l = 1:length(psym)
        temp = temp1(...
            logical((p1(k, :) == psym(l))...
            ));
        prop(l) = mean(temp == 1);
    end
    
    X = reshape(...
        repmat(psym, size(k, 2), 4), [], 1....
        );
    Y = reshape(chose_symbol(k, :, :), [], 1);
    
    [logitCoef, dev] = glmfit(...
        X, Y, 'binomial','logit');
    pp = glmval(logitCoef, pcue', 'logit');
    
    lin1 = plot(...
        linspace(0, 1, 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    hold on
    
    lin3 = plot(...
        pcue,  pp,... %'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
        'Color', green_color, 'LineWidth', 3 ...
        );
    
    
    hold on
    sc1 = scatter(pcue, prop, 180,...
        'MarkerEdgeColor', 'w',...
        'MarkerFaceColor', green_color, 'MarkerFaceAlpha', 0.6);
    
    
    hold on
    ind_point = interp1(lin3.YData, lin3.XData, 0.5);
    
    sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
        'MarkerEdgeColor', 'w');
    
    %sc2.MarkerFaceAlpha = alpha(i);
    
    ylabel('P(choose described cue)', 'FontSize', 26);
    
    xlabel('Described cue win probability', 'FontSize', 26);
    
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    text(ind_point + (0.05), .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
    
    box off
    set(gca, 'Fontsize', 16);
    
    clear chose_symbol
    clear pp
    clear prop
    set(gca,'TickDir','out')
    title(titles{exp_num});

    saveas(gcf, sprintf('fig/exp/ambiguity_curves/lottery_exp_%d.png', exp_num));
    
    exp_num = exp_num + 1;


end



function plot_fitted_values_all(d, idx, fit_folder, orange_color, blue_color, exp_names)

    i = 1;

    figure('Position', [1,1,1920,1090]);
    titles = {'Exp. 4', 'Exp. 5 Sess. 1', 'Exp. 5 Sess. 2'};

    for exp_name = {exp_names{:} exp_names{end}}
        if i == 3
            session = 1;
            to_add = '_sess_2';
        else
            session = 0;
            to_add = '_sess_1';
        end
        subplot(2, 3, i);
        exp_name = char(exp_name);
        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_sym_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);

        % set ntrials
        ntrials = size(cho, 2);
        subjecttot = length(d.(exp_name).sub_ids);
        nz = [8, 1];
        cont1(ismember(cont1, [6, 7, 8, 9])) = ...
            cont1(ismember(cont1, [6, 7, 8, 9]))-1;
        cont2(ismember(cont2, [6, 7, 8, 9])) = ...
            cont2(ismember(cont2, [6, 7, 8, 9]))-1;

        [parameters, ll] = runfit(...
            subjecttot,...
            cont1,...
            cont2,...
            cho,...
            ntrials,...
            nz,...
            fit_folder,...
            sprintf('%s%s%s', exp_name, '_exp_vs_exp', to_add));

        ev = [-0.8, -0.6, -0.4, -0.2, 0.2, 0.4, 0.6, 0.8];

        Y1 = parameters(:, 1:8)';

        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);

        % set ntrials
        ntrials = size(cho, 2);
        subjecttot = length(d.(exp_name).sub_ids);
        nz = [8, 1];
        cont1(ismember(cont1, [6, 7, 8, 9])) = ...
            cont1(ismember(cont1, [6, 7, 8, 9]))-1;
        cont2 = ev2;

        [parameters, ll] = runfit(...
            subjecttot,...
            cont1,...
            cont2,...
            cho,...
            ntrials,...
            nz,...
            fit_folder,...
            sprintf('%s%s%s', exp_name, '_desc_vs_exp', to_add));

        Y2 = parameters(: , 1:8)';

        %x = linspace(min(xlim), max(yl), 10);
        brick_comparison_plot(...
            Y1,...
            Y2,...
            blue_color,...
            orange_color,...
            [-1, 1], 11,...
            titles{i},...
            'Symbol Expected Value',...
            'Fitted value', ev, 1);

        hold on

        yline(0, 'LineStyle', ':', 'LineWidth', 2);
        hold on

        x_lim = get(gca, 'XLim');
        y_lim = get(gca, 'YLim');

        x = linspace(x_lim(1), x_lim(2), 10);

        y = linspace(y_lim(1), y_lim(2), 10);
        plot(x, y, 'LineStyle', '--', 'Color', 'k');
        hold on


        for sub = 1:subjecttot
            X = ev;
            Y = Y1(:, sub);
            [r(1, i, sub, :), thrw1, thrw2] = glmfit(X, Y);
            b = glmfit(1:length(ev), Y);
            pY1(sub, :) = glmval(b, 1:length(ev), 'identity');
            X = ev;
            Y = Y2(:, sub);
            [r(2, i, sub, :), thrw1, thrw2] = glmfit(X, Y);
            b = glmfit(1:length(ev), Y);
            pY2(sub, :) = glmval(b, 1:length(ev), 'identity');
        end

        mn1 = mean(pY1, 1);
        mn2 = mean(pY2, 1);
        err1 = std(pY1, 1)./sqrt(subjecttot);
        err2 = std(pY2, 1)./sqrt(subjecttot);

        curveSup1 = (mn1 + err1);
        curveSup2 = (mn2 + err2);
        curveInf1 = (mn1 - err1);
        curveInf2 = (mn2 -err2);

        plot(1:length(ev), mn1, 'LineWidth', 1.7, 'Color', blue_color);
        hold on
        plot(1:length(ev), mn2, 'LineWidth', 1.7, 'Color', orange_color);
        hold on
        fill([(1:length(ev))'; flipud((1:length(ev))')], [curveInf1'; flipud(curveSup1')],...
            blue_color, ...
            'lineWidth', 1, ...
            'LineStyle', 'none',...
            'Facecolor', blue_color, ...
            'Facealpha', 0.55);
        hold on
        fill([(1:length(ev))'; flipud((1:length(ev))')],[curveInf2'; flipud(curveSup2')],...
            orange_color, ...
            'lineWidth', 1, ...
            'LineStyle', 'none',...
            'Facecolor', orange_color, ...
            'Facealpha', 0.55);
        hold on
        i = i + 1;
        box off


    end

    titles2 = {'Intercept', 'Slope'};
    sub_plot = [4, 3];
    for j = 1:2

        subplot(2, 2, sub_plot(j))
        for k = 1:3
            %rsize = reshape(r(:, k, :, j), [size(r, 3), 2]);
            %mn(k, :) = mean(rsize);
            %err(k, :) = std(rsize)./sqrt(size(r, 3));

            dd{k, 1} = reshape(r(2, k, :, j), [], 1);
            dd{k, 2} = reshape(r(1, k, :, j), [], 1);
            
            mn(k, 1) = mean(dd{k, 1});
            mn(k, 2) = mean(dd{k, 2});
            
            err(k, 1) = std(dd{k, 1})./sqrt(length(dd{k, 1}));
            err(k, 2) = std(dd{k, 2})./sqrt(length(dd{k, 2}));

        end
        
        x = dd{1, 1};
        y = dd{1, 2};
        p = signrank(x,y);
        pp(1) = p;
       
        x = dd{2, 1};
        y = dd{2, 2};
        p = signrank(x,y);
        pp(2) = p;
  
        x = dd{3, 1};
        y = dd{3, 2};
        p = signrank(x,y);
        pp(3) = p;

        %pp = pval_adjust(pp, 'bonferroni');
        for sp = pp 
            if sp < .001
                h = '***';
            elseif sp < .01
                h='**';
            elseif sp < .05
                h ='*';
            else 
                h = 'none';
            end
            fprintf('h=%s, p=%d \n', h, sp);
        end
        fprintf('===================== \n');
        b = bar(mn);% 'EdgeColor', 'w', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
        hold on

        b(1).FaceColor = orange_color;
        b(2).FaceColor = blue_color;
        b(1).FaceAlpha = 0.7;
        b(2).FaceAlpha = 0.7;

        ax1 = gca;
        set(gca, 'XTickLabel', titles);
        ylabel('Value');
        title(titles2{j});
        legend('post-test ED', 'post-test EE',  'Location', 'southeast');
        e1 = errorbar(b(1).XData+b(1).XOffset, mn(:, 1), err(:, 1), 'LineStyle', 'none',...
            'LineWidth', 2, 'Color', 'k', 'HandleVisibility','off');
        hold on
        e2 = errorbar(b(2).XData+b(2).XOffset, mn(:, 2), err(:, 2), 'LineStyle', 'none',...
            'LineWidth', 2, 'Color', 'k', 'HandleVisibility','off');

        box off

        hold on
        ngroups = 3;
        nbars = 2;
        % Calculating the width for each bar group
        groupwidth = min(0.8, nbars/(nbars + 1.5));
        colors = [orange_color; blue_color];
        for b = 1:nbars
            x = (1:ngroups) - groupwidth/2 + (2*b-1) * groupwidth / (2*nbars);
            hold on
            for k = 1:length(x)

                d = reshape(dd{k, b}, [], 1);
                nsub = length(d);

                s = scatter(...
                    x(k).*ones(1, nsub)-Shuffle(linspace(-0.04, 0.04, nsub)),...
                    d',...
                    'MarkerFaceAlpha', 0.65, 'MarkerEdgeAlpha', 1,...
                    'MarkerFaceColor', colors(b, :),...
                    'MarkerEdgeColor', 'w', 'HandleVisibility','off');
            end
        end

        uistack(e1, 'top');
        uistack(e2, 'top');

        %set(gca, 'xtick', []);
        set(gca, 'box', 'off');
        %set(ax(j), 'box', 'off');

        %set(gca, 'ytick', []);
        %ylim([0, 1.15]);

        box off
    end


    saveas(gcf, 'fig/fit/all/fitted_value_exp_4_5.png')

end


function [parameters, ll] = ...
    runfit(subjecttot, cont1, cont2, cho, ntrials, nz, folder, fit_filename)

    try
        disp(sprintf('%s%s', folder, fit_filename));
        data = load(sprintf('%s%s', folder, fit_filename));
        parameters = data.data('parameters');  %% Optimization parameters
        ll = data.data('ll');
        answer = question(...
            'There is already a fit file, would you like to use it or to rerun analyses (the old file will be replaced)',...
            'Use existent fit file', 'Rerun and erase');
        if strcmp(answer, 'Use existent fit file')
            return
        end
    catch
    end
    parameters = zeros(subjecttot, 8);
    ll = zeros(subjecttot, 1);

    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting subject');
    for sub = 1:subjecttot

        waitbar(...
            sub/subjecttot,...  % Compute progression
            w,...
            sprintf('%s%d', 'Fitting subject ', sub)...
            );

        [
            p,...
            l,...
            rep,...
            output,...
            lmbda,...
            grad,...
            hess,...
            ] = fmincon(...
            @(x) qvalues(...
            x,...
            cont1(sub, :),...
            cont2(sub, :),...
            cho(sub, :),...
            nz,...
            ntrials),...
            zeros(8, 1),...
            [], [], [], [],...
            ones(8, 1) .* -1,...
            ones(8, 1),...
            [],...
            options...
            );
        parameters(sub, :) = p;
        ll(sub) = l;

    end
    %% Save the data
    data = containers.Map({'parameters', 'll'},...
        {parameters, ll});
    save(sprintf('%s%s', folder, fit_filename), 'data');
    close(w);

end


