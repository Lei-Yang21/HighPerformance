# HighPerformance : INFO0939

Shallow water simulation and performance analysis of sequential, MPI, OpenMP,
hybrid, and GPU implementations.

## Project structure

```text
.
├── Core/
│   ├── src/                 # C implementations of the base simulation
│   ├── config/              # Base parameters and weak scaling variants
│   ├── data/                # Input bathymetry: h_simple.dat
│   └── scripts/
│       ├── environment.sh   # Shared paths and run preparation
│       ├── run_jobs.sh      # Run the four CPU simulation jobs in order
│       ├── run_scaling.sh   # Run the four listed scaling jobs in order
│       ├── jobs/            # Slurm jobs: simulation, GPU, and profiling
│       └── scaling/         # Strong and weak scaling experiments
├── More Features/
│   ├── Coriolis/            # Implementations including the Coriolis force
│   ├── MPI_GPU/             # MPI + GPU exploration
│   └── New_source/          # Perlin noise bathymetry and an extended wave source
├── notebooks/
│   ├── scaling.ipynb        # Scaling analysis and plot generation
│   └── figures/             # Exported strong and weak scaling plots
├── bin/                     # Compiled executables, ignored by Git
└── results/                 # Run output, ignored by Git
```

`bin/` and `results/` are created during compilation and execution.

## Building the core solver

Run these commands **from the repository root**, on Linux or in an HPC environment
with GCC and, for the distributed implementations, MPI:

```bash
mkdir -p bin
gcc -O3 Core/src/shallow.c -o bin/shallow -lm
gcc -O3 Core/src/shallow_opti.c -o bin/shallow_opti -lm
gcc -O3 -fopenmp Core/src/shallow_openmp.c -o bin/shallow_openmp -lm
mpicc -O3 Core/src/shallow_mpi.c -o bin/shallow_mpi -lm
mpicc -O3 -fopenmp Core/src/shallow_combin.c -o bin/shallow_combin -lm
```

`Core/src/shallow_mpi2.c` is an additional MPI variant available for experiments;
the provided jobs do not use it. `Core/src/shallow_gpu.c` is compiled by the GPU
job using the cluster's modules.

## Running locally

Paths in the parameter files are relative to the **working directory**.
Copy the bathymetry there before starting the simulation:

```bash
mkdir -p results/local
cp Core/data/h_simple.dat results/local/
cd results/local
../../bin/shallow ../../Core/config/param_simple.txt
```

## Running on the cluster

Compile the CPU executables into `bin/`, then start either sequence from the
repository root on the cluster login node.

```bash
bash Core/scripts/run_jobs.sh
bash Core/scripts/run_scaling.sh
```

`run_jobs.sh` runs the serial, OpenMP, MPI, and hybrid jobs in that order.
`run_scaling.sh` runs OpenMP, MPI, and hybrid strong scaling, followed by OpenMP
weak scaling. Each launcher uses `sbatch --wait` to wait for each job before
submitting the next one and stops if Slurm returns an error. Keep the launcher
running until the sequence finishes.

Submit GPU and profiling jobs separately from the repository root.

```bash
sbatch Core/scripts/jobs/lucia_gpu.job
sbatch Core/scripts/jobs/scalasca_profile.job
```

The GPU job performs its own compilation. For Scalasca, compile a hybrid
executable into `bin/` with the cluster's profiling instrumentation.

To submit from another directory, export the repository's absolute path:

```bash
export PROJECT_DIR=/absolute/path/HighPerformance
sbatch "$PROJECT_DIR/Core/scripts/jobs/shallow_mpi.sh"
```

Scripts write output to `results/`, with a subdirectory for each job or experiment.
Slurm logs remain in the submission directory, as specified by the
`#SBATCH --output` directives. Partitions, accounts, modules, and requested
resources match the original cluster and should be adapted to your environment.
The supplied weak scaling parameters cover powers of two up to 64 cores; add
matching parameter files to explore larger configurations.

## Scaling notebook and figures

The notebook analyzes recorded timings from the strong and weak scaling
experiments. [Open the notebook](notebooks/scaling.ipynb).

The exported PNG plots are stored separately and can be viewed directly.
[Browse the scaling figures](notebooks/figures/).

To regenerate the PNGs, use an environment with Python, Jupyter, and Matplotlib.
Start Jupyter from `notebooks/` and run all cells to save the plots in `figures/`.

```bash
cd notebooks
jupyter notebook scaling.ipynb
```

## Additional features

The main investigation focuses on the Coriolis force. `MPI_GPU/` and `New_source/`
contain additional explorations, preserved in their original directories.
Their executables can be compiled into separate subdirectories of `bin/` to avoid
collisions between files with the same name.

### Perlin noise bathymetry and wave sources

`New_source/generate.c` combines several octaves of 2D Perlin noise to generate
a synthetic seabed. The `init.txt` file controls the grid dimensions and spacing,
the random seed, and the noise settings. Persistence scales the amplitude of each
successive octave, and lacunarity scales its frequency. The final parameter sets
the maximum depth after normalization.

Generate a bathymetry map from the repository root.

```bash
mkdir -p bin/features results/new_source
gcc -O3 "More Features/New_source/generate.c" -o bin/features/generate -lm
cd results/new_source
../../bin/features/generate "../../More Features/New_source/init.txt"
```

The generator writes `map.dat` to the current directory. Set the input bathymetry
filename in the simulation parameters to `map.dat` and run the solver from that
directory.

The Perlin noise defines the seabed. Wave forcing is configured separately through
`source_type`. In `New_source/shallow_opti.c`, `source_type = 3` combines two
sinusoidal surface elevation sources along the horizontal centerline with
opposite sinusoidal velocities at the top and bottom boundaries.
