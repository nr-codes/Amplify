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


export = seed;
export.tau_phase = data.tau_phase;
export.p_phase = data.p_phase;
export.fimp_1 = data.fimp_1;

names = fieldnames(export);
for k = 1:numel(names)
    export.(names{k}) = reshape(double(export.(names{k}))', 1, []);
end
export.ngrid = size(seed.q, 2);
export.na = size(seed.a, 2);

writestruct(export, 'fivelinkbipedtropic.json');