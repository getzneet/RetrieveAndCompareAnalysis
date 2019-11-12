function lik = qvalues(params, s1, s2, a, nz, ntrials)

Q = reshape(params, nz);
lik = 0;

for t = 1:ntrials
    
    if isnan(s2(t))
        lik = lik + Q(s(t), a(t))- log(sum(exp(Q(s(t), :))));
        
    elseif length(unique(s1)) == length(unique(s2))
        choice = [Q(s2(t)), Q(s1(t))];
        value = choice((a(t) == 1) + 1);
        lik = lik + value - log(sum(exp(choice)));

    else
        choice = [s2(t), Q(s1(t))];
        value = choice((a(t) == 1) + 1);
        lik = lik + value - log(sum(exp(choice)));
    end
    
end

lik = -lik; % LL vector taking into account both the likelihood
end

