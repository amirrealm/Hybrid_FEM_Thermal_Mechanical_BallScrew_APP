function Initial = initializeParameters()
% INITIALIZEPARAMETERS - Initializes global parameters for simulation.
% This function defines various physical, thermal, and geometric properties.

    global Initial

    % General Physical Properties
    Initial.T0 = 25;                     % Initial temperature (°C)
    Initial.F_preload = 1275;             % Preload force (N)
    Initial.Density = 7.872;              % Material density (g/cm³)
    Initial.k = 40;                       % Thermal conductivity (W/mK), range: 36-43
    Initial.Cp = 448;                     % Specific heat capacity (J/kgK)

    % Geometric Parameters (Profile)
    Initial.Radius_Profile = 2.209;       % Profile radius (mm)
    Initial.X_profile1 = 12.501;          % X-coordinate of profile (right) (mm)
    Initial.X_profile2 = 11.499;          % X-coordinate of profile (left) (mm)
    Initial.Y_profile = 1.101;            % Y-coordinate of profile (mm)

    % Ball Parameters
    Initial.X_ball = 12;                  % X-coordinate of ball center (mm)
    Initial.Y_ball = 0.5;                 % Y-coordinate of ball center (mm)

    % Nut Dimensions
    Initial.length_Nut_X = 54;            % Nut length in X direction (mm)
    Initial.length_Nut_Y = 5;             % Nut length in Y direction (mm)

    % Flange Parameters
    Initial.Ax_Flang = 12;                % X-coordinate of flange (mm)
    Initial.Ay_Flang = 14;                % Y-coordinate of flange (mm) (depends on catalog)

    % Left and Right Sections
    Initial.Ax_left = 0.1 * Initial.length_Nut_X;  % X left part (mm)
    Initial.Ay_left = 2;                            % Y left part (mm)
    Initial.Ax_right = Initial.length_Nut_X - Initial.Ax_left; % X right part (mm)
    Initial.Ay_right = 2;                           % Y right part (mm)

    % Motion & Revolutions
    Initial.revolutions = 4;              % Number of revolutions 
    Initial.Rotation = 1800;              % Rotation speed (RPM)

    % Thermal Properties
    Initial.meshSize = 0.5;               % Mesh size (mm)
    Initial.ThermalConductivity = 45;     % Thermal conductivity (W/mK)
    Initial.SpecificHeat = 477;           % Specific heat capacity (J/kgK)
    Initial.CTE = 15E-6;                  % Coefficient of thermal expansion (1/K)
    Initial.L = 3.941;                    % Length change (mm)
    Initial.thermalVal = 25;              % Thermal value (°C)
    Initial.Q = 0;                        % Heat source (J)

    % Contact Parameters
    Initial.ball_storage = 5;             % Number of balls in storage
    Initial.CE = 0.464;                   % Elastic constant coefficient
    Initial.CK = 1.758;                   % Stiffness coefficient
    Initial.angle = 45;                   % Contact angle (degrees)
    Initial.frs = 0.55;                   % Friction coefficient (static)
    Initial.fm = 0.55;                    % Friction coefficient (dynamic)

end
