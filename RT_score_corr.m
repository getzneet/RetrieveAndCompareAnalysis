%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [1, 2, 3, 4, 5, 6.2];%, 6.2, 7.1, 7.2];
displayfig = 'off';


num = 0;
%
ed = cell(length(selected_exp),1);
pm = cell(length(selected_exp), 1);
mean_heur = cell(length(selected_exp), 1);

for exp_num = selected_exp
    num = num + 1;
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    throw = de.extract_ED(exp_num);
    symp = unique(throw.p1);
    lotp = unique(throw.p2);
    
    heur = heuristic(throw, symp, lotp);
    mean_heur{num} = mean(heur, 2);
   
    %de.zscore_RT(exp_num);
   
    data = de.extract_ED(exp_num);
    
    for i = 1:nsub
            ed{num}(i,1) = -mean(data.rtime(i,:))';          
    end
    
    sim_params.de = de;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.exp_num = exp_num;
    sim_params.nsub = nsub;
    sim_params.model = 1;
    
    [Q, tt] = get_qvalues(sim_params);
    le{num,1} = mean(argmax_estimate(data, symp, lotp, Q),2); 
%    
%              
    sim_params.model = 2;
    [Q, tt] = get_qvalues(sim_params);

    pm{num,1} = mean(argmax_estimate(data, symp, lotp, Q),2); 
    
%     param = load(...
%         sprintf('data/post_test_fitparam_EE_exp_%d_%s',...
%         round(exp_num), num2str(sess)));
%     Q = param.midpoints;
% 
%     ee{num,1} = mean(argmax_estimate(data, symp, lotp, Q),2); 



end
%-------------------------------------------------------------------------%
% fig                                                  %
% ------------------------------------------------------------------------%
x1 = reshape(vertcat(mean_heur{:}), [], 1);
x2 = reshape(vertcat(le{:}), [], 1);
x3 = reshape(vertcat(pm{:}), [], 1);

y = reshape(vertcat(ed{:}), [],1);

figure('Position', [0, 0, 3000, 800], 'visible', 'on');
subplot(1,3, 1)

scatterCorr(x1, y, orange_color, .5, 1, 50, 'w', 0);
xlabel('Heuristic-explained score');
xlim([.2, 1.08])
ylabel('-RT (ms)');
box off
set(gca, 'tickdir', 'out');

subplot(1,3, 2)

scatterCorr(x2, y, blue_color, .5, 1, 50, 'w', 0);
xlabel('LE estimates-explained score');
ylabel('-RT (ms)');
xlim([.2, 1.08])

box off
set(gca, 'tickdir', 'out');

subplot(1,3, 3)

scatterCorr(x3, y, magenta_color, .5, 1, 50, 'white', 0);
xlabel('PM estimates-explained score');
ylabel('-RT (ms)');
xlim([.2, 1.08])

box off
set(gca, 'tickdir', 'out');

% subplot(1,4, 4)
% 
% scatterCorr(x4, y, green_color, .5, 1, 50, 'white', 0);
% xlabel('EE estimates-explained score');
% ylabel('-RT (ms)');
% xlim([0, 1.08])
% 
% box off
% set(gca, 'tickdir', 'out');


suptitle('simulation score predicts -RT (ms)');


function score = heuristic(data, symp,lotp)
    for i = 1:size(data.cho,1)
             count = 0;

        for j = 1:length(symp)
            
            for k = 1:length(lotp)
                count = count + 1;
                actual_choice = data.cho(i, logical(...
                    (data.p1(i,:)==symp(j)).*(data.p2(i,:)==lotp(k))));
                
                if lotp(k) >= .5 
                    prediction = 2;
                else
                    prediction = 1;
                end
                
               score(i, count) = prediction == actual_choice;
               
            end
        end
    end
end


function score = argmax_estimate(data, symp, lotp, values)
    for i = 1:size(data.cho,1)
         count = 0;

        for j = 1:length(symp)
            
            for k = 1:length(lotp)
                count = count + 1;
                actual_choice = data.cho(i, logical(...
                    (data.p1(i,:)==symp(j)).*(data.p2(i,:)==lotp(k))));
                
                if lotp(k) >= values(i,j)
                    prediction = 2;
                else
                    prediction = 1;
                end
                
               score(i, count) = prediction == actual_choice;
            end
        end
    end
end


        