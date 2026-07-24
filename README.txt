REPLICATION GUIDE
=================

Paper: On the Impact of Rural Electrification: The Role of Complementary Factors

This repository contains data and code to replicate the results presented in 
the paper. The main analysis uses a cleaned dataset and requires Stata and 
QGIS for spatial components.

SOFTWARE REQUIREMENTS
---------------------

Stata - Install packages: reghdfe, ivreghdfe, estout, coefplot, geodist, spmap

QGIS 3.22+ - Required for spatial figures. Install the Least-Cost Path plugin 
(optional; least-cost distances already included in data_cleaned.dta)

DATA
----

Main dataset: use/data_cleaned.dta - Cleaned dataset ready for all regressions

REPOSITORY STRUCTURE
--------------------

code/               # Stata scripts (master_code.do)
Geospatial_files/   # GIS data (GeoPackage files, rasters, QGIS projects)
figures/            # Output figures (.pdf, .png)
tables/             # Output tables 
use/                # Processed datasets (.dta)
logfiles/           # Stata log files

REPLICATION STEPS
-----------------

1. Set Up: Ensure all directories are present

2. Run Stata: Open code/master_code.do, update file paths to your working 
   directory, and execute

3. Check Outputs: Tables -> tables/, Figures -> figures/, Logs -> logfiles/

4. (Optional) GIS: To recreate spatial figures, open QGIS projects in 
   Geospatial_files/qgis_projects/

QGIS FIGURES
------------

The following figures are created in QGIS (not Stata):

- Figure 1: Transmission lines (existing/planned)
- Figure 3: Hydropower plants, urban centers, villages
- Figure 4: Urban centers, villages, terrain
- Figure 7: Railway lines (existing/planned)
- Figure 8: Wildlife reserves
- Figure A1: Hydropower plants, transmission lines, villages
- Figure A2: Least-cost gridline, hydropower stations, enumeration areas

QGIS project files: Geospatial_files/

All other figures and tables are Stata-generated.

-------------------------------------------------------------------------------

CONTACT

Wondmagegn Tirkaso
Email: wondewin@gmail.com
