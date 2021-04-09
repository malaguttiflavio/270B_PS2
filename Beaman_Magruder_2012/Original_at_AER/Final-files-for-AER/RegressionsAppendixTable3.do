#delimit;
estimates clear;

ge missingscore2=1 if OP_coworkers_REFrep~=. & reftestz==.;
replace missingscore2=1 if refage==. & ref==1;
replace missingscore2=1 if refed_cont==. &  ref==1;
replace missingscore2=1 if reflnincome==. & ref==1;

global ifconditions="missingscore2~=1 ";
local outfilename = "appendixtable_3.csv";

global controls="i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend ";

global treatvar_1="reftestz";


*****************************;
** OLS **;
*****************************;

foreach i in refravtest refdigtest refage refed_cont reflnincome {;
	xi: reg `i' $treatvar_1 $controls if (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions;
	sum  `i' if OPtreat3==1 & (OP==1 &  OPtreat~=6 & OPtreat~=7) & $ifconditions;
	local mean=r(mean);
	local sd=r(sd);
	eststo `i'_h1 , addscalars(mean `mean' sd `sd');
};


noisily dis [" PUZZLE PERFORMANCE Covariates "];
noisily dis [" ************************** "];
noisily esttab refravtest* refdigtest* refage* refed_cont* reflnincome* using `outfilename', scalars(mean sd) cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) 
	starlevel(* .1 ** .051 *** .01) stardetach keep(reftestz) 
	order(reftestz) style(tab) varwidth(8) modelwidth(8) plain label replace;
	
	
