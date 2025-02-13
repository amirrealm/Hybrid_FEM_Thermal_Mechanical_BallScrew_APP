function [Parameters] = fc_Calculation_Parameters(Parameters)
% FC_CALCULATION_PARAMETERS - Computes various parameters related to contact mechanics,
% friction, lubrication, and material properties based on given geometric and material data.

%% Calculation of Contact Ellipse Dimensions (Hertzian Contact Theory)
% Parameter 'a' is the semi-major axis of the contact ellipse
Parameters.Calculation.Nut.a = (1.1552 * Parameters.Calculation.Nut.Rx * Parameters.Calculation.Nut.K^(0.4676)) * ...
                               (Parameters.Constant.Preload / (Parameters.Material.ElasticModulu_Ball_Nut * (Parameters.Calculation.Nut.Rx)^2))^(1/3);
                               
Parameters.Calculation.Screw.a = (1.1552 * Parameters.Calculation.Screw.Rx * Parameters.Calculation.Screw.K^(0.4676)) * ...
                                 (Parameters.Constant.Preload / (Parameters.Material.ElasticModulu_Ball_Screw * (Parameters.Calculation.Screw.Rx)^2))^(1/3);

% Parameter 'b' is the semi-minor axis of the contact ellipse
Parameters.Calculation.Nut.b = (1.1502 * Parameters.Calculation.Nut.Rx * Parameters.Calculation.Nut.K^(-0.1876)) * ...
                               (Parameters.Constant.Preload / (Parameters.Material.ElasticModulu_Ball_Nut * (Parameters.Calculation.Nut.Rx)^2))^(1/3);

Parameters.Calculation.Screw.b = (1.1502 * Parameters.Calculation.Screw.Rx * Parameters.Calculation.Screw.K^(-0.1876)) * ...
                                 (Parameters.Constant.Preload / (Parameters.Material.ElasticModulu_Ball_Screw * (Parameters.Calculation.Screw.Rx)^2))^(1/3);

%% Calculation of Contact Curvature Radius (Ra)
% Ra is the Hertzian radius of curvature of the elastic contact.
% Reference: Article "Ball Bearing and Tapered Roller Bearing Torque" - Luc Houpert
Parameters.Calculation.Ra = (Parameters.Geometry.D_Ball / 2) * ((1 + Parameters.Constant.Kapa) / (1 + (Parameters.Constant.Kapa / 2)));

%% Calculation of Equivalent Young's Modulus
% Reference: "Numerical and Analytical Calculation in Ball Bearings" - Luc Houpert
Parameters.Calculation.Nut.E_Surf = ((2 * Parameters.Calculation.Ra) / Parameters.Calculation.Nut.a) * ...
                                    (Parameters.Geometry.D_Ball * sind(Parameters.Geometry.AngleContact) / Parameters.Geometry.D_Screw);
                                    
Parameters.Calculation.Screw.E_Surf = ((2 * Parameters.Calculation.Ra) / Parameters.Calculation.Screw.a) * ...
                                      (Parameters.Geometry.D_Ball * sind(Parameters.Geometry.AngleContact) / Parameters.Geometry.D_Screw);

%% Curve Fitting for Hertzian Contact Model
% The coefficients for fc and fp are obtained from curve-fitting experimental data.
% Reference: "Numerical and Analytical Calculation in Ball Bearings" - Luc Houpert
Parameters.Calculation.Nut.fc = 1.0026 - 0.1653 * Parameters.Calculation.Nut.E_Surf - 0.2638 * Parameters.Calculation.Nut.E_Surf^2 - ...
                                2.5521 * Parameters.Calculation.Nut.E_Surf^3 + 1.9749 * Parameters.Calculation.Nut.E_Surf^4;
                                
Parameters.Calculation.Screw.fc = 1.0026 - 0.1653 * Parameters.Calculation.Screw.E_Surf - 0.2638 * Parameters.Calculation.Screw.E_Surf^2 - ...
                                  2.5521 * Parameters.Calculation.Screw.E_Surf^3 + 1.9749 * Parameters.Calculation.Screw.E_Surf^4;

