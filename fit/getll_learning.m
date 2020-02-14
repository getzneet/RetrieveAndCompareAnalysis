function ll = getll_learning(params, s, a, cfa, r, cfr, ntrials, model, fit_cf)
    
    switch model
        case {1, 3}
            beta1 = params(1);
            alpha1 = params(2);
        case 2
            beta1 = params(1);
            alpha1 = params(2);
            alpha2 = params(3);
    end

    ll = 0;
    ncond = length(unique(s));
    Q = zeros(ncond, 2)+.5;
    
    for t = 1:ntrials
        
        
        if model == 3
            v = Q(s(t), 1);
            v = v * (-1 + (a(t) == 1));                                                 
            ll = ll + log(1/(1+(exp(-(v*beta1)))); 
            
            deltaI = ((r(t)==1) - (cfr(t)==1)) - Q(s(t), 1);          

        else
            D(a(t)) = Q(s(t), a(t))*1 + (1-Q(s(t), a(t)))*-1;
            D(3-a(t)) = Q(s(t), 3-a(t))*1 + (1-Q(s(t), 3-a(t)))*-1;
        
            ll = ll + (D(a(t))*beta1) - log(sum(exp(D(:).*beta1)));
            
            deltaI = (r(t)==1) - Q(s(t), a(t));
            if fit_cf
                cfdeltaI = (cfr(t)==1) - Q(s(t), cfa(t));                       
            end

        end
   
        switch model 
            case 1
                Q(s(t), a(t)) = Q(s(t), a(t)) + alpha1 * deltaI;
                if fit_cf
                    Q(s(t), cfa(t)) = Q(s(t), cfa(t)) + alpha1 * cfdeltaI;
                end
            case 2
               Q(s(t), a(t)) = Q(s(t), a(t)) + alpha1 * deltaI * ...
                        (deltaI > 0) + alpha2 * deltaI * (deltaI < 0);
                if fit_cf
                    Q(s(t), cfa(t)) = Q(s(t), cfa(t)) + ...
                        alpha2 * cfdeltaI * (cfdeltaI > 0) + ...
                        alpha1 * cfdeltaI * (cfdeltaI < 0);
                end
            case 3
               Q(s(t), 1) = Q(s(t), 1) + alpha1 * deltaI;

        end
        
            
    end

ll = -ll;
end
