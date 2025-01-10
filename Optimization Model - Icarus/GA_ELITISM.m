%% ------------------ ALGORITMO GENÉTICO - ELITISMO ------------------ %% 
function [GENETIC_OUTPUTS] = GA_ELITISM(INPUT, GENETIC_PARAMETERS)

cons = GENETIC_PARAMETERS.cons;
max_generations = GENETIC_PARAMETERS.max_generations;
pop_size = GENETIC_PARAMETERS.pop_size;
prob_crossover = GENETIC_PARAMETERS.prob_crossover;
prob_mutation = GENETIC_PARAMETERS.prob_mutation;
elitism_preservation = GENETIC_PARAMETERS.elitism_preservation;

%% HIPERPARÂMETROS DO MODELO

% DEFINE OS LIMITES PARA CADA VARIÁVEL:
cons_min = cons(:,1)';
cons_max = cons(:,2)';

% DEFINE OS PARÂMETROS DO MODELO:
n_gens = length(cons);

% DEFINE LISTAS IMPORTANTES:
best_solutions = zeros(pop_size, n_gens);
best_fitnesses = zeros(1, max_generations);
mean_fitnesses = zeros(1, max_generations);
std_fitnesses = zeros(1, max_generations);
all_solutions = [];

%% POPULAÇÃO INICIAL -> MIJARLILI

% CRIA PRIMEIRA POPULAÇÃO:
population = (repmat(cons_max, pop_size, 1) - repmat(cons_min, pop_size, 1)) ...
    .* rand(pop_size, n_gens) + repmat(cons_min, pop_size, 1);

% AVALIA A PRIMEIRA POPULAÇÃO:
[fitness] = GA_FITNESS (INPUT, pop_size, population);

% ARMAZENA A MAIOR AVALIAÇÃO E SUA POSIÇÃO:
[best_fitness, i] = max(fitness);

% ARMAZENA O INDIVÍDUO DE MAIOR AVALIAÇÃO:
solution_indv = population(i,:);
solution_fitness = best_fitness;


