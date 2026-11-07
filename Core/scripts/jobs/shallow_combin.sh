#!/bin/bash
#SBATCH --job-name="shampi_omp"
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=8
#SBATCH --time=10:00
#SBATCH --output=combi_%j.out


export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export OMP_PROC_BIND=spread
export OMP_PLACES=threads

# With sbatch, submit from the repository root or export PROJECT_DIR.
PROJECT_DIR="${PROJECT_DIR:-${SLURM_SUBMIT_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)}}"
source "${PROJECT_DIR}/Core/scripts/environment.sh" || exit 1
PARAM_FILE="param_simple.txt"


prepare_run "${RESULTS_DIR}/hybrid_${SLURM_JOB_ID:-local}" || exit 1

mpirun "${EXEC_DIR}/shallow_combin" "${CONFIG_DIR}/${PARAM_FILE}"
