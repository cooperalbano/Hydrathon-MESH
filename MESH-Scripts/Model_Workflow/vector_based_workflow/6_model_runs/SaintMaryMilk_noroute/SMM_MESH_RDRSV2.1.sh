#!/bin/bash
#SBATCH --account=rpp-kshook 
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --mem=30G
#SBATCH --time=2:00:00
#SBATCH --job-name=SMM_MESH_noroute
#SBATCH --mail-user=cooper.albano@usask.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END

# module loads
module load openmpi/4.0.3
module load netcdf-fortran/4.5.2

# foring, config and run dirs
#dir_mesh=/project/6008034/calbano/MESH_code/r1813
dir_mesh=/project/6008034/calbano/MESH_code/r1773

#$dir_mesh/sa_mesh 
mpirun $dir_mesh/mpi_sa_mesh_1773
