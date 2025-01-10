%% ------------------------- FUNÇÃO CROSSOVER ------------------------- %% 
function [c1, c2] = GA_CROSSOVER (prob, n_gens, population, cons_max,...
    cons_min, prob_c)

% DEFINE SE O CROSSOVER IRÁ OCORRER OU NÃO:
cross = rand;

% DEFINE A POSIÇÃO DOS DOIS PAIS NA POPULAÇÃO:
p1 = GA_SELECTION(prob);
p2 = GA_SELECTION(prob);

% CASO O CROSSOVER OCORRA:
if cross <= prob_c
    % GERA A MATRIZ DE COEFICIENTES BETA ALEATÓRIOS:
    beta = rand(1, n_gens);
    
    % DEFINE OS DOIS FILHOS:
    c1 = beta .* population(p1,:)+(1 - beta) .* population(p2,:);
    c2 = beta .* population(p2,:)+(1 - beta) .* population(p1,:);
    
    % VERIFICA SE OS FILHOS ULTRAPASSAM OS LIMITES ESTABELECIDOS:
    c1 = min(c1, cons_max);
    c1 = max(c1, cons_min);
    c2 = min(c2, cons_max);
    c2 = max(c2, cons_min);

% CASO O CROSSOVER NÃO OCORRA:
elseif cross > prob_c
    % OS PAIS SÃO PROPAGADOS PARA A PRÓXIMA GERAÇÃO:
    c1 = population(p1,:);
    c2 = population(p2,:);

end