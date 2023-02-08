#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=10G
#SBATCH --time=00:30:00
#SBATCH --job-name=BowAtBanff_change_unity
#SBATCH --error=errors_BowAtBanff
#SBATCH --mail-user=example.email@usask.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END

# load modules 
module load cdo/1.9.8

# input folder
infolder=../../forcing # /subbasin_select  
fl=rdrsv2.1_2010-2018.nc
echo $fl

for var in RDRS_v2.1_P_HU_1.5m RDRS_v2.1_A_PR0_SFC RDRS_v2.1_P_P0_SFC RDRS_v2.1_P_FB_SFC RDRS_v2.1_P_FI_SFC RDRS_v2.1_P_TT_1.5m RDRS_v2.1_P_UVC_10m latitude longitude 
	do
		echo $var
		cdo selname,$var $infolder/$fl $infolder/$var'_'$fl		
	done

## Adjust Units
## Pressure from "mb" to "Pa"
cdo mulc,100 $infolder/'RDRS_v2.1_P_P0_SFC_'$fl $infolder/tmp.nc
cdo setattribute,RDRS_v2.1_P_P0_SFC@units=Pa $infolder/tmp.nc $infolder/'RDRS_v2.1_P_P0_SFC_'$fl
rm $infolder/tmp.nc

## Temperature from "deg_C" to "K"
cdo addc,273.16 $infolder/'RDRS_v2.1_P_TT_1.5m_'$fl $infolder/tmp.nc
cdo setattribute,RDRS_v2.1_P_TT_1.5m@units=K $infolder/tmp.nc $infolder/'RDRS_v2.1_P_TT_1.5m_'$fl
rm $infolder/tmp.nc

## Wind speed from "knts" to "m/s"
cdo mulc,0.5144444444444444 $infolder/'RDRS_v2.1_P_UVC_10m_'$fl $infolder/tmp.nc
cdo setattribute,RDRS_v2.1_P_UVC_10m@units="m s-1" $infolder/tmp.nc $infolder/'RDRS_v2.1_P_UVC_10m_'$fl
rm $infolder/tmp.nc

## Precipitation from "m" over the hour to a rate "mm/s" = "kg m-2 s-1"
cdo divc,3.6 $infolder/'RDRS_v2.1_A_PR0_SFC_'$fl $infolder/tmp.nc
cdo setattribute,RDRS_v2.1_A_PR0_SFC@units="mm s-1" $infolder/tmp.nc $infolder/'RDRS_v2.1_A_PR0_SFC_'$fl
rm $infolder/tmp.nc

#merge files 
cdo -z zip -b F32 merge $infolder/'RDRS_v2.1_P_HU_1.5m_'$fl $infolder/'RDRS_v2.1_A_PR0_SFC_'$fl $infolder/'RDRS_v2.1_P_P0_SFC_'$fl $infolder/'RDRS_v2.1_P_FB_SFC_'$fl $infolder/'RDRS_v2.1_P_FI_SFC_'$fl $infolder/'RDRS_v2.1_P_TT_1.5m_'$fl $infolder/'RDRS_v2.1_P_UVC_10m_'$fl $infolder/'latitude_'$fl $infolder/'longitude_'$fl $infolder/u$fl

for var in RDRS_v2.1_P_HU_1.5m RDRS_v2.1_A_PR0_SFC RDRS_v2.1_P_P0_SFC RDRS_v2.1_P_FB_SFC RDRS_v2.1_P_FI_SFC RDRS_v2.1_P_TT_1.5m RDRS_v2.1_P_UVC_10m latitude longitude
	do
		rm $infolder/$var'_'$fl		
	done 

rm 	$infolder/$fl
mv $infolder/u$fl $infolder/$fl

# --- Code Provenance
# Copy this script into the input folder/_workflow_log/
mkdir $infolder/_workflow_log/
cp ./3_Climateforcing_change_unity.sh $infolder/_workflow_log/
# Create a log file
dt=$(date +'%Y%m%d')
echo "changed Pressure from 'mb' to 'Pa', Temperature from 'deg_C' to 'K', Wind speed from 'knts' to 'm/s', and Precipitation from 'm' over the hour to a rate 'mm/s' = 'kg m-2 s-1'" >> $infolder/_workflow_log/$dt"_change_unity.txt"