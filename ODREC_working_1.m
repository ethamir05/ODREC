%% Inputs
% An example main code to use ODREC (One Dimensional REgenerative Cooling
% analysis)
% Yiğithan Mehmet Köse
% September 2023

clc
clear all
close all

% load('Methane.mat')
% l_prop = CH4_liquid;
% s_prop = CH4_saturated;
% v_prop = CH4_vapor;

load('Propane.mat')
l_prop = C3H8_liquid;
s_prop = C3H8_saturated;
v_prop = C3H8_vapor;

% load('Oxygen.mat')
% l_prop = O2_liquid;
% s_prop = O2_saturated;
% v_prop = O2_vapor;

%General Engine Properties
Fuel = 'C3H8(L)';           %fuel name
Oxidizer = 'O2(L)';         %oxidizer name (engine messes up when changed to N2O)
OF = 4.6;                   %oxidizer/fuel mixture ratio
Pc = 26e5;                  %combustion chamber pressure, Pa
Ft = 6270;                  %thrust, N
P_ambient = 1e5;            %ambient pressure, Pa
T_f_c = 231.076;            %fuel temperature entering combustion chamber, K
T_o_c = 90.170;             %oxidizer temperature entering combustion chamber, K

%Engine Wall Material
K_wall = 25;               %engine wall thermal conductivity, W/mK (11 FOR INCONEL, 25 FOR SS, 298 FOR COPPER)
eps = 3.5e-6;               %cooling channel roughness, m

%Coolant General Properties
i_c = 1;                    %coolant index, 1:fuel, 2:oxidizer
T_c_i = 210;                %coolant inlet temperature, K
P_c_i = 38e5;               %coolant inlet pressure, Pa

%Cooling Channel Properties
N = 40;                     %number of cooling channels
w = 0.635;                  %cooling channel base width, m
h = 0.00317;                  %cooling channel height, m
y = 0.005;                  %thickness at channel base, m

%Coolant Vapor Table Specifiscations
P_1 = 25e5;                 %pressure in first table of vapor properties, Pa
P_l = 50e5;                 %pressure in last table of vapor properties, Pa
N_p = 6;                    %number of tables of vapor properties

%Thrust Chamber Profile
L_star = 2.2;               %characteristic length, m
theta_n = 60;               %bell nozzle entry angle, deg
theta_e = 85;               %bell nozzle exit angle, deg
N1 = 30;                    %thrust chamber cylindrical part number of divisions
N2 = 16;                    %thrust chamber round conical section number of divisions
N3 = 16;                    %thrust chamber throat entrance number of divisions
N4 = 16;                    %thrust chamber throat exit number of divisions
N5 = 30;                    %thrust chamber bell curve nozzle number of divisions

% % Raw geometry input (m)
raw_data = [
    0.070358,   0.047498;
    0.060402,   0.045770;
    0.052310,   0.044109;
    0.047564,   0.043000;
    0.040104,   0.041118;
    0.039726,   0.040808;
    0.036357,   0.039815;
    0.022074,   0.034506;
    0.005062,   0.025416;
    0.0,      0.023876;     % Throat
   -0.024243,   0.033329;
   -0.029258,   0.039039;
   -0.037846,   0.052530;
   -0.062451,   0.066802;
   -0.082935,   0.066802;
  -0.144018,   0.066802;
  -0.229464,   0.066802;
  -0.314960,   0.066802;
];


% Defining X and Y

X_control = raw_data(:,1);
Y_control = raw_data(:,2);

% 2. Sorting
[X_control_sorted, idx] = sort(X_control);
Y_control_sorted = Y_control(idx);

% Defining interpolation points and greating column grids
discretization = [N1 N2 N3 N4 N5];
N_total = sum(discretization);

X_fine = linspace(min(X_control_sorted), max(X_control_sorted), N_total)';

% 4. Spline interpolation
pp = spline(X_control_sorted, Y_control_sorted);
Y_fine = ppval(pp, X_fine);

% 5. Ensure column vectors
X_fine = X_fine(:);
Y_fine = Y_fine(:);

% 6. Assemble geometry matrix for calculations
geom = [X_fine, Y_fine];

% 7. Plot (test)
figure(4);
plot(geom(:,1), geom(:,2), 'b-', 'LineWidth', 2);
hold on;
scatter(X_control_sorted, Y_control_sorted, 40, 'r', 'filled');
xlabel('Axial Position (X)'); 
ylabel('Radial Position (Y)'); 
axis equal; grid on;

