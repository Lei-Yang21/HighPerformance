#!/bin/bash
#SBATCH --job-name="shallow serial"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=05:00
#SBATCH --output=shallow_serial_%j.out

# define some variables
# With sbatch, submit from the repository root or export PROJECT_DIR.
PROJECT_DIR="${PROJECT_DIR:-${SLURM_SUBMIT_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)}}"
source "${PROJECT_DIR}/Core/scripts/environment.sh" || exit 1
PARAM_FILE="param_simple.txt"

# Prepare an isolated directory for simulation output.
prepare_run "${RESULTS_DIR}/serial_${SLURM_JOB_ID:-local}" || exit 1

# run the simulation
"${EXEC_DIR}/shallow" "${CONFIG_DIR}/${PARAM_FILE}"
