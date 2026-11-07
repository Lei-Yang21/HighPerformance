#!/bin/bash
#SBATCH --job-name="shallow_openmp"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=10:00
#SBATCH --output=openmp_%j.out

# define some variables
# With sbatch, submit from the repository root or export PROJECT_DIR.
PROJECT_DIR="${PROJECT_DIR:-${SLURM_SUBMIT_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)}}"
source "${PROJECT_DIR}/Part1/scripts/environment.sh" || exit 1
PARAM_FILE="param_simple.txt"


# Prepare an isolated directory for simulation output.
prepare_run "${RESULTS_DIR}/openmp_${SLURM_JOB_ID:-local}" || exit 1

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# run the simulation
"${EXEC_DIR}/shallow_openmp" "${CONFIG_DIR}/${PARAM_FILE}"
