function [Torque] = fc_Torque(Parameters, Forces)
% FC_TORQUE - Computes different torque components in a ball-screw system.
% The torque calculations include friction moments due to curvature, pivoting effects,
% elastic resistance, and braking moment.

    global Torque

    %% Friction Moment Due to Curvature (MC)
    % MC represents the friction torque due to the elliptical shape of the contact area.
    % Reference: Article 5 on friction moment calculations.
    Torque.MC.Nut = 0.0806 * Parameters.Calculation.frictionCoefficient * Parameters.Constant.Preload * ...
                    (Parameters.Calculation.Nut.a^2 / Parameters.Calculation.Ra) * Parameters.Calculation.Nut.fc;

    Torque.MC.Screw = 0.0806 * Parameters.Calculation.frictionCoefficient * Parameters.Constant.Preload * ...
                      (Parameters.Calculation.Screw.a^2 / Parameters.Calculation.Ra) * Parameters.Calculation.Screw.fc;

    %% Friction Moment Due to Pivoting Effects (MP)
    % MP represents the additional friction moment caused by the pivoting of the rolling elements.
    % Reference: Article 5 on friction moment calculations.
    Torque.MP.Nut = (3/8) * Parameters.Calculation.frictionCoefficient * Parameters.Constant.Preload * ...
                    (Parameters.Calculation.Nut.a) * Parameters.Calculation.Nut.fp;

    Torque.MP.Screw = (3/8) * Parameters.Calculation.frictionCoefficient * Parameters.Constant.Preload * ...
                      (Parameters.Calculation.Screw.a) * Parameters.Calculation.Screw.fp;

    %% Elastic Resistance of Pure Rolling (MER)
    % MER accounts for the resistance due to elastic deformation during rolling motion.
    % It is influenced by the contact stiffness, friction coefficient, and ball size.
    Torque.MER.Nut = 7.48e-7 * (Parameters.Geometry.D_Ball / 2)^0.33 * ...
                     Parameters.Constant.Preload^1.33 * ...
                     (1 - 3.519e-36 * (Parameters.Calculation.Nut.K - 1)^0.806 * ...
                     (Parameters.Calculation.frictionCoefficientMuS / 0.11));

    Torque.MER.Screw = 7.48e-7 * (Parameters.Geometry.D_Ball / 2)^0.33 * ...
                       Parameters.Constant.Preload^1.33 * ...
                       (1 - 3.519e-36 * (Parameters.Calculation.Screw.K - 1)^0.806 * ...
                       (Parameters.Calculation.frictionCoefficientMuS / 0.11));

    %% Braking Moment (MB)
    % MB represents the braking moment applied outside the rolling element center.
    % It depends on the friction coefficient between contacting balls, ball diameter, and applied force.
    % Equation: MB = Mub * dw/2 * FB
    Torque.MB = Parameters.Calculation.frictionCoefficientMb * (Parameters.Geometry.D_Ball / 2) * Forces.FB;

end
