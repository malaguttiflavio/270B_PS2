* -----------------------------------------------------------------------------
*  PROJECT: Beaman and Magruder 2012, Reproduction
*  PROGRAM: Table 1
*  PROGRAMMER: Beaman and Magruder, AER auxiliary files
*  REPRODUCER: Malagutti, 2021
* -----------------------------------------------------------------------------
* IN
local RAW_DTA "$inpdir/Kolkata.dta"

* OUT
local RAW_CSV "$outdir/Kolkata.csv"

/* LOAD DATA
----------------------------------------------------------------- */
use "`RAW_DTA'", clear


export delimited using "`RAW_CSV'", replace

