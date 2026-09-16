% MAIN - Point Mass
%
% Finds the optimal trajectory to slide a point-mass across a 1d
% frictionless plane, using a variety of cost functions.
%
% Simple force-squared cost function  --  This is easy to optimize
%
tic; % ----------------------------------------------- Amplify 6/5/26
clc; clear;
addpath ../../

% User-defined dynamics and objective functions
problem.func.dynamics = @(t,x,u)( dynamics(x,u) );
problem.func.pathObj = @(t,x,u)( obj_forceSquared(u) );

% Problem bounds
problem.bounds.initialTime.low = 0;
problem.bounds.initialTime.upp = 0;
problem.bounds.finalTime.low = 1.0;
problem.bounds.finalTime.upp = 1.0;

problem.bounds.state.low = [0; -inf];
problem.bounds.state.upp = [1; inf];
problem.bounds.initialState.low = [0;0];
problem.bounds.initialState.upp = [0;0];
problem.bounds.finalState.low = [1;0]; 
problem.bounds.finalState.upp = [1;0];

problem.bounds.control.low = -50; %-inf;
problem.bounds.control.upp = 50; %inf;

% Guess at the initial trajectory
problem.guess.time = [0,1];
problem.guess.state = [0, 0; 1, 0];
problem.guess.control = [1, -1];

% Options for fmincon
problem.options.nlpOpt = optimset(...
    'Display','off',...   % {'iter','final','off'}  % ----- Amplify 6/5/26
    'GradObj','on',...
    'GradConstr','on',...
    'DerivativeCheck','off');   %Fmincon automatically checks


problem.options.method = 'trapezoid';
% problem.options.method = 'rungeKutta';

problem.options.verbose = 0; % --------------- Amplify 6/5/26

% Solve the problem
soln = optimTraj(problem);
toc; % ----------------------------------------------- Amplify 6/5/26

soln = Amplify_directCollocation(soln); % ------------ Amplify 6/15/26
soln.info % ------------------------------------------ Amplify 6/5/26
disp 'demo: moving block';  % --------------------- Amplify 6/5/26