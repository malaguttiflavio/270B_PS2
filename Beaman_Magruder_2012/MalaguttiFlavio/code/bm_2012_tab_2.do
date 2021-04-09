* -----------------------------------------------------------------------------
*  PROJECT: Beaman and Magruder 2012, Reproduction
*  PROGRAM: Table 2
*  PROGRAMMER: Beaman and Magruder, AER auxiliary files
*  REPRODUCER: Malagutti, 2021
* -----------------------------------------------------------------------------
* IN
local RAW_DATA "$inpdir/Kolkata.dta"

* OUT
local TAB_2 "$outdir/bm_2012_tab_2.csv"

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
// POST: RELATION TO OP;
global CONTROLS   = "i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend ";
global TREATVAR1  = "OPtreat1 OPtreat2 OPtreat4 OPtreat5";
global TREATVAR2 = "OPtestzOPtreat1 OPtestzOPtreat2 OPtestzOPtreat4 OPtestzOPtreat5 OPtreat1 OPtreat2 OPtreat4 OPtreat5 OPtestz";
global NUMCORRECT = "(numcorrect==4 | numcorrect==3)";

#delimit cr

/* TABLE 2: COLUMN 1
----------------------------------------------------------------- */
xi: reg ref $TREATVAR1 $CONTROLS if $CONDITIONS & OPtestz<6
  	 sum ref if OPtreat3==1
	
 local mean=r(mean)
 local sd=r(sd)

 eststo ref1, addscalars(mean `mean' sd `sd')

/* TABLE 2: COLUMN 2
----------------------------------------------------------------- */
// CLEAN
gen     FTreat4=1 if OPtreat4==1 & $NUMCORRECT
replace FTreat4=0 if FTreat4~=1 & OPtreat~=.

gen     excludedgroup=1 if OPtreat1==0 & FTreat4==0 & OPtreat2==0 & OPtreat5==0
replace excludedgroup=0 if excludedgroup~=1 & OPtreat<6

// REG
xi: reg ref OPtreat1 FTreat4 $CONTROLS if $CONDITIONS & OPtestz<6  
	sum  ref if excludedgroup==1

	local mean=r(mean)
	local sd=r(sd)

	test OPtreat1 = FTreat4

eststo reffaux_1, addscalars(mean `mean' sd `sd')

/* TABLE 2: COLUMN 3
----------------------------------------------------------------- */
xi: reg ref $TREATVAR2  $CONTROLS if  $CONDITIONS & OPtestz<6
	   sum ref if OPtreat3==1

	local mean=r(mean)
	local sd=r(sd)

eststo ref2, addscalars(mean `mean' sd `sd')

/* EXPORT
----------------------------------------------------------------- */
local KEEP  OPtestzOPtreat1 OPtestzOPtreat2 OPtestzOPtreat4 OPtestzOPtreat5 FTreat4 OPtreat1 OPtreat2 OPtreat4 OPtreat5 OPtestz
local ORDER OPtestzOPtreat1 OPtestzOPtreat2 OPtestzOPtreat4 OPtestzOPtreat5 FTreat4 OPtestz OPtreat1 OPtreat2 OPtreat4 OPtreat5

#delim ;
noisily esttab ref* using "`TAB_2'", plain replace
   cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) starlevel(* .1 ** .051 *** .01) stardetach
   stats(N mean sd, fmt(%9.3g))
   keep(`KEEP') order(`ORDER')
   style(tab) varwidth(8) modelwidth(8) ;
#delim cr
