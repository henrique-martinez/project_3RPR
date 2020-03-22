clear all
close all
clc

conditionnement = 0.1;
minPhi = -65;
maxPhi = -5;

% global parameters

D = 3.0673752163598356;
d = 0.8579682472699844;
% conditionement
condList = [];
% minArmLengths
min_rho = [];
% maxArmLengths
max_rho = [];

O = [0 0]';
A_1 = [0 0]';
A_2 = [D 0]';
A_3 = [D*1/2 D*sqrt(3)/2]';

pointsList = [];
N = 15;
taille = 1.5;
for i=-(taille/2):(taille/N):(taille/2)
    for j=-(taille/2):(taille/N):(taille/2)
        pointsList = [pointsList, [i+D/2;j+D*sqrt(3)/6]];
    end
end

pointsList

% end-effector position
x = D/2
y = D*sqrt(3)/6
phi = deg2rad((maxPhi-minPhi)/2)
% inverse kinematics

B_1 = [x+d*cos(phi-5*pi/6) y+d*sin(phi-5*pi/6)]';
B_2 = [x+d*cos(phi-pi/6) y+d*sin(phi-pi/6)]';
B_3 = [x+d*cos(phi+pi/2) y+d*sin(phi+pi/2)]';

figure(1);
plot([A_1(1) A_2(1) A_3(1) A_1(1)],[A_1(2) A_2(2) A_3(2) A_1(2)], "--ok", "linewidth", 3); hold on;
plot([A_1(1) B_1(1)],[A_1(2) B_1(2)], '-o', 'linewidth', 3); hold on;
plot([A_2(1) B_2(1)],[A_2(2) B_2(2)], '-o', 'linewidth', 3); hold on;
plot([A_3(1) B_3(1)],[A_3(2) B_3(2)], '-o', 'linewidth', 3); hold on;
plot([B_1(1) B_2(1) B_3(1) B_1(1)],[B_1(2) B_2(2) B_3(2) B_1(2)], '-o', 'linewidth', 3); hold on;

for i=1:length(pointsList)
  for phi=deg2rad(minPhi):pi/36:deg2rad(maxPhi)
    % end-effector position
    x = pointsList(1,i);
    y = pointsList(2,i);

    % inverse kinematics

    B_1 = [x+d*cos(phi-5*pi/6) y+d*sin(phi-5*pi/6)]';
    B_2 = [x+d*cos(phi-pi/6) y+d*sin(phi-pi/6)]';
    B_3 = [x+d*cos(phi+pi/2) y+d*sin(phi+pi/2)]';

    P = [x y]';

    rho_1 = norm(B_1 - A_1);
    rho_2 = norm(B_2 - A_2);
    rho_3 = norm(B_3 - A_3);

    min_rho = [min_rho, min([rho_1, rho_2, rho_3])];
    max_rho = [max_rho, max([rho_1, rho_2, rho_3])];

    % jacobian
    E = [0, -1; 1, 0];

    v_1 = (B_1-A_1)/norm(B_1-A_1);
    v_2 = (B_2-A_2)/norm(B_2-A_2);
    v_3 = (B_3-A_3)/norm(B_3-A_3);

    % paralel Jacobian

    A = [(v_1)',-(v_1)'*E*(P-B_1); ...
         (v_2)',-(v_2)'*E*(P-B_2); ...
         (v_3)',-(v_3)'*E*(P-B_3)];

    M = isnan(A);

    if(det(A) == 0 || any(M(:)))
      J = [];
      if(det(A) == 0)
        disp('Paralel singularity');
      else
        disp('any M');  
      end
      condList = [condList 1e-16];
    else
      % serial Jacobian 
      B = eye(3);

      % condition
      J = inv(A)*B;
      condList = [condList (conditionnement*cond(J)-1)];
    end

    if((conditionnement*cond(J)-1)>0)
        plot(P(1),P(2), '-+r', 'linewidth', 2); hold on;
    else
        plot(P(1),P(2), '-+k', 'linewidth', 2); hold on;
    end

  end
end

rectangle('Position',[D/2-0.5, D*sqrt(3)/6-0.5, 1, 1],'Curvature',1,'LineWidth',3)
title(strcat(['D = ',num2str(D),' and d = ',num2str(d)]))
axis equal