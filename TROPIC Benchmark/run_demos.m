%RUN_DEMOS Run demos and log data to file.
%
% NOTES:
% Data is overwritten each time this script is called.
%
% See also: extract_demo_data
%

% Author: Nelson Rosa Jr. (nr@illinoistech.edu)
%         No AI usage

% For quick reference, IPOPT 3.12.3, CasADi 3.5.1, spatial_v2

% clone library
if(~isfolder('TROPIC'))
    disp('Cloning.  This will be awhile...');
    gitclone('https://github.com/fevrem/TROPIC.git');
end

% number of runs
runs = 10;

% save current directory
here = pwd;

% list of demo files
files = {
    'planar-7-dof-biped/Amplify_main.m';
    'planar-7-dof-biped/Amplify_main_zero_tol.m';
    'planar-7-dof-biped/Amplify_main_zero_tol_no_opts.m';
    };

% run add_path
cd('TROPIC/');
run('TROPIC_add_path.m');
cd(here);

% log output
log = 'tropic_demos.txt';
if exist(log,'file')
    delete(log);
end
diary(log);

% run demo files
for i = 1:length(files)
    % suppress IPOPT iteration output
    if strcmp(files{i}, files{3})
        % and remove TROPIC added options
        copyfile('@NLP/IPOPToptions_none.m', ...
            'TROPIC/optimization/@NLP/IPOPToptions.m');
    else
        % and keep TROPIC added options
        copyfile('@NLP/IPOPToptions.m', ...
            'TROPIC/optimization/@NLP/IPOPToptions.m');
    end

    % copy file
    f = fullfile('TROPIC/examples/', files{i});
    [dir, base, ext] = fileparts(f);

    copyfile(files{i}, f);

    cd(dir);
    f = [base, ext];
    for j = 1:runs
        fprintf('demo: %s --- run: %d\n', base, j);
        private_workspace(f)
    end
    cd(here);
end

% create csv file
diary off;
extract_ipopt_data(log, 'tropic_demos.csv');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Helper Function
function private_workspace(s)
run(s)
end