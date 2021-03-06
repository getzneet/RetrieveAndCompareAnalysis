function lik = getll(params, s, a, cfa, r, cfr, ev, phase, map, model, fit_counterfactual, ntrials)

beta1 = 1; % choice temperature
alpha1 = 0; % first learning rate
alpha2 = 0; % second learning rate
alpha3 = 0;
pri = 0; % priors applied on Q values t == 1
phi = 0; % perseveration
tau = 0;

% 1: basic df=2
% 2: asymmetric neutral df=3
% 3: asymmetric pessimistic df=3
% 4: priors df=3
% 5: perseveration df=3
% 6: perseveration tau df=4
% 7: full df=5
% 8:

% get parameters depending on the model
switch model
    case 1
        alpha1 = params(2);
        if fit_counterfactual
            alpha3 = params(9);
        end
    case 2
        alpha1 = params(2);
        alpha2 = params(3);
    case 3
        alpha1 = params(2);
        alpha2 = params(3);
        pri = -2;
    case 4
        alpha1 = params(2);
        if fit_counterfactual
            alpha3 = params(9);
        end
        pri = params(4);
    case 5
        alpha1 = params(2);
        if fit_counterfactual
            alpha3 = params(9);
        end
        phi = params(5);
        tau = 1;
    case 6
        alpha1 = params(2);
        if fit_counterfactual
            alpha3 = params(9);
        end
        phi = params(5);
        tau = params(6);
    case 7
        alpha1 = params(2);
        alpha2 = params(3);
        %pri = params(4);
        phi = params(5);
        tau = 1;
    case 8
        alpha1 = params(2);
        alpha2 = params(3);
        %pri = params(4);
        phi = params(5);
        tau = params(6);
    case 9
        % innovation variance
        sig_xi = params(7);
        sig_eps = params(8);
end

% initial previous aice
lik = 0;
ncond = 4;
%ncond = max(s);
Q = zeros(ncond, 2) + pri; %  Q-values
preva = zeros(ncond, 1); % prev action
kg = zeros(ncond, 2); % kalman gain
mu = zeros(ncond, 2); % mean reward of each option
v = zeros(ncond, 2); % variance
c = zeros(max(s), 2); % choicetrace

for t = 1:ntrials
        
    if phase(t) == 1
        lik = lik + (beta1 * Q(s(t), a(t))) + (phi * c(s(t), a(t)))...
            - log([...
            exp((beta1 * Q(s(t), 1)) + (phi * c(s(t), 1)))...
            + exp((beta1 * Q(s(t), 2)) + (phi * c(s(t), 2)))...
            ]);
    else
        % Get symbol value (learned in phase == 1)
        flat1 = reshape(Q', [], 1);
        % find qvalue using contingency number 
        Q1 = flat1(map(s(t)));
        Q2 = ev(t);
        v = [Q1 Q2];
        lik = lik + (beta1 * v(a(t))) + (phi * c(s(t), a(t)))...
            - log([...
            exp((beta1 * Q1) + (phi * c(s(t), 1)))...
            + exp((beta1 * Q2) + (phi * c(s(t), 2)))...
            ]);
    end
    
    if phase(t) == 1
        % compute PE
        deltaI = r(t) - Q(s(t), a(t));
        if fit_counterfactual
            cfdeltaI = cfr(t) - Q(s(t), cfa(t)); 
        end
        
        switch model
            case {1, 4, 5, 6} % regular learning rule
                Q(s(t), a(t)) = Q(s(t), a(t)) + alpha1 * deltaI;
                if fit_counterfactual
                    Q(s(t), cfa(t)) = Q(s(t), cfa(t)) + alpha3 * cfdeltaI;
                end
            case {2, 3, 7, 8} % asymmetric learning rule
                % update chosen option
                Q(s(t), a(t)) = Q(s(t), a(t)) + alpha1 * deltaI * ...
                    (deltaI > 0) + alpha2 * deltaI * (deltaI < 0);
                if fit_counterfactual
                    % update unchosen option
                    Q(s(t), cfa(t)) = Q(s(t), cfa(t)) + alpha2 * cfdeltaI * ...
                        (cfdeltaI > 0) + alpha1 * cfdeltaI * (cfdeltaI < 0);
                end
            case 9 % Kalman filter
                kg(s(t), a(t)) = (v(s(t), a(t)) + sig_xi)./...
                    (v(s(t), a(t)) + sig_xi + sig_eps);
                mu(s(t), a(t)) = mu(s(t), a(t)) + kg(s(t), a(t)) *...
                    (r(t) - mu(s(t), a(t)));
                v(s(t), a(t)) = (1-kg(s(t), a(t))) * (v(s(t), a(t)) + sig_xi);
            otherwise
                error('Model does not exists');
        end
        c = updatechoicetrace(s, a, c, t, tau);
        
        preva(s(t)) = a(t);  % save the choice
        % for the next round (perseverations)
    end
    
end

%save(Qfilename, Q);
lik = -lik; % LL vector taking into account both the likelihood
end

function c = updatechoicetrace(s, a, c, t, tau)
    c(s(t), 1) =  (1 - tau) * c(s(t), 1) + tau * (a(t) == 1); 
    c(s(t), 2) =  (1 - tau) * c(s(t), 2) + tau * (a(t) == 2); 
end


