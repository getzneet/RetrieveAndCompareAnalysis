ev1 = [-.8, -.7, -.6, -.5, .5, .6, .7, .8];
ev2 = [-.4, -.3, -.2, -.1, .1, .2, .3, .4];


count = 1;
for i = 1:length(ev1)
    for j = 1:length(ev2)
        if (ev1(i) ~= ev2(j))
            trials(count, :) = [ev1(i), ev2(j), i, j];
            count = count + 1;
        end
    end
end

% ------------------------------------------------------------------
% Run simulations
%-------------------------------------------------------------------
corr_heuristic = simulate_better_than_zero_heuristic(trials);
disp(mean(corr_heuristic));


% ------------------------------------------------------------------
% Simultion functions
% ------------------------------------------------------------------
function correct = simulate_better_than_zero_heuristic(trials)
for t = 1:length(trials)
    c = [1, 2];
    choice = c(1 + (trials(t, 2) >= .1));
    correct(t) = trials(t, choice) == max(trials(t, 1:2));
end
end