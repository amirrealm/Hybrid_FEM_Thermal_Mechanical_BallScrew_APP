function [Parameters] = fc_SpeedParameter_Calculation(Parameters)
% FC_SPEEDPARAMETER_CALCULATION - Computes the dimensionless speed parameter (U) 
% for the nut and screw based on viscosity, speed, elasticity, and rolling radius.
% The speed parameter is an essential factor in elastohydrodynamic lubrication (EHL) analysis.

    %% Calculation of Dimensionless Speed Parameter (U)
    % U represents the speed parameter and is defined as the ratio of dynamic viscosity 
    % times rolling speed to the product of the material's elastic modulus and contact radius.
    % Reference: Elastohydrodynamic lubrication (EHL) theory.

    % Speed parameter for nut
    Parameters.Calculation.SpeedParameter_New.Nut = ...
        (Parameters.Calculation.ViscosityNew * Parameters.Calculation.Speed) / ...
        (Parameters.Material.ElasticModulu_Ball_Nut * Parameters.Calculation.Nut.Rx);

    % Speed parameter for screw
    Parameters.Calculation.SpeedParameter_New.Screw = ...
        (Parameters.Calculation.ViscosityNew * Parameters.Calculation.Speed) / ...
        (Parameters.Material.ElasticModulu_Ball_Screw * Parameters.Calculation.Screw.Rx);

end
