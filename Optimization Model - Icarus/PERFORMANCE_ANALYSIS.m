%% -------------------- AVALIAÇÕES DE PERFORMANCE -------------------- %% 
function [OUTPUT] = PERFORMANCE_ANALYSIS (INPUT)

% DEFINE OS INPUTS:
TO_dist = INPUT.decisions.TO_dist;

% REALIZA AS AVALIAÇÕES AERODINÂMICAS:
[OUTPUT] = AVL_RUN (INPUT);

% REALIZA A SIMULAÇÃO DE DECOLAGEM COM DIFERENTES VALORES DE MASSA:
for m = 10 : 0.1 : 40
    [s_tot, OUTPUT] = TAKEOFF_SIMULATION (m, INPUT, OUTPUT);
    if s_tot > TO_dist
        [s_tot] = TAKEOFF_SIMULATION ((m - 0.1), INPUT, OUTPUT);
        MTOW = m - 0.1;
        break
    end
end

% DEFINIÇÃO DOS OUTPUTS RELACIONADOS A PERFORMANCE:
OUTPUT.performance.s_tot = s_tot;
OUTPUT.performance.MTOW = MTOW;
end