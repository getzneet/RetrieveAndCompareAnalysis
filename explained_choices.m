%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [6, 8];%, 6.2, 7.1, 7.2];
displayfig = 'on';
colors = [dark_green; dark_blue; pink; black];

num = 0;

figure('Units', 'centimeters',...
    'Position', [0,0,5.3*2, 5.3/1.25*2], 'visible', displayfig)

sub_count = 0;
stats_data = table();

for exp_num = selected_exp
    num = num + 1;
    
    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    data = de.extract_ED(exp_num);
    symp = unique(data.p1(1,:));
 
    heur = heuristic(data);
    le = [];
    
    
    % get le q values estimates
    for i = 1:length(sess)
        sim_params.de = de;
        sim_params.sess = sess(i);
        sim_params.exp_name = name;
        sim_params.exp_num = exp_num;
        sim_params.nsub = nsub;
        sim_params.model = 1;
        
        if length(sess) == 2
            d = de.extract_ED(...
                str2num(sprintf('%d.%d', exp_num, sess(i)+1)));
        else
            d = data;
        end
        
        [Q, tt] = get_qvalues(sim_params);

        le = [le argmax_estimate(d, symp, Q)];
        
    end
    
    o_heur = nan(nsub, 1);
    o_le = nan(nsub, 1);
    none = nan(nsub, 1);
    both = nan(nsub, 1);
    
    for sub = 1:nsub
        o_heur(sub,1) = mean(...
            logical((data.cho(sub,:)==heur(sub,:)) .* (data.cho(sub,:)~=le(sub,:))));
        o_le(sub,1) = mean(...
            logical((data.cho(sub,:)~=heur(sub,:)) .* (data.cho(sub,:)==le(sub,:))));
        
        none(sub,1) = mean(...
            logical((data.cho(sub,:)~=heur(sub,:)).*(data.cho(sub,:)~=le(sub,:))));
        both(sub,1) = mean(...
            logical((data.cho(sub,:)==heur(sub,:)).*(data.cho(sub,:)==le(sub,:))));
        
%         for mod_num = 1:4
%                 T1 = table(...
%                     sub+sub_count, exp_num, dd{mod_num},...
%                     {modalities{mod_num}}, 'variablenames',...
%                     {'subject', 'exp_num', 'score', 'modality'}...
%                     );
%                 stats_data = [stats_data; T1];
%         end
    end

    dd(num, :) = [mean(o_heur), mean(o_le), mean(both), mean(none)];    
  
end


b = bar(dd, 'stacked', 'facecolor','flat', 'edgecolor', 'w');

for i = 1:4
    b(i).CData = colors(i,:);
end
set(gca, 'tickdir', 'out');
set(gca, 'fontsize', fontsize)
box off;

% mkdir('fig', 'violinplot');
% mkdir('fig/violinplot/', 'RT');
% saveas(gcf, 'fig/violinplot/RT/explained.svg');
% 
% % save stats file
% mkdir('data', 'stats');
% stats_filename = 'data/stats/RT_H_LE_BOTH_NONE.csv';
% writetable(stats_data, stats_filename);


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


function score = argmax_estimate(data, symp, values)
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




        