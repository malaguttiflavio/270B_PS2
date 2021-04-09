* -----------------------------------------------------------------------------
*  PROJECT: Beaman and Magruder 2012, Reproduction
*  PROGRAM: Table 6
*  PROGRAMMER: Beaman and Magruder, AER auxiliary files
*  REPRODUCER: Malagutti, 2021
* -----------------------------------------------------------------------------
* IN
local RAW_DATA "$inpdir/Kolkata.dta"

* OUT
local TAB_6 "$outdir/bm_2012_tab_6.csv"

* ELSE
estimates clear
eststo clear
macro shift

/* MAIN GLOBALS
----------------------------------------------------------------- */
global CONDITIONS = "OPtestz~=. & missingscore~=1"
global CONTROLS   = "i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend"

/* CORRELATIONS WITH PERFORMANCE: COLUMN 1
----------------------------------------------------------------- */
 xi: heckman reftestz antperf_puzzle  $CONTROLS if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $CONDITIONS & OPtestz>0, ///
             select (sumrefrain anyrain $controls) twostep
 test sumrefrain anyrain

 eststo perf_antperf_1, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2))

/* CORRELATIONS WITH PERFORMANCE: COLUMN 2
----------------------------------------------------------------- */
 xi: heckman reftestz antperf_puzzle  $CONTROLS if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $CONDITIONS & OPtestz<0, ///
             select (sumrefrain anyrain $controls) twostep
 test sumrefrain anyrain

 eststo perf_antperf_2, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2))

/* EXPORT
----------------------------------------------------------------- */
#delim ;
 noisily esttab perf_antperf* using `TAB_6', plain label replace
           scalars(fstat ncens) cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) 
 	         starlevel(* .1 ** .051 *** .01) stardetach
           keep(antperf_puzzle) 
           style(tab) varwidth(8) modelwidth(8) ;
#delim cr
