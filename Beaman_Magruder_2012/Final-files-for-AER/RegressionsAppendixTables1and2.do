#delimit;
estimates clear;
eststo clear;
macro shift;

*******************************************************;
******** Appendix Table 1 - OLS full sample *******;
*******************************************************;

global treatvar_1="OPtreat4 OPtreat5";
global treatvar_2="OPtestz  OPtreat4 OPtreat5";
global treatvar_3="OPtestzOPtreat4 OPtestzOPtreat5 OPtestz  OPtreat4 OPtreat5";

global ifconditions="missingscore~=1";
local outfilename_1 = "appendixtable_1.csv";

global controls="i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend ";

foreach i in OP_coworkers OP_relative {;
	ge `i'_e=`i'_REFrep;
	replace `i'_e=0 if ref==0;
};


foreach i in OP_coworkers_e OP_relative_e {;

	xi: reg `i' $treatvar_1 $controls if OP==1 & OPtreat~=6 & OPtreat~=7 & $ifconditions;
	sum  `i' if OPtreat3==1;
	local mean=r(mean);
	local sd=r(sd);
	eststo `i'_1, addscalars(mean `mean' sd `sd');

	xi: reg `i' $treatvar_3 $controls if OP==1 & OPtreat~=6 & OPtreat~=7 & $ifconditions;
	testparm OPtreat*;
	local pvalue=r(p);
	eststo `i'_2, addscalars(pvalue `pvalue');
};


#delimit;
noisily dis ["COWORKER REGRESSIONS "];
noisily dis [" ************************** "];
noisily esttab OP_coworkers_e* OP_relative_e* using `outfilename_1', scalars(ncens mean sd) cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) 
starlevel(* .1 ** .051 *** .01) stardetach keep(sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5) 
order(sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5) style(tab) varwidth(8) modelwidth(8) 
plain label margin replace;


*******************************************************;
***** Appendix Table 2 - Robustness to temp control ***;
*******************************************************;

estimates clear;
macro shift;

global ifconditions="OPtestz~=. & missingscore~=1";
local outfilename_2 = "appendixtable_2.csv";


xi: heckman reftestz $treatvar_1 refactualmeantemp $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions, select (sumrefrain anyrain $treatvar_1 $controls) twostep;
test sumrefrain anyrain;
eststo reftestz_h_r1, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2));

xi: heckman reftestz $treatvar_2 refactualmeantemp $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions, select (sumrefrain anyrain $treatvar_2 $controls) twostep;
test sumrefrain anyrain;
eststo reftestz_h_r2, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2));

xi: heckman reftestz $treatvar_3 refactualmeantemp $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions, select (sumrefrain anyrain $treatvar_3 $controls) twostep;
test sumrefrain anyrain;
eststo reftestz_h_r3, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2));


noisily dis [" PUZZLE PERFORMANCE REGRESSIONS "];
noisily dis [" ************************** "];
noisily esttab reftestz_h_* using `outfilename_2', 
	scalars(fstat millscoeff millsse ncens ) cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) 
	starlevel(* .1 ** .051 *** .01) stardetach keep(sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5) 
	order(sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5) style(tab) varwidth(8) modelwidth(8) 
	plain label margin replace;

