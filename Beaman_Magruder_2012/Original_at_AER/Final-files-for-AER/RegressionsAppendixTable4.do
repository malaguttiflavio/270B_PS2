#delimit;
estimates clear;
macro shift;

global ifconditions="missingscore3~=1";

local outfilename = "appendixtable_4.csv";

ge missingscore3=1 if OP_coworkers_REFrep~=. & reftestz==.;
replace missingscore3=1 if refage==. & ref==1;
replace missingscore3=1 if refed==. &  ref==1;
replace missingscore3=1 if refcode==. & ref==1;
replace missingscore3=1 if (refdigtest==. & ref==1) | (refravtest==. & ref==1);
replace missingscore3=1 if reflnincome==. & ref==1;

global controls="i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend ";

global treatvar_1="OPtestzOPtreat4 OPtestzOPtreat5 OPtestz  OPtreat4 OPtreat5";

*****************************;
** Other Referral Characteristics **;
*****************************;
egen refagegrp = cut(refage), at(15 25 30 35 40 45 50 55 60 65 70 100);
gen ln_refincome = ln(refincome+1);

xi: heckman reftestz $treatvar_1 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions, 
	select (sumrefrain anyrain $treatvar_1 $controls) twostep;
test sumrefrain anyrain;
eststo orc_h1, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2));

xi: heckman reftestz $treatvar_1 i.refagegrp i.refed i.refcode refravtest refdigtest ln_refincome $controls if 
	(OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions, select (sumrefrain anyrain $treatvar_1 $controls) twostep;
test sumrefrain anyrain;
eststo orc_h2, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2));



noisily dis [" PUZZLE PERFORMANCE REGRESSIONS "];
noisily dis [" ************************** "];

noisily esttab orc* using `outfilename', scalars(fstat ncens) cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) 
	starlevel(* .1 ** .051 *** .01) stardetach keep(OPtestzOPtreat4 OPtestzOPtreat5 OPtestz  OPtreat4 OPtreat5 refravtest refdigtest ln_refincome) 
	order(OPtestzOPtreat4 OPtestzOPtreat5 OPtestz  OPtreat4 OPtreat5 refravtest refdigtest ln_refincome) style(tab) varwidth(8) modelwidth(8) plain label replace;
