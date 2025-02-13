function [Parameters] = fc_Viscosity_Calculation(Parameters)
% FC_VISCOSITY_CALCULATION - Computes the viscosity of the lubricant 
% at atmospheric pressure and at the contact temperature.
% The calculation is based on empirical models for lubrication dynamics.

    %% Calculation of Parameter B for Viscosity Equation
    % Parameter B is derived using the static viscosity, density, and a reference constant.
    % The logarithm term is used to model the behavior of viscosity with respect to pressure.
    Parameters.Calculation.Viscosity.ParameterB = 159.6 * log( ...
        (Parameters.Material.ViskosStatics * Parameters.Material.Density) / (1.8 * 10^-4));

    %% Calculation of Parameter A for Viscosity Equation
    % Parameter A is derived using an exponential function to model the dependence of viscosity
    % on temperature and lubrication properties.
    Parameters.Calculation.Viscosity.ParameterA = Parameters.Material.ViskosStatics * ...
        Parameters.Material.Density * exp(-Parameters.Calculation.Viscosity.ParameterB / 135);

    %% Computation of New Viscosity at the Updated Temperature
    % The final viscosity is calculated using the empirical model with the new temperature input.
    Parameters.Calculation.ViscosityNew = (Parameters.Calculation.Viscosity.ParameterA * ...
        exp(Parameters.Calculation.Viscosity.ParameterB / (Parameters.Constant.TemperatureNew + 95))) ...
        / Parameters.Material.Density;

end
