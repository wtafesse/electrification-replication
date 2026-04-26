/*==============================================================================
TITLE: On the Impact of Rural Electrification: The Role of Complementary 
       Factors
DATA: Ethiopian Rural Socioeconomic Survey (ERSS) 2011-2015 panel data
      combined with geospatial data on electricity infrastructure, hydropower 
      facilities, urban settlements, and topographic features
AUTHOR: Wondmagegn Tirkaso
DATE: April 5, 2022
==============================================================================*/
/*------------------------------------------------------------------------------
NOTE ON SPATIAL FIGURES:
Some of the figures in this analysis are created using QGIS and are not produced 
by this Stata code. These spatial/map figures include:
  - Figure 1: Existing and planned electricity transmission lines
  - Figure 3: Hydropower plants, major urban centers and household villages
  - Figure 4: Major urban centers, household villages, and terrain structures
  - Figure 7: Existing and planned railway lines in Ethiopia
  - Figure 8: Wildlife Reserves in Ethiopia
  - Figure A1: Hydropower plants, transmission lines and villages
  - Figure A2: Least cost gridline, hydropower stations and enumeration areas

Separate QGIS project files and geopackage data file are provided for these figures.
All other figures and tables are produced by this Stata code.
------------------------------------------------------------------------------*/

*------------------------------------------------------------------------------
* 0. SETUP
*------------------------------------------------------------------------------
clear all
set more off
capture log close _all
set seed 10175641

* Set working directory
cd "C:\Users\Tirkaso\Dropbox\Electrifiction_draft_2025\Manuscript2020\Paper I\Submissions\Journal of African Economies\2nd_Round_RR\Replication_code"

* Create log folder if it does not exist
capture mkdir "logfiles"

* Open named log files
log using "logfiles\Results_log.smcl", replace name(smcllog)
log using "logfiles\Results_log.txt", text replace name(txtlog)

* Load data
use "use\data_cleaned.dta", clear


*------------------------------------------------------------------------------
* 1. DEFINE MACROS
*------------------------------------------------------------------------------

* Core variables for tables
global vlist elec_access enterp age hh_size mari_stat sex ///
    avhh_educ farm_area mean_rainfall_hh roadkm micro_inst

* Control variables
global xlist age hh_size farm_area drft_animal avhh_educ ///
    nonagwage_income share_nonfarm agriequp_value totalasset_value ///
    mean_rainfall_hh main_accesroad elec_mktkms ///
    elec_bankkms

* Distance variables
global dist_vars dist20 near_bank_kms near_mkt_kms ///
    elec_roadkms

* Infrastructure variables
global infra_vars hh_railway_dist_kms hh_natur_dist_kms_updatd ///
    ea_5citdis_kms dist20_mktkms dist20_bankkms roadkm dist20_roadkms

* Combine all variables for transformation
global all_transform_vars $xlist $dist_vars $infra_vars

* Apply inverse hyperbolic sine transformation
ihstrans $all_transform_vars
foreach x in $all_transform_vars {
    capture gen log`x' = ln(`x' + 1)
}

* Set panel structure
xtset year hh_id

*------------------------------------------------------------------------------
* 2. SUMMARY STATISTICS
*------------------------------------------------------------------------------

* Electricity access by year and location
tabstat elec_access [aweight=weight], by(year) stat(n mean sd min max) long format
tabstat elec_access [aweight=weight] if rural==1, by(year) stat(n mean sd min max) long format
tabstat elec_access [aweight=weight] if rural==2, by(year) stat(n mean sd min max) long format

* Summary statistics by year
eststo summry: qui estpost summarize sex mari_stat enterp elec_access elec_asset $xlist
eststo summry2011: qui estpost summarize sex mari_stat enterp elec_access elec_asset $xlist if year==2011
eststo summry2013: qui estpost summarize sex mari_stat enterp elec_access elec_asset $xlist if year==2013
eststo summry2015: qui estpost summarize sex mari_stat enterp elec_access elec_asset $xlist if year==2015


**Table A1: Summary of the descriptive statistics 

* Detailed summary for key variables
eststo summry: qui estpost summarize $vlist
eststo summry11: qui estpost summarize $vlist if year==2011
eststo summry13: qui estpost summarize $vlist if year==2013
eststo summry15: qui estpost summarize $vlist if year==2015

esttab summry11 summry13 summry15 using "tables\Table_A1.rtf", ///
    title(Table A1: Summary of the descriptive statistics) ///
    mtitles("2011" "2013" "2015") ///
    cells("mean(fmt(2) label(Mean)) sd(fmt(2) label(SD))") ///
    nogap nonumber ///
    varlabels(elec_access "Access for electricity in the household (1=yes, 0=no)" ///
        outage "Total number of electricity power failures" ///
        enterp "Non-farm business ownership (1=yes, 0=no)" ///
        nf_empl "Non-farm employment participation (1=yes, 0=no)" ///
        age "Age of household head (years)" ///
        hh_size "Household size" ///
        mari_stat "Marital status of household head" ///
        sex "Gender of household head" ///
        avhh_educ "Average household schooling (years)" ///
        dist_road "Distance to nearest major road (km)" ///
        distancekm_wekly_markt "Distance to nearest large weekly market (km)" ///
        farm_area "Land per household (hectares)" ///
        mean_rainfall_hh "Average 12-month rainfall Jan-Dec (mm)" ///
        roadkm "Distance to nearest tar/asphalt road (km)" ///
        phone_acess "Phone call access in community (yes=1, no=0)") ///
    replace
*------------------------------------------------------------------------------
* 3. FIGURES
*------------------------------------------------------------------------------

**Figure 1: Existing and planned electricity transmission lines (QGIS)  

preserve
collapse (mean) elec_access enterp share_nonfarm, by(year)

