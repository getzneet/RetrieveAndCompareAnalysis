close all
clear all

addpath './'
addpath './plot'

%------------------------------------------------------------------------
% Set parameters
%------------------------------------------------------------------------
conf = 'block';
feedback = 'complete_mixed';
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


[corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
    DataExtraction.extract_elicitation_data(data, sub_ids, exp, 0);


% ----------------------------------------------------------------------
% Compute for each symbol p of chosing depending on described cue value
% ------------------------------------------------------------------------
pcue = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
psym = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];
chose_symbol = zeros(size(cho, 1), length(pcue), length(psym));
for i = 1:size(cho, 1)
    for j = 1:length(pcue)
        for k = 1:length(psym)
            temp = ...
                cho(...
                    i,...
                    logical((p2(i, :) == pcue(j)) .* (p1(i, :) == psym(k))));
            chose_symbol(i, j, k) = temp == 1;
        end
    end
end

% ----------------------------------------------------------------------
% PLOT P(learnt value) vs Described Cue
% ------------------------------------------------------------------------

X = reshape(...
        repmat(pcue, nsub, 1), [], 1....
    );
pp = zeros(length(psym), length(pcue));

for i = 1:length(psym)
    Y = reshape(chose_symbol(:, :, i), [], 1);
    [logitCoef, dev] = glmfit(...
        X, Y, 'binomial','logit');
    pp(i, :) = glmval(logitCoef, pcue', 'logit');
    lin = plot(pcue',  pp(i, :));
    ind_point(i) = interp1(lin.XData, lin.YData, 0.5);
end
figure
y = linspace(0, 1, 10);
x = linspace(.1, .8, 10);
plot(x, y, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.8,...
    'HandleVisibility','off');
hold on
plot([1:8]./10, ind_point, 'LineWidth', 2);

% hold on
% for sub = 1:nsub
%     
%     lin2 = plot(linspace(0, 1, 8), ind_point(sub,:), 'Color', blue_color, 'LineWidth', 2.5);
%     lin2.Color(4) = 0.5;
%     
% end
% 
