#delimit;
estimates clear;
eststo clear;
macro shift;
global ifconditions="missingscore~=1";
local outfilename = "table_2.csv";

** POST: RELATION TO OP **;
global controls="i.OPagegrp OPed_cont ln_income OPpuzzletypeA OPravtest OPdigtest i.wkid weekend ";

global treatvar_1="OPtreat1 OPtreat2 OPtreat4 OPtreat5";
global treatvar_2="OPtestzOPtreat1 OPtestzOPtreat2 OPtestzOPtreat4 OPtestzOPtreat5 OPtreat1 OPtreat2 OPtreat4 OPtreat5 OPtestz";

/*Column 1*/;
xi: reg ref $treatvar_1 $controls if $ifconditions & OPtestz<6;
	sum  ref if OPtreat3==1;
	local mean=r(mean);
	local sd=r(sd);
eststo ref1, addscalars(mean `mean' sd `sd');


/*Column 2*/;
global numcorrect="(numcorrect==4 | numcorrect==3)";
ge FTreat4=1 if OPtreat4==1 & $numcorrect;
replace FTreat4=0 if FTreat4~=1 & OPtreat~=.;
ge excludedgroup=1 if OPtreat1==0 & FTreat4==0 & OPtreat2==0 & OPtreat5==0;
replace excludedgroup=0 if excludedgroup~=1 & OPtreat<6;
#delimit;
xi: reg ref OPtreat1 FTreat4 $controls if $ifconditions & OPtestz<6  ;
	sum  ref if excludedgroup==1;
	local mean=r(mean);
	local sd=r(sd);
	test OPtreat1 = FTreat4;
eststo reffaux_1, addscalars(mean `mean' sd `sd');

/*Column 3*/;
xi: reg ref $treatvar_2  $controls if  $ifconditions & OPtestz<6;
	sum  ref if OPtreat3==1;
	local mean=r(mean);
	local sd=r(sd);
eststo ref2, addscalars(mean `mean' sd `sd');

noisily dis [" ATTRITION REGRESSIONS "];
noisily dis [" ************************** "];
noisily esttab ref* using `outfilename', cells(b(star fmt(%9.6f)) se(fmt(%9.6f))) starlevel(* .1 ** .051 *** .01) 
	stardetach stats(N mean sd, fmt(%9.3g)) keep( OPtestzOPtreat1 OPtestzOPtreat2 OPtestzOPtreat4 OPtestzOPtreat5 FTreat4 OPtreat1 OPtreat2 OPtreat4 OPtreat5 OPtestz) 
	order(OPtestzOPtreat1 OPtestzOPtreat2 OPtestzOPtreat4 OPtestzOPtreat5 FTreat4 OPtestz OPtreat1 OPtreat2 OPtreat4 OPtreat5 )style(tab) varwidth(8) modelwidth(8) plain replace;

