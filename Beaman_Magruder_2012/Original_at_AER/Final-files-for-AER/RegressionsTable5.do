#delimit;
estimates clear;
macro shift;


global ifconditions="OPtestz~=. & missingscore~=1";
local outfilename = "table_5.csv";


** POST: RELATION TO OP **;

global controls="i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend ";

global treatvar_1="OPtreat4 OPtreat5";
global treatvar_2="OPtestz  OPtreat4 OPtreat5";
global treatvar_3="OPtestzOPtreat4 OPtestzOPtreat5 OPtestz  OPtreat4 OPtreat5";


*****************************;
** Heckman: columns 1-3 **;
*****************************;
xi: heckman reftestz $treatvar_1 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions, select (sumrefrain anyrain $treatvar_1 $controls) twostep;
	sum  reftestz if OPtreat3==1 & (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions;
	local mean=r(mean);
	local sd=r(sd);
test sumrefrain anyrain;
eststo reftestz_h1, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2) mean `mean' sd `sd');

xi: heckman reftestz $treatvar_2 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions, select (sumrefrain anyrain $treatvar_2 $controls) twostep;
test sumrefrain anyrain;
eststo reftestz_h2, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2));

xi: heckman reftestz $treatvar_3 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions, select (sumrefrain anyrain $treatvar_3 $controls) twostep;
test sumrefrain anyrain;
eststo reftestz_h3, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2));



*****************************;
** OLS: Full Sample results, columns 4-6 **;
*****************************;

ge reftestz_e=reftestz;
replace reftestz_e=-2.033682 if reftestz==.;

xi: reg reftestz_e $treatvar_1 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions;
testparm OPtreat*;
	sum  reftestz_e if OPtreat3==1 & (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions;
	local mean=r(mean);
	local sd=r(sd);
eststo reftestz_e_1, addscalars(pvalue r(p) mean `mean' sd `sd');

xi: reg reftestz_e $treatvar_2 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions;
testparm OPtreat*;
eststo reftestz_e_2, addscalars(pvalue r(p));

xi: reg reftestz_e $treatvar_3 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions;
testparm OPtreat*;
eststo reftestz_e_3, addscalars(pvalue r(p));


noisily dis [" PUZZLE PERFORMANCE REGRESSIONS "];
noisily dis [" ************************** "];
noisily esttab reftestz_h1 reftestz_h2 reftestz_h3 reftestz_e_1 reftestz_e_2 reftestz_e_3 using `outfilename', 
	scalars(mean sd fstat millscoeff millsse ncens ) cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) 
	starlevel(* .1 ** .051 *** .01) stardetach keep(sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5) 
	order(sumrefrain anyrain OPtestzOPtreat4 OPtestzOPtreat5 OPtestz OPtreat4 OPtreat5) style(tab) varwidth(8) modelwidth(8) 
	plain label margin replace;

