#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=60G
#SBATCH --time=01:00:00
#SBATCH --job-name=RDRS_forcing_merge
#SBATCH --error=errors_RDRS_forcing_merge
#SBATCH --mail-user=example.email@usask.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END

# load modules and combine forcing NetCDF
module load cdo/1.9.8

# cd to datatool.sh output directory
cd ../../forcing/
mkdir years

# merge into yearly files
for i in 2010 2011 2012 2013 2014 2015 2016 2017 2018
do
cdo -z zip -b F32 mergetime /project/6008034/CompHydCore/Hydrathon/2-easymore/rdrs/rdrs_smm_remapped_$i*.nc years/rdrsv2.1_$i.nc
done

# Merge into a single file for 2010 to 2018
cdo -z zip -b F32 mergetime ./years/* ./rdrsv2.1_2010-2018.nc

