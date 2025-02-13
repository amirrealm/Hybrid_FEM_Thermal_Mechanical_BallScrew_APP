function [Stiff] = fc_stiff(L_new)
% FC_STIFF - Computes the stiffness of a ball screw system based on 
% updated length and contact geometry changes due to thermal expansion.
%
% Inputs:
%   L_new - Updated system length after thermal expansion
%
% Outputs:
%   Stiff - Computed stiffness of the ball screw system

    global Initial Parameters

    %% 1. Update Contact Angle Based on New Length
    % The contact angle is updated using the ratio of the new length to the initial length.
    Parameters.Geometry.AngleContact = atand(L_new / Initial.L);

    %% 2. Compute Radii of Curvature for the Screw (Ro_s) and Nut (Ro_n)
    % These are used in the stiffness calculations for ball-raceway contacts.

    % Radius of curvature at the screw contact point
    Ro_s = (4 / (Parameters.Geometry.D_Ball * 1000)) - ...
           (1 / (Initial.frs * (Parameters.Geometry.D_Ball * 1000))) + ...
           (2 * cosd(45)) / ((Parameters.Geometry.D_Screw2 * 1000) - ...
           ((Parameters.Geometry.D_Ball * 1000) * cosd(45)));

    % Radius of curvature at the nut contact point
    Ro_n = (4 / (Parameters.Geometry.D_Ball * 1000)) - ...
           (1 / (Initial.frs * (Parameters.Geometry.D_Ball * 1000))) - ...
           (2 * cosd(45)) / ((Parameters.Geometry.D_Screw2 * 1000) + ...
           ((Parameters.Geometry.D_Ball * 1000) * cosd(45)));

    %% 3. Compute Tangential Contact Coefficients (Co_ts and Co_tn)
    % These coefficients describe how much of the force is directed tangentially in the contact.
    Co_ts = abs(((-1 / (Initial.frs * (Parameters.Geometry.D_Ball * 1000))) - ...
                 (2 * cosd(45)) / ((Parameters.Geometry.D_Screw2 * 1000) - ...
                 ((Parameters.Geometry.D_Ball * 1000) * cosd(45)))) / Ro_s);

    Co_tn = abs(((-1 / (Initial.frs * (Parameters.Geometry.D_Ball * 1000))) + ...
                 (2 * cosd(45)) / ((Parameters.Geometry.D_Screw2 * 1000) + ...
                 ((Parameters.Geometry.D_Ball * 1000) * cosd(45)))) / Ro_n);

    %% 4. Compute Sinusoidal Contact Coefficients
    % These coefficients describe the normal force component in the contact region.
    Si_ts = sqrt(1 - (Co_ts^2));
    Si_tn = sqrt(1 - (Co_tn^2));

    %% 5. Compute Contact Load Coefficients (Y_s and Y_n)
    % The load distribution factors are used to determine stiffness in rolling contacts.
    % Reference: Contact mechanics equations for rolling elements.
    Y_s = 1.282 * ((-0.154 * (Si_ts)^(1/4)) + (1.348 * (Si_ts)^(1/2)) - (0.194 * Si_ts));
    Y_n = 1.282 * ((-0.154 * (Si_tn)^(1/4)) + (1.348 * (Si_tn)^(1/2)) - (0.194 * Si_tn));

    %% 6. Compute CK - Load Distribution Coefficient
    CK = Y_s * (Ro_s^(1/3)) + Y_n * (Ro_n^(1/3));

    %% 7. Compute CE - Contact Elasticity Coefficient
    % CE is calculated using Young’s modulus of the nut and ball materials.
    CE = ((11550 * ((Parameters.Material.ElasticModulu_Ball_Nut * 1000) + ...
          (Parameters.Material.ElasticModulu_Ball_Nut * 1000))) / ...
          ((Parameters.Material.ElasticModulu_Ball_Nut * 1000) * ...
          (Parameters.Material.ElasticModulu_Ball_Nut * 1000)))^(1/3) * 1000;

    %% 8. Compute Zt - Number of Load-Bearing Balls
    % This formula approximates the number of balls actively involved in load transmission.
    Zt = round(((pi * Parameters.Geometry.D_Screw2) / ...
          ((cosd(Parameters.Geometry.Anglepitch) * Parameters.Geometry.D_Ball))) - ...
          Initial.ball_storage);

    %% 9. Compute Stiffness of the Ball Screw System
    % The final stiffness calculation considers:
    % - Number of load-bearing balls (Zt)
    % - Contact angle effects (sind^2.5)
    % - Pitch angle effects (cosd^2.5)
    % - Elasticity and load distribution coefficients (CE, CK)
    Stiff = ((Zt * (sind(Parameters.Geometry.AngleContact)^(2.5)) * ...
              (cosd(Parameters.Geometry.Anglepitch)^(2.5))) / ...
              (((CE * 1e-1)^3) * ((CK * 1e-1)^(1.5)))) / 1e3;

end
