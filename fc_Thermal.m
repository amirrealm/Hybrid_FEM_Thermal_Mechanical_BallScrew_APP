function [] = fc_Thermal()
% FC_THERMAL - Performs a transient thermal-structural analysis of a ball-screw system.
% This function simulates temperature distribution, thermal expansion, 
% and its effect on mechanical properties such as preload force and stiffness.

    global Initial Parameters Data

    fact = sqrt(1000) / 2;  % Scaling factor for stiffness calculation
    time = 10;  % Number of simulation steps

    % Define thermal boundary conditions on selected edges
    % Termalelement represents the edge indices for thermal boundaries
    Termalelement = [4 5 8 9 10 11 12 15 16 17 18 23];

    %% 1. Create and Set Up Thermal Model
    thermalmodel = createpde('thermal', 'transient');
    
    % Import geometry from existing finite element mesh
    thermalmodel.geometryFromMesh(Parameters.MeshBasic.Points', Parameters.MeshBasic.ConnectivityList');

    % Define thermal properties (conductivity, density, and specific heat)
    thermalProperties(thermalmodel, 'ThermalConductivity', Initial.ThermalConductivity, ...
                                  'MassDensity', Initial.Density, ...
                                  'SpecificHeat', Initial.SpecificHeat);

    % Apply thermal boundary condition: Set fixed temperature
    thermalBC(thermalmodel, 'Edge', Termalelement, 'Temperature', Initial.thermalVal);  

    % Apply initial temperature condition
    thermalIC(thermalmodel, 25);  % Initial temperature in °C

    % Generate mesh for thermal analysis
    generateMesh(thermalmodel, 'Hmax', Initial.meshSize);

    % Uncomment for debugging and visualization:
    % figure
    % pdegplot(thermalmodel, 'EdgeLabels', 'on');  % Display edge labels
    % figure
    % pdemesh(thermalmodel);  % Display mesh

    %% 2. Solve the Transient Thermal Model
    tlist = 0:1;  % Time stepping for transient analysis
    thermalresults = solve(thermalmodel, tlist);
    T = thermalresults.Temperature(:, end);  % Extract final temperature distribution

    %% 3. Create Structural Model and Apply Thermal Expansion Effects
    model = createpde('structural', 'static-planestress');
    
    % Assign geometry and mesh from thermal model
    model.Geometry = thermalmodel.Geometry;
    model.Mesh = thermalmodel.Mesh;

    % Define structural properties
    structuralProperties(model, 'YoungsModulus', Parameters.Material.ElasticModulusNut, ...
                                'PoissonsRatio', Parameters.Material.PoissinModulusNut, ...
                                'CTE', Initial.CTE);  % Coefficient of thermal expansion

    % Set reference temperature
    model.ReferenceTemperature = 25;  % °C

    % Apply thermal stress as a body load
    structuralBodyLoad(model, 'Temperature', thermalresults);

    % Apply boundary conditions (fixed constraints)
    structuralBC(model, 'Edge', [Termalelement, 26], 'Constraint', 'fixed');

    % Solve for thermal stress and expansion
    thermalstressresults = solve(model);
    displacement_x = thermalstressresults.Displacement.ux;
    displacement_y = thermalstressresults.Displacement.uy;

    %% 4. Calculate Geometric and Mechanical Effects
    % Identify nodes on edge 2 (for expansion tracking)
    Nf = findNodes(thermalmodel.Mesh, 'region', 'Edge', 2);
    
    % Compute expansion effects based on displacement
    A = thermalmodel.Mesh.Nodes(:, Nf)';
    B = displacement_x(Nf, 1);
    X = A(:, 1) + B;
    Xbund = [A(:, 1); X];
    Ybund = [A(:, 2); A(:, 2)];
    k = boundary(Xbund, Ybund);

    % Compute the change in contact area due to thermal expansion
    Ra = polyarea(Xbund(k), Ybund(k));

    % Compute new effective length after thermal expansion
    L_new = (Initial.L) - (Ra * fact);

    % Compute updated mechanical stiffness
    [Stiff] = fc_stiff(L_new);

    % Compute updated preload force
    Initial.F_preload = sqrt(((L_new * 1e3)^3) * (Stiff * Initial.revolutions)^2) / 1e6;
    F_preload = Initial.F_preload;

    % Store mechanical parameters
    Mechanical_Stiff = Stiff;
    Mechanical_angle = Parameters.Geometry.AngleContact;

    % Update friction, geometry, and mesh computations
    fc_Frictionforce();
    fc_TempFriction();
    fc_2DGeometry();
    fc_MeshBasic();

    % Clear temporary variables
    A = []; B = []; X = []; Xbund = []; Ybund = []; k = [];

    %% 5. Main Loop for Time-Stepping Simulation
    for loop = 1:time
        % Update thermal model conditions for next iteration
        thermalIC(thermalmodel, thermalresults);
        thermalBC(thermalmodel, 'Edge', Termalelement, 'Temperature', Initial.thermalVal);
        tlist = 0:1;
        thermalresults = solve(thermalmodel, tlist);
        T = [T, thermalresults.Temperature(:, end)];

        % Recompute structural effects due to updated temperature
        model = createpde('structural', 'static-planestress');
        model.Geometry = thermalmodel.Geometry;
        model.Mesh = thermalmodel.Mesh;

        structuralProperties(model, 'YoungsModulus', Parameters.Material.ElasticModulusNut, ...
                                    'PoissonsRatio', Parameters.Material.PoissinModulusNut, ...
                                    'CTE', Initial.CTE);

        model.ReferenceTemperature = 25;  
        structuralBodyLoad(model, 'Temperature', thermalresults);
        structuralBC(model, 'Edge', [Termalelement, 26], 'Constraint', 'fixed');

        thermalstressresults = solve(model);
        displacement_x = [displacement_x, thermalstressresults.Displacement.ux];
        displacement_y = [displacement_y, thermalstressresults.Displacement.uy];

        % Compute updated expansion effects
        A = thermalmodel.Mesh.Nodes(:, Nf)';
        B = displacement_x(Nf, end);
        X = A(:, 1) + B;
        Xbund = [A(:, 1); X];
        Ybund = [A(:, 2); A(:, 2)];
        k = boundary(Xbund, Ybund);

        Ra_new = polyarea(Xbund(k), Ybund(k));
        L_new = (Initial.L) - (Ra_new * fact);

        % Update mechanical stiffness and preload force
        [Stiff] = fc_stiff(L_new);
        Initial.F_preload = sqrt(((L_new * 1e3)^3) * (Stiff * Initial.revolutions)^2) / 1e6;

        % Store new results
        F_preload = [F_preload, Initial.F_preload];
        Mechanical_Stiff = [Mechanical_Stiff, Stiff];
        Mechanical_angle = [Mechanical_angle, Parameters.Geometry.AngleContact];

        % Recompute forces, friction, geometry, and mesh
        fc_Frictionforce();
        fc_TempFriction();
        fc_2DGeometry();
        fc_MeshBasic();

        % Clear temporary variables
        A = []; B = []; X = []; Xbund = []; Ybund = []; k = [];
    end

    %% 6. Store Final Results
    Data.Temperature = T;
    Data.ThermalExpansion_x = displacement_x;
    Data.ThermalExpansion_y = displacement_y;
    Data.ThermalStressResult = thermalstressresults;
    Data.ThermalModel = thermalmodel;
    Data.ThermalGradient = thermalresults;
    Data.Initial = Initial;
    Data.Parameters = Parameters;
    Data.F_preload = F_preload;
    Data.model = model;
    Data.Mechanical.Stiff = Mechanical_Stiff;
    Data.Mechanical.angle = Mechanical_angle;

end