Parameters.Calculation.Nut.fp = 0.0042 + 1.1045 * Parameters.Calculation.Nut.E_Surf + 0.4625 * Parameters.Calculation.Nut.E_Surf^2 - ...
                                0.5648 * Parameters.Calculation.Nut.E_Surf^3;
                                
Parameters.Calculation.Screw.fp = 0.0042 + 1.1045 * Parameters.Calculation.Screw.E_Surf + 0.4625 * Parameters.Calculation.Screw.E_Surf^2 - ...
                                  0.5648 * Parameters.Calculation.Screw.E_Surf^3;

%% Calculation of Friction Coefficient
% Reference: "Torque of Tapered Roller Bearing" - M.R. Hoeprich
% Friction coefficient estimated using an exponential fitting function
Parameters.Calculation.frictionCoefficient = exp(Parameters.Constant.friction_a + ...
                                                 (Parameters.Constant.friction_b * Parameters.Geometry.RotationSpeed) - ...
                                                 (Parameters.Constant.friction_c * Parameters.Geometry.RotationSpeed^2));

% Static and Ball-to-Ball Friction Coefficients
Parameters.Calculation.frictionCoefficientMuS = 0.11;  % Static friction coefficient
Parameters.Calculation.frictionCoefficientMb = 0.1;    % Ball-to-ball friction coefficient

%% Dimensionless Load Parameter (W)
% W represents the dimensionless load parameter in Hertzian contact theory
Parameters.Calculation.loadParameter_New.Nut = Parameters.Constant.Preload / ...
                                              (Parameters.Material.ElasticModulu_Ball_Nut * (Parameters.Calculation.Nut.Rx)^2);
Parameters.Calculation.loadParameter_New.Screw = Parameters.Constant.Preload / ...
                                                (Parameters.Material.ElasticModulu_Ball_Screw * (Parameters.Calculation.Screw.Rx)^2);

%% Viscosity Calculation
% Calls the function to calculate dynamic and static viscosity
Parameters = fc_Viscosity_Calculation(Parameters);

%% Speed Parameter Calculation
% Calls the function to compute the speed parameter
Parameters = fc_SpeedParameter_Calculation(Parameters);

%% Minimum Film Thickness Calculation (Lubrication)
% Computed using the Hamrock-Dowson relation for elastohydrodynamic lubrication (EHL)
Parameters.Calculation.Nut.h = 3.63 * Parameters.Calculation.Nut.Rx * ...
                               Parameters.Calculation.SpeedParameter_New.Nut^0.66 * ...
                               Parameters.Constant.G^0.49 * ...
                               Parameters.Calculation.loadParameter_New.Nut^-0.073 * ...
                               (1 - exp(-0.68 * Parameters.Calculation.Nut.a / Parameters.Calculation.Nut.b));

Parameters.Calculation.Screw.h = 3.63 * Parameters.Calculation.Screw.Rx * ...
                                 Parameters.Calculation.SpeedParameter_New.Screw^0.66 * ...
                                 Parameters.Constant.G^0.49 * ...
                                 Parameters.Calculation.loadParameter_New.Screw^-0.073 * ...
                                 (1 - exp(-0.68 * Parameters.Calculation.Screw.a / Parameters.Calculation.Screw.b));

%% Lubrication Regime Evaluation
% The lubricant parameter Lambda determines the lubrication regime.
% Lambda = Minimum film thickness / Combined surface roughness
Parameters.Calculation.Lambda.Nut = Parameters.Calculation.Nut.h / ...
                                    sqrt(Parameters.Geometry.RoughnessBall^2 + Parameters.Geometry.RoughnessNut^2);

Parameters.Calculation.Lambda.Screw = Parameters.Calculation.Screw.h / ...
                                      sqrt(Parameters.Geometry.RoughnessBall^2 + Parameters.Geometry.RoughnessScrew^2);

%% Friction Coefficient Due to Surface Roughness
% The friction coefficient in ball-race contacts is influenced by roughness.
% This section can be extended to incorporate empirical models for surface friction.

end
