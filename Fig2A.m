%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [1, 2, 3, 4];
modality = 'LE';
color = blue;

displayfig = 'on';

stats_data = table();

% filenames
filename = 'Fig2A';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);


figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)
%subaxis(4,6,1, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0, 'SpacingVert', 0.03);

sub_count = 0;
num = 0;
for exp_num = selected_exp
    clear dd
    num = num + 1;
    
    data = de.extract_LE(exp_num);
    data_ed = de.extract_ED(exp_num);
    
    if exp_num == 4
        data.con(data.con == 2) = 4;
    end
    ncon = length(unique(data.con));
    
    dd = NaN(ncon, data.nsub);
    cons =flip(unique(data.con));
    for i = 1:ncon
        for sub = 1:data.nsub
            dd(i, sub) = mean(data.corr(sub, data.con(sub,:)==cons(i)));          
          
        end
    end
    
    for sub = 1:data.nsub
        s1= mean(data.corr(sub,:));
        s2 = mean(data_ed.corr(sub,:));
        T1 = table(...
            sub+sub_count, exp_num, s1, {'LE'}, ...
            'variablenames',...
            {'subject', 'exp_num', 'score', 'modality'}...
            );
        T2 = table(sub+sub_count, exp_num, s2,{'ED'}, ...
            'variablenames',...
            {'subject', 'exp_num', 'score', 'modality'}...
            );
        
        stats_data = [stats_data; T1; T2];
    end
    
    sub_count = sub_count + sub;
    
    subplot(1, length(selected_exp), num)
    
    if num == 1
        labely = 'Correct choice rate';
    else
        labely = '';
    end
    
    plot([10, 85], [50, 50], 'color', 'k', 'linestyle', ':')
    
    brickplot(...
        dd.*100,... %data
        color.*ones(4, 3),...%color
        [-0.08*100, 1.08*100], fontsize,...%ylim % fontsize
        '',...%title
        '',...%xlabel
        '',...%ylabel
        {'60/40','70/30', '80/20', '90/10'},... %varargin
        0,... %noscatter
        [-10, 105],... %xlim
        [10, 35, 60, 85],... %xvalues
        5, ... %barwidth
        0 ...%median
        );
    
    plot([10, 85], [50, 50], 'color', 'k', 'linestyle', ':')
    xlabel('Symbol pair');
    ylabel(labely);
    
    box off
    hold on
    
    %set(gca, 'ytick', [0:10]./10);
    set(gca,'TickDir','out')
    set(gca, 'fontsize', fontsize);
    
end

writetable(stats_data, stats_filename);

T = stats_data;
cond_ED = strcmp(T.modality, 'ED');
cond_LE = strcmp(T.modality, 'LE');

disp('FULL');
fitlm(T, 'score ~ modality*exp_num')
disp('********************************************');
disp('LE');
fitlm(T(cond_LE,:), 'score ~ exp_num')
disp('********************************************');

disp('ED');
fitlm(T(cond_ED,:), 'score ~ exp_num')
disp('********************************************');


%