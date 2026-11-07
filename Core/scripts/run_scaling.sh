#!/bin/bash
set -e

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.."
export PROJECT_DIR="$PWD"

sbatch --wait Core/scripts/scaling/omp_scaling.sh
sbatch --wait Core/scripts/scaling/mpi_scaling.sh
sbatch --wait Core/scripts/scaling/combin_scaling.sh
sbatch --wait Core/scripts/scaling/weak_scaling_openmp.sh
