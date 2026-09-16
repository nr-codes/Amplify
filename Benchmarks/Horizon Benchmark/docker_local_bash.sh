#!/usr/bin/env bash

# start timing
TS0=$(date +"%s")

# turn off '&' replacement with docker_remote_template in bash 5.2 and later
if shopt -p patsub_replacement &>/dev/null; then
  shopt -u patsub_replacement
fi

# default values
RUNS=10
HELP="Usage: $0 [--runs N] \
  \n  -h,--help         This help message. \
  \n  -r,--runs N       Run examples N times (default is 10). \n"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--runs)
      RUNS="$2"
      shift 2
      ;;
    -h|--help)
      printf "$HELP"
      exit 0
      ;;
    *)
      echo "Unknown option: $1.  Use -h for options summary."
      exit 1
      ;;
  esac
done

# template script to run in docker container
read -r -d '' REMOTE < src/docker_remote_template.sh

# oop version
OOP_REMOTE="python3"
OOP_REMOTE="${REMOTE//RUN/$OOP_REMOTE}"
OOP_REMOTE="${OOP_REMOTE//SCRIPT/py}"
OOP_REMOTE="${OOP_REMOTE//LIB/oop}"
OOP_REMOTE="${OOP_REMOTE//OUT/mat}"

# container info
IMAGE=francescoruscelli/horizon
CONTAINER_NAME=borealis

OOP="tar -xvf oop.tgz && cd oop && \
  echo 'REMOTE' > docker_remote_oop.sh && . docker_remote_oop.sh"
OOP="${OOP//REMOTE/$OOP_REMOTE}"

# copy content and run
cp -r src/urdf src/replay oop/

tar -czvf oop.tgz oop

for ((i = 1; i <= RUNS; i++)); do
  echo "----------- run $i of $RUNS"
  docker run -d --rm --name ${CONTAINER_NAME} --network="host" ${IMAGE} sleep infinity

  # OOP
  docker cp ./oop.tgz "${CONTAINER_NAME}:/home/user"
  docker exec borealis bash -c "${OOP}"
  docker cp "${CONTAINER_NAME}:/home/user/oop_out.tgz" .
  tar -xvf oop_out.tgz

  docker stop "${CONTAINER_NAME}"
  sleep 10 # fragile, but consistent in avoiding CONTAINER_NAME errors
done

awk -f src/parse_ipopt.awk oop_out/*.txt > ipopt_output.csv
cp src/ipopt_output.xlsx .

tar -czvf ipopt_runs.tgz oop_out/*.txt oop_out/*.mat \
  oop \
  ipopt_output.csv ipopt_output.xlsx 

rm oop.tgz oop_out.tgz
rm -r oop_out

# stop timing
TS1=$(date +"%s")
TSE=$((TS1 - TS0))
printf "Done! Elapsed time: %d seconds.\n" $TSE
