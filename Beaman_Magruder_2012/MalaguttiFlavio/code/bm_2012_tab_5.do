* -----------------------------------------------------------------------------
*  PROJECT: Beaman and Magruder 2012, Reproduction
*  PROGRAM: Table 5
*  PROGRAMMER: Beaman and Magruder, AER auxiliary files
*  REPRODUCER: Malagutti, 2021
* -----------------------------------------------------------------------------
* IN
local RAW_DATA "$inpdir/Kolkata.dta"

* OUT
local TAB_5 "$outdir/bm_2012_tab_5.csv"

* ELSE
estimates clear
eststo clear
macro shift

/* LOAD DATA
----------------------------------------------------------------- */
use "`RAW_DATA'", clear
estimates clear
macro shift

/* MAIN GLOBALS
----------------------------------------------------------------- */
#delimit ;

global CONDITIONS = "OPtestz~=. & missingscore~=1";
// POST: RELATION TO OP;
global CONTROLS  = "i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend";
global TREATVAR1 = "OPtreat4 OPtreat5";
global TREATVAR2 = "OPtestz  OPtreat4 OPtreat5";
global TREATVAR3 = "OPtestzOPtreat4 OPtestzOPtreat5 OPtestz  OPtreat4 OPtreat5";

#delimit cr

/* HECKMAN: COLUMN 1
----------------------------------------------------------------- */
 xi: heckman reftestz $treatvar_1 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $CONDITIONS, ///
             select (sumrefrain anyrain $TREATVAR1 $CONTROLS) twostep

	sum  reftestz if OPtreat3==1 & (OP==1 &  OPtreat~=6 & OPtreat~=7) & $CONDITIONS
	local mean=r(mean)
	local sd=r(sd)

 test sumrefrain anyrain
 
 eststo reftestz_h1, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2) mean `mean' sd `sd')

/* HECKMAN: COLUMN 2
----------------------------------------------------------------- */
 xi: heckman reftestz $treatvar_2 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $CONDITIONS, ///
             select (sumrefrain anyrain $TREATVAR2 $CONTROLS) twostep

 test sumrefrain anyrain
 
 eststo reftestz_h2, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2))

/* HECKMAN: COLUMN 3
----------------------------------------------------------------- */
 xi: heckman reftestz $treatvar_3 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $CONDITIONS, ///
             select (sumrefrain anyrain $TREATVAR3 $CONTROLS) twostep

 test sumrefrain anyrain

 eststo reftestz_h3, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2))


/* OLS: COLUMN 4
----------------------------------------------------------------- */
 ge      reftestz_e = reftestz
 replace reftestz_e = -2.033682 if reftestz==.
 
 xi: reg reftestz_e $treatvar_1 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $CONDITIONS
 testparm OPtreat*
 
	sum  reftestz_e if OPtreat3==1 & (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions
 local mean=r(mean)
 local sd=r(sd)

 eststo reftestz_e_1, addscalars(pvalue r(p) mean `mean' sd `sd')

/* OLS: COLUMN 5
----------------------------------------------------------------- */
 xi: reg reftestz_e $treatvar_2 $CONTROLS if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $CONDITIONS
 testparm OPtreat*

 eststo reftestz_e_2, addscalars(pvalue r(p))

/* OLS: COLUMN 6
----------------------------------------------------------------- */
 xi: reg reftestz_e $treatvar_3 $CONTROLS if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $CONDITIONS
 testparm OPtreat*
 
 eststo reftestz_e_3, addscalars(pvalue r(p))


/* EXPORT
----------------------------------------------------------------- */
local VARS  reftestz_h1 reftestz_h2 reftestz_h3 reftestz_e_1 reftestz_e_2 reftestz_e_3
local KEEP  sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5
local ORDER sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5

#delim ;
noisily esttab `VARS' using `TAB_5', plain label margin replace
	scalars(mean sd fstat millscoeff millsse ncens) 
 cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) 
	starlevel(* .1 ** .051 *** .01) stardetach
 keep(`KEEP') order(`ORDER')
 style(tab) varwidth(8) modelwidth(8);

#delim cr
