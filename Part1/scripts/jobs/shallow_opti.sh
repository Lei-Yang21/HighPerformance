#!/bin/bash
#SBATCH --job-name="shallow opti"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=15:00
#SBATCH --output=opti_%j.out

# define some variables
# With sbatch, submit from the repository root or export PROJECT_DIR.
PROJECT_DIR="${PROJECT_DIR:-${SLURM_SUBMIT_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)}}"
source "${PROJECT_DIR}/Part1/scripts/environment.sh" || exit 1
PARAM_FILE="param_simple.txt"



# Prepare an isolated directory for simulation output.
prepare_run "${RESULTS_DIR}/optimized_${SLURM_JOB_ID:-local}" || exit 1

# run the simulation
"${EXEC_DIR}/shallow_opti" "${CONFIG_DIR}/${PARAM_FILE}"
