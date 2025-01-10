%% ----------------- SELEÇÃO DOS PAIS - ROULETTE WHEEL ----------------- %% 
function parent = GA_SELECTION (prob)

% GERA UM VALOR ALEATÓRIO ENTRE 0 E 1:
r = rand;

% CALCULA A PROBABILIDADE ACUMULADA DE CADA PAI SER SELECIONADO:
c = cumsum(prob);

% SELECIONA O INDIVÍDUO COM BASE NA PROBABILIDADE ACUMULADA:
parent = find(r <= c, 1, 'first');
end