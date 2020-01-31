% -------------------------------------------------------------------%
% This script finds the best fitting Values for each exp             %
% then plots the article figs                                        %
% -------------------------------------------------------------------%
init;

selected_exp = [4.1];

sessions = [0, 1];
fit_counterfactual = 0;
fit_elicitation = 0;

whichmodel = [1, 2];
init_value = {[30, .5], [30, .5, 0, 0]};
lb = {[0.01, 0], [0.01, 0, 0, 0]};
ub = {[100, 1], [100, 1, 1, 1]};

options = optimset(...
    'Algorithm',...
    'interior-point',...
    'Display', 'off',...
    'MaxIter', 10000*5,...
    'MaxFunEval', 10000*5);

folder = 'data/';
fit_folder = 'data/fit/';


models = {'RW', 'Bayesian'};

paramlabels = {
    '\beta', '\alpha_c', };

 nfpm = [2, 4];


for exp_num = selected_exp
     
    idx1 = (exp_num - round(exp_num)) * 10;
    sess = sessions(uint64(idx1));
   
    % load data
    exp_name = char(filenames{round(exp_num)});
    fit_filename = exp_name;

    [cho1, out1, cfout1, corr, con11, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    [corr1, cho2, out2, p1, p2, ev1, ev2, ctch, cont11, cont21, dist, rtime] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
             
    [corr1, cho3, out2, p1, p2, ev1, ev21, ctch, cont12, cont22, dist, rtime] = ...
        DataExtraction.extract_sym_vs_sym_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
               
    % concat
    map = [2 4 6 8 -1 7 5 3 1];

    cho = horzcat(cho1, cho2, cho3);
    cfcho = (cho1 == 1) + 1;
    phase = vertcat(ones(size(con11, 2), 1), ones(size(cont11, 2), 1) .* 2,...
        ones(size(cont12, 2), 1) .* 3);
    
    j = 1;
    for cont = {cont11, cont12, cont22}
        cont = cont{:};
        for sub = 1:size(cont, 1)
            for t = 1:length(cont(sub, :))
                cont(sub, t) = map(cont(sub, t));
            end
        end
        con{j} = cont;
        j = j+1;
     end
            
    con1 = horzcat(con11, con{1}, con{2});
    con2 = horzcat(con11, ev2, con{3});
 
    out = out1;
    cfout = cfout1;
       
    % set ntrials
    ntrials = size(cho, 2);
    
    nmodel = length(whichmodel);
    subjecttot = size(cho, 1);

    nparam = length(paramlabels);
    
    try
        data = load(sprintf('%s%s', fit_folder, fit_filename));
        %lpp = data.data('lpp');
        parameters = data.data('parameters');  %% Optimization parameters
        ll = data.data('ll');
        %hessian = data.data('hessian');
        if  ~exists('answer')
            answer = question(...
                'There is already a fit file, would you like to use it or to rerun analyses (the old file will be replaced)',...
                'Use existent fit file', 'Rerun and erase');
        end
        if strcmp(answer, 'Rerun and erase')
            [parameters, ll] = runfit(...
                subjecttot,...
                nparam,...
                nmodel,...
                whichmodel,...
                con1,...
                con2,...
                cho,...
                cfcho,...
                out,...
                cfout,...
                phase,...
                ntrials,...
                fit_folder,...
                fit_filename);
        end
    catch
        [parameters, ll] = runfit(...
            subjecttot,...
            nparam,...
            nmodel,...
            whichmodel,...
            con1,...
            con2,...
            cho,...
            cfcho,...
            out,...
            cfout,...
            phase,...
            ntrials,...
            fit_folder,...
            fit_filename);
        
    end
    
    
    % --------------------------------------------------------------------
    % MODEL SELECTION PROCEDURE
    % --------------------------------------------------------------------
    % Compute information criteria
    % --------------------------------------------------------------------
    i = 0;
    for n = whichmodel
        bic(n, :) = -2 * -ll(n, :) + nfpm(n) * log(ntrials);
        aic(n, :)= -2 * -ll(n, :) + 2 * nfpm(n);
    end
   
    models = {'RW', 'RW_{degradation}'};
    
    figNames = {'AIC', 'BIC'};
    i = 0;
    for criterium = {aic, bic}
        i = i + 1;
        
        options.modelNames = models{whichmodel};
        options.figName = figNames{i};
        options.DisplayWin = 0;
       
        
        if strcmp('ME', figNames{i})
            [postr, out] = VBA_groupBMC(cell2mat(criterium));
        else
            [postr, out] = VBA_groupBMC(-cell2mat(criterium), options);
        end
        
        post(i, :, :) = postr.r;
        mn(i, :) = mean(postr.r, 2);
        err(i, :) = std(postr.r, 1, 2)/sqrt(size(postr.r, 2));
        eF(i, :) = out.Ef;
    end
    
    % --------------------------------------------------------------------
    % Plot P(M|D)
    % --------------------------------------------------------------------
    
    figure('Renderer', 'painters',...
        'Position', [927,131,726,447], 'visible', 'on')
    
    b = bar(mn, 'EdgeColor', 'w', 'FaceAlpha', 0.55);
    hold on
    ngroups = 2;
    nbars = 2;
    nsub = size(postr.r, 2);
    % Calculating the width for each bar group
    groupwidth = min(0.8, nbars/(nbars + 1.5));
    cc = [0    0.4470    0.7410;
        0.8500    0.3250    0.0980j
        0.9290    0.6940    0.1250];
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        hold on
        for j = 1:length(x)
            s = scatter(...
                x(j).*ones(1, nsub)-Shuffle(linspace(-0.04, 0.04, nsub)),...
                post(j, i, :),...
                'MarkerFaceAlpha', 0.65, 'MarkerEdgeAlpha', 1,...
                'MarkerFaceColor', cc(i, :),...
                'MarkerEdgeColor', 'w', 'HandleVisibility','off');
        end
        errorbar(x, mn(:, i), err(:,i), 'LineStyle', 'none', 'LineWidth',...
            2.5, 'Color', 'k', 'HandleVisibility','off');
    end
    hold off
    ylim([0, 1.08]);
 
    box off
    set(gca, 'XTickLabel', figNames);
    ylabel('p(M|D)');
    set(gca, 'Fontsize', 20);
    
    % --------------------------------------------------------------------
    % Plot parameters
    % --------------------------------------------------------------------
    
    % compute
    pp = {parameters{2, :}};
    for i = 1:subjecttot
        p(i, 1:2) = pp{i}(3:4);
    end
    mn = [mean(p(:, 1)), mean(p(:, 2))];
    err = [std(p)./sqrt(subjecttot)];
    
     
    figure('Renderer', 'painters',...
        'Position', [927,131,726,447], 'visible', 'on')
    
    % ---------------------------------------------------------------- % 
     cc = [
        0.8500    0.3250    0.0980;
        0    0.4470    0.7410;
        0.9290    0.6940    0.1250];
    ci = 1;
    for m = mn       
        b = bar(ci, m, 'EdgeColor', 'w',...
            'FaceAlpha', 0.55, 'FaceColor', cc(ci, :));         
        hold on
        ci = ci + 1;
    end
    % ---------------------------------------------------------------- % 

    ngroups = 2;
    nbars = 1;
    nsub = subjecttot;
    
    % Calculating the width for each bar group
    groupwidth = min(0.8, nbars/(nbars + 1.5));
   
    
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        hold on
        for j = 1:length(x)
            s = scatter(...
                x(j).*ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub)),...
                p(:, j), 130,...
                'MarkerFaceAlpha', 0.65, 'MarkerEdgeAlpha', 1,...
                'MarkerFaceColor', cc(j, :),...
                'MarkerEdgeColor', 'w', 'HandleVisibility','off');
        end
        errorbar(x, mn, err, 'LineStyle', 'none', 'LineWidth', 2.5,...
            'Color', 'k', 'HandleVisibility','off');
    end
    hold off
    ylim([0, 1.08]);
   
    box off
    %xticklabels({'Experience', 'Description'});
    ylabel('\lambda');
    set(gca, 'Fontsize', 20);
