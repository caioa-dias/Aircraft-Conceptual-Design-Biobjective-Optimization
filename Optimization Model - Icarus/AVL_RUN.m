%% ------------------ AVALIAÇÕES AERODINÂMICAS - AVL ------------------ %% 
function [OUTPUT] = AVL_RUN (INPUT)

% ESCRITA DO ARQUIVO .AVL:
AVL_FILE (INPUT);

% PUXA O ARQUIVO DO AEROFÓLIO PARA A PASTA PRINCIPAL:
movefile (strcat('Airfoils\', INPUT.design.airfoil));

% CRIAÇÃO DO ARQUIVO ".RUN":
avl_run = fopen('Astra.run', 'w');
fprintf(avl_run, 'LOAD Astra.avl\n');
fprintf(avl_run, 'OPER\n');
fprintf(avl_run, 'X\n');
fprintf(avl_run, 'ST\n');
fprintf(avl_run, 'Astra_Coefficients.txt\n');
fprintf(avl_run, 'FS\n');
fprintf(avl_run, 'Astra_Distribution.txt\n\n');
fprintf(avl_run, 'QUIT\n');
fclose(avl_run);

% EXECUÇÃO DAS ANÁLISES AERODINÂMICAS:
dos(strcat('AVL.exe', '<', 'Astra.run'));

% DEVOLVE O ARQUIVO DO AEROFÓLIO PARA A SUA PASTA:
movefile(INPUT.design.airfoil, 'Airfoils\');

% LEITURA DO ARQUIVO ".TXT" E DEFINIÇÃO DOS OUTPUTS:
read1 = fopen('Astra_Coefficients.txt');
OUTPUT.AVL.CL = cell2mat(textscan(read1, 'CLtot =%f',1, 'HeaderLines', 23));
OUTPUT.AVL.CDi = cell2mat(textscan(read1, 'CDtot =%f',1));
fclose(read1);

% LEITURA DO ARQUIVO ".TXT" E DEFINIÇÃO DOS OUTPUTS:
read2 = fopen('Astra_Distribution.txt');
data = textscan(read2, '%s', 'Delimiter', '\n');
fclose(read2);

cl_distribution = zeros(1,20);
for i = 21:40
    local = textscan(data{1}{i}, '%f %f %f %f %f %f %f %f %f %f %f %f %f');
    cl_distribution(i-20) = local{8};
end

[M, I] = max(cl_distribution);
if I == 1
    OUTPUT.AVL.Cl_Distribution = 'root';
else
    OUTPUT.AVL.Cl_Distribution = 'tip';
end

% DELETA OS ARQUIVOS ".TXT", ".RUN" e ".AVL":
delete('Astra_Coefficients.txt');
delete('Astra_Distribution.txt');
delete('Astra.run');
delete('Astra.avl');
end