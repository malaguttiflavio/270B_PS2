* -----------------------------------------------------------------------------
*  PROJECT: Beaman and Magruder 2012, Reproduction
*  PROGRAM: Table 4
*  PROGRAMMER: Beaman and Magruder, AER auxiliary files
*  REPRODUCER: Malagutti, 2021
* -----------------------------------------------------------------------------
* IN
local RAW_DATA "$inpdir/Kolkata.dta"

* OUT
local TAB_4 "$outdir/bm_2012_tab_4.csv"

* ELSE
estimates clear
eststo clear
macro shift

/* LOAD DATA
----------------------------------------------------------------- */
use "`RAW_DATA'", clear

/* MAIN GLOBALS
----------------------------------------------------------------- */
#delimit ;

global CONDITIONS="missingscore~=1";
global TREATVAR1 = "OPtreat4 OPtreat5";
global TREATVAR2="OPtestzOPtreat4 OPtestzOPtreat5 OPtestz  OPtreat4 OPtreat5";
// POST: RELATION TO OP **;
global CONTROLS="i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend ";

#delimit cr

/* FIRST STAGE
----------------------------------------------------------------- */
xi: dprobit ref sumrefrain anyrain $treatvar_1 $controls if OP==1 & OPtreat~=6 & OPtreat~=7 & $CONDITIONS
xi: dprobit ref sumrefrain anyrain $treatvar_2 $controls if OP==1 & OPtreat~=6 & OPtreat~=7 & $CONDITIONS

/* SECOND STAGE
----------------------------------------------------------------- */
foreach i in OP_coworkers_REFrep OP_relative_REFrep {

	xi: heckman `i' $treatvar_1 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7 ) & $ifconditions, select (sumrefrain anyrain $TREATVAR1 $CONTROLS) twostep
	testparm OPtreat*

	local pvalue=r(p)
	sum  `i' if OPtreat3==1
	local mean=r(mean)
	local sd=r(sd)
	test sumrefrain anyrain

	eststo `i'_h1, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2) mean `mean' sd `sd')

	xi: heckman `i' $treatvar_2 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7 ) & $ifconditions, select (sumrefrain anyrain $TREATVAR2 $CONTROLS) twostep
	test sumrefrain anyrain

	eststo `i'_h2, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2))
}

/* EXPORT
----------------------------------------------------------------- */
local VARS  OP_coworkers_REFrep_h1 OP_coworkers_REFrep_h2 OP_relative_REFrep_h1 OP_relative_REFrep_h2
local KEEP  sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5
local ORDER sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5

#delim ;
noisily esttab `VARS' using `TAB_4', plain label margin replace
           scalars(mean sd fstat millscoeff millsse ncens ) 
           cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) 
           starlevel(* .1 ** .051 *** .01) stardetach
           keep(`KEEP') order(`ORDER') 
           style(tab) varwidth(8) modelwidth(8);
#delim cr
