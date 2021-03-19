%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5,6];%, 6.2, 7.1, 7.2];
displayfig = 'on';
colors = [orange; orange; green];
zscored = 0;

stats_data = table();

num = 0;

lotp = [0, .1, .2, .3, .4, .5,.6, .7, .8, .9, 1];
sub_count = 0;
for exp_num = selected_exp
    
    num = num + 1;
    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    data_ed = de.extract_ED(exp_num);
    data_ee = de.extract_EE(exp_num);
    
    for sub = 1:nsub
        mask_lot = (ismember(data_ed.p2(sub,:), lotp));
        mask_cho1 = (data_ed.cho(sub,:)==1);
        mask_cho2 = (data_ed.cho(sub,:)==2);
        e(sub+sub_count,1) = median(data_ed.rtime(sub, logical(mask_lot.*mask_cho1)));
        d(sub+sub_count,1) = median(data_ed.rtime(sub, logical(mask_lot.*mask_cho2)));

        ee(sub+sub_count,1) = median(data_ee.rtime(sub,:));
        
        modalities = {'e', 'd', 'EE'};
        dd = {e(sub+sub_count,1); d(sub+sub_count,1); ee(sub+sub_count,1)};
        
        for mod_num = 1:3
            T1 = table(...
                sub+sub_count, exp_num, dd{mod_num},...
                {modalities{mod_num}}, 'variablenames',...
                {'subject', 'exp_num', 'RT', 'modality'}...
                );
            stats_data = [stats_data; T1];
        end
    end
    
    sub_count = sub_count + sub;

end

figure('Units', 'centimeters',...
    'Position', [0,0,5.3*2, 5.3/1.25*2], 'visible', displayfig)

if zscored
    y1 = -3;
    y2 = 1;
else
    y1 = 0;
    y2 = 6500;
end


x1 = e';
x2 = d';
x3 = ee';

labely = 'Median reaction time per subject';
    
skylineplot({x1; x2; x3}, 5*2,...
    colors,...
    y1,...
    y2,...
    fontsize,...
    '',...
    '',...
    labely,...
    {'ED_{e}', 'ED_{d}', 'EE'});

set(gca, 'tickdir', 'out');
box off;


mkdir('fig', 'violinplot');
mkdir('fig/violinplot/', 'RT');
saveas(gcf, 'fig/violinplot/RT/RT.svg');

% save stats file
mkdir('data', 'stats');
stats_filename = 'data/stats/RT_E_D_EE.csv';
writetable(stats_data, stats_filename);

% ------------------------------------------------------------------------%

function score = heuristic(data, symp,lotp)

for sub = 1:size(data.cho,1)
    count = 0;
    
    for t = 1:size(data.cho,2)
        
        count = count + 1;
        
        if data.p2(sub,t) >= .5
            prediction = 2;
        else
            prediction = 1;
        end
        
        score(sub, count) = prediction;
        
    end
end
end


function score = argmax_estimate(data, symp, lotp, values)
for sub = 1:size(data.cho,1)
    count = 0;
    
    for t = 1:size(data.cho,2)
        
        count = count + 1;
        
        if data.p2(sub,t) >= values(sub, symp==data.p1(sub,t))
            prediction = 2;
        else
            prediction = 1;
        end
        
        score(sub, count) = prediction;
        
    end
end
end




        