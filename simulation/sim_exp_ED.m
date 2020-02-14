function [a, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(exp_num, exp_name, d, idx, sess, varargin, model)
    
    %[a, out, con, p1, p2, ev1, ev2, Q] = sim_exp_learning(exp_name, d, idx, sess);
    
   [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    ntrials = size(cho, 2);

    if model == 4
       [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
                DataExtraction.extract_estimated_probability_post_test(...
                d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);

        for sub = 1:size(cho, 1)
            i = 1;      

            for p = unique(p1)'
                Q(sub, i) = cho(sub, (p1(sub, :) == p))./100;
                i = i + 1;          
            end
        end
    else
        [Q, params] = get_qvalues(...
            exp_name, sess, cho, cfcho, con, out, cfout, ntrials, (exp_num>2), model);
        Q = sort_Q(Q);
    end
    
    
    clear cho cfcho out cfout corr con p1 p2 rew rtime ev1 ev2 i
  
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    nsub = d.(exp_name).nsub;
    ntrials = size(cho, 2);
%     for nagent = 1:nagent
    i = 1;  
    for sub = 1:nsub

%        beta1 = params{1}(sub);

        %Qsub(1:4, 1:2) = Q(sub, :, :);

        %flatQ = reshape(Qsub', [], 1);
        flatQ = 1.*Q(sub, :)+ -1.*(1-Q(sub,:));
        %flatQ = 1.*Q+ -1.*(1-Q);

        %flatQ = flatQ .* (1-lambda_desc);
        s2 = ev2(sub, :);
        p_range = 1:length(unique(p1));

        for t = 1:ntrials

            what_sym = p_range(p1(sub, t)==unique(p1));
            v = [flatQ(what_sym), s2(t)];
            [throw, a(sub, t)] = max(v);
            %
            %                  pp = softmaxfn(v, beta1);
            % %
            %                 a(sub, t) = randsample(...
            %                     [1, 2],... % randomly drawn action 1 or 2
            %                     1,... % number of element picked
            %                     true,...% replacement
            %                     pp... % probabilities
            %                 );
            %

        end
        i = i + 1;
    end
        
%     end
%     
%     cont1 = repmat(cont1, 20, 1);
%     cont2 = repmat(cont2, nagent, 1);
%     p1 = repmat(p1, nagent, 1);
%     p2 = repmat(p2, nagent, 1);
%     ev1 = repmat(ev1, nagent, 1);
%     ev2 = repmat(ev2, nagent, 1);

end


   
function p = softmaxfn(Q, b)
    p = exp(Q.*b)./ sum(exp(Q.*b));
end


