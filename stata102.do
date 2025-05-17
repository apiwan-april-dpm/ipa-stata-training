use "Stata 102.dta", clear



*** Chapter 1: Naming & Labeling Variables
rename (educ addressdur areadur) (education address_duration area_duration)
rename surveyid, upper
rename SURVEYID, lower

describe area_duration areadur_unit
label variable areadur_unit "How long has your household been living in this area? (unit)"

label define timeunit 1 days 2 weeks 3 months 4 years // define a value label set 
label values areadur_unit timeunit // attach the "timeunit" label to variable "areadur_unit"
tab areadur_unit

// values of areadur_unit are displayed differently in tabulate, the actual values of the variable are unchanged
summarize areadur_unit

label values addressdur_unit timeunit // the same value label can be attached to multiple variables
tab addressdur_unit

label define timeunit 5 decades, add
label list timeunit

// Delimit
label define timeunit2 1 milliseconds 2 seconds 3 minutes 4 hours 5 days 6 weeks 7 months 8 quarters 9 trimesters 10 semesters 11 years 12 decades
label list timeunit2

label drop timeunit2
#delimit ;
    label define timeunit2
        1 milliseconds
        2 seconds
        3 minutes
        4 hours
        5 days
        6 weeks
        7 months
        8 quarters
        9 trimesters
        10 semesters
        11 years
        12 decades
    ;
#delimit cr
label list timeunit2

tabulate castecode ///
		if sex == 1 & age <= 35, ///
        missing nolabel

  

*** Chapter 2: Variable Types
// Convert string variables into numeric variables 
destring hhid, generate(hhid_num)
codebook hhid hhid_num

//Convert numerics into strings
tostring literateyn, generate(literateyn_str)
codebook literateyn literateyn_str
tabulate literateyn
tabulate literateyn_str

drop hhid_num literateyn_str

// Convert string variable to value labeled numeric variable
encode thanavisitreason, generate(visitreason)
codebook thanavisitreason visitreason

label define visitreasonlab ///
        1  "To register a Crime" ///
        2  "To answer charges filed against you" ///
        3  "To say hello/to chat" ///
        97 "Refuse to answer" ///
        98 "Other" ///
        99 "Don't Know"
encode thanavisitreason, generate(visitreason2) label(visitreasonlab)
codebook thanavisitreason visitreason2

// Convert value labeled variable to a string variable
decode visitreason, generate(visitreasonstr)
codebook visitreasonstr



*** Chapter 3: Unique IDs & Duplicates
isid hhid // to check if there're duplicate IDs
duplicates list hhid // find duplicate IDs
duplicates drop // searches for observations that are identical, and drops all but one

list hhid sex age educ occupation if hhid == "1802011" | hhid == "1813023"
browse if hhid == "1802011" | hhid == "1813023"



*** Chapter 4: Macros and Locals
codebook age
local variable age // creates local macro named "variable" and assigns it the value of "age"
summarize `variable'

// Using Macros with String
local a a1 a2 a3
local b b1 b2 b3
local ab `a' `b'

display "`a'"
display "`b'"
display "`ab'"

// Using Macros with Numerics
local i 8
display (`i' * 3)/2

local num = 1 * 2 + 3 // 1 * 2 + 3 is evaluated, then is stored within the local `num'
display "`num'"

local num 1 * 2 + 3 // stores the string as-is in the local `num'
display "`num'"



*** Chapter 5: Loops
foreach letter in a b c d { // defines a local macro called letter, which take on values a, b, c, d
        display "`letter'"
		}
		
foreach var in sex age educ {
        display "Checking `var' for missing values..."
        list hhid `var' if `var' == .
		}



*** Chapter 6: Importing
import excel using "Demo Info.xlsx", clear firstrow // treat the first row as variable names
browse

import delimited using "Demo Info.csv", clear varnames(1)
browse



*** Chapter 7: Merging
//  merge "New Variables" into our main data "Stata 102"
use "Stata 102", clear
isid hhid // hhid is not unique in master dataset, but unique in using dataset

merge m:1 hhid using "New Variables.dta" // 2 new variables from "New Variables.dta" is merged into main dataset
browse hhid children grandchildren

duplicates tag hhid, generate(dup) // create variable "dup" if hhid is unique, dup = 0
browse hhid children grandchildren if dup == 1 // values of both new variables were repeated for the duplicated values of hhid

tab _merge // 1 = from the master dataset, 2 = from using dataset, and 3 in both datasets 
drop _merge



*** Chapter 8: Appending
use "New Observations.dta", clear
browse

use "Stata 102.dta", clear
append using "Raw/New Observations.dta" // add observations to existing variables
sort hhid
list hhid in -10/-1 // list the last 10 observations
