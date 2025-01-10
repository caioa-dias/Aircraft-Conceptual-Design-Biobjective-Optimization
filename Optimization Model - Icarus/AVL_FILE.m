%% -------------------- CRIAÇÃO DO ARQUIVO DA ASA -------------------- %% 
function AVL_FILE(INPUT)

% DEFINIÇÃO DOS INPUTS:
c1 = INPUT.design.chord_r;
c2 = INPUT.design.chord_r * INPUT.design.taper;
bt = INPUT.design.span;
b = INPUT.design.span/2;
b1 = b * INPUT.design.y_taper;
o = INPUT.design.offset_tip;
t1 = INPUT.design.twist_mid;
t2 = INPUT.design.twist_tip;
a = INPUT.design.airfoil;

% CÁLCULOS NECESSÁRIOS:
Sref = 2*((c1 * b1) + (((c1 + c2)*(b - b1))/2));
Cref = Sref / bt;

% CRIAÇÃO DO ARQUIVO:
avl_file = fopen('Astra.avl', 'w');

fprintf(avl_file, 'Astra\n');
fprintf(avl_file, '0.0                        | Mach\n');
fprintf(avl_file, '0        0        0        | iYsym  iZsym  Zsym\n');
fprintf(avl_file, '%.4f %.4f %.4f | Sref   Cref   Bref\n', Sref, Cref, bt);
fprintf(avl_file, '0.0000  0.0000  0.0000  | Xref   Yref   Zref\n\n');

fprintf(avl_file, 'SURFACE\n');
fprintf(avl_file, 'Main Wing\n');
fprintf(avl_file, '30   1.0\n\n');

fprintf(avl_file, 'YDUPLICATE\n');
fprintf(avl_file, '0.0\n\n');

fprintf(avl_file, 'ANGLE\n');
fprintf(avl_file, '0.0\n\n');

fprintf(avl_file, 'SECTION\n');
fprintf(avl_file, '0.000  0.000  0.000  %.3f  0.0  10  -2.0\n', c1);
fprintf(avl_file, 'AFILE\n');
fprintf(avl_file, '%s\n\n', a);

fprintf(avl_file, 'SECTION\n');
fprintf(avl_file, '0.000  %.3f  0.000  %.3f  %.1f  10  1.0\n', b1, c1, t1);
fprintf(avl_file, 'AFILE\n');
fprintf(avl_file, '%s\n\n', a);

fprintf(avl_file, 'SECTION\n');
fprintf(avl_file, '%.3f  %.3f  0.000  %.3f  %.1f\n', o, b, c2, t2);
fprintf(avl_file, 'AFILE\n');
fprintf(avl_file, '%s', a);

fclose(avl_file);
end