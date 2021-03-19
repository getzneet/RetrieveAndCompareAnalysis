%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5,6.1,6.2];%, 6.2, 7.1, 7.2];
displayfig = 'on';
colors = [dark_green; dark_blue;  pink; black];
zscored = 0;

num = 0;
%
ed = cell(length(selected_exp),1);
pm = cell(length(selected_exp), 1);
mean_heur = cell(length(selected_exp), 1);
symp = [.1, .2, .3, .4, .6, .7, .8, .9];
lotp = [.1, .2, .3, .4, .6, .7, .8, .9];
 
figure('Units', 'centimeters',...
    'Position', [0,0,5.3*2, 5.3/1.25*2], 'visible', displayfig)
sub_count = 1;
stats_data = table();
for exp_num = selected_exp
    
    num = num + 1;
    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    throw = de.extract_ED(exp_num);
%     symp = unique(throw.p1);
%     lotp = unique(throw.p2);
    
    if zscored
        de.zscore_RT(exp_num);
    end
    
    dd = heuristic(throw);
    heur(sub_count:nsub+sub_count) = mean(dd==throw.cho, 2);
    [sorted, idx] = sort(heur);
    rt(sub_count:nsub+sub_count) = median(data.rtime(idx,:), 2);
    
%     data = de.extract_ED(exp_num);
%    
%     
%     sim_params.de = de;
%     sim_params.sess = sess;
%     sim_params.exp_name = name;
%     sim_params.exp_num = exp_num;
%     sim_params.nsub = nsub;
%     sim_params.model = 1;
%     
%     [Q, tt] = get_qvalues(sim_params);
%     le = argmax_estimate(data, symp, lotp, Q);
    
%     for sub = 1:nsub
%         o_heur(sub+sub_count,1) = median(...
%             data.rtime(sub, logical((...
%                 data.cho(sub,:)== heur(sub,:)) .* (data.cho(sub,:)~=le(sub,:)))));
%         o_le(sub+sub_count,1) = median(...
%             data.rtime(sub,logical((data.cho(sub,:)~= heur(sub,:)) .* (data.cho(sub,:)==le(sub,:)))));
%         
%         none(sub+sub_count,1) = median(...
%             data.rtime(sub,logical((data.cho(sub,:)~=heur(sub,:)).*(data.cho(sub,:)~=le(sub,:)))));
%         both(sub+sub_count,1) = median(...
%             data.rtime(sub,logical((data.cho(sub,:)==heur(sub,:)).*(data.cho(sub,:)==le(sub,:)))));
%         
%         modalities = {'heur', 'le', 'both', 'none'};
%         dd = {o_heur(sub+sub_count,1); o_le(sub+sub_count,1); both(sub+sub_count,1); none(sub+sub_count,1)};
% 
%         for mod_num = 1:4
%                 T1 = table(...
%                     sub+sub_count, exp_num, dd{mod_num},...
%                     {modalities{mod_num}}, 'variablenames',...
%                     {'subject', 'exp_num', 'RT', 'modality'}...
%                     );
%                 stats_data = [stats_data; T1];
%         end
%     end
%     
    sub_count = sub_count + sub;
    
  
end
return

if zscored
    y1 = -3;
    y2 = 1;
else
    y1 = 0;
    y2 = 6500;
end
x1 = o_heur;
x2 = o_le;
x3 = both;
x4 = none;

labely = 'Median RT per subject';


skylineplot({x1'; x2'; x3'; x4'}, 5*2,...
    colors,...
    y1,...
    y2,...
    fontsize,...
    '',...
    'Choices exclusively explained by',...
    labely,...
    {'Heuristic', 'LE estimates', 'Both', 'None'},0);
set(gca, 'tickdir', 'out');
box off;

mkdir('fig', 'violinplot');
mkdir('fig/violinplot/', 'RT');
saveas(gcf, 'fig/violinplot/RT/explained.svg');

% save stats file
mkdir('data', 'stats');
stats_filename = 'data/stats/RT_H_LE_BOTH_NONE.csv';
writetable(stats_data, stats_filename);


% ------------------------------------------------------------------------%

function score = heuristic(data)

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




        