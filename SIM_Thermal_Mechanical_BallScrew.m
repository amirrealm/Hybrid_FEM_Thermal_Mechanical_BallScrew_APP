clear all; clc; close all; 
tic; 

%% 1. Initialize Global Variables and Parameters
% Define global structures for simulation
global Initial Friction Parameters Data Forces Torque

% Call the function to initialize system parameters
initializeParameters();

%% 2. Compute Friction Forces
% This function calculates various forces, torques, and frictional effects
fc_Frictionforce();

%% 3. Compute Frictional Heat Generation
% Determines heat generation due to friction and updates temperature-related parameters
fc_TempFriction();

%% 4. Generate 2D Geometry for Ball Screw System
% Constructs the 2D profile including the nut, balls, and contact points
fc_2DGeometry();

%% 5. Generate Finite Element Mesh
% Creates a mesh from the 2D geometry for further thermal and structural analysis
fc_MeshBasic();

%% 6. Perform Thermal Analysis
% Solves for temperature distribution, thermal expansion, and its mechanical effects
fc_Thermal();

%% 7. Display Execution Time
% Computes and displays the total execution time in HH:MM:SS format
t = toc;
disp(datestr(datenum(0,0,0,0,0,t), 'HH:MM:SS'));

