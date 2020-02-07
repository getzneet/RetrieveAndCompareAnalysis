function [corr, con] = sim_exp_learning(...
    exp_name, exp_num, d, idx, sess, nagent, model)
       
    [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    clear corr
    if exp_num < 3
        cfcho = ones(size(cfcho)) .* -2;
    end
    
    data = load(sprintf('data/fit/%s_learning_%d', exp_name, sess));
    parameters = data.data('parameters');
    
    switch model
        case 1
            alpha1 = parameters(1, :, 2);
            beta1 = parameters(1, :, 1);
            
        case 2           
            alpha1 = parameters(2, :, 2);
            alpha2 = parameters(2, :, 3);
            beta1 = parameters(2, :, 1);
    end
    
    nsub = length(alpha1);
    ntrials = length(cho(1, :));
    Q = zeros(nsub*nagent, 4, 2); 
    
    i = 1;
    for agent = 1:nagent

        for sub = 1:nsub
            
            s = con(sub, :);
            cfr = cfout(sub, :);
            r = out(sub, :);
            
            for t = 1:ntrials
                
                pp = softmaxfn(...
                    Q(i, s(t), :).*1+(1- Q(i, s(t), :))*-1, beta1(sub));
                
                a(i,t) = randsample(...
                    [1, 2],... % randomly drawn action 1 or 2
                    1,... % number of element picked
                    true,...% replacement
                    pp... % probabilities
                );
                
                cfa(t) = 3-a(i,t);
                if a(i,t) == cho(t)
                    r = out(t);
                    cfr = cfout(t);
                else
                    r = cfout(t);
                    cfr = out(t);
                end
                
                deltaI = (r==1) - Q(i, s(t), a(i,t));
                cfdeltaI = (cfr==1) - Q(i, s(t), cfa(t));

                switch model
                    case 1
                        Q(i, s(t), a(i,t)) = ...
                            Q(i, s(t), a(i,t)) + alpha1(sub) * deltaI;
                        if cfcho(t) ~= -2
                            Q(i, s(t), cfa(t)) = ...
                                Q(i, s(t), cfa(t)) + alpha1(sub) * cfdeltaI;
                        end
                    case 2
%                         Q(i, s(t), a(i,t)) = ...
%                             Q(i, s(t), a(i,t)) + alpha1(sub) * (deltaI>0)...
%                             + alpha2(sub) * (deltaI;
%                         if cfcho(t) ~= -2
%                             Q(i, s(t), cfa(t)) = ...
%                                 Q(i, s(t), cfa(t)) + alpha1(sub) * cfdeltaI;
%                         end
                        
                end
                                        
                v = [ev1(sub, t), ev2(sub, t)];
                
                corr(i, t) = v(a(i,t)) > v(3-a(i,t));
                
            end
            i = i + 1;
            %clear cfa a
        end
        
    end
    %cont1 = repmat(cont1, 20, 1);
    con = repmat(con, nagent, 1);
    p1 = repmat(p1, nagent, 1);
    p2 = repmat(p2, nagent, 1);
    ev1 = repmat(ev1, nagent, 1);
    ev2 = repmat(ev2, nagent, 1);
end


   
function p = softmaxfn(Q, b)
    p = exp(Q.*b)./ sum(exp(Q.*b));
end


