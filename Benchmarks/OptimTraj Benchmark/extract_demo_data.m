function extract_demo_data(inputFile, outputFile)
%EXTRACT_DEMO_DATA Parse optimization logs and write results to CSV
%
%   extract_demo_data(INPUTFILE, OUTPUTFILE) reads a text file containing
%   MATLAB optimization output logs and extracts key metrics for each run.
%   The extracted data is written to a CSV file.
%
%   INPUTS:
%       inputFile   - Path to the input text file
%       outputFile  - Path to the output CSV file
%
%   OUTPUT:
%       A CSV file with columns:
%       DEMO_LABEL, DEMO_NAME, NUMBER, exitFlag, objVal,
%       iterations, funcCount, constrviolation, nlpTime, Elapsed_time
%
%   DESCRIPTION:
%       Each record is identified by a line of the form:
%           demo: NAME --- run: N
%       and ends with a line:
%           demo: LABEL
%
%       The function extracts timing and selected fields from the
%       optimization result struct printed in the log.
%
%   EXAMPLE:
%       extract_demo_data('log.txt', 'results.csv')
%
%   See also: readlines, regexp, writetable

% Author: Nelson Rosa Jr. (nr@illinoistech.edu)
%         All code generated using M365 Copilot

lines = readlines(inputFile);

results = {};

% Record fields
demo_name = "";
number = "";
elapsed = "";
iterations = "";
funcCount = "";
constrviolation = "";
nlpTime = "";
exitFlag = "";
objVal = "";
ndv = "";
nc = "";
nceq = "";
nzbnd = "";

for i = 1:length(lines)
    line = strtrim(lines(i));

    % --- Start of a record ---
    if startsWith(line, "demo:") && contains(line, "--- run:")

        % Reset fields for new record
        demo_name = "";
        number = "";
        elapsed = "";
        iterations = "";
        funcCount = "";
        constrviolation = "";
        nlpTime = "";
        exitFlag = "";
        objVal = "";
        ndv = "";
        nc = "";
        nceq = "";
        nzbnd = "";

        % Extract DEMO_NAME and NUMBER
        tokens = regexp(line, '^demo:\s*(.*?)\s*--- run:\s*(\d+)', 'tokens');
        if ~isempty(tokens)
            demo_name = string(tokens{1}{1});
            number = string(tokens{1}{2});
        end
        % --- End of record: plain demo line gives DEMO_LABEL ---
    elseif startsWith(line, "demo:")
        tokens = regexp(line, '^demo:\s*(.*)', 'tokens');
        if ~isempty(tokens)
            demo_label = string(tokens{1}{1});

            % Save completed record
            results(end+1, :) = {demo_label, demo_name, number, ...
                exitFlag, objVal, ...
                iterations, funcCount, constrviolation, ...
                nlpTime, elapsed, ...
                ndv, nceq, nc, nzbnd};
        end
    end

    % --- Extract fields ---
    if startsWith(line, "Elapsed time is")
        t = regexp(line, 'Elapsed time is ([0-9.]+)', 'tokens');
        if ~isempty(t), elapsed = string(t{1}{1}); end
    end

    if contains(line, "iterations:")
        t = regexp(line, '^\s*iterations:\s*([0-9]+)', 'tokens');
        if ~isempty(t), iterations = string(t{1}{1}); end
    end

    if contains(line, "funcCount:")
        t = regexp(line, '^\s*funcCount:\s*([0-9]+)', 'tokens');
        if ~isempty(t), funcCount = string(t{1}{1}); end
    end

    if contains(line, "constrviolation:")
        t = regexp(line, '^\s*constrviolation:\s*([0-9.eE+-]+)', 'tokens');
        if ~isempty(t), constrviolation = string(t{1}{1}); end
    end

    if contains(line, "nlpTime:")
        t = regexp(line, '^\s*nlpTime:\s*([0-9.eE+-]+)', 'tokens');
        if ~isempty(t), nlpTime = string(t{1}{1}); end
    end

    if contains(line, "exitFlag:")
        t = regexp(line, '^\s*exitFlag:\s*([-]?[0-9]+)', 'tokens');
        if ~isempty(t), exitFlag = string(t{1}{1}); end
    end

    if contains(line, "objVal:")
        t = regexp(line, '^\s*objVal:\s*([0-9.eE+-]+)', 'tokens');
        if ~isempty(t), objVal = string(t{1}{1}); end
    end

    if contains(line, "amplify_ndv:")
        t = regexp(line, '^\s*amplify_ndv:\s*([0-9.eE+-]+)', 'tokens');
        if ~isempty(t), ndv = string(t{1}{1}); end
    end

    if contains(line, "amplify_nc:")
        t = regexp(line, '^\s*amplify_nc:\s*([0-9.eE+-]+)', 'tokens');
        if ~isempty(t), nc = string(t{1}{1}); end
    end

    if contains(line, "amplify_nceq:")
        t = regexp(line, '^\s*amplify_nceq:\s*([0-9.eE+-]+)', 'tokens');
        if ~isempty(t), nceq = string(t{1}{1}); end
    end

    if contains(line, "amplify_nzbnd:")
        t = regexp(line, '^\s*amplify_nzbnd:\s*([0-9.eE+-]+)', 'tokens');
        if ~isempty(t), nzbnd = string(t{1}{1}); end
    end
end

% Convert to table
T = cell2table(results, 'VariableNames', ...
    {'DEMO_LABEL','DEMO_NAME','NUMBER','exitFlag','objVal',...
    'iterations','funcCount','constrviolation',...
    'nlpTime','Elapsed_time', 'nvars', 'nceq', 'ncineq', 'nzbnd'});

writetable(T, outputFile);
end