end

% --------------------------------1:length(whichmodel)-----------------------------------
% FUNCTIONS USED IN THIS SCRIPT
% --------------------------------------------------------------------
function [parameters,ll] = ...
    runfit(subjecttot, nparam, nmodel, whichmodel, con1, con2, cho, cfcho, out,...
    cfout, phase, ntrials, folder, fit_filename)

     init_value = {[30, .5], [30, .5, 0, 0]};
    lb = {[0.01, 0], [0.01, 0, 0, 0]};
    ub = {[100, 1], [100, 1, 1, 1]};
    
    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting subject');
    
    for nsub = 1:subjecttot
        
        waitbar(...
            nsub/subjecttot,...  % Compute progression
            w,...
            sprintf('%s%d', 'Fitting subject ', nsub)...
            );
        
        for model = whichmodel
         
            
            [
                p1,...
                l1,...
                rep1,...
                grad1,...
                hess1,...
            ] = fmincon(...
                @(x) getll(...
                    x,...
                    con1(nsub, :),...
                    con2(nsub, :),...
                    cho(nsub, :),...
                    cfcho(nsub, :),...
                    out(nsub, :),...
                    cfout(nsub, :),...
                    phase,...
                    model, ntrials),...
                init_value{model},...
                [], [], [], [],...
                lb{model},...
                ub{model},...
                [],...
                options...
                );
            parameters{model, nsub} = p1;
            ll(model, nsub) = l1;

        end
    end
%     % Save the data
%     data = containers.Map({'parameters', 'll'},...
%         {parameters, ll});
%     save(sprintf('%s%s', folder, fit_filename), 'data');
    close(w);
    
end

% --------------------------------------------------------------------



function barplot_model_comparison(post) 
    nsub = size(post, 3);
    for i = 1:size(post, 2)
        means(:,i) = mean(y(i, :));
        errors(i) = sem(y(i, :));
       % param_labels{i} = labels{param_idx(i)};
    end

    b = bar(means, 'EdgeColor', 'w');
    hold on
    e = errorbar(means, errors, 'Color', 'black', 'LineWidth', 2, 'LineStyle', 'none');
    %hold off
    box off
    
    
    set(gca, 'FontSize', 20);
    
    %xticklabels(param_labels);

    title(ttl);
    ax1 = gca;

    for i = 1:length(means)   

        ax(i) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
         'YAxisLocation','right','Color','none','XColor','k','YColor','k');
          
        hold(ax(i), 'all');
        
        X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
        s = scatter(...
            X + (i-1),...
            y(i, :),...
             'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75, 'MarkerEdgeAlpha', 1,...
             'MarkerFaceColor', colors(i, :),...
             'MarkerEdgeColor', 'w');
        set(gca, 'xtick', []);
        set(gca, 'box', 'off');
        set(ax(i), 'box', 'off');
        
        set(gca, 'ytick', []);
        box off
    end
    uistack(e, 'top');
    box off;
end

