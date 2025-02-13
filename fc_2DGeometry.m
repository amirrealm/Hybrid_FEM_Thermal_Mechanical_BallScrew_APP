function [] = fc_2DGeometry()
% FC_2DGEOMETRY - Generates the 2D geometry of a ball screw system.
% This function creates the profile of the ball screw, including the nut, flanges,
% left and right sections, ball profiles, and subtracts necessary parts using polybool operations.

    global Parameters Initial

    %% 1. Define Key Geometric Parameters
    alpha = Parameters.Geometry.AngleContact;    % Contact angle in degrees
    ball_radius = (Parameters.Geometry.D_Ball / 2) * 1000;   % Ball radius in mm
    Radius = Initial.Radius_Profile; % Profile radius in mm
    n = Initial.revolutions;         % Number of revolutions in the system

    %% 2. Define Nut Geometry
    % The nut's shape is defined as a rectangular polygon
    Ax = {[0 0 Initial.length_Nut_X Initial.length_Nut_X 0]};
    Ay = {[0 Initial.length_Nut_Y Initial.length_Nut_Y 0 0]};

    % Mesh size for discretization
    meshSize = Initial.meshSize;

    %% 3. Define Profile and Ball Coordinates
    % X and Y coordinates for the profile
    X_profile1 = Initial.X_profile1;  % X coordinate for profile (right direction)
    X_profile2 = Initial.X_profile2;  % X coordinate for profile (left direction)
    Y_profile = Initial.Y_profile;    % Y coordinate for profile

    % Ball center coordinates
    X_ball = Initial.X_ball;  % X coordinate for ball center
    Y_ball = Initial.Y_ball;  % Y coordinate for ball center

    %% 4. Define Flange, Left, and Right Sections
    % Define flange geometry
    Ax_Flang = {[0 0 Initial.Ax_Flang Initial.Ax_Flang 0]};
    Ay_Flang = {[0 Initial.Ay_Flang Initial.Ay_Flang 0 0]};

    % Define left section geometry
    Ax_left = {[0 0 Initial.Ax_left Initial.Ax_left 0]};
    Ay_left = {[0 Initial.Ay_left Initial.Ay_left 0 0]};

    % Define right section geometry
    Ax_right = {[Initial.Ax_right Initial.Ax_right Initial.length_Nut_X Initial.length_Nut_X Initial.Ax_right]};
    Ay_right = {[0 Initial.Ay_right Initial.Ay_right 0 0]};

    %% 5. Apply Boolean Operations to Construct the Final Nut Geometry
    % The 'union' operation adds the flange to the main nut shape
    [Ax, Ay] = polybool('union', Ax, Ay, Ax_Flang, Ay_Flang);

    % The 'subtraction' operation removes the left and right sections from the nut
    [Ax, Ay] = polybool('subtraction', Ax, Ay, Ax_left, Ay_left);
    [Ax, Ay] = polybool('subtraction', Ax, Ay, Ax_right, Ay_right);

    %% 6. Generate Ball Profiles and Compute Contact Points
    % Loop to define the profiles for each revolution
    p = 0;
    Cx = {}; Cy = {}; % Initialize cell arrays for geometry storage
    theta = linspace(0, 2 * pi, 100);  % Angular positions for circular profiles

    for i = 1:n
        % Define the right profile for each revolution
        x1{1, i} = Radius * cos(theta) + (X_profile1 + p);
        y1{1, i} = -Radius * sin(theta) - Y_profile;  % Negative sign ensures correct orientation

        % Compute the ball contact points
        D(1, i) = (X_ball + p) + (ball_radius * sind(alpha));  % X coordinate of contact point
        D(2, i) = ball_radius * cosd(alpha) - Y_ball;          % Y coordinate of contact point

        % Increment pitch for the next revolution
        p = p + (Parameters.Geometry.Pitch * 1000);
    end

    % Subtract ball profiles from nut geometry
    [Cx, Cy] = polybool('subtraction', Ax, Ay, x1, y1);

    %% 7. Generate the Left Profile and Subtract it from the Geometry
    p = 0;
    for j = 1:n
        % Define the left profile for each revolution
        x1{1, j} = Radius * cos(theta) + (X_profile2 + p);
        y1{1, j} = -Radius * sin(theta) - Y_profile;

        % Increment pitch for the next revolution
        p = p + (Parameters.Geometry.Pitch * 1000);
    end

    % Subtract left-side profiles from nut geometry
    [Cx, Cy] = polybool('subtraction', Ax, Ay, x1, y1);

    %% 8. Create a Triangular Mesh for the 2D Geometry
    % Convert the resulting geometry into a polygon shape
    pg = polyshape(Cx, Cy);

    % Generate a triangulation for the geometry
    tr = triangulation(pg);

    %% 9. Store Results in Global Parameters
    % Save the final 2D geometry points and contact point data
    Parameters.Point2D = tr;
    Parameters.EndPointRadius = D;
    Parameters.CxGeometry = Cx;
    Parameters.CyGeometry = Cy;

end
