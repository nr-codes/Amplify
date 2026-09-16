%% EXTRACT SOLUTION

% structure containing the solution data
data = ExtractData(nlp, rbm);

%% SAVE SEED
seed.q = data.pos;
seed.qd = data.vel;
seed.qdd = data.acc;
seed.t = data.t;
seed.Fc_1 = data.Fc1;
seed.a = data.a;
seed.u = data.input;
%seed.du = data.der_input;

if ~evalin( 'base', 'exist(''nlp'',''var'') == 1' )
    run ../../TROPIC_add_path.m;
    main;
end

nlp.Problem.SwingFootHeight.Function(seed.q(:, 26));

nlp.Functions.DynamicsODE(seed.q(:, 26), seed.qd(:, 26), seed.qdd(:, 26), seed.u(:, 26), seed.Fc_1(:, 26));

import casadi.*;

H = Function('H', {rbm.States.q.sym}, {rbm.Dynamics.H_matrix});
full(H(seed.q(:, 26)));

b = Function('b', {rbm.States.q.sym, rbm.States.dq.sym}, {rbm.Dynamics.C_terms});
full(b(seed.q(:, 26), seed.qd(:, 26)));

disp('left_foot @ ncp/2');
left_foot = Function('left_foot', {rbm.States.q.sym}, {rbm.BodyPositions{5,2}})
full(left_foot(seed.q(:, 26)));

disp('right_foot @ ncp/2');
right_foot = Function('right_foot', {rbm.States.q.sym}, {rbm.BodyPositions{7,2}});
full(right_foot(seed.q(:, 26)));

disp('left_foot @ 0');
left_foot = Function('left_foot', {rbm.States.q.sym}, {rbm.BodyPositions{5,2}});
full(left_foot(seed.q(:, 1)));

disp('right_foot @ 0');
right_foot = Function('right_foot', {rbm.States.q.sym}, {rbm.BodyPositions{7,2}});
full(right_foot(seed.q(:, 1)));

disp('left_foot @ T');
left_foot = Function('left_foot', {rbm.States.q.sym}, {rbm.BodyPositions{5,2}});
full(left_foot(seed.q(:, end)));

disp('right_foot @ T');
right_foot = Function('right_foot', {rbm.States.q.sym}, {rbm.BodyPositions{7,2}});
full(right_foot(seed.q(:, end)));

alpha = nlp.Problem.Trajectory.PolyCoeff.sym;
tau = SX.sym('norm_phase_var');
t_plus = SX.sym('phase_var_0');
t_minus = SX.sym('phase_var_T');

[phi, dphi, d2phi] = BezierTrajectory(nlp.Problem.Trajectory, alpha, tau, t_minus, t_plus);

q = rbm.States.q.sym;
qd = rbm.States.dq.sym;
qdd = rbm.States.ddq.sym;

dphi_dq   = dphi * rbm.Model.c;
d2phi_dq2 = d2phi * rbm.Model.c.^2;

ya   = phi;
dya  = dphi_dq*qd;
ddya = dphi_dq*qdd + d2phi_dq2*qd.^2;

bez = Function('ya', {alpha, tau}, {ya});
full(bez(seed.a, data.tau_phase));

dbez = Function('dya', {q, qd, alpha, tau, t_plus, t_minus}, {dya});
full(dbez(seed.q, seed.qd, seed.a, data.tau_phase, data.p_phase(1), data.p_phase(2)));

ddbez = Function('ddya', {q, qd, qdd, alpha, tau, t_plus, t_minus}, {ddya});
full(ddbez(seed.q, seed.qd, seed.qdd, seed.a, data.tau_phase, data.p_phase(1), data.p_phase(2)));

seed.qdd(4:7, :) - full(ddbez(seed.q, seed.qd, seed.qdd, seed.a, data.tau_phase, data.p_phase(1), data.p_phase(2)));


disp('impact at 0')
H = Function('H', {rbm.States.q.sym}, {rbm.Dynamics.H_matrix});
H0 = full(H(seed.q(:, 1)))

J = Function('J', {rbm.States.q.sym}, {rbm.Contacts{1}.Jac_contact});
J0 = full(J(seed.q(:, 1)))

R = Model.RelabelingMatrix();

H0*(seed.qd(:, 1) - R*seed.qd(:, end))

ime = H0*(seed.qd(:, 1) - R*seed.qd(:, end)) - J0'*data.fimp_1
postv = J0*seed.qd(:, 1)


data.fimp_1

% disp('impact at T with 0 values')
% R = Model.RelabelingMatrix();
% H = Function('H', {rbm.States.q.sym}, {rbm.Dynamics.H_matrix});
% H0 = full(H(R*seed.q(:, 1)))
% 
% J = Function('J', {rbm.States.q.sym}, {rbm.Contacts{1}.Jac_contact});
% J0 = full(J(R*seed.q(:, 1)));
% 
% ime = H0*(R*seed.qd(:, 1) - seed.qd(:, end)) - J0'*data.fimp_1
% postv = J0*R*seed.qd(:, 1);
% 
% A = [H0*R, -(J0*R)'; J0*R, zeros(2,2)];
% b = [H0*seed.qd(:, end); zeros(2,1)];
% imesoln = A \ b
% 
% data.fimp_1

disp('impact at T')
H = Function('H', {rbm.States.q.sym}, {rbm.Dynamics.H_matrix});
HT = full(H(seed.q(:, end)));

J = Function('J', {rbm.States.q.sym}, {jacobian(rbm.BodyVelocities{7,2}([1,3]), rbm.States.dq.sym)});
JT = full(J(seed.q(:, end)));

A = [HT, -JT'; JT, zeros(2,2)];
b = [HT*seed.qd(:, end); zeros(2,1)];

imesoln = A \ b;

qdpost = imesoln(1:7);
qdpost = HT \ (HT*seed.qd(:, end) + JT'*data.fimp_1);

fimp = imesoln(8:end);
data.fimp_1;

JT*qdpost;