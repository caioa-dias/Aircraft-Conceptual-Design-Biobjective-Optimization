%% ---------------------- SIMULAÇÃO DA DECOLAGEM ---------------------- %% 
function [s_tot, OUTPUT] = TAKEOFF_SIMULATION (m, INPUT, OUTPUT)

% DECLARAÇÃO DAS VARIÁVEIS:
c1 = INPUT.design.chord_r;
c2 = INPUT.design.chord_r * INPUT.design.taper;
b = INPUT.design.span/2;
b1 = b * INPUT.design.y_taper;
Sref = 2*((c1 * b1) + (((c1 + c2)*(b - b1))/2));
OUTPUT.design.Sref = Sref;

g = INPUT.world.gravity;
rho = INPUT.world.density;
mu = INPUT.world.friction;
Ta = INPUT.design.power_plant(1);
Tb = INPUT.design.power_plant(2);
Tc = INPUT.design.power_plant(3);
CD0 = INPUT.decisions.friction_drag;
h_o = INPUT.decisions.obstacle;

CL = OUTPUT.AVL.CL;
CDi = OUTPUT.AVL.CDi;


% DEFINIÇÃO DAS VARIÁVEIS IMPORTANTES PARA O LOOP: 
v_x = 0; a_x = 0;                              % Velocidade-X em t=0.
vx_list = zeros(1,10); t_list = zeros(1,10);   % Listas de Armazenamento.
i = 1;                                         % Contador de Iterações.


% DEFINIÇÕES DA FORÇA PESO E DA SUSTENTAÇÃO:
W = m * g;                                     % Peso para determinado m.
L = 0;                                         % Sustentação em t=0.


% SIMULAÇÃO DA CORRIDA EM SOLO:
for t = 0 : 0.05 : 30
    if L <= W
        v0_x = v_x;                            % Velocidade-X em t-1.
        v_x = v0_x + a_x * 0.05;               % Velocidade-X em t.

        q = 0.5 * rho * (v_x)^2;               % Pressão dinâmica em t.
        T = (Ta * (v_x)^2) + (Tb * v_x) + Tc;  % Tração em t.
        D = q * Sref * (CD0 + CDi);            % Arrasto em t.
        L = q * Sref * CL;                     % Sustentação em t.
        R = mu * (W - L);                      % Atrito em t.

        a_x = (T - D - R)/m;                   % Aceleração-X em t.

        vx_list(i) = v_x;                      % Armezenamento de V_x.
        t_list(i) = t;                         % Armezenamento de t.
        i = i + 1;                           
    end
end


% CÁLULO DA DISTÂNCIA PERCORRIDA NA CORRIDA EM SOLO:
s_g = trapz(t_list(1:end), vx_list(1:end));


% TRANSIÇÃO ATÉ ULTRAPASSAR O OBSTÁCULO:
tr_r = 0.2156 * ((1.045*v_x)^2);                % Raio de transição.
s_t = sqrt(tr_r^2 - (tr_r-h_o)^2);             % Distância - ultrapassagem.

s_tot = s_g + s_t;                             % Distância total.
end