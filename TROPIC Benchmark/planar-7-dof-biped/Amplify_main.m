%% LOAD DYNAMICAL SYSTEM
tic; % ----------------------------------------------- Amplify 6/5/26
clear all; clc; close all; %#ok<*CLALL>

[rbm] = ld_model(...
    {'model', @Model.planar_7_dof_biped},...
    {'debug', false});


%% SPECIFY CONTACT

% Right leg end
rbm.Contacts{1} = Contact(rbm, 'Point',...
    {'Friction', true},...
    {'FrictionCoefficient', 0.6},...
    {'FrictionType', 'Pyramid'},...
    {'ContactFrame', rbm.BodyPositions{5,2}([1,3])});


%% CREATE NLP

nlp = NLP(rbm,...
    {'NFE', 25},...
    {'CollocationScheme', 'HermiteSimpson'},...
    {'LinearSolver', 'mumps'},...
    {'ConstraintTolerance', 1E-4});

% Create functions for dynamics equations 
nlp = ConfigFunctions(nlp, rbm);


%% Virtual constraint
nlp = AddVirtualConstraints(nlp, rbm,...
    {'PolyType', 'Bezier'},...
    {'PolyOrder', 5},...
    {'PolyPhase', 'state-based'});


% load user-defined constraints
[nlp, rbm] = LoadConstraints(nlp, rbm);


%% LOAD SEED

[nlp, rbm] = LoadSeed(nlp, rbm); % ------------------------- Amplify 6/5/26
%[nlp, rbm] = LoadSeed(nlp, rbm, 'planar-7-dof-seed.mat'); % Amplify 6/5/26
 

%% FILL UP & SOLVE NLP

nlp = ParseNLP(nlp, rbm);

nlp = SolveNLP(nlp);

toc; % ----------------------------------------------- Amplify 6/5/26
disp 'demo: planar 7-DOF biped';  % ---------- Amplify 6/5/26