function [] = fc_TempFriction()
% FC_TEMPFICTION - Computes the frictional heat generation and its effect 
% on temperature in a ball-screw system.
% The function estimates temperature rise due to frictional heat at the contact points.

    global Parameters Friction Initial

    %% Calculation of Nut Speed (speed_Nut)
    % The speed of the nut is calculated based on the rotational speed and pitch of the screw.
    % Formula: speed_Nut = (Rotation Speed * Pitch) / 60
    % Units: [mm/min] converted to [m/s]
    Parameters.Calculation.speed_Nut = (Parameters.Geometry.RotationSpeed * (Parameters.Geometry.Pitch * 1000)) / 60;

    %% Frictional Heat Generation per Unit Contact Area (q_nut)
    % q_nut represents the heat flux (Watt) generated due to friction at the nut contact area.
    % It is computed based on the frictional torque, semi-major axis (a), semi-minor axis (b),
    % and the nut speed.
    q_nut = (1000 * Friction.Torque.Nut / (pi * Parameters.Calculation.Nut.a * Parameters.Calculation.Nut.b)) * ...
            (Parameters.Calculation.speed_Nut / 1000);  % Heat flux in Watts

    %% Calculation of Contact Ellipse Shape Factor (se)
    % The shape factor se is based on the ratio of the semi-major axis (a) to the semi-minor axis (b).
    % Reference: Contact mechanics for elliptical Hertzian contact areas.
    ee = (Parameters.Calculation.Nut.a) / Parameters.Calculation.Nut.b;
    se = (16 * (ee)^1.75) / ((3 + (ee)^0.75) * (1 + (3 * (ee)^0.75)));

    %% Thermal Diffusivity Coefficient (Alpha_Kappa)
    % Alpha_Kappa is computed using the thermal conductivity (k), specific heat capacity (Cp),
    % and density of the material.
    % Formula: Alpha_Kappa = k / (Cp * density)
    Alpha_Kappa = Initial.k / (Initial.Cp * Parameters.Constant.density);

    %% Peclet Number (pe) for Thermal Diffusion
    % The Peclet number represents the ratio of heat conduction to heat diffusion.
    % It is dependent on the nut speed, semi-minor axis (b), and thermal diffusivity.
    pe = ((Parameters.Calculation.speed_Nut / 1000) * Parameters.Calculation.Nut.b) / (2 * Alpha_Kappa);

    %% Maximum Contact Temperature Rise (T_max)
    % The maximum temperature rise at the contact point is computed based on heat flux,
    % thermal conductivity, and the shape factor se.
    T_max = (2 * q_nut * (Parameters.Calculation.Nut.a)) / ...
            (Initial.k * (sqrt(pi * (1.273 * se + pe))));

    %% Update Initial Temperature Values
    % The computed temperature rise is assigned to the system's initial temperature parameters.
    Initial.thermalVal = T_max;
    Initial.T0 = T_max;

    %% Heat Generation Output (Q)
    % The total heat generated due to friction is stored in Initial.Q (converted to kW).
    Initial.Q = q_nut * 1e-3;  % Convert from Watts to kW

end
