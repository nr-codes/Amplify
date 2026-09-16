% MAIN.m
%
% Solve the cart-pole swing-up problem
tic; % ----------------------------------------------- Amplify 6/5/26
clc; clear;
addpath ../../

p.m1 = 2.0;  % (kg) Cart mass
p.m2 = 0.5;  % (kg) pole mass
p.g = 9.81;  % (m/s^2) gravity
p.l = 0.5;   % (m) pendulum (pole) length

dist = 0.8;  %How far must the cart translate during its swing-up
maxForce = 100;  %Maximum actuator forces
duration = 2;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                     Set up function handles                             %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

problem.func.dynamics = @(t,x,u)( cartPoleDynamics(x,u,p) );
problem.func.pathObj = @(t,x,u)( u.^2 );  %Force-squared cost function

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                     Set up problem bounds                               %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

problem.bounds.initialTime.low = 0;
problem.bounds.initialTime.upp = 0;
problem.bounds.finalTime.low = duration;
problem.bounds.finalTime.upp = duration;

problem.bounds.initialState.low = zeros(4,1);
problem.bounds.initialState.upp = zeros(4,1);
problem.bounds.finalState.low = [dist;pi;0;0];
problem.bounds.finalState.upp = [dist;pi;0;0];

problem.bounds.state.low = [-2*dist;-2*pi;-inf;-inf];
problem.bounds.state.upp = [2*dist;2*pi;inf;inf];

problem.bounds.control.low = -maxForce;
problem.bounds.control.upp = maxForce;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                    Initial guess at trajectory                          %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

problem.guess.time = [0,duration];
problem.guess.state = [problem.bounds.initialState.low, problem.bounds.finalState.low];
problem.guess.control = [0,0];


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                         Solver options                                  %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

problem.options.nlpOpt = optimset(...
    'Display','off',... % ---------------- Amplify 6/5/26
    'MaxFunEvals',1e5);

% problem.options.method = 'trapezoid';
% problem.options.method = 'hermiteSimpson';
% problem.options.method = 'rungeKutta';
% problem.options.method = 'chebyshev';

problem.options.verbose = 0; % --------------- Amplify 6/5/26

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                            Solve!                                       %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

soln = optimTraj(problem);
toc; % ----------------------------------------------- Amplify 6/5/26

soln = Amplify_directCollocation(soln); % ------------ Amplify 6/15/26
soln.info % ------------------------------------------ Amplify 6/5/26
disp 'demo: cart-pole (min force)';  % --------------- Amplify 6/5/26