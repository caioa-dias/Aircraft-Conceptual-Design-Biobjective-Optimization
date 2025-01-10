%% -------------------------- FUNÇÃO FITNESS -------------------------- %% 
function [rank] = GA_FITNESS (INPUT, pop_size, population)

rank = zeros (pop_size, 1);

for j = 1 : pop_size
    individual = population (j,:);
    
    INPUT.design.chord_r = individual(1);
    INPUT.design.taper = individual(2);
    INPUT.design.span = individual(3);
    INPUT.design.y_taper = individual(4);
    INPUT.design.offset_tip = individual(5);

    % CÁLCULO PARA A TORÇÃO INTERMEDIÁRIA:
    twist_mid = [0.0 -1.0 -2.0 -3.0];
    n = find(individual(6) <= [0.25 0.50 0.75 1.00], 1, 'first');
    INPUT.design.twist_mid = twist_mid(n);

    % CÁLCULO PARA A TORÇÃO NA PONTA:
    twist_tip = [twist_mid(n) twist_mid(n)-1 twist_mid(n)-2 twist_mid(n)-3];
    n = find(individual(7) <= [0.25 0.50 0.75 1.00], 1, 'first');
    INPUT.design.twist_tip = twist_tip(n);

    % CÁLCULO PARA AEROFÓLIO:
    airfoil = ["E423.dat" "UruA84212.dat" "UruA94113.dat" "UruA104612.dat"];
    n = find(individual(8) <= [0.25 0.50 0.75 1.0], 1, 'first');
    INPUT.design.airfoil = airfoil(n);

    % CÁLCULO PARA O GRUPO MOTOPROPULSOR:
    GMP = [[-0.0249 -1.2568 102.3320]
              [-0.0273 -0.07934 115.8218]
              [-0.0282 -0.2911 122.6452]
              [-0.0332 -2.3898 116.6083]
              [-0.0284 -1.5923 125.6174]
              [-0.0311 -1.0840 143.4866]
              [-0.0330 -0.4877 154.1342]];
    n = find(individual(9) <= [0.143 0.286 0.429 0.572 0.715 0.858 1.000], 1, 'first');
    INPUT.design.power_plant = GMP(n,:);


    % CÁLCULOS FINAIS:
    [OUTPUT] = PERFORMANCE_ANALYSIS (INPUT);

    MTOW = OUTPUT.performance.MTOW;
    
    empty_w = INPUT.decisions.wing_density * OUTPUT.design.Sref;
    
    rank(j) = OUTPUT.performance.MTOW/(9*empty_w);
    

    % PENALIDADES E BONIFICAÇÕES:
    if strcmp(OUTPUT.AVL.Cl_Distribution, 'tip') == 1
        rank(j) = rank(j) * 0.2;
    end
    
    if MTOW >= 18 && MTOW <= 22
        rank(j) = rank(j) + ((-5/2)*(MTOW^2) + (100)*MTOW - (990));
    end

    if MTOW > 22
        rank(j) = rank(j) + ((-1)*MTOW + 22);
    end

end
end