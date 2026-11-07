#!/bin/bash
#SBATCH --job-name="shallow_mpi"
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --time=05:00
#SBATCH --output=mpi_%j.out

# define some variables
# With sbatch, submit from the repository root or export PROJECT_DIR.
PROJECT_DIR="${PROJECT_DIR:-${SLURM_SUBMIT_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)}}"
source "${PROJECT_DIR}/Core/scripts/environment.sh" || exit 1
PARAM_FILE="param_simple.txt"

# Prepare an isolated directory for simulation output.
prepare_run "${RESULTS_DIR}/mpi_${SLURM_JOB_ID:-local}" || exit 1

# run the MPI simulation
mpirun "${EXEC_DIR}/shallow_mpi" "${CONFIG_DIR}/${PARAM_FILE}"
