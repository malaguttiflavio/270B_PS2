* -----------------------------------------------------------------------------
* PATHS
* -----------------------------------------------------------------------------

* check what your username is in Stata by typing "di c(username)"
if "`c(username)'" == "flavioamalagutti" {
    global ROOT "/Users/flavioamalagutti/Documents/GitHub/Beaman_Magruder_2012_reproduction/Beaman_Magruder_2012/MalaguttiFlavio"
}               
else if "`c(username)'" == "yourname" {
    global ROOT "your_path"
}

cd "${ROOT}"

cap mkdir "./code"
cap mkdir "./input"
cap mkdir "./output"
cap mkdir "./tmp"

global codedir "${ROOT}/code"
global inpdir  "${ROOT}/input"
global outdir  "${ROOT}/output"
global tmpdir  "${ROOT}/tmp"


* RUN --------------------------------------------------------------------------
do "$codedir/bm_2012_tab_1"
do "$codedir/bm_2012_tab_2"
do "$codedir/bm_2012_tab_3"
do "$codedir/bm_2012_tab_4"
do "$codedir/bm_2012_tab_5"
do "$codedir/bm_2012_tab_6"



