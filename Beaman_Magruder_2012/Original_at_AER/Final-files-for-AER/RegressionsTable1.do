#delimit;

global ifconditions="age_hhr~=. & OPagegrp~=. & OPed~=. & ln_income~=. & OPpuzzletypeA~=. & OPravtest~=. & 
	OPdigtest~=. & wkid~=. & weekend~=. & missingscore~=1";
	local outfilename = "table_1.csv";



ge cons=1;

foreach i in testz income ln_income quartile1 {;
	ge `i'_nonat=`i' if noref==0;
};
label var testz_nonat "Test Scores Among Non-Attriting OPs";
label var income_nonat "Income  Among Non-Attriting OPs";
label var quartile1_nonat "Quartile1 Among Non-Attriting OPs";

ge mainearner=1 if qa1p12_hhr==1 | qa1p12_hhr==2;
replace mainearner=0 if qa1p12_hhr>2 & qa1p12_hhr~=.;
replace mainearner=0 if  qa1p11_hhr==2;
label var mainearner "Resp is primary earner in HH";

*** Randomization check ****;

global satis_list = "age_hhr literate_hhr class5_hhr class10_hhr married_hhr employed_hhr ln_income 
	hhhead_hhr mainearner young_hhr  ravtest digtest othertype testz testz_nonat";
global indep_list ="OPtreat1 OPtreat2 OPtreat3 OPtreat4 OPtreat5 OPtreat6 cons";
global nv = wordcount("$satis_list");

cap prog drop fill;
program def fill;
    syntax, i(real);
    qui {;

        cap replace depvaroptreat1 = _b[OPtreat1] if _n == ((`i' * 3) - 2);
        cap replace depvaroptreat1 = _se[OPtreat1] if _n == ((`i' * 3) - 1);
        cap replace depvaroptreat2 = _b[OPtreat2] if _n == ((`i' * 3) - 2);
        cap replace depvaroptreat2 = _se[OPtreat2] if _n == ((`i' * 3) - 1);
        cap replace depvaroptreat4 = _b[OPtreat4] if _n == ((`i' * 3) - 2);
        cap replace depvaroptreat4 = _se[OPtreat4] if _n == ((`i' * 3) - 1);
        cap replace depvaroptreat5 = _b[OPtreat5] if _n == ((`i' * 3) - 2);
        cap replace depvaroptreat5 = _se[OPtreat5] if _n == ((`i' * 3) - 1);
        cap replace depvarcons = _b[cons] if _n == ((`i' * 3) - 2);
        cap replace depvarcons = _se[cons] if _n == ((`i' * 3) - 1);

        cap replace nobs = e(N) if _n == ((`i' * 3)  - 2);


        };
end;

local i = 0;
foreach var of varlist $satis_list {;
    local i = `i' + 1;
    global outname`i' = "`var'";
    global label`i': variable label `var';
    };



global regout = "depends deplabel depvaroptreat1 depvaroptreat2 depvaroptreat4 depvaroptreat5 depvarcons nobs pvalue";
qui for any depends deplabel: gen str1 X = "";
qui for any depvaroptreat1 depvaroptreat2  depvaroptreat4 depvaroptreat5 depvarcons nobs pvalue: gen X=.;


forvalues i = 1/$nv {;	
	
    replace depends = "${outname`i'}" if _n == ((`i' * 3) - 2);
    replace deplabel = "${label`i'}" if _n == ((`i' * 3) - 2);

	reg ${outname`i'} OPtreat1 OPtreat2 OPtreat4 OPtreat5 cons if OP==1 & $ifconditions & OPtreat<6, noc;
	fill, i(`i');
	
	testparm OPtreat*;	
	replace pvalue=r(p) if _n == ((`i' * 3)  - 2);


};




*****************************
OUTSHEETING
*****************************;
preserve;
keep $regout;
drop if _n > $nv * 3+ 50;

outsheet using `outfilename', comma replace;
restore;
