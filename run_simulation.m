% --------------------------------------------------------------------
% This function simulates the task using heuristic vs fitted values
% --------------------------------------------------------------------
function [corr_heuristic, corr1, corr2] = run_simulation()

    %--------------------------------------------------------------------
    % Set parameters
    %--------------------------------------------------------------------

    % filenames and folders
    filenames = {
        'block_complete_mixed_exp_vs_exp_sess_1',...
        'block_complete_mixed_desc_vs_exp_sess_1',...
        'block_complete_mixed_2s_exp_vs_exp_sess_1', ...
        'block_complete_mixed_2s_desc_vs_exp_sess_1', ...
        'block_complete_mixed_2s_amb_exp_vs_exp_sess_1', ...
         'block_complete_mixed_2s_amb_desc_vs_exp_sess_1' ...
        'block_complete_mixed_2s_exp_vs_exp_sess_2', ...
        'block_complete_mixed_2s_desc_vs_exp_sess_2', ...
         'block_complete_mixed_2s_amb_exp_vs_exp_sess_2', ...
         'block_complete_mixed_2s_amb_desc_vs_exp_sess_2' ...
        };
    fit_folder = 'data/fit/qvalues/';
    
    %--------------------------------------------------------------------
    % Generate trials
    %----------------------------------------------------------------------
    ev = [-.8, -.6, -.4, -.2, .2, .4, .6, .8];
    count = 1;
    for i = 1:length(ev)
        for j = 1:length(ev)
            if (ev(i) ~= ev(j))
                trials(count, :) = [ev(i), ev(j), i, j];
                count = count + 1;
            end
        end
    end
      
    % ------------------------------------------------------------------
    % Run simulations
    %-------------------------------------------------------------------
    corr_heuristic = simulate_better_than_zero_heuristic(trials);
    
    count = 1;
    for i = [1, 3, 5]
        f = char(filenames{i});
        corr1{count} = simulate_exp_vs_exp_using_fitted_values(trials, fit_folder, f);
        count = count + 1;
    end
    %corr1 = containers.Map({filenames{[1, 3, 5]}}, corr1);
    count = 1;

    for i = [1, 3, 5]
        f = char(filenames{i});
        corr2{count} = simulate_desc_vs_exp_using_fitted_values(trials, fit_folder, f);
        count = count + 1;
    end
   
        
    % ------------------------------------------------------------------
    % Simultion functions
    % ------------------------------------------------------------------
    function correct = simulate_better_than_zero_heuristic(trials)
        for t = 1:length(trials)
            c = [1, 2];
            choice = c(1 + (trials(t, 2) >= .2));
            correct(t) = trials(t, choice) == max(trials(t, 1:2)); 
        end
    end

    function correct = simulate_exp_vs_exp_using_fitted_values(trials, folder, file)
        data = load(sprintf('%s%s', folder, file));
        values = data.data('parameters');%% fitted_values
        values = mean(values);
        for t = 1:length(trials)
                [throw, choice] = max(values(trials(t, 3:4)));
                correct(t) = trials(t, choice) == max(trials(t, 1:2));
            
        end
        
    end

    function correct = simulate_desc_vs_exp_using_fitted_values(trials, folder, file)
        data = load(sprintf('%s%s', folder, file));
        values = data.data('parameters');
        values = mean(values);
        for t = 1:length(trials)
                [throw, choice] = max([values(trials(t, 3)), trials(t, 2)]);
                correct(t) = trials(t, choice) == max(trials(t, 1:2));
            
        end
    end


end