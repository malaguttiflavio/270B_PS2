#delimit;

** Appendix Figure 2 **;

twoway(kdensity OPtestz if OPtreat==1) (kdensity reftestz if OPtreat==1);
graph save afig2_highfixedtreat.gph, replace;
twoway(kdensity OPtestz if OPtreat==2) (kdensity reftestz if OPtreat==2);
graph save afig2_lowfixedtreat.gph, replace;
twoway(kdensity OPtestz if OPtreat==3) (kdensity reftestz if OPtreat==3);
graph save afig2_verylowfixedtreat.gph, replace;
twoway(kdensity OPtestz if OPtreat==4) (kdensity reftestz if OPtreat==4);
graph save afig2_highperftreat.gph, replace;
twoway(kdensity OPtestz if OPtreat==5) (kdensity reftestz if OPtreat==5);
graph save afig2_lowperftreat.gph, replace;

** Appendix Figure 3 **;

twoway (lpoly reftestz OPtestz if OPtreat<4) (lpoly reftestz OPtestz if (OPtreat==4|OPtreat==5));
graph save appendixfig3.gph, replace;

** Appendix Figure 4 **;

twoway (lpoly reftestz OPtestz if OP_relative_REFrep==1&OPtreat<4) (lpoly reftestz OPtestz if OP_coworkers_REFrep==1&OPtreat<4);
graph save appendixfig4.gph, replace;
