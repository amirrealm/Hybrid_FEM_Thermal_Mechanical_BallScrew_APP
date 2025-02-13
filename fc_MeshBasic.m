function [] = fc_MeshBasic()
% FC_MESHBASIC - Generates a finite element mesh for the 2D ball screw system.
% This function creates a mesh based on the 2D geometry, identifies contact nodes,
% finds elements within a specified radius, and stores the triangulation.

    global Parameters Initial

    %% 1. Retrieve Stored 2D Geometry Coordinates
    % Extract previously computed X and Y geometry coordinates.
    Cx = Parameters.CxGeometry;
    Cy = Parameters.CyGeometry;

    %% 2. Create PDE Model and Generate Mesh
    % Create a PDE model and generate a mesh from the stored triangulation.
    Basic = createpde;
    Basic.geometryFromMesh(Parameters.Point2D.Points', Parameters.Point2D.ConnectivityList');

    % Generate a mesh with a maximum element size (Hmax).
    generateMesh(Basic, 'Hmax', 0.05);

    %% 3. Identify Contact Nodes and Elements
    % Loop through each revolution to locate the nearest contact nodes and elements.
    for k = 1:Initial.revolutions
        % Find the node closest to the contact point for each revolution.
        N_ID(k, 1) = findNodes(Basic.Mesh, 'nearest', [Parameters.EndPointRadius(1, k); Parameters.EndPointRadius(2, k)]);

        % Find elements around the contact point within a 0.05 mm radius.
        En(k, :) = findElements(Basic.Mesh, 'radius', [Parameters.EndPointRadius(1, k), Parameters.EndPointRadius(2, k)], 0.05);

        % Uncomment the following lines to visualize contact nodes.
        % figure
        % pdemesh(Basic)
        % hold on
        % plot(Basic.Mesh.Nodes(1, N_ID), Basic.Mesh.Nodes(2, N_ID), 'or', 'MarkerFaceColor', 'g')
    end

    %% 4. Visualize Position of Contact Nodes (Optional)
    % Uncomment the following lines for debugging or visualization purposes.
    % figure
    % pdemesh(Basic)
    % hold on
    % plot(Basic.Mesh.Nodes(1, N_ID), Basic.Mesh.Nodes(2, N_ID), 'ok', 'MarkerFaceColor', 'g')

    %% 5. Compute Mesh Boundaries for Contact Elements
    % Loop through each contact element to extract its boundary points.
    for eleman = 1:size(En, 1)
        % Get the element connectivity (node indices).
        A = Basic.Mesh.Elements(:, En(eleman, 1));

        % Extract X and Y boundary coordinates.
        XBound = Basic.Mesh.Nodes(1, A)';
        YBound = Basic.Mesh.Nodes(2, A)';

        % Compute the boundary of the element using MATLAB's boundary function.
        rng('default');  % Ensure reproducibility
        k = boundary(XBound, YBound, 0.1);

        % Store boundary coordinates.
        Cx{1, eleman + 1} = XBound(k)';
        Cy{1, eleman + 1} = YBound(k)';
    end

    %% 6. Create a Triangulation from the Extracted Boundaries
    % Convert boundary data into a polyshape and generate a triangulation.
    pg = polyshape(Cx, Cy);
    tr = triangulation(pg);

    %% 7. Store the Final Mesh in Parameters
    % Save the generated mesh in the global Parameters structure.
    Parameters.MeshBasic = tr;

end
