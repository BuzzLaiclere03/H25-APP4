clear all;
close all;

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
figure("Name", "Pôles et zéros de Hm");
figure(1)
pzmap(Hm);
[m.z, m.p, m.k] = zpkdata(Hm, 'v')
%Diagramme de Bode
figure("name", "Diagramme de Bode de Hm");
figure(2)
bode(Hm, (10:0.1:10000)*2*pi)

%% Fonction de transfert Elec
%Création
He = 1/((Le+Bl*Hm)*s + Re+ Rs);
He = minreal(He)
%Pôles & Zéros
figure("name", "Pôles et zéros de He");
figure(3)
pzmap(He);
[e.z, e.p, e.k] = zpkdata(He, 'v')
%Diagramme de Bode
figure("name", "Diagramme de Bode de He");
figure(4)
bode(He, (10:0.1:10000)*2*pi)

%% Fonction de transfert Electro-Acoustique
%Création
Ha = He*Hm*(rho*Sm*s^2*exp(-s*d/c))/(2*pi*d);%
Ha = minreal(Ha)
%Pôles & Zéros
figure("name", "Pôles et zéros de Ha");
figure(5)
pzmap(Ha);
[a.z, a.p, a.k] = zpkdata(Ha, 'v')
%Diagramme de Bode
figure("name", "Diagramme de Bode de Ha");
figure(6)
bode(Ha, (10:0.1:10000)*2*pi)

%% Son continue - PWM
%Série fournier PWM 100Hz 50% composante continue & 10 1ers harmoniques

%Création du PWM
NbHarmoniques = 10;
k = [-NbHarmoniques:1:NbHarmoniques];

Fe = 1000;% c quoi comme variable ça?
T = 0.01; % s
dt = T/Fe;
w0 = 2*pi/T; % rad/s
t = [0:dt:T-dt];
x = [ones(1, Fe/2), zeros(1, Fe/2)];
x = x*3.3;

%fonctions de transfert harmoniques
for i=1:length(k)
    u(i,:) = exp(-j*k(i)*w0*t);
end

%Amplitudes & phases des fonctions de transfert harmoniques
for i=1:length(k)
    X(i) = 1/T*trapz(t, x.*u(i,:));
end

%Affichage
AMP = abs(X);
PHASE = angle(X);

for i=1:length(AMP)
    if AMP(i) <= 0.01
        PHASE(i) = 0;
    end
end

figure("name", "Diagramme d'amplitude et de phase du PWM")
figure(7)
subplot(2, 1, 1)
stem(k, AMP)
xlabel("Harmoniques");
ylabel("Amplitude");
subplot(2, 1, 2)
stem(k, PHASE)
xlabel("Harmoniques");
ylabel("Phase");

%Reconstruction
y = 0;
for i=1:length(k)
    y = y+AMP(i)*cos(k(i)*w0*t+PHASE(i));
end
figure("name", "Reconstruction du PWM")
figure(8)
plot(t, y)

%Réponse Ha
for i = 1:length(k)
    H_k(i) = evalfr(Ha,j*k(i)*w0);
end
for i = 1:length(k)
    Y_k(i) = X(i) * H_k(i);
end

y = 0;
for i = 1:length(k)
    y = y + Y_k(i)*exp(1i*k(i)*w0*t);
end
figure("name", "Réponse du système au PWM")
figure(9)
plot(t, y)

%% Courant PWM
for i = 1:length(k)
    H_k(i) = evalfr(He,j*k(i)*w0);
end
for i = 1:length(k)
    Y_k(i) = X(i) * H_k(i);
end

y = 0;
for i = 1:length(k)
    y = y + Y_k(i)*exp(1i*k(i)*w0*t);
end
figure("name", "Courant du système avec PWM")
figure(10)
plot(t, y)

%% Son percussif - Impulse
%Création du signal
Fe = 100e4; % Fréquence d'échantillonnage 100 kHz
Te = 1/Fe;  % Période d'échantillonnage
t = 0:Te:0.05; % Simulation sur 50 ms
tt = 0:Te:0.05; % Simulation sur 50 ms
y_X = linspace(0,0.05,0.05/Te+1); 

%Dirac fait chier en tabarnak
%Dick_offset = zeros(1,5001);
Dick_offset = 1 * (tt > (d/c));
% Signal d'entrée : impulsion de 3.3V pendant 10 ms
u = 3.3 * (tt >= 0 & tt <= 10e-3);

%Fraction rationnelles de H electro acoustique & Laplace ^ -1
h = 0;
[R,P,K] = residue(Ha.Numerator{1}, Ha.Denominator{1});
for i=1:length(P)
    h = h+R(i)*exp(P(i)*t);
end
h = Dick_offset .* h;
test = impulse(Ha, t);
plot(t, test)
%Convolution avec signal pour obtenir p(t)
p_t = conv(h, u) * Te;%
t_conv = (0:length(p_t)-1) * Te; % Temps associé

%Affichage
figure("name", "Réponse du système après Impulse")
figure(11);
plot(t_conv, p_t);
%plot(t_conv, p_t);
xlabel("Temps (s)");
ylabel("Amplitude");

%% Courant Impulse
%Fraction rationnelles de H electrique & Laplace ^ -1
h = 0;
[R,P,K] = residue(He.Numerator{1}, He.Denominator{1});
for i=1:length(P)
    h = h+R(i)*exp(P(i)*t);
end

i_t = conv(u, h) * Te; % Convolution discrète (intégration par Te)
t_conv = (0:length(i_t)-1) * Te; % Temps associé

figure("name", "Courant du système avec Impulse")
figure(12);
plot(t_conv, i_t);
xlabel("Temps (s)");
ylabel("Courant");
%% Faire le simulink