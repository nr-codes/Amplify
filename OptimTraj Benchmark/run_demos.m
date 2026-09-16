%RUN_DEMOS Run demos and log data to file.
%
% NOTES: 
% Must have symbolic and optimization toolboxes for the OptimTraj
% library to run without error.
%
% Data is overwritten each time this script is called.
%
% See also: extract_demo_data
%

% Author: Nelson Rosa Jr. (nr@illinoistech.edu)
%         No AI usage

% clone library
if(~isfolder('OptimTraj'))
    gitclone('https://github.com/MatthewPeterKelly/OptimTraj.git');
end

% output problem size in soln struct
copyfile('directCollocation/Amplify_directCollocation.m', ...
    'OptimTraj/Amplify_directCollocation.m');

% number of runs
runs = 10;

% save current directory
here = pwd;

% list of demo files
files = {
    'acrobot/Amplify_MAIN.m';
    'cartPole/Amplify_MAIN_minForce.m';
    'cartPole/Amplify_MAIN_minTime.m';
    'fiveLinkBiped/Amplify_MAIN.m';
    'minimumWork/Amplify_MAIN_forceSquared.m';
    };

% log output
log = 'optimtraj_demos.txt';
if exist(log,'file')
    delete(log);
end
diary(log);

% run demo files
for i = 1:length(files)
    f = fullfile('OptimTraj\demo\', files{i});
    [dir, base, ext] = fileparts(f);

    copyfile(files{i}, f)

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
extract_demo_data(log, 'optimtraj_demos.csv');
fprintf('updated optimtraj_demos.csv.\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Helper Function
function private_workspace(s)
run(s)
end