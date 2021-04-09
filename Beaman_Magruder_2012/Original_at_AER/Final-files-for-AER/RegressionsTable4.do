#delimit;
estimates clear;
eststo clear;
macro shift;


global treatvar_1="OPtreat4 OPtreat5";
global treatvar_2="OPtestzOPtreat4 OPtestzOPtreat5 OPtestz  OPtreat4 OPtreat5";

global ifconditions="missingscore~=1";
local outfilename = "table_4.csv";


** POST: RELATION TO OP **;

global controls="i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend ";


** First stage **;

xi: dprobit ref sumrefrain anyrain $treatvar_1 $controls if OP==1 & OPtreat~=6 & OPtreat~=7 & $ifconditions;

xi: dprobit ref sumrefrain anyrain $treatvar_2 $controls if OP==1 & OPtreat~=6 & OPtreat~=7 & $ifconditions;


** Second stage **;

foreach i in OP_coworkers_REFrep OP_relative_REFrep {;


	xi: heckman `i' $treatvar_1 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7 ) & $ifconditions, select (sumrefrain anyrain $treatvar_1 $controls) twostep;
	testparm OPtreat*;
	local pvalue=r(p);
	sum  `i' if OPtreat3==1;
	local mean=r(mean);
	local sd=r(sd);
	test sumrefrain anyrain;
	eststo `i'_h1, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2) mean `mean' sd `sd');

	xi: heckman `i' $treatvar_2 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7 ) & $ifconditions, select (sumrefrain anyrain $treatvar_2 $controls) twostep;
	test sumrefrain anyrain;
	eststo `i'_h2, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2));
};


#delimit;
noisily dis ["COWORKER REGRESSIONS "];
noisily dis [" ************************** "];
noisily esttab OP_coworkers_REFrep_h1 OP_coworkers_REFrep_h2 OP_relative_REFrep_h1 OP_relative_REFrep_h2 using `outfilename', 
scalars(mean sd fstat millscoeff millsse ncens ) cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) 
starlevel(* .1 ** .051 *** .01) stardetach keep(sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5) 
order(sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5) style(tab) varwidth(8) modelwidth(8) 
plain label margin replace;