* Figure 2: Electricity, enterprise ownership, and off-farm income trends
graph twoway ///
    (connected elec_access year, lcolor(navy) lwidth(thin) lpattern(shortdash)) ///
    (connected enterp year) ///
    (connected share_nonfarm year, lwidth(thin) lpattern(longdash_dot)), ///
    xlab(, nogrid) ylabel(, angle(horizontal) nogrid) ///
    ytitle("Percent", size(small)) xtitle("Year", size(small)) ///
    legend(position(6) order(1 "Electricity access" 2 "Non-farm enterprise ownership" ///
        3 "Off-farm income share") rows(1) size(vsmall) region(lstyle(none)))	 ///
    graphregion(color(white) lcolor(white)) ///
    plotregion(color(white) lcolor(white))	
graph export "figures\Figure_2.png", replace
graph export "figures\Figure_2.pdf", replace
restore
 
* Figure A3: Electricity access in rural Ethiopia (2011-2015)
graph bar elec_access, over(year) ///
    bar(1, color(green)) bar(2, color(green)) ///
    ytitle("Rate", size(small)) ///
    blabel(bar, format(%4.2f)) ///
    intensity(10) ylab(, nogrid) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(fcolor(white) lcolor(white))

graph export "figures/Figure_A3.png", replace
graph export "figures/Figure_A3.pdf", replace

* Figure A4: Non-farm business ownership and off-farm income share

graph bar enterp share_nonfarm, over(year) ///
    bar(1, color(green)) bar(2, color(blue)) ///
    ytitle("Rate", size(small)) ///
    legend(position(6) cols(2) ///
        order(1 "Non-farm enterprise ownership" ///
              2 "Off-farm income share") ///
        size(small) region(fcolor(white) lcolor(none))) ///
    blabel(bar, format(%4.2f) color(black)) ///
    intensity(10) ylab(, nogrid) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(fcolor(white) lcolor(white))

graph export "figures/Figure_A4.png", replace
graph export "figures/Figure_A4.pdf", replace
*------------------------------------------------------------------------------
* 4. MAIN ANALYSIS: ENTERPRISE OWNERSHIP
*------------------------------------------------------------------------------

* Model 1: Baseline
eststo iv1_1: ivreghdfe enterp mari_stat ihs_age ihs_hh_size ihs_farm_area ///
    micro_inst credit_access weekly_markt fsrad3_lcmaj srtm_5_15 ///
    ihs_nonagwage_income (elec_access = ihs_dist20) if rural==1, ///
    abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st1_1)
estadd scalar KPLM = `e(widstat)' :st1_1elec_access
estadd scalar CDF = `e(cdf)' :st1_1elec_access
estadd scalar AP = `e(rkf)' :st1_1elec_access
estadd scalar Obs = `e(N)' :st1_1elec_access
estadd local yrx "Yes" :st1_1elec_access
estadd local eax "Yes" :st1_1elec_access
estadd local hhc "Yes" :st1_1elec_access
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'
estadd scalar CDF = `e(cdf)'
estadd scalar KPLM = `e(widstat)' 

* Model 2: Interaction with market distance
eststo iv1_2: ivreghdfe enterp ihs_near_mkt_kms mari_stat ihs_age sex ///
    ihs_hh_size ihs_avhh_educ ihs_farm_area micro_inst credit_access ///
    ihs_agriequp_value fsrad3_lcmaj ihs_nonagwage_income ihs_totalasset_value ///
    (elec_access ihs_elec_mktkms = ihs_dist20 ihs_dist20_mktkms) if rural==1, ///
    abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st1_2)
estadd scalar KPLM = `e(widstat)' :st1_2elec_access
estadd scalar CDF = `e(cdf)' :st1_2elec_access
estadd scalar AP = `e(rkf)' :st1_2elec_access
estadd scalar Obs = `e(N)' :st1_2elec_access
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'
estadd scalar CDF = `e(cdf)'
estadd scalar KPLM = `e(widstat)' 

* Model 3: Interaction with bank distance
eststo iv1_3: ivreghdfe enterp ihs_near_bank_kms mari_stat ihs_age sex ///
    ihs_hh_size ihs_avhh_educ ihs_farm_area micro_inst credit_access ///
    fsrad3_lcmaj ihs_agriequp_value ihs_nonagwage_income ihs_main_accesroad ///
    farm_type nfarm_emplt (elec_access ihs_elec_bankkms = ihs_dist20 ihs_dist20_bankkms) ///
    if rural==1, abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st1_3)
estadd scalar KPLM = `e(widstat)' :st1_3elec_access
estadd scalar CDF = `e(cdf)' :st1_3elec_access
estadd scalar AP = `e(rkf)' :st1_3elec_access
estadd scalar Obs = `e(N)' :st1_3elec_access
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'
estadd scalar CDF = `e(cdf)'
estadd scalar KPLM = `e(widstat)' 

* Model 4: Interaction with road distance
eststo iv1_4: ivreghdfe enterp ihs_roadkm mari_stat ihs_age sex ihs_hh_size ///
    ihs_farm_area weekly_markt credit_access micro_inst fsrad3_lcmaj srtm_5_15 ///
    ihs_drft_animal ihs_nonagwage_income ///
    (elec_access ihs_elec_roadkms = ihs_dist20 ihs_dist20_roadkms) if rural==1, ///
    abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st1_4)
estadd scalar KPLM = `e(widstat)' :st1_4elec_access
estadd scalar CDF = `e(cdf)' :st1_4elec_access
estadd scalar AP = `e(rkf)' :st1_4elec_access
estadd scalar Obs = `e(N)' :st1_4elec_access
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'
estadd scalar CDF = `e(cdf)'
estadd scalar KPLM = `e(widstat)' 

*------------------------------------------------------------------------------
* 5. MAIN ANALYSIS: OFF-FARM INCOME SHARE
*------------------------------------------------------------------------------

* Model 1: Baseline
eststo iv2_1: ivreghdfe ihs_share_nonfarm ihs_hh_size sex ihs_age mari_stat ///
    ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm fsrad3_lcmaj ///
    (elec_access = ihs_dist20) if rural==1, ///
    abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st2_1)
