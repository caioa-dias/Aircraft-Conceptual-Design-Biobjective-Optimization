%% -------------------------- FUNÇÃO MUTAÇÃO -------------------------- %% 
function pop = GA_MUTATION (pop_size, n_gens, prob_m, pop, cons_max, ...
    cons_min)

% DEFINE O LOOP PARA CADA LINHA / INDIVÍDUO:
for i = 1 : pop_size

    % DEFINE O LOOP PARA CADA COLUNA / GENE:
    for j = 1 : n_gens
        mut = rand;
        
        % SE O NÚMERO GERADO FOR MENOR QUE PROB_M A MUTAÇÃO OCORRE NO GENE:
        if mut <= prob_m
            pop(i,j) = (cons_max(j) - cons_min(j)) .* rand + cons_min(j);
        end
    end
end