%% Initialize the analysis

inputs.fuel = Fuel;
inputs.oxidizer = Oxidizer;
inputs.T_o_c = T_o_c;
inputs.T_f_c = T_f_c;
inputs.discretization = [N1 N2 N3 N4 N5];
inputs.eps = eps;
inputs.i_c = i_c;
inputs.y = y;
inputs.L_star = L_star;
inputs.theta_n = theta_n;
inputs.theta_e = theta_e;
inputs.P_c_i = P_c_i;
inputs.T_c_i = T_c_i;
inputs.k_wall = K_wall;
inputs.P_1 = P_1;
inputs.P_l = P_l;
inputs.N_p = N_p;

inputs.Pc = Pc;
inputs.F = Ft;
inputs.OF = OF;
inputs.Pe = P_ambient;
inputs.N = N;
inputs.w = w;
inputs.h = h;

%% Analysis

Results = ODREC(inputs,l_prop,s_prop,v_prop, geom);
Results = Results.Thermal_Analysis(inputs);
Tw = Results.T_w;

%% Plots

figure(1)
var = myaxisc(3,0.08);
p(1) = plot(var.p(1),100*Results.X,Results.T_w,'Color',[0,0,1]);
p(2) = plot(var.p(2),100*Results.X,100*Results.Z,'Color','[.7 .7 .7]','LineWidth',3);
p(3) = plot(var.p(3),100*Results.X,Results.q/1e6,'Color','r');
var.xlim([-17,4]);
var.ylabel(1,'Wall Temperature (K)');
var.ylabel(2,'Radius (cm)');
var.ylabel(3,'Wall Heat Flux (MW/m^2)');
var.xlabel('x (cm)');
var.ylim(1,[400,1000])
var.ylim(2,[0,0.2])
var.ylim(3,[0,45])
var.ycolor(1,[0,0,1]);
var.ycolor(2,[.5 .5 .5]);
var.ycolor(3,'r');
leg = legend(var.legendtarget,p,...
    'Wall Temperature','Engine Contour','Wall Heat Flux');
set(leg,'Color','W')
set(gcf,'color','W')
set(gca,'fontname','times')
var.fontsize(9)

figure(2)
plot(Results.Tem_c,Results.p_c/1e5,'>','MarkerSize',5,...
    'MarkerEdgeColor','blue',...
    'MarkerFaceColor',[1 .6 .6])
hold on
plot(s_prop(:,1),s_prop(:,2)/1e5,'k')
xlabel('Temperature (K)')
ylabel('Pressure (bar)')
set(gcf,'color','W')
set(gca,'fontname','times')
legend('Coolant state in channels','Saturation line')

figure(3)
var = myaxisc(4,0.08);
p(1) = plot(var.p(1),100*Results.X,Results.Tem_c,'v-','Color',[0.4660 0.6740 0.1880],'MarkerSize',5,'MarkerEdgeColor','[0.4660 0.6740 0.1880]','MarkerFaceColor','green');
p(2) = plot(var.p(2),100*Results.X,100*Results.Z,'Color','[.7 .7 .7]','LineWidth',3);
p(3) = plot(var.p(3),100*Results.X,Results.X_g,'s-','Color','r','MarkerSize',5,'MarkerEdgeColor','red','MarkerFaceColor',[1 .6 .6]);
p(4) = plot(var.p(4),100*Results.X,Results.p_c/1e5,'^-','Color','blue','MarkerSize',5,'MarkerEdgeColor','blue','MarkerFaceColor',[0.3010 0.7450 0.9330]);

var.xlim([-17,4]);
var.ylabel(1,'Coolant Temperature (K)');
var.ylabel(2,'Radius (cm)');
var.ylabel(3,'Vapor Fraction');
var.ylabel(4,'Coolant Pressure (bar)');
var.xlabel('x (cm)');
var.ylim(1,[100,270])
var.ylim(2,[0,20])
var.ylim(3,[-0.05,1.05])
var.ylim(4,[29,42])

var.ycolor(1,[0.4660 0.6740 0.1880]);
var.ycolor(2,[.4 .4 .4]);
var.ycolor(3,'r');
var.ycolor(4,'b');

leg = legend(var.legendtarget,p,...
    'Temperature','Engine Contour','Vapor Fraction','Pressure');
set(leg,'Color','W')

set(gcf,'color','W')
set(gca,'fontname','times')
var.fontsize(9)