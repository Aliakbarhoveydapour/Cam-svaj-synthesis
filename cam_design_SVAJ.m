% =========================================================================
% Cam Design - S V A J Diagrams
% Author: Aliakbar Hoveydapour
%
% Multi-segment cam motion synthesis:
%   Segment 1 (0-60 deg)    : 4-5-6-7 Polynomial Rise   (0 -> 20.5 mm)
%   Segment 2 (60-150 deg)  : Cycloidal Return           (20.5 -> 5.5 mm)
%   Segment 3 (150-260 deg) : Cycloidal Rise              (5.5 -> 20.5 mm)
%   Segment 4 (260-360 deg) : Dwell                       (20.5 mm)
%
% =========================================================================

clear; clc; close all;

omega = 250 * (2 * pi / 60);   % cam angular velocity, rad/s (250 rpm)

% Segment angular spans (radians)
beta1 = deg2rad(60);    % Segment 1: polynomial rise
beta2 = deg2rad(90);    % Segment 2: cycloidal return
beta3 = deg2rad(110);   % Segment 3: cycloidal rise
beta4 = deg2rad(100);   % Segment 4: dwell

% Lift values (mm)
h1_rise   = 20.5;   % total rise, segment 1 (0 -> 20.5)
h2_fall   = 15.0;   % total fall, segment 2 (20.5 -> 5.5)
h3_rise   = 15.0;   % total rise, segment 3 (5.5 -> 20.5)
S_dwell   = 20.5;   % dwell height, segment 4

% Angle grid
N = 1000;
theta_deg = linspace(0, 360, N);
S_vals = zeros(1, N);
V_vals = zeros(1, N);
A_vals = zeros(1, N);
J_vals = zeros(1, N);

for i = 1:N
    d = theta_deg(i);

    if d <= 60
        % --- Segment 1: 4-5-6-7 Polynomial Rise ---
        theta = deg2rad(d);
        x = theta / beta1;
        S_vals(i) =  h1_rise * (35*x^4 - 84*x^5 + 70*x^6 - 20*x^7);
        V_vals(i) =  h1_rise * (omega/beta1)   * (140*x^3 - 420*x^4 + 420*x^5 - 140*x^6);
        A_vals(i) =  h1_rise * (omega/beta1)^2 * (420*x^2 - 1680*x^3 + 2100*x^4 - 840*x^5);
        J_vals(i) =  h1_rise * (omega/beta1)^3 * (840*x - 5040*x^2 + 8400*x^3 - 4200*x^4);

    elseif d <= 150
        % --- Segment 2: Cycloidal Return (fall) ---
        theta = deg2rad(d - 60);
        x = theta / beta2;
        S_vals(i) = h1_rise - h2_fall * (x - (1/(2*pi))*sin(2*pi*x));
        V_vals(i) = -h2_fall * (omega/beta2)   * (1 - cos(2*pi*x));
        A_vals(i) = -h2_fall * (omega/beta2)^2 * (2*pi*sin(2*pi*x));
        J_vals(i) = -h2_fall * (omega/beta2)^3 * (4*pi^2*cos(2*pi*x));

    elseif d <= 260
        % --- Segment 3: Cycloidal Rise (was SHM; changed to fix
        %     acceleration discontinuity, see header note) ---
        theta = deg2rad(d - 150);
        x = theta / beta3;
        S_vals(i) = (h1_rise - h2_fall) + h3_rise * (x - (1/(2*pi))*sin(2*pi*x));
        V_vals(i) =  h3_rise * (omega/beta3)   * (1 - cos(2*pi*x));
        A_vals(i) =  h3_rise * (omega/beta3)^2 * (2*pi*sin(2*pi*x));
        J_vals(i) =  h3_rise * (omega/beta3)^3 * (4*pi^2*cos(2*pi*x));

    else
        % --- Segment 4: Dwell ---
        S_vals(i) = S_dwell;
        V_vals(i) = 0;
        A_vals(i) = 0;
        J_vals(i) = 0;
    end
end

% ---------------------- Plotting: S V A J ----------------------
figure('Position', [100, 100, 600, 800]);

subplot(4, 1, 1);
plot(theta_deg, S_vals, 'b', 'LineWidth', 1.5);
ylabel('S (mm)');
title('Cam Kinematic Diagrams');
grid on; xlim([0 360]);

subplot(4, 1, 2);
plot(theta_deg, V_vals, 'r', 'LineWidth', 1.5);
ylabel('V (mm/s)');
grid on; xlim([0 360]);

subplot(4, 1, 3);
plot(theta_deg, A_vals, 'g', 'LineWidth', 1.5);
ylabel('A (mm/s^2)');
grid on; xlim([0 360]);

subplot(4, 1, 4);
plot(theta_deg, J_vals, 'k', 'LineWidth', 1.5);
ylabel('J (mm/s^3)');
xlabel('Cam Angle (degrees)');
grid on; xlim([0 360]);

% ---------------------- Save figure ----------------------
saveas(gcf, 'SVAJ_diagrams.png');
