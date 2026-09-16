@echo off
setlocal enabledelayedexpansion

set n=10

rem Output log file (overwrite)
set logfile="benchmark.txt"
echo. > %logfile%

set dir="ampl-cli"

rem List of model names
set names=acrobot ^
cart-pendulum-time ^
cart-pendulum-utot ^
five-link-mc-kelly ^
five-link-phc-kelly ^
five-link-tropic ^
grasp-cbc ^
grasp-conopt ^
grasp-gurobi ^
grasp-highs ^
grasp-knitro ^
grasp-raposa ^
grasp-scip ^
kinematic-car-conopt ^
kinematic-car-filter ^
kinematic-car-gurobi ^
kinematic-car-ipopt ^
kinematic-car-knitro ^
kinematic-car-lancelot ^
kinematic-car-loqo ^
kinematic-car-minos ^
kinematic-car-snopt ^
moving-block ^
spot-col3 ^
spot-rk1 ^
spot-rk4

set start_time=%TIME%
for %%N in (%names%) do (
  for /L %%k in (1,1,!n!) do (
    echo START: %%N -- RUN %%k
    echo START: %%N -- RUN %%k >> %logfile%
    echo ----------------- >> %logfile%

    rem Build a temporary AMPL script
    (
      echo cd %dir%;
      echo reset;
      echo model %%N.mod;
      echo data %%N.dat;
      echo include %%N.run;
    ) > temp.run

    rem Execute AMPL and append output to log
    set tic=!TIME!
    ampl.exe temp.run >> %logfile% 2>&1
    set toc=!TIME!

    echo END: %%N -- RUN %%k -- TIC !tic: =0! -- TOC !toc: =0! >> %logfile%
    echo(  >> %logfile%
    echo(  >> %logfile%
  )
)
set end_time=%TIME%
echo All runs started at %start_time% and ended at %end_time%

del temp.run

awk.exe -f ./benchmark.awk %logfile% > benchmark.csv
echo updated benchmark.csv
