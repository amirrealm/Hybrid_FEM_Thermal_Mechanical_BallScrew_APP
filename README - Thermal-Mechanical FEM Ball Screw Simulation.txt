Thermal-Mechanical FEM Analysis of a Ball Screw System:

This MATLAB project performs a Finite Element Method (FEM) analysis of a ball screw system, integrating thermal and mechanical effects. The simulation models:

- Heat generation due to friction
- Thermal expansion effects
- Contact mechanics and preload changes
- Stiffness variations over time
- Temperature and displacement distributions

The analysis helps in understanding how temperature fluctuations and mechanical deformations influence the performance of the ball screw system.

###################################################
###################################################

Features

- Computes frictional forces and torques
- Models heat generation and temperature rise
- Simulates thermal expansion and structural deformation
- Generates 2D geometry and meshing for FEM analysis
- Uses transient thermal analysis to track temperature evolution
- Computes stiffness changes due to thermal effects

###################################################
###################################################

Dependencies & Requirements:
MATLAB Toolboxes Required:

Partial Differential Equation Toolbox (for FEM)

###################################################
###################################################

Run the Main Script ---> (SIM_Thermal_Mechanical_BallScrew.m) 

###################################################
###################################################

Adjusting Simulation Parameters:

 Modify (initializeParameters.m) to change:
     
	- Material properties (e.g., Young’s modulus, thermal conductivity)
    - Geometrical dimensions (e.g., ball diameter, screw pitch)
    - Initial conditions (e.g., preload force, contact angle)

###################################################
###################################################

Changing the Time Step:
 Modify (fc_Thermal.m) to change:
      time = ??   [s]
	  
	  
	  
###################################################
###################################################
	  
Notes:
Ensure all required MATLAB toolboxes are installed before running the script.
The simulation parameters can be adjusted to test different configurations.
