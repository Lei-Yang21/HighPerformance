# HighPerformance — INFO0939

Shallow water simulation and performance analysis of sequential, MPI, OpenMP,
hybrid, and GPU implementations.

## Project structure

```text
.
├── Part1/
│   ├── src/                 # C implementations of the base simulation
│   ├── config/              # Base parameters and weak scaling variants
│   ├── data/                # Input bathymetry: h_simple.dat
│   └── scripts/
│       ├── environment.sh   # Shared paths and run preparation
│       ├── jobs/            # Slurm jobs: simulation, GPU, and profiling
│       └── scaling/         # Strong and weak scaling experiments
├── Part2/
│   ├── Coriolis/            # Implementations including the Coriolis force
│   ├── MPI_GPU/             # MPI + GPU exploration
│   └── New_source/          # Bathymetry generation and related implementation
├── notebooks/
│   └── scaling.ipynb        # Analysis and plots of recorded measurements
├── bin/                     # Compiled executables, ignored by Git
└── results/                 # Run output, ignored by Git
```

`bin/` and `results/` are created during compilation and execution.
Files previously at the repository root are now in `Part1/`, except for the
notebook, which is in `notebooks/`. Source code, data, parameters, and results
stored in the notebook have been preserved.

## Building Part 1

Run these commands **from the repository root**, on Linux or in an HPC environment
with GCC and, for the distributed implementations, MPI:

```bash
mkdir -p bin
gcc -O3 Part1/src/shallow.c -o bin/shallow -lm
gcc -O3 Part1/src/shallow_opti.c -o bin/shallow_opti -lm
gcc -O3 -fopenmp Part1/src/shallow_openmp.c -o bin/shallow_openmp -lm
mpicc -O3 Part1/src/shallow_mpi.c -o bin/shallow_mpi -lm
mpicc -O3 -fopenmp Part1/src/shallow_combin.c -o bin/shallow_combin -lm
```

`Part1/src/shallow_mpi2.c` is an additional MPI variant available for experiments;
the provided jobs do not use it. `Part1/src/shallow_gpu.c` is compiled by the GPU
job using the cluster's modules.

## Running locally

Paths in the parameter files are relative to the **working directory**.
Copy the bathymetry there before starting the simulation:

```bash
mkdir -p results/local
cp Part1/data/h_simple.dat results/local/
cd results/local
../../bin/shallow ../../Part1/config/param_simple.txt
```

The parameter files `param_simple_1.txt` through `param_simple_64.txt` are used for
weak scaling. The notebook uses measurements stored in its cells and requires
Python, Jupyter, and Matplotlib to run again.

## Running on the cluster

Submit jobs **from the repository root** so that `SLURM_SUBMIT_DIR` points to the
project:

```bash
sbatch Part1/scripts/jobs/shallow_serial.sh
sbatch Part1/scripts/jobs/shallow_openmp.sh
sbatch Part1/scripts/jobs/shallow_mpi.sh
sbatch Part1/scripts/jobs/shallow_combin.sh
sbatch Part1/scripts/scaling/omp_scaling.sh
sbatch Part1/scripts/scaling/mpi_scaling.sh
sbatch Part1/scripts/scaling/combin_scaling.sh
sbatch Part1/scripts/scaling/weak_scaling_openmp.sh
sbatch Part1/scripts/jobs/lucia_gpu.job
sbatch Part1/scripts/jobs/scalasca_profile.job
```

First compile the corresponding executable into `bin/`. The GPU job performs its
own compilation. For Scalasca, use a hybrid executable instrumented with the
cluster's profiling tools.

To submit from another directory, export the repository's absolute path:

```bash
export PROJECT_DIR=/absolute/path/HighPerformance
sbatch "$PROJECT_DIR/Part1/scripts/jobs/shallow_mpi.sh"
```

Scripts write output to `results/`, with a subdirectory for each job or experiment.
Slurm logs remain in the submission directory, as specified by the
`#SBATCH --output` directives. Partitions, accounts, modules, and requested
resources match the original cluster and should be adapted to your environment.
The supplied weak scaling parameters cover powers of two up to 64 cores; add
matching parameter files to explore larger configurations.

## Part 2

The main investigation focuses on the Coriolis force. `MPI_GPU/` and `New_source/`
contain additional explorations, preserved in their original directories.
Their executables can be compiled into separate subdirectories of `bin/` to avoid
collisions between files with the same name.

Example for the bathymetry generator, from the repository root:

```bash
mkdir -p bin/part2 results/new_source
gcc -O3 Part2/New_source/generate.c -o bin/part2/generate -lm
cd results/new_source
../../bin/part2/generate ../../Part2/New_source/init.txt
```

The generator writes `map.dat` to the current directory. To use it in a simulation,
create a suitable parameter file that references this map.
