**** Do files to recreate tables in Beaman and Magruder ****
clear all
set more off
set mem 300m
set mat 500
** set directory here **
cd "C:\Users\Lori\Documents\jeremy_networks\draft\aer_submission\final\Final files for AER"
use Kolkata, clear

** Table 1
do "RegressionsTable1.do"

** Table 2
do "RegressionsTable2.do"

** Table 3
do "RegressionsTable3.do"

** Table 4
do "RegressionsTable4.do"

** Table 5
do "RegressionsTable5.do"

** Table 6
do "RegressionsTable6.do"

** Appendix Tables 1 & 2
do "RegressionsAppendixTables1and2.do"

** Appendix Table 3 
do "RegressionsAppendixTable3.do"

** Appendix Table 4 
do "RegressionsAppendixTable4.do"

** Appendix Figures 2, 3 and 4

do "AppendixFigures2_3_4.do"
