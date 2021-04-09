#delimit;
estimates clear;
eststo clear;
macro shift;

global ifconditions="OPtestz~=. & missingscore~=1";
local outfilename_perf = "table_6.csv";

global controls="i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend ";


*****************************;
** Correlation with Performance **;
*****************************;


xi: heckman reftestz antperf_puzzle  $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions & OPtestz>0, select (sumrefrain anyrain $controls) twostep;
test sumrefrain anyrain;
eststo perf_antperf_1, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2) );

xi: heckman reftestz antperf_puzzle  $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions & OPtestz<0, select (sumrefrain anyrain $controls) twostep;
test sumrefrain anyrain;
eststo perf_antperf_2, addscalars(millscoeff e(lambda) millsse e(selambda) ncens e(N_cens) fstat r(chi2));


noisily dis [" ANTICIPATED PERFORMANCE REGRESSIONS "];
noisily dis [" ************************** "];

noisily esttab perf_antperf* using `outfilename_perf', scalars(fstat ncens) cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) 
	starlevel(* .1 ** .051 *** .01) stardetach keep(antperf_puzzle) style(tab) varwidth(8) modelwidth(8) plain label replace;

