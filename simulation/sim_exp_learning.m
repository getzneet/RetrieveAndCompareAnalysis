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
        case {1, 3}
            alpha1 = parameters{model}(:, 2);
            beta1 = parameters{model}(:, 1);
            
        case 2           
            alpha1 = parameters{2}(:, 2);
            alpha2 = parameters{2}(:, 3);
            beta1 = parameters{2}(:, 1);
    end
    
    nsub = length(alpha1);
    ntrials = length(cho(1, :));
    Q = zeros(nsub*nagent, 4, 2)+.5; 
    
    i = 1;
    for agent = 1:nagent

        for sub = 1:nsub
            
            s = con(sub, :);
%             a = cho(sub, :);
%             cfa = 3-cho(sub, :);
            %flatQ = mean(Q(:, :, :)).*1 + (1- mean(Q(:, :, :)))*-1;
            %alpha1(sub) = 0.5;
            
            for t = 1:ntrials
               
                if model == 3
                    a1 = Q(s(t), 1)*beta1(sub);
                    a2 = -Q(s(t), 1)*beta1(sub);
                    if t == 1
                        pp = [1/(1+exp(-a1)),...
                            1/(1+exp(a2))];
                    else
                        pp = [1/(1+exp(-a1)),...
                            1/(1+exp(-a2))];
                    end
                    disp(pp);
                else
                    pp = softmaxfn(...
                        Q(sub, s(t), :).*1 + (1- Q(sub, s(t), :))*-1,...
                        beta1(sub) ...
                    );
                end
                
                a(t) = randsample(...
                    [1, 2],... % randomly drawn action 1 or 2
                    1,... % number of element picked
                    true,...% replacement
                    pp... % probabilities
                );
                
                cfa(t) = 3-a(t);
                if a(t) == cho(sub, t)
                    r = out(sub, t);
                    cfr = cfout(sub, t);
                else
                    r = cfout(sub, t);
                    cfr = out(sub, t);
                end
              
                if model == 3
                    deltaI = ((r==1) - (cfr==1)) - Q(sub, s(t), 1); 
                else
                    deltaI = (r==1) - Q(sub, s(t), a(t));
                end
                
                if (cfcho(t) ~= -2) && (model ~= 3)
                    cfdeltaI = (cfr==1) - Q(sub, s(t), cfa(t));
                end

                switch model
                    case 1
                        Q(sub, s(t), a(t)) = ...
                            Q(sub, s(t), a(t)) + alpha1(sub) * deltaI;
                        if (cfcho(t) ~= -2) && (model ~= 3)
                            Q(sub, s(t), cfa(t)) = ...
                                Q(sub, s(t), cfa(t)) + alpha1(sub) * cfdeltaI;
                        end
                    case 2
                         Q(sub, s(t), a(t)) = Q(sub, s(t), a(t)) + ...
                         alpha1(sub) * deltaI * (deltaI>0) + ...
                         alpha2(sub) * deltaI * (deltaI<0);
                        if cfcho(t) ~= -2
                            Q(sub, s(t), cfa(t)) = Q(sub, s(t), cfa(t)) + ...
                                alpha2(sub) * cfdeltaI * (cfdeltaI>0) + ...
                                alpha1(sub) * cfdeltaI * (cfdeltaI<0);
                        end
                    case 3
                        
                        Q(sub, s(t), 1) =  Q(sub, s(t), 1) + alpha1(sub) * deltaI;
                        
                end
                                        
                v = [ev1(sub, t), ev2(sub, t)];
                
                corr(sub, t) = v(a(t)) > v(3-a(t));
                
            end
            i = i + 1;
            clear cfa a
        end
        
    end
    
    %cont1 = repmat(cont1, 20, 1);
%     con = repmat(con, nagent, 1);
%     p1 = repmat(p1, nagent, 1);
%     p2 = repmat(p2, nagent, 1);
%     ev1 = repmat(ev1, nagent, 1);
%     ev2 = repmat(ev2, nagent, 1);
end


   
function p = softmaxfn(Q, b)
    p = exp(Q.*b)./ sum(exp(Q.*b));
end