estadd scalar KPLM = `e(widstat)' :st2_1elec_access
estadd scalar CDF = `e(cdf)' :st2_1elec_access
estadd scalar AP = `e(rkf)' :st2_1elec_access
estadd scalar Obs = `e(N)' :st2_1elec_access
estadd local yrx "Yes" :st2_1elec_access
estadd local eax "Yes" :st2_1elec_access
estadd local hhc "Yes" :st2_1elec_access
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'
estadd scalar CDF = `e(cdf)'
estadd scalar KPLM = `e(widstat)' 

* Model 2: Interaction with market distance
eststo iv2_2: ivreghdfe ihs_share_nonfarm ihs_near_mkt_kms ihs_hh_size sex ///
    ihs_age mari_stat ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm fsrad3_lcmaj ///
    (elec_access ihs_elec_mktkms = ihs_dist20 ihs_dist20_mktkms) if rural==1, ///
    abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st2_2)
estadd scalar KPLM = `e(widstat)' :st2_2elec_access
estadd scalar CDF = `e(cdf)' :st2_2elec_access
estadd scalar AP = `e(rkf)' :st2_2elec_access
estadd scalar Obs = `e(N)' :st2_2elec_access
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'
estadd scalar CDF = `e(cdf)'
estadd scalar KPLM = `e(widstat)' 

* Model 3: Interaction with bank distance
eststo iv2_3: ivreghdfe ihs_share_nonfarm ihs_near_bank_kms ihs_hh_size sex ///
    ihs_age mari_stat ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm fsrad3_lcmaj ///
    (elec_access ihs_elec_bankkms = ihs_dist20 ihs_dist20_bankkms) if rural==1, ///
    abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st2_3)
estadd scalar KPLM = `e(widstat)' :st2_3elec_access
estadd scalar CDF = `e(cdf)' :st2_3elec_access
estadd scalar AP = `e(rkf)' :st2_3elec_access
estadd scalar Obs = `e(N)' :st2_3elec_access
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'
estadd scalar CDF = `e(cdf)' 
estadd scalar KPLM = `e(widstat)' 

* Model 4: Interaction with road distance
eststo iv2_4: ivreghdfe ihs_share_nonfarm ihs_roadkm ihs_hh_size sex ihs_age ///
    mari_stat ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm fsrad3_lcmaj ///
    (elec_access ihs_elec_roadkms = ihs_dist20 ihs_dist20_roadkms) if rural==1, ///
    abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st2_4)
estadd scalar KPLM = `e(widstat)' :st2_4elec_access
estadd scalar CDF = `e(cdf)' :st2_4elec_access
estadd scalar AP = `e(rkf)' :st2_4elec_access
estadd scalar Obs = `e(N)' :st2_4elec_access
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'
estadd scalar CDF = `e(cdf)'
estadd scalar KPLM = `e(widstat)' 
**Exporting tables 	
	
*Table 1: First-Stage estimates.

esttab st1_1elec_access st2_1elec_access  ///
    using "tables\Table_1.rtf", ///
    b(3) se r2 obs title(First-Stage estimates for non-farm enterprise ownership and off-farm income share.) ///
    mtitles("Non-farm enterprise (1)" "Off-farm income (5)") ///
    nonumbers nonote ///
    addnotes("Note: The instrument is constructed considering electric transmission lines connecting hydropower stations and the 20 major urban centers in Ethiopia. In addition, households' proximity to the least cost distance to the gridline is calculated within a 10 km buffer zone. Standard errors in parentheses are clustered at the village level. *** p<0.01, ** p<0.05, * p<0.1.") ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(ihs_dist20) ///
    varlabels(ihs_dist20 "Distance to the least cost gridline × time trend") ///
    s(hhc yrx eax KPLM  N, label("Household level controls" "Year level fixed effects" ///
        "District level fixed effects" "F statistic" "Observations")) ///
    replace
	
*Table 2: Second-Stage estimates.
	
* Export combined second-stage results
esttab iv1_1 iv1_2 iv1_3 iv1_4 iv2_1 iv2_2 iv2_3 iv2_4 ///
    using "tables\Table_2.rtf", ///
    b(3) se r2 title(Second-Stage estimates for non-farm enterprise ownership and off-farm income share.) ///
    mgroups("Enterprise" "Off-farm income", pattern(1 0 0 0 1 0 0 0)) ///
    mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") ///
    nonumbers ///
    addnotes("Note: The dependent variables are non-farm enterprise ownership (columns 1–4) and the share of non-farm income (columns 5–8). The result in column (1) does not consider any of the complementary factors. In column (2), the interaction between electricity access and proximity to the nearest market is considered. Similarly, the interaction between electricity access and proximity to the nearest commercial bank is considered in column (3). Village level clustered standard errors in parentheses. *** p<0.01, ** p<0.05, * p<0.1.") ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(elec_access ihs_near_mkt_kms ihs_roadkm ihs_near_bank_kms ///
        ihs_elec_mktkms ihs_elec_roadkms ihs_elec_bankkms) ///
    varlabels(elec_access "Electricity access" ///
        ihs_near_mkt_kms "Distance to nearest market" ///
        ihs_roadkm "Distance to nearest road network" ///
        ihs_near_bank_kms "Distance to nearest bank" ///
        ihs_elec_mktkms "Electricity × Market distance" ///
        ihs_elec_roadkms "Electricity × Road distance" ///
        ihs_elec_bankkms "Electricity × Bank distance") ///
    s(hhc yrx eax KPLM N, label("Household level controls" "Year level fixed effects" ///
        "District level fixed effects"  "F statistics" "Observations")) ///
    nonote replace
	

*------------------------------------------------------------------------------
* 6. ROBUSTNESS: EXCLUDING HOUSEHOLDS NEAR CITIES (ENTERPRISE OWNERSHIP)
*------------------------------------------------------------------------------