for iter = 1 : max_generations
    %% SELEÇÃO DOS PAIS -> RODA DA FORTUNA
    
    % DEFINE A PROBABILIDADE ACUMULADA DE CADA INDIVÍDUO:
    prob = zeros(pop_size, 1);
    
    fitness_pad = fitness ./ (1+fitness);
    
    for i = 1 : pop_size
        prob(i) = fitness_pad(i) / sum(fitness_pad);
    end
    
    
    %% CROSSOVER -> RECOMBINAÇÃO
    
    % DEFINE AS MATRIZES QUE IRÃO COMPORTAR OS FILHOS:
    c1 = zeros(pop_size/2, n_gens);
    c2 = zeros(pop_size/2, n_gens);
    
    % GERA A PRÓXIMA GERAÇÃO:
    for i = 1 : pop_size/2
        [c1(i,:), c2(i,:)] = GA_CROSSOVER (prob, n_gens, population, cons_max, cons_min, prob_crossover);
    end
    
    % ARMAZENA OS INDIVÍDUOS GERADOS PELO CROSSOVER:
    population_crossover = [c1; c2];
    
    
    %% MUTAÇÃO
    
    % ARMAZENA OS INDIVÍDUOS GERADOS APÓS AS MUTAÇÕES:
    population_mutation = GA_MUTATION (pop_size, n_gens, prob_mutation, population_crossover, cons_max, cons_min);
    % ARMAZENA AS AVALIAÇÕES DOS INDIVÍDUOS GERADOS APÓS AS MUTAÇÕES:
    [fitness_mutation] = GA_FITNESS (INPUT, pop_size, population_crossover);
    
    
    %% MÉTODO DO ELITISMO
    
    % REALIZA O ORDENAMENTO DA POPULAÇÃO DA NOVA GERAÇÃO:
    [fitness_mutation, sort_order] = sort(fitness_mutation, 'ascend');
    population_mutation = population_mutation(sort_order, :);


    % REALIZA O ORDENAMENTO DA POPULAÇÃO:
    [fitness, sort_order] = sort(fitness, 'descend');
    population = population(sort_order, :);

    % TROCA OS PIORES INDIVÍDUOS DA NOVA GERAÇÃO PELOS MELHORES DA ANTIGA:
    for i = 1 : elitism_preservation
        population_mutation(i,:) = population(i,:);
        fitness_mutation(i,:) = fitness(i,:);
    end
    
    % SELECIONA OS PARA A PRÓXIMA GERAÇÃO:
    population = population_mutation;
    fitness = fitness_mutation;

    % REALIZA O ORDENAMENTO FINAL PARA A NOVA GERAÇÃO:
    [fitness, sort_order] = sort(fitness, 'descend');
    population = population(sort_order, :);
    

    %% RESULTADOS
    
    % ARMAZENA O MELHOR INDIVÍDUO:
    best_indv = population(1,:);
    % ARMAZENA O FITNESS DO MELHOR INDIVÍDUO:
    best_fitness = fitness(1,:);
    % ARMAZENA O FITNESS MÉDIO DA GERAÇÃO:
    mean_fitness = sum(fitness(:,:))/pop_size;
    % ARMAZENA O DESVIO PADRÃO DO FITNESS DA GERAÇÃO:
    std_fitness = std(fitness(:,:));
    % ARMAZENA TODOS OS INDIVÍDUOS
    all_solutions = [all_solutions; population fitness];

    % ARMAZENA ESTAS INFORMAÇÕES EM LISTAS:
    best_solutions(iter,:) = best_indv;
    best_fitnesses(iter) = best_fitness;
    mean_fitnesses(iter) = mean_fitness;
    std_fitnesses(iter) = std_fitness;
    
    % SUBSTITUI A SOLUÇÃO DO PROBLEMA, CASO NECESSÁRIO:
    if best_fitness > solution_fitness
        solution_fitness = best_fitness;
        solution_indv = best_indv;
    end

    % ARMAZENA VARIÁVEIS UTILIZADAS NO PLOT:
    bf = best_solutions(iter, :);
    bv = best_fitnesses(iter);

    % CÁLCULO PARA A TORÇÃO INTERMEDIÁRIA:
    twist_mid = [0.0 -1.0 -2.0 -3.0];
    n = find(bf(6) <= [0.25 0.50 0.75 1.00], 1, 'first');
    bf(6) = twist_mid(n);

    % CÁLCULO PARA A TORÇÃO NA PONTA:
    twist_tip = [twist_mid(n) twist_mid(n)-1 twist_mid(n)-2 twist_mid(n)-3];
    n = find(bf(7) <= [0.25 0.50 0.75 1.00], 1, 'first');
    bf(7) = twist_tip(n);

    % CÁLCULO PARA AEROFÓLIO:
    airfoil = ["E423.dat" "UruA84212.dat" "UruA94113.dat" "UruA104612.dat"];
    n = find(bf(8) <= [0.25 0.50 0.75 1.0], 1, 'first');
    air = airfoil(n);
    filename = "Airfoils\" + air;
    data = readtable(filename, 'Delimiter', '   ', 'ReadVariableNames', false, 'HeaderLines', 1);
    data.Properties.VariableNames = {'x', 'y'};


    % CÁLCULO PARA O GRUPO MOTOPROPULSOR:
    GMP_text = ["SII-4035-450kv + 17x8E" "SII-4035-450kv + 17x10E" ...
        "SII-4035-450kv + 17x12E" "SII-4035-450kv + 18x5.5MR" ...
        "SII-4035-450kv + 18x8E" "SII-4035-450kv + 18x10E" ...
        "SII-4035-450kv + 18x12E"];
    n = find(bf(9) <= [0.143 0.286 0.429 0.572 0.715 0.858 1.000],...
    1, 'first');
    prop = GMP_text(n);


    p1 = sprintf('Generation %.f', iter);
    p2 = sprintf('Fitness: %.3f', bv);
    p3 = "Airfoil: " + air;
    p4 = "PS: " + prop;
    p5 = sprintf('Intermediate Twist: %.1f°', bf(6));
    p6 = sprintf('Tip Twist: %.1f°', bf(7));
    p7 = "Plots\Generation"+ iter +".png";

    % SALVA UM PLOT COM O MELHOR RESULTADO:
    x = [0 0 (bf(3)/2)*bf(4) (bf(3)/2)...
        (bf(3)/2) (bf(3)/2)*bf(4)];
    y = [0 bf(1) bf(1) (bf(1)-...
        bf(5)) (bf(1)-bf(5)-...
        (bf(1)*bf(2))) 0];

    figure;
    fill(x, y, 'r', -x, y, 'r')
    axis([-1.8 1.8 -0.75 1.15])
    title('Genetic Algorithm Optimization')
    text(-0.775, -0.65, 'Caio Dias; caiodiasfilho02@gmail.com', 'FontSize', 7, 'Color', '#696969')
    xlabel('y (m)')
    ylabel('x (m)')
    text (-1.7, 1, p1, 'FontWeight','bold')
    text(-1.7, 0.9, p2, 'FontSize', 9)

    text (0.65, -0.475, p3{1}(1:end-4), 'FontSize', 9)

    text (-1.7, -0.225, p4, 'FontSize', 9)
    text (-1.7, -0.35, p5, 'FontSize', 9)
    text (-1.7, -0.475, p6, 'FontSize', 9)

    axes('Position',[0.68 0.225 0.15 0.15])
    fill(data.x, data.y, 'red');
    axis equal
    axis off
    grid off;

    axes('Position',[0.75 0.765 0.125 0.125]);
    plot(best_fitnesses(1:iter), 'LineWidth',1, 'Color', 'blue');
    set(gca, 'fontsize',6);
    xlabel('Generations');
    ylabel('Fitness');
    axis([1 max_generations 0 15]);
    grid on;

    saveas(gcf, p7)
    grid off
    hold off
end

% ARMAZENA AS SAÍDAS DA FUNÇÃO EM UM STRUCT:
GENETIC_OUTPUTS.best_fitnesses = best_fitnesses;
GENETIC_OUTPUTS.mean_fitnesses = mean_fitnesses;
GENETIC_OUTPUTS.std_fitnesses = std_fitnesses;
GENETIC_OUTPUTS.best_solutions = best_solutions;
GENETIC_OUTPUTS.solution_fitness = solution_fitness;
GENETIC_OUTPUTS.solution_indv = solution_indv;
GENETIC_OUTPUTS.all_solutions = all_solutions;
end