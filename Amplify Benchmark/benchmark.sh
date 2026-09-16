#!/usr/bin/env bash

#set -euo pipefail

# Output log file (overwrite)
logfile="benchmark_sh.txt"
: > "$logfile"

dir="ampl-cli"

# List of model names
names=(
  acrobot
  cart-pendulum-time
  cart-pendulum-utot
  five-link-mc-kelly
  five-link-phc-kelly
  five-link-tropic
  grasp-cbc
  grasp-conopt
  grasp-gurobi
  grasp-highs
  grasp-knitro
  grasp-raposa
  grasp-scip
  kinematic-car-conopt
  kinematic-car-filter
  kinematic-car-gurobi
  kinematic-car-ipopt
  kinematic-car-knitro
  kinematic-car-lancelot
  kinematic-car-loqo
  kinematic-car-minos
  kinematic-car-snopt
  moving-block
  spot-col3
  spot-rk1
  spot-rk4
)

n=10

start_time=$(date +%s.%N)
for model in "${names[@]}"; do
  for ((k=1; k<=n; k++)); do
    echo "START: $model -- RUN $k"
    {
      echo "START: $model -- RUN $k"
      echo "-----------------"
    } >> "$logfile"

    # Build a temporary AMPL script
    {
      echo "cd '$dir';"
      echo "reset;"
      echo "model $model.mod;"
      echo "data $model.dat;"
      echo "include $model.run;"
    } > temp.run

    # Execute AMPL and append output to log
    tic=$(date +%s.%N)
    #ampl temp.run >> "$logfile" 2>&1
    toc=$(date +%s.%N)

    {
      echo "END: $model -- RUN $k -- TIC $tic -- TOC $toc"
      echo
      echo
    } >> "$logfile"
  done
done
end_time=$(date +%s.%N)
echo "All runs took $(echo "$end - $start" | bc) s to complete."

rm -f temp.run

awk -f ./benchmark.awk "$logfile" > benchmark_sh.csv
echo "updated benchmark_sh.csv"