* Loop over distance thresholds: 5km, and 10km
foreach dist in 5 10 15 20 {
    local i = `dist'/5  // Create index for naming
    
    * Baseline model
    eststo iv1b_a`i': ivreghdfe enterp mari_stat ihs_age ihs_hh_size ///
        ihs_farm_area micro_inst credit_access weekly_markt fsrad3_lcmaj ///
        srtm_5_15 ihs_nonagwage_income (elec_access = ihs_dist20) ///
        if rural==1 & ea_5citdis_kms>`dist', ///
        abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st1b_a`i')
    estadd scalar KPLM = `e(widstat)' :st1b_a`i'elec_access
    estadd scalar CDF = `e(cdf)' :st1b_a`i'elec_access
    estadd scalar AP = `e(rkf)' :st1b_a`i'elec_access
    estadd scalar Obs = `e(N)' :st1b_a`i'elec_access
    estadd local yrx "Yes" :st1b_a`i'elec_access
    estadd local eax "Yes" :st1b_a`i'elec_access
    estadd local hhc "Yes" :st1b_a`i'elec_access
    
    * Market interaction
    eststo iv1b_b`i': ivreghdfe enterp ihs_near_mkt_kms mari_stat ihs_age sex ///
        ihs_hh_size ihs_avhh_educ ihs_farm_area micro_inst credit_access ///
        ihs_agriequp_value fsrad3_lcmaj ihs_nonagwage_income ihs_totalasset_value ///
        (elec_access ihs_elec_mktkms = ihs_dist20 ihs_dist20_mktkms) ///
        if rural==1 & ea_5citdis_kms>`dist', ///
        abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st1b_b`i')
    estadd scalar KPLM = `e(widstat)' :st1b_b`i'elec_access
    estadd scalar CDF = `e(cdf)' :st1b_b`i'elec_access
    estadd scalar AP = `e(rkf)' :st1b_b`i'elec_access
    estadd scalar Obs = `e(N)' :st1b_b`i'elec_access
    estadd local yrx "Yes" :st1b_b`i'elec_access
    estadd local eax "Yes" :st1b_b`i'elec_access
    estadd local hhc "Yes" :st1b_b`i'elec_access
    
    * Bank interaction
    eststo iv1b_c`i': ivreghdfe enterp ihs_near_bank_kms mari_stat ihs_age sex ///
        ihs_hh_size ihs_avhh_educ ihs_farm_area micro_inst credit_access ///
        fsrad3_lcmaj ihs_agriequp_value ihs_nonagwage_income ihs_main_accesroad ///
        farm_type nfarm_emplt (elec_access ihs_elec_bankkms = ihs_dist20 ihs_dist20_bankkms) ///
        if rural==1 & ea_5citdis_kms>`dist', ///
        abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st1b_c`i')
    estadd scalar KPLM = `e(widstat)' :st1b_c`i'elec_access
    estadd scalar CDF = `e(cdf)' :st1b_c`i'elec_access
    estadd scalar AP = `e(rkf)' :st1b_c`i'elec_access
    estadd scalar Obs = `e(N)' :st1b_c`i'elec_access
    estadd local yrx "Yes" :st1b_c`i'elec_access
    estadd local eax "Yes" :st1b_c`i'elec_access
    estadd local hhc "Yes" :st1b_c`i'elec_access
    
    * Road interaction
    eststo iv1b_d`i': ivreghdfe enterp ihs_roadkm mari_stat ihs_age sex ///
        ihs_hh_size ihs_farm_area weekly_markt credit_access micro_inst ///
        fsrad3_lcmaj srtm_5_15 ihs_drft_animal ihs_nonagwage_income ///
        (elec_access ihs_elec_roadkms = ihs_dist20 ihs_dist20_roadkms) ///
        if rural==1 & ea_5citdis_kms>`dist', ///
        abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st1b_d`i')
    estadd scalar KPLM = `e(widstat)' :st1b_d`i'elec_access
    estadd scalar CDF = `e(cdf)' :st1b_d`i'elec_access
    estadd scalar AP = `e(rkf)' :st1b_d`i'elec_access
    estadd scalar Obs = `e(N)' :st1b_d`i'elec_access
    estadd local yrx "Yes" :st1b_d`i'elec_access
    estadd local eax "Yes" :st1b_d`i'elec_access
    estadd local hhc "Yes" :st1b_d`i'elec_access
}

*------------------------------------------------------------------------------
* 7. ROBUSTNESS: EXCLUDING HOUSEHOLDS NEAR CITIES (OFF-FARM INCOME)
*------------------------------------------------------------------------------

* Loop over distance thresholds
foreach dist in 5 10 15 20 {
    local i = `dist'/5
    
    * Baseline model
    eststo iv2b_`i'a: ivreghdfe ihs_share_nonfarm ihs_hh_size sex ihs_age ///
        mari_stat ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm fsrad3_lcmaj ///
        (elec_access = ihs_dist20) if rural==1 & ea_5citdis_kms>`dist', ///
        abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st2b_`i'a)
    estadd scalar KPLM = `e(widstat)' :st2b_`i'aelec_access
    estadd scalar CDF = `e(cdf)' :st2b_`i'aelec_access
    estadd scalar AP = `e(rkf)' :st2b_`i'aelec_access
    estadd scalar Obs = `e(N)' :st2b_`i'aelec_access
    estadd local yrx "Yes" :st2b_`i'aelec_access
    estadd local eax "Yes" :st2b_`i'aelec_access
    estadd local hhc "Yes" :st2b_`i'aelec_access
    
    * Market interaction
    eststo iv2b_`i'b: ivreghdfe ihs_share_nonfarm ihs_near_mkt_kms ihs_hh_size ///
        sex ihs_age mari_stat ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm ///
        fsrad3_lcmaj (elec_access ihs_elec_mktkms = ihs_dist20 ihs_dist20_mktkms) ///
        if rural==1 & ea_5citdis_kms>`dist', ///
        abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st2b_`i'b)
    estadd scalar KPLM = `e(widstat)' :st2b_`i'belec_access
    estadd scalar CDF = `e(cdf)' :st2b_`i'belec_access
    estadd scalar AP = `e(rkf)' :st2b_`i'belec_access
    estadd scalar Obs = `e(N)' :st2b_`i'belec_access
    estadd local yrx "Yes" :st2b_`i'belec_access
    estadd local eax "Yes" :st2b_`i'belec_access
    estadd local hhc "Yes" :st2b_`i'belec_access
    
    * Bank interaction
    eststo iv2b_`i'c: ivreghdfe ihs_share_nonfarm ihs_near_bank_kms ihs_hh_size ///
        sex ihs_age mari_stat ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm ///
        fsrad3_lcmaj (elec_access ihs_elec_bankkms = ihs_dist20 ihs_dist20_bankkms) ///
        if rural==1 & ea_5citdis_kms>`dist', ///
        abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st2b_`i'c)
    estadd scalar KPLM = `e(widstat)' :st2b_`i'celec_access
    estadd scalar CDF = `e(cdf)' :st2b_`i'celec_access
    estadd scalar AP = `e(rkf)' :st2b_`i'celec_access
    estadd scalar Obs = `e(N)' :st2b_`i'celec_access
    estadd local yrx "Yes" :st2b_`i'celec_access
    estadd local eax "Yes" :st2b_`i'celec_access
    estadd local hhc "Yes" :st2b_`i'celec_access
    
    * Road interaction
    eststo iv2b_`i'd: ivreghdfe ihs_share_nonfarm ihs_roadkm ihs_hh_size sex ///
        ihs_age mari_stat ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm ///
        fsrad3_lcmaj (elec_access ihs_elec_roadkms = ihs_dist20 ihs_dist20_roadkms) ///
        if rural==1 & ea_5citdis_kms>`dist', ///
        abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st2b_`i'd)
    estadd scalar KPLM = `e(widstat)' :st2b_`i'delec_access
    estadd scalar CDF = `e(cdf)' :st2b_`i'delec_access
    estadd scalar AP = `e(rkf)' :st2b_`i'delec_access
    estadd scalar Obs = `e(N)' :st2b_`i'delec_access
    estadd local yrx "Yes" :st2b_`i'delec_access
    estadd local eax "Yes" :st2b_`i'delec_access
    estadd local hhc "Yes" :st2b_`i'delec_access
}


*Table A2

* PANEL 1: EXCLUDING HOUSEHOLDS WITHIN 5 KM RADIUS 

esttab st1b_a1elec_access st1b_b1elec_access st1b_c1elec_access st1b_d1elec_access ///
       st2b_1aelec_access st2b_1belec_access st2b_1celec_access ///
    using "tables\Table_A2_Panel1.rtf", ///
    b(3) se r2 ///
    title(Table A2: First-Stage estimates excluding control groups (Excluding households within 5 km radius)) ///
    mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") ///
    nonumbers nonote ///
    addnotes("Note: The dependent variables are non-farm enterprise ownership in columns (1) - (4), the share of non-farm income in columns (5) - (7). Estimates in Table A2 exclude those households within" ///
        "a radius of 5 kilometers from any of the top 20 big cities in Ethiopia. The instrument is constructed considering electric transmission lines connecting hydropower stations and the 20 major" ///
        "urban centers in Ethiopia. In addition, the least cost distance to the grid line is calculated within a 5 kilometer radius of the household's village. The result in column (1) uses not consider any" ///
        "interaction with infrastructure. In column (2), the interaction between electricity access and proximity to the nearest commercial market is considered. Similarly, the interaction between electricity access" ///
        "and proximity to the nearest commercial bank is considered in column (3). Village level clustered standard errors in parentheses.") ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(ihs_dist20 ) ///
    varlabels(ihs_dist20 "Distance to the Least-cost grid line") ///
    s(hhc eax yrx KPLM N, ///
        label("Household level controls" "District level fixed effects" ///
              "Year fixed effects" "F-statistics" "Observations")) ///
    replace

* PANEL 2: EXCLUDING HOUSEHOLDS WITHIN 10 KM RADIUS 

esttab st1b_a2elec_access st1b_b2elec_access st1b_c2elec_access st1b_d2elec_access ///
       st2b_2aelec_access st2b_2belec_access st2b_2celec_access ///
    using "tables\Table_A2_Panel2.rtf", ///
    b(3) se r2 ///
    title(Table A2: First-Stage estimates excluding control groups (Excluding households within 10 km radius)) ///
    mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") ///
    nonumbers nonote ///
    addnotes("Note: The dependent variables are non-farm enterprise ownership in columns (1) - (4), the share of non-farm income in columns (5) - (7). Estimates in Table A2 exclude those households within" ///
        "a radius of 10 kilometers from any of the top 20 big cities in Ethiopia. The instrument is constructed considering electric transmission lines connecting hydropower stations and the 20 major" ///
        "urban centers in Ethiopia. In addition, the least cost distance to the grid line is calculated within a 10 kilometer radius of the household's village.") ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(ihs_dist20  ) ///
    varlabels(ihs_dist20 "Distance to the Least-cost grid line") ///
    s(hhc eax yrx CDF N, ///
        label("Household level controls" "District level fixed effects" ///
              "Year fixed effects" "F-statistics" "Observations")) ///
    replace
	
*------------------------------------------------------------------------------
* 8. COEFFICIENT PLOTS
*------------------------------------------------------------------------------

**Figure 5: Coefficient plots - non-farm enterprise ownership (10km)

* Plot 1: Full Sample (no legend)
*second stage - electricity access 

coefplot ///
    (iv1_1, label(Model 1) offset(-0.3) mlabel("Model 1") mlabposition(13) mlabgap(-26.9) mlabsize(small) mlabcolor(black)) ///
    (iv1_2, label(Model 2) offset(-0.1) mlabel("Model 2") mlabposition(13) mlabgap(-40.2) mlabsize(small) mlabcolor(black)) ///
    (iv1_3, label(Model 3) offset(0.1) mlabel("Model 3") mlabposition(13) mlabgap(-46.0) mlabsize(small) mlabcolor(black)) ///
    (iv1_4, label(Model 4) offset(0.3) mlabel("Model 4") mlabposition(13) mlabgap(-36.6) mlabsize(small) mlabcolor(black)), ///
    keep(elec_access) drop(_cons) ///
    ytitle("Estimates") ///
    title("Full Sample", size(medium)) ///
    graphregion(color(white)) plotregion(color(white)) bgcolor(white) ///
    vertical nolabels ///
    ciopts(recast(rcap)) ///
    xlabel(none) ///
    ylabel(, angle(horizontal) labsize(medium) nogrid) ///
    legend(off) ///
    name(fullsampleplot, replace)

* Plot 2: Excluding Controls (no legend)
coefplot ///
    (iv1b_a2, label(Model 1) offset(-0.3) mlabel("Model 1") mlabposition(13) mlabgap(-34.5) mlabsize(small) mlabcolor(black)) ///
    (iv1b_b2, label(Model 2) offset(-0.1) mlabel("Model 2") mlabposition(13) mlabgap(-63.3) mlabsize(small) mlabcolor(black)) ///
    (iv1b_c2, label(Model 3) offset(0.1) mlabel("Model 3") mlabposition(13) mlabgap(-60.7) mlabsize(small) mlabcolor(black)) ///
    (iv1b_d2, label(Model 4) offset(0.3) mlabel("Model 4") mlabposition(13) mlabgap(-53.6) mlabsize(small) mlabcolor(black)), ///
    keep(elec_access) drop(_cons) ///
    ytitle("Estimates") ///
    title("Excluding Controls", size(medium)) ///
    graphregion(color(white)) plotregion(color(white)) bgcolor(white) ///
    vertical nolabels ///
    ciopts(recast(rcap)) ///
    xlabel(none) ///
    ylabel(, angle(horizontal) labsize(medium) nogrid) ///
    legend(off) ///
    name(excludecontrolsplot, replace)


* Combine both plots with common bottom title
graph combine fullsampleplot excludecontrolsplot, ///
    col(2) ycommon ///
    graphregion(color(white) margin(b=8)) plotregion(color(white)) ///
    name(combinedplot2, replace) ///
    note("Electricity Access", span position(6) size(small) yoffset(-5)) ///
    imargin(zero) ///
    xsize(5) ysize(3) ///
    altshrink

* Save Stata graph file
graph save "figures/Figure_5.gph", replace

* Export in PNG and PDF
graph export "figures/Figure_5.png", name("combinedplot2") replace
graph export "figures/Figure_5.pdf", name("combinedplot2") replace


**Figure 6: Coefficient plots - Off-farm income share (10 km)
	
* Second stage - electricity access

* Plot 1: Full Sample

coefplot ///
    (iv2_1, label(Model 1) offset(-0.3) mlabel("Model 1") mlabposition(13) mlabgap(-26.5) mlabsize(small) mlabcolor(black)) ///
    (iv2_2, label(Model 2) offset(-0.1) mlabel("Model 2") mlabposition(13) mlabgap(-38.4) mlabsize(small) mlabcolor(black)) ///
    (iv2_3, label(Model 3) offset(0.1) mlabel("Model 3") mlabposition(13) mlabgap(-59.7) mlabsize(small) mlabcolor(black)) ///
    (iv2_4, label(Model 4) offset(0.3) mlabel("Model 4") mlabposition(13) mlabgap(-36.9) mlabsize(small) mlabcolor(black)), ///
    keep(elec_access) drop(_cons) ///
    ytitle("Estimates") ///
    title("Full Sample", size(medium)) ///
    graphregion(color(white)) plotregion(color(white)) bgcolor(white) ///
    vertical nolabels ///
    ciopts(recast(rcap)) ///
    xlabel(none) ///
    ylabel(, angle(horizontal) labsize(medium) nogrid) ///
    legend(off) ///
    name(fullsampleplot2, replace)

* Plot 2: Excluding Controls (no legend)
coefplot ///
    (iv2b_1b, label(Model 1) offset(-0.3) mlabel("Model 1") mlabposition(13) mlabgap(-24.3) mlabsize(small) mlabcolor(black)) ///
    (iv2b_2b, label(Model 2) offset(-0.1) mlabel("Model 2") mlabposition(13) mlabgap(-26.5) mlabsize(small) mlabcolor(black)) ///
    (iv2b_3b, label(Model 3) offset(0.1) mlabel("Model 3") mlabposition(13) mlabgap(-19.0) mlabsize(small) mlabcolor(black)) ///
    (iv2b_4b, label(Model 4) offset(0.3) mlabel("Model 4") mlabposition(13) mlabgap(-19.0) mlabsize(small) mlabcolor(black)), ///
    keep(elec_access) drop(_cons) ///
    ytitle("Estimates") ///
    title("Excluding Controls", size(medium)) ///
    graphregion(color(white)) plotregion(color(white)) bgcolor(white) ///
    vertical nolabels ///
    ciopts(recast(rcap)) ///
    xlabel(none) ///
    ylabel(, angle(horizontal) labsize(medium) nogrid) ///
    legend(off) ///
    name(excludecontrolsplot2, replace)

* Combine both plots with common bottom title
graph combine fullsampleplot2 excludecontrolsplot2, ///
    col(2) ycommon ///
    graphregion(color(white) margin(b=8)) plotregion(color(white)) ///
    name(combinedplot_3, replace) ///
    note("Electricity Access", span position(6) size(small) yoffset(-5)) ///
    imargin(zero) ///
    xsize(5) ysize(3) ///
    altshrink

* Save and export
graph save "figures/Figure_6.gph", replace
graph export "figures/Figure_6.png", name("combinedplot_3") replace
graph export "figures/Figure_6.pdf", name("combinedplot_3") replace	
	
*------------------------------------------------------------------------------
* 9. PLACEBO TESTS
*------------------------------------------------------------------------------

* 1.1 Railway Distance Placebo (Table 3)

* Main IV specification (using valid instrument)
eststo iv1_1: ivreghdfe enterp mari_stat ihs_age ihs_hh_size ihs_farm_area ///
    micro_inst credit_access weekly_markt fsrad3_lcmaj srtm_5_15 ///
    ihs_nonagwage_income (elec_access = ihs_dist20) if rural==1, ///
    abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st1_1)

* Store first-stage statistics
estadd scalar KPLM = `e(widstat)' :st1_1elec_access
estadd scalar CDF = `e(cdf)' :st1_1elec_access
estadd scalar AP = `e(rkf)' :st1_1elec_access
estadd scalar Obs = `e(N)' :st1_1elec_access
estadd local yrx "Yes" :st1_1elec_access
estadd local eax "Yes" :st1_1elec_access
estadd local hhc "Yes" :st1_1elec_access

* Store second-stage statistics
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar KPLM = `e(widstat)'
estadd scalar CDF = `e(cdf)'
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'

* Placebo IV specification (using railway distance as instrument)
eststo plac1_iv1_2: ivreghdfe enterp mari_stat ihs_age ihs_hh_size ///
    ihs_farm_area micro_inst credit_access weekly_markt fsrad3_lcmaj ///
    srtm_5_15 ihs_nonagwage_income (elec_access = ihs_hh_railway_dist_kms) ///
    if rural==1, abs(woreda_id year) cl(hh_id) first savefirst ///
    savefprefix(plac1_st1_1)

* Store first-stage statistics
estadd scalar KPLM = `e(widstat)' :plac1_st1_1elec_access
estadd scalar CDF = `e(cdf)' :plac1_st1_1elec_access
estadd scalar AP = `e(rkf)' :plac1_st1_1elec_access
estadd scalar Obs = `e(N)' :plac1_st1_1elec_access
estadd local yrx "Yes" :plac1_st1_1elec_access
estadd local eax "Yes" :plac1_st1_1elec_access
estadd local hhc "Yes" :plac1_st1_1elec_access

* Store second-stage statistics
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar KPLM = `e(widstat)'
estadd scalar CDF = `e(cdf)'
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'

* Export Table 3
esttab iv1_1 plac1_iv1_2 using "tables\Table_3.rtf", ///
    b(3) se r2 ///
    title(Table 3: Placebo Estimates Using Distance to Planned Railway as Instrument.) ///
    mtitles("IV Estimates" "Placebo Estimates") ///
    nonumbers nonote ///
    addnotes("Note: Village level clustered standard errors in parentheses. In column (1), the distance between households and the nearest least-cost electricity gridline is used as an instrument in the first-stage estimation, while column (2) uses the distance to the nearest planned railway line as the instrument. The instruments are constructed considering 20 major urban centers in Ethiopia. *** p<0.01, ** p<0.05, * p<0.1.") ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(elec_access) ///
    varlabels(elec_access "Electricity access") ///
    s(hhc yrx eax KPLM N, ///
    label("Household level controls" "Year level fixed effects" "District level fixed effects" "F statistics" "Observations")) ///
    replace

* 1.2 Natural Reserve Distance Placebo (Table 5)

* Main IV specification (using valid instrument)
eststo iv1_1: ivreghdfe enterp mari_stat ihs_age ihs_hh_size ihs_farm_area ///
    micro_inst credit_access weekly_markt fsrad3_lcmaj srtm_5_15 ///
    ihs_nonagwage_income (elec_access = ihs_dist20) if rural==1, ///
    abs(woreda_id year) cl(hh_id) first savefirst savefprefix(st1_1)

* Store statistics
estadd scalar KPLM = `e(widstat)' :st1_1elec_access
estadd scalar CDF = `e(cdf)' :st1_1elec_access
estadd scalar AP = `e(rkf)' :st1_1elec_access
estadd scalar Obs = `e(N)' :st1_1elec_access
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar KPLM = `e(widstat)'
estadd scalar CDF = `e(cdf)'
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'

* Placebo IV specification (using natural reserve distance as instrument)
eststo plac3_iv1_1: ivreghdfe enterp mari_stat ihs_age ihs_hh_size ///
    ihs_farm_area micro_inst credit_access weekly_markt fsrad3_lcmaj ///
    srtm_5_15 ihs_nonagwage_income (elec_access = ihs_hh_natur_dist_kms_updatd) ///
    if rural==1, abs(woreda_id year) cl(hh_id) first savefirst ///
    savefprefix(plac3_st1_1)

* Store statistics
estadd scalar KPLM = `e(widstat)' :plac3_st1_1elec_access
estadd scalar CDF = `e(cdf)' :plac3_st1_1elec_access
estadd scalar AP = `e(rkf)' :plac3_st1_1elec_access
estadd scalar Obs = `e(N)' :plac3_st1_1elec_access
estadd local yrx "Yes"
estadd local eax "Yes"
estadd local hhc "Yes"
estadd scalar KPLM = `e(widstat)'
estadd scalar CDF = `e(cdf)'
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'

* Export Table 5
esttab iv1_1 plac3_iv1_1 using "tables\Table_5.rtf", ///
    b(3) se r2 ///
    title(Table 5: Placebo Estimates Using Distance to Natural Reserve as Instrument) ///
    mtitles("IV Estimates" "Placebo Estimates") ///
    nonumbers nonote ///
    addnotes("Note: Village level clustered standard errors in parentheses. In column (1), the distance between households and the nearest least-cost electricity gridline is used as an instrument in the first-stage estimation, while column (2) uses the distance to the nearest natural reserve as the instrument. The instruments are constructed considering 20 major urban centers in Ethiopia. *** p<0.01, ** p<0.05, * p<0.1.") ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(elec_access) ///
    varlabels(elec_access "Electricity access") ///
    s(hhc yrx eax KPLM N, ///
    label("Household level controls" "Year level fixed effects" "District level fixed effects" "F statistics" "Observations")) ///
    replace


********************************************************************************
* PART 2: SHARE OF NON-FARM INCOME
********************************************************************************

* 2.1 Railway Distance Placebo (Table 4)

* Main IV specification (using valid instrument)
eststo iv2_1: ivreghdfe ihs_share_nonfarm ihs_hh_size sex ihs_age mari_stat ///
    ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm fsrad3_lcmaj ///
    (elec_access = ihs_dist20) if rural==1, abs(woreda_id year) cl(hh_id) ///
    first savefirst savefprefix(st2_1)

* Store statistics
estadd scalar KPLM = `e(widstat)' :st2_1elec_access
estadd scalar CDF = `e(cdf)' :st2_1elec_access
estadd scalar AP = `e(rkf)' :st2_1elec_access
estadd scalar Obs = `e(N)' :st2_1elec_access
estadd local yrx = "Yes"
estadd local eax = "Yes"
estadd local hhc = "Yes"
estadd scalar KPLM = `e(widstat)'
estadd scalar CDF = `e(cdf)'
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'

* Placebo IV specification (using railway distance as instrument)
eststo plac1_iv2_1: ivreghdfe ihs_share_nonfarm ihs_hh_size sex ihs_age ///
    mari_stat ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm fsrad3_lcmaj ///
    (elec_access = ihs_hh_railway_dist_kms) if rural==1, ///
    abs(woreda_id year) cl(hh_id) first savefirst savefprefix(plac1_st2_1)

* Store statistics
estadd scalar KPLM = `e(widstat)' :plac1_st2_1elec_access
estadd scalar CDF = `e(cdf)' :plac1_st2_1elec_access
estadd scalar AP = `e(rkf)' :plac1_st2_1elec_access
estadd scalar Obs = `e(N)' :plac1_st2_1elec_access
estadd local yrx = "Yes"
estadd local eax = "Yes"
estadd local hhc = "Yes"
estadd scalar KPLM = `e(widstat)'
estadd scalar CDF = `e(cdf)'
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'

* Export Table 4
esttab iv2_1 plac1_iv2_1 using "tables\Table_4.rtf", ///
    b(3) se r2 ///
    title(Table 4: Placebo Estimate for Non-Farm Employment Participation Using Distance to Planned Railway as Instrument) ///
    mtitles("IV Estimates" "Placebo Estimates") ///
    nonumbers nonote ///
    addnotes("Note: Village level clustered standard errors in parentheses. In column (1), the distance between households and the nearest least-cost electricity gridline is used as an instrument in the first-stage estimation, while column (2) uses the distance to the nearest planned railway line as the instrument. The instruments are constructed considering 20 major urban centers in Ethiopia.") ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(elec_access) ///
    varlabels(elec_access "Electricity access") ///
    s(hhc yrx eax KPLM N, ///
    label("Household level controls" "Year level fixed effects" "District level fixed effects" "F statistics" "Observations")) ///
    replace

* 2.2 Natural Reserve Distance Placebo (Table 6)

* Main IV specification (using valid instrument)
eststo iv2_1: ivreghdfe ihs_share_nonfarm ihs_hh_size sex ihs_age mari_stat ///
    ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm fsrad3_lcmaj ///
    (elec_access = ihs_dist20) if rural==1, abs(woreda_id year) cl(hh_id) ///
    first savefirst savefprefix(st2_1)

* Store statistics
estadd scalar KPLM = `e(widstat)' :st2_1elec_access
estadd scalar CDF = `e(cdf)' :st2_1elec_access
estadd scalar AP = `e(rkf)' :st2_1elec_access
estadd scalar Obs = `e(N)' :st2_1elec_access
estadd local yrx = "Yes"
estadd local eax = "Yes"
estadd local hhc = "Yes"
estadd scalar KPLM = `e(widstat)'
estadd scalar CDF = `e(cdf)'
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'

* Placebo IV specification (using natural reserve distance as instrument)
eststo plac3_iv2_1: ivreghdfe ihs_share_nonfarm ihs_hh_size sex ihs_age ///
    mari_stat ihs_farm_area ihs_mean_rainfall_hh ihs_roadkm fsrad3_lcmaj ///
    (elec_access = ihs_hh_natur_dist_kms_updatd) if rural==1, ///
    abs(woreda_id year) cl(hh_id) first savefirst savefprefix(plac3_st2_1)

* Store statistics
estadd scalar KPLM = `e(widstat)' :plac3_st2_1elec_access
estadd scalar CDF = `e(cdf)' :plac3_st2_1elec_access
estadd scalar AP = `e(rkf)' :plac3_st2_1elec_access
estadd scalar Obs = `e(N)' :plac3_st2_1elec_access
estadd local yrx = "Yes"
estadd local eax = "Yes"
estadd local hhc = "Yes"
estadd scalar KPLM = `e(widstat)'
estadd scalar CDF = `e(cdf)'
estadd scalar AP = `e(rkf)'
estadd scalar Obs = `e(N)'

* Export Table 6
esttab iv2_1 plac3_iv2_1 using "tables\Table_6.rtf", ///
    b(3) se r2 ///
    title(Second-Stage estimates for non-farm employment participation) ///
    mtitles("IV Estimates" "Placebo Estimates") ///
    nonumbers nonote ///
    addnotes("Note: Village level clustered standard errors in parentheses. In column (1), the distance between households and the nearest least-cost electricity gridline is used as an instrument in the first-stage estimation, while column (2) uses the distance to the nearest natural reserve as the instrument. The instruments are constructed considering 20 major urban centers in Ethiopia. *** p<0.01, ** p<0.05, * p<0.1.") ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(elec_access) ///
    varlabels(elec_access "Electricity access") ///
    s(hhc yrx eax KPLM N, ///
    label("Household level controls" "Year level fixed effects" "District level fixed effects" "F statistics" "Observations")) ///
    replace

*------------------------------------------------------------------------------
* 10. END
*------------------------------------------------------------------------------

display "Replication code completed successfully"
display "Date: `c(current_date)'"
display "Time: `c(current_time)'"

log close smcllog
log close txtlog
* End of file








