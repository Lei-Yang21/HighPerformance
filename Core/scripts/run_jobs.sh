#!/bin/bash
set -e

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.."
export PROJECT_DIR="$PWD"

sbatch --wait Core/scripts/jobs/shallow_serial.sh
sbatch --wait Core/scripts/jobs/shallow_openmp.sh
sbatch --wait Core/scripts/jobs/shallow_mpi.sh
sbatch --wait Core/scripts/jobs/shallow_combin.sh
