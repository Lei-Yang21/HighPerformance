#!/bin/bash
# Shared paths for the Core jobs and scaling experiments.
# PROJECT_DIR is resolved by the caller because Slurm copies submitted scripts.
EXEC_DIR="${PROJECT_DIR}/bin"
CONFIG_DIR="${PROJECT_DIR}/Core/config"
DATA_DIR="${PROJECT_DIR}/Core/data"
RESULTS_DIR="${PROJECT_DIR}/results"

prepare_run() {
  mkdir -p "$1" || return 1
  cp "${DATA_DIR}/h_simple.dat" "$1/" || return 1
  cd -- "$1" || return 1
}
