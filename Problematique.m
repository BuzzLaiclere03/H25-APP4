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
figure(1)
figure("name", "Pôles et zéros de Hm");
pzmap(Hm);
[m.z, m.p, m.k] = zpkdata(Hm, 'v')
%Diagramme de Bode
figure(2)
figure("name", "Diagramme de Bode de Hm",'NumberTitle','off');
bode(Hm, 0.1:0.001:100)

%% Fonction de transfert Elec
%Création
He = 1/((Le+Bl*Hm)*s + Re+ Rs);
He = minreal(He)
%Pôles & Zéros
figure(3)
figure("name", "Pôles et zéros de He",'NumberTitle','off');
pzmap(He);
[e.z, e.p, e.k] = zpkdata(He, 'v')
%Diagramme de Bode
figure(4)
figure("name", "Diagramme de Bode de He",'NumberTitle','off');
bode(He, 0.1:0.001:100)

%% Fonction de transfert Electro-Acoustique
%Création
Ha = He*Hm*(rho*Sm*s^2*exp(-s*d/c))/(2*pi*d);
Ha = minreal(Ha)
%Pôles & Zéros
figure(5)
figure("name", "Pôles et zéros de Ha",'NumberTitle','off');
pzmap(Ha);
[a.z, a.p, a.k] = zpkdata(Ha, 'v')
%Diagramme de Bode
figure(6)
figure("name", "Diagramme de Bode de Ha",'NumberTitle','off');
bode(Ha, 0.1:0.001:100)

%% PWM
%Série fournier PWM 100Hz 50% composante continue

%Amplitudes & phases des fonctions de transfert harmoniques


%% Impulse
%Fraction rationnelles de H electro acoustique

%Laplace ^ -1

%Convolution aec PWM pour obtenir p(t)


%% Faire le simulink