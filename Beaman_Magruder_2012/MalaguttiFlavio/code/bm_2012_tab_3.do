* -----------------------------------------------------------------------------
*  PROJECT: Beaman and Magruder 2012, Reproduction
*  PROGRAM: Table 3
*  PROGRAMMER: Beaman and Magruder, AER auxiliary files
*  REPRODUCER: Malagutti, 2021
* -----------------------------------------------------------------------------
* IN
local RAW_DATA "$inpdir/Kolkata.dta"

* OUT
local TAB_3 "$outdir/bm_2012_tab_3.csv"

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

global CONDITIONS = "missingscore~=1";
global TREATVAR1 = "OPtreat1 OPtreat2 ";
global TREATVAR2 = "OPtestzOPtreat1 OPtestzOPtreat2  OPtestz  OPtreat1 OPtreat2 ";

// POST: RELATION TO OP **;
global CONTROLS="i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend ";

#delimit cr

/* FIRST STAGE
----------------------------------------------------------------- */
xi: dprobit ref sumrefrain anyrain $TREATVAR1 $controls if OP == 1 & OPtreat < 4 & $CONDITIONS
xi: dprobit ref sumrefrain anyrain $TREATVAR2 $controls if OP == 1 & OPtreat < 4 & $CONDITIONS

/* SECOND STAGE
----------------------------------------------------------------- */
foreach i in OP_coworkers_REFrep OP_relative_REFrep reftestz {

	xi: heckman `i' $TREATVAR1 $controls if (OP==1 &  OPtreat<4) & $CONDITIONS, select (sumrefrain anyrain $TREATVAR1 $CONTROLS) twostep
	testparm OPtreat*

	local pvalue = r(p)
	sum  `i' if OPtreat3 == 1
	local mean = r(mean)
	local   sd = r(sd)
	test sumrefrain anyrain

	eststo `i'_h1, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2) pvalue `pvalue' mean `mean' sd `sd')

	xi: heckman `i' $TREATVAR2 $controls if (OP==1 &  OPtreat<4 ) & $CONDITIONS, select (sumrefrain anyrain $TREATVAR2 $CONTROLS) twostep
	testparm OPtreat* OPtest*

	local pvalue = r(p)
	sum `i' if OPtreat3 == 1
	local mean = r(mean)
	local   sd = r(sd)
	test sumrefrain anyrain

	eststo `i'_h2, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2) pvalue `pvalue')

}

/* EXPORT
----------------------------------------------------------------- */
local TABVARS OP_coworkers_REFrep_h1 OP_coworkers_REFrep_h2 OP_relative_REFrep_h1 OP_relative_REFrep_h2 reftestz_h2
local KEEP    sumrefrain anyrain OPtestzOPtreat1 OPtestzOPtreat2 OPtestz OPtreat1 OPtreat2
local ORDER   sumrefrain anyrain  OPtestzOPtreat1 OPtestzOPtreat2 OPtestz OPtreat1 OPtreat2

#delimit;
 noisily esttab `TABVARS' using `TAB_3', plain label margin replace
           scalars(pvalue mean sd fstat millscoeff millsse ncens ) 
           cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) 
           starlevel(* .1 ** .051 *** .01) stardetach 
           keep(`KEEP') order(`ORDER') 
           style(tab) varwidth(8) modelwidth(8) ;
#delimit cr
