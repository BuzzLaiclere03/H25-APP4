%Variable Globales
d = 1; % mètre
rho = 1; % kg/m3
c = 340; % m/s
Rs = 70; % ohm

%% Variables pour Haut Parleur #1
Bl = 10.8; % Tm
%Variables Elec
Re = 6.4; % ohm
Le = 0.051e-3; % H 
%Variables Mec
Mm = 13.3e-3; % kg
Rm = 0.5; % kg/s
Km = 935; % N/m
%Variables Acoustiques
Sm = 0.0201; % m2

%%% Variables pour Haut Parleur #2
%Bl = 4.2; % Tm
%%Variables Elec
%Re = 3; % ohm
%Le = 0.05e-3; % H 
%%Variables Mec
%Mm = 10.5e-3; % kg
%Rm = 0.48; % kg/s
%Km = 400; % N/m
%%Variables Acoustiques
%Sm = 0.0222; % m2

%% Fonction de transfert Mec
%Création
s = tf('s');
Hm = Bl/(Mm*s^2 + Rm*s + Km);
Hm = minreal(Hm)
%Pôles & Zéros
figure();
pzmap(Hm);
[z, p, k] = zpkdata(Hm, 'v')
%Diagramme de Bode

%% Fonction de transfert Elec
%Création
He = 1/(Le*s+Bl*s/Hm + Re+ Rs);
He = minreal(He)
%Pôles & Zéros
figure();
pzmap(He);
[z, p, k] = zpkdata(He, 'v')
%Diagramme de Bode


%% Fonction de transfert Electro-Acoustique
%Création
Ha = (rho*Sm*s^2*exp(-s*d/c))/(2*pi*d*Hm*He);
Ha = minreal(Ha)
%Pôles & Zéros
figure();
pzmap(Ha);
[z, p, k] = zpkdata(Ha, 'v')
%Diagramme de Bode


%% PWM
%Série fournier PWM 100Hz 50% composante continue

%Amplitudes & phases des fonctions de transfert harmoniques


%% Impulse
%Fraction rationnelles de H electro acoustique

%Laplace ^ -1

%Convolution aec PWM pour obtenir p(t)


%% Faire le simulink