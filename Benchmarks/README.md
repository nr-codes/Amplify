# Overview
The original data used in the accompanying paper is in `summary.xlsx`.  It depends on other `.xlsx` files that reside in the subdirectories, so its content can change if any of these spreadsheets are changed.  In particular, running scripts in the subfolders will change the output data in `summary.xlsx` as the scripts overwrite the underlying data sources (i.e., `.txt`, `.csv`, and `.xlsx` files).

The documentation below outlines how to run the benchmark examples for the Amplify, Horizon, OptimTraj, and TROPIC libraries.  The relevant folders contain scripts that will run the examples in a batch mode.  Users are expected to have working versions of a library's programming environment (e.g., AMPL, bash/WSL, Docker, Matlab, etc.).

## Pre-Requisites
* Amplify requires either a [local copy of AMPL](https://portal.ampl.com/account/ampl/) or an [Internet connection and access to the NEOS server](https://neos-server.org/).
* Horizon requires a bash shell environment as well as [Docker and the Horizon Docker image](https://advrhumanoids.github.io/horizon/docker.html) to be installed.  In a Windows environment, a batch script is provided that will launch a WSL instance, which needs to have a bash shell installed.
* [OptimTraj](https://github.com/MatthewPeterKelly/OptimTraj) and [TROPIC](https://github.com/fevrem/TROPIC) require Matlab.
  * OptimTraj also requires the Optimization and Symbolic toolboxes for certain examples.

# Amplify
## Command-Line Models
To use a local copy of AMPL (e.g., `ampl.exe` or `ampl`) to run all of the
example models, run `benchmark.bat` in a DOS shell or `benchmark.sh` in a bash
shell.  Each script assumes the AMPL executable is in the active search path
for launching executables.  Output files will either have the naming convention
of `benchmark.[csv|txt]` or `benchmark_sh.[csv|txt]`.  The input files are
taken from `ampl-cli`.

The examples can also be run individually through the AMPL CLI as well.  First,
launch the AMPL CLI in the `ampl-cli` directory, then enter the following model, data, and include commands during the session:
```
ampl: model acrobot.mod;
ampl: data acrobot.dat;
ampl: include acrobot.run;
ampl: exit;
```
`acrobot` can be replaced with the name of the any of the other examples in the
`ampl-cli` folder.

## NEOS Models
To run the models using the NEOS server in batch mode, launch `index.html`.  Then
drag and drop the examples in the `neos_server` directory or use the file
explorer in `index.html`; this interface will be apparent once you open `index.html`.  Successfully loaded examples will morph in color from yellow to
green when successfully uploaded.  Yellow indicates that the first run is
complete and dark green represents the final run is complete.  The default
number of runs is 10, but this can be changed in the javascript files found in the
`html` folder.

Alternatively, the files can be individually uploaded through the [NEOS
interface](https://neos-server.org/neos/solvers/index.html).  Choose an
appropriate solver and upload the relevant files.

## Amplify Lines of Source Code
To count the number of lines of source code, run `cloc-aml.cmd` in the `Amplify LOC` folder.  The script will download and then run [cloc](https://github.com/AlDanial/cloc) on the Amplify core code in the directory.

# Horizon
Change into the `Horizon Benchmark` folder.  Then, run `docker_local_cmd.bat` in a DOS shell with an underlying WSL installation with a bash shell (e.g., Ubunutu 22.04), or run `docker_local_bash.sh` in a bash shell.  Several output files are generated.

Both scripts assume Docker is in the search path.  The script `docker_local_cmd.bat` is just a wrapper script for `docker_local_bash.sh`.  The bash script has only been tested in Ubuntu 22.04 (WSL) and 24.04 (native Linux install).  The scripts are a modified version of the ones in the [OOPAMLBenchmarks](https://github.com/nr-codes/OOPAMLBenchmarks) repository.

# OptimTraj
Change into the `OptimTraj Benchmark` folder and run `run_demos.m`.  You can
then inspect the output csv file `optimtraj_demos.csv`.  At the time of
testing, the latest version of OptimTraj was commit `27bcf50`.  The script was
executed in Matlab 2024a.

## Modified Demo Files
All changes are stored in individual `.m` files of the form `demo/<demo
name>/Amplify_<rest of file name>.m`.  Use MATLAB's diff tool to see the
changes made with respect to `demo/<demo name>/<rest of file name>.m`.  The
modified files are
- `demo/acrobot/Amplify_MAIN.m`,
- `demo/cartPole/Amplify_MAIN_minforce.m`,
- `demo/cartPole/Amplify_MAIN_minTime.m`,
- `demo/fiveLinkBiped/Amplify_MAIN.m`, and
- `demo/minimumWork/Amplify_MAIN.m`.

Common changes to all files are
- addition of `tic` and `toc` commands to time model generation and solution time.
- addition to turn off outputs using `options.nlpOpt`.
- addition to print demo name.
- addition of option to suppress printing OptimTraj loop iteration.
- addition of function call to compute number of decision variables and constraints.
- commenting out of extra solve iterations.
- removal of all code after `optimTraj(problem)` is called.

Additionally, the five-link biped demo has the following changes as well
- replacing default `method` with suggested method `hermiteSimpsonGrad`.
- addition of code to write a CSV file of results.

# TROPIC 
Change into the `TROPIC Benchmark` folder and run `run_demos.m`.  You can then
inspect the output csv file `tropic_demos.csv`.  At the time of testing, the
latest version of TROPIC was commit `956271d`.  The script was executed in
Matlab 2024a.

## Modified Demo Files
All changes are stored in individual `.m` files.  For example, the demos are of
the form `<demo name>/Amplify_<rest of file name>.m`.  Use MATLAB's diff tool
to see the changes made with respect to `examples/<demo name>/<rest of file
name>.m`.  The modified files are
- `@NLP/IPOPToptions.m`, 
- `planar-7-dof-biped/Amplify_main.m`, and
- `planar-7-dof-biped/Amplify_main_zero_tol.m`.

Changes to `planar-7-dof-biped/*.m` are
- addition of `tic` and `toc` commands to time model generation and solution time.
- commenting out .mat seed value to warm start search.
- uncommenting call to generate manual seed value.
- addition to print demo name.
- removal of all code after `nlp = SolveNLP(nlp)` is called.

Changes to `@NLP/IPOPToptions.m` is
- addition `print_level` option to suppress printing each interation.

# Timing Definition for Each Library
Below is a list of how wall time is defined for each library.  The source code
can be referenced for more precise implementation details.
- OptimTraj wall time is from when the demo script starts until the NLP is solved.
  - The elapsed time is stored in `Elapsed_time` in `OptimTraj Benchmark/optimtraj_demos.csv`.
- Amplify (+ NEOS) wall time is from when the run script starts (reset to
  _ampl_elapsed_time) until the NLP is solved (_ampl_elapsed_time  +
  _solver_elapsed_time).
  - The elapsed time is the sum of `ampl_elapsed_time` and `solve_elapsed_time` in `Amplify Benchmark/benchmark.csv` and `AmplifyBenchmark/neos_benchmark.csv`.
- TROPIC wall time is from when the demo script starts until the NLP is solved.
  - The elapsed time is stored in `Elapsed` in `TROPIC Benchmark/tropic_demos.csv`.
- Horizon wall time is from when the demo script starts until the NLP is solved.
  - The elapsed time is stored in `total_wall` in `Horizon Benchmark/ipopt_output.csv`.
- Amplify + NEOS cloud time is from when the code enters and exist a function call to run(...).
  - The cloud time is the difference of `toc` and `tic` in `Amplify Benchmark/neos_benchmark.csv`.