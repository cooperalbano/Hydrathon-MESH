******************************************************************************
************************** SAINT MARY / MILK SYSTEM **************************
**************************     HYDRATHON: MESH      **************************
******************************************************************************
----------------------------------------------------

The workflow for this setup was obtained from the GitHub 
repository available at: https://github.com/cooperalbano/MESH-Scripts

----------------------------------------------------

The basin discretization, climate forcing data, and land cover for the Saint Mary / Milk system were preprocessed by Kasra Keshavarz using EASYMORE (https://github.com/ShervanGharari/EASYMORE), datatool (https://github.com/kasra-keshavarz/datatool), and GISTool (https://github.com/kasra-keshavarz/gistool).

Basin discretization: 	MERIT-Hydro
Climate forcing: 	RDRS v2.1
Land cover:		MODIS

----------------------------------------------------

Several edits to the default workflow were necessary to complete
the setup using the pre-processed data. Important edits are 
listed below:

1. Add code to 'create_MESH_drainage_database.py to 
account for different values used to represent 
outlet stream segments in the 'tosegment' field.

158| for i in range(0,len(tosegment)):
159| 	if tosegment[i] == -9999:
160|		tosegment[i] = 0

In the future, a cnotrol file setting could be added
to allow the user to specify this value, and avoid 
the need to modify the script for different data sources.

2. Add the names of MODIS landcover types to the 
'create_MESH_drainage_database.py' script.

3. Fixed an incorrect suffix for the log file in 
'create_MESH_drainage_database.py'.

4. Due to a combination of file size and number of files,
the RDRS v2.1 forcing data for 2010 - 2018 could not
be merged all at once using 'forcing_merge.sh'. To fix
this, the script was modified to first merge into 9 
yearly files which were placed into '/root_path/forcing/years/'.
An additional line was added to then merge the yearly 
files into a single file for the entire period. See the
edited 'forcing_merge.sh' script at: 

'/root_path/vector_based_workflow/4_climate_forcing/'

5. The default climate forcing variables for temperature, 
humidity, and wind speed were altered.

6. The script '4_MESH_vectorbased_forcing.py' was altered to
remove the control file input of the forcing name in favour
of manual entry. This was done because the script previously
assumed an output file name from the '2_easymore_remapping.py' 
script that was not used in the pre-processing for this setup.

7. The script '4_MESH_vectorbased_forcing.py' had assumed a 
dimension called 'ID' which was titled 'COMID' in the
pre-processed data used for this setup. The 'ID' dimension was
chamged to 'COMID'.

