function [Parameters] = fc_Constant_Parameters()
% FC_CONSTANT_PARAMETERS - Initializes and computes constant parameters 
% related to geometry, material properties, and rolling contact mechanics.
% This function defines parameters used in calculations for forces, torque, and friction.

    global Initial

    % Extract initial values from global Initial struct
    T0 = Initial.T0;                 % Initial temperature (°C)
    F_preload = Initial.F_preload;   % Preload force (N)

    % ---------------- GEOMETRIC PARAMETERS ----------------
    Parameters.Geometry.D_Screw = 25 / 1000;        % Screw diameter (m)
    Parameters.Geometry.D_Screw2 = 27 / 1000;       % Secondary screw diameter (m)
    Parameters.Geometry.D_Ball = 3 / 1000;          % Ball diameter (m)
    Parameters.Geometry.Pitch = 10 / 1000;          % Screw pitch (m)
    Parameters.Geometry.Mass_table = 0.5;          % Table mass (kg)
    Parameters.Geometry.AngleContact = 45;         % Contact angle (degrees)

    % Lead angle (pitch angle) of the screw
    Parameters.Geometry.Anglepitch = atand(...
                                Parameters.Geometry.Pitch / ...
                                (pi * Parameters.Geometry.D_Screw2)); % Pitch angle (degrees)

    % Length of the nut (single unit) in meters
    Parameters.Geometry.LengthNut = 133 / (2 * 1000);  

    % Helix length calculation for the screw
    Parameters.Geometry.LenghtHelix = ((Parameters.Geometry.LengthNut) / ...
                                       Parameters.Geometry.Pitch) * ...
                                       sqrt((pi * Parameters.Geometry.D_Screw)^2 + ...
                                       (Parameters.Geometry.Pitch)^2);

    % Number of balls in the nut raceway
    Parameters.Geometry.BallNumber = round(Parameters.Geometry.LenghtHelix / Parameters.Geometry.D_Ball);

    % Load-bearing fraction of balls (usually between 0.7 to 0.95)
    Parameters.Geometry.fz = 0.7; 

    % Effective number of load-bearing balls
    Parameters.Geometry.Zt = Parameters.Geometry.fz * Parameters.Geometry.BallNumber;

    % Rotational speed of the screw
    Parameters.Geometry.RotationSpeed = Initial.Rotation;  

    % Surface roughness values (m)
    Parameters.Geometry.RoughnessBall = 8e-8;
    Parameters.Geometry.RoughnessScrew = 3e-7;
    Parameters.Geometry.RoughnessNut = 3e-7;

    % ---------------- MATERIAL PROPERTIES ----------------
    % Elastic modulus for screw, balls, and nut (Pa)
    Parameters.Material.ElasticModulusScrew = 2.1e11;  
    Parameters.Material.ElasticModulusBall = 2.1e11;  
    Parameters.Material.ElasticModulusNut = 2.1e11;  

    % Poisson's ratio for screw, balls, and nut
    Parameters.Material.PoissinModulusScrew = 0.3;  
    Parameters.Material.PoissinModulusBall = 0.3;   
    Parameters.Material.PoissinModulusNut = 0.3;   

    % Viscosity properties
    Parameters.Material.ViskosStatics = 68e-6;   % Static viscosity (m²/s)
    Parameters.Material.ViskosDynamics = 0.05;   % Dynamic viscosity 

    % Material density (kg/m³)
    Parameters.Material.Density = Initial.Density;

    % ---------------- CONSTANT PARAMETERS ----------------
    Parameters.Constant.G = 0.4276;  % Dimensionless material constant
    Parameters.Constant.F_nut_Screw = 0.515; % Curvature parameter (0.515 - 0.54)

    % Temperature-related constants
    Parameters.Constant.TemperatureInput = 25; % Input temperature (°C)
    Parameters.Constant.TemperatureNew = Initial.thermalVal;  % Updated temperature (°C)

    % Rotational speed (rpm)
    Parameters.Constant.RotationalSpeed = Parameters.Geometry.RotationSpeed;

    % Preload force calculations
    Parameters.Constant.Preload1 = ((F_preload) / ...
                                   (cosd(Parameters.Geometry.Anglepitch) * ...
                                    sind(Parameters.Geometry.AngleContact)));  

    Parameters.Constant.Preload2 = ((Parameters.Geometry.Mass_table * 9.8) / ...
                                   (cosd(Parameters.Geometry.Anglepitch) * ...
                                    sind(Parameters.Geometry.AngleContact)));

    % Total preload force (N)
    Parameters.Constant.Preload = Parameters.Constant.Preload1 + Parameters.Constant.Preload2;

    % Friction coefficients (empirical values)
    Parameters.Constant.friction_a = -2.643;
    Parameters.Constant.friction_b = -0.002;
    Parameters.Constant.friction_c = 4.983e-7;

    % Contact curvature radius factor (ranges from 0.02 to 0.1, typical = 0.05)
    Parameters.Constant.Kapa = 0.05; 

    % Density parameter (same as material density)
    Parameters.Constant.density = Initial.Density;

    % Contact roughness parameters
    Parameters.Constant.B = 1.42;  
    Parameters.Constant.C = 0.8;   

    % Reference friction coefficient (empirical value)
    Parameters.Constant.Mu0 = 0.2;  

    % ---------------- CALCULATED VARIABLES ----------------
    % Equivalent rolling radius in the nut-screw contact
    Parameters.Calculation.Nut.Rx = ((2 / Parameters.Geometry.D_Ball) - ...
                                    (2 * cosd(Parameters.Geometry.AngleContact) / ...
                                    (Parameters.Geometry.D_Screw + ...
                                    (Parameters.Geometry.D_Ball * cosd(Parameters.Geometry.AngleContact)))))^-1;

    % Equivalent rolling radius in the screw contact
    Parameters.Calculation.Screw.Rx = ((2 / Parameters.Geometry.D_Ball) + ...
                                      (2 * cosd(Parameters.Geometry.AngleContact) / ...
                                      (Parameters.Geometry.D_Screw - ...
                                      (Parameters.Geometry.D_Ball * cosd(Parameters.Geometry.AngleContact)))))^-1;

    % Transversal equivalent radius for nut and screw
    Parameters.Calculation.Nut.Ry = ((Parameters.Constant.F_nut_Screw * Parameters.Geometry.D_Ball) / ...
                                    (2 * Parameters.Constant.F_nut_Screw - 1));

    Parameters.Calculation.Screw.Ry = ((Parameters.Constant.F_nut_Screw * Parameters.Geometry.D_Ball) / ...
                                      (2 * Parameters.Constant.F_nut_Screw - 1));

    % Radii ratio (K)
    Parameters.Calculation.Nut.K = Parameters.Calculation.Nut.Ry / Parameters.Calculation.Nut.Rx;
    Parameters.Calculation.Screw.K = Parameters.Calculation.Screw.Ry / Parameters.Calculation.Screw.Rx;

    % Young's modulus between nut and ball
    Parameters.Material.ElasticModulu_Ball_Nut = 2 * (((1 - (Parameters.Material.PoissinModulusBall)^2) / ...
                                                     (Parameters.Material.ElasticModulusBall)) + ...
                                                     ((1 - (Parameters.Material.PoissinModulusNut)^2) / ...
                                                     (Parameters.Material.ElasticModulusNut)))^-1;

    % Young's modulus between screw and ball
    Parameters.Material.ElasticModulu_Ball_Screw = 2 * (((1 - (Parameters.Material.PoissinModulusBall)^2) / ...
                                                       (Parameters.Material.ElasticModulusBall)) + ...
                                                       ((1 - (Parameters.Material.PoissinModulusScrew)^2) / ...
                                                       (Parameters.Material.ElasticModulusScrew)))^-1;

    % Tangential speed in ball-race rolling direction
    Parameters.Calculation.Speed = (pi * (convangvel(Parameters.Constant.RotationalSpeed, 'rpm', 'rad/s') / 30)) * ...
                                   (1 - ((Parameters.Geometry.D_Ball * cosd(Parameters.Geometry.AngleContact)) / Parameters.Geometry.D_Screw)^2) * ...
                                   (Parameters.Geometry.D_Screw / 4);

    % Deformed radius in ball-race contact
    Parameters.Calculation.Nut.Rd = (2 * Parameters.Geometry.D_Ball * Parameters.Constant.F_nut_Screw) / ...
                                    (2 * Parameters.Constant.F_nut_Screw + 1);

    Parameters.Calculation.Screw.Rd = (2 * Parameters.Geometry.D_Ball * Parameters.Constant.F_nut_Screw) / ...
                                      (2 * Parameters.Constant.F_nut_Screw + 1);

    % Mass of a single ball (kg)
    Parameters.Calculation.Mass = Parameters.Constant.density * (4 / 3) * pi * (Parameters.Geometry.D_Ball / 2)^3;

end
