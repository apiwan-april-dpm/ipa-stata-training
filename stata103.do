cd "/Users/puengapiwan/Desktop/Github Repositories/Data"
use "Stata 103", clear
describe, short
sort hhid
ssc install egenmore


*** Chapter 1: Logical Expressions and Dummy Variables
gen female = (sex == 2) if !missing(sex) 
drop female

gen female = cond(sex == 2, 1, 0)
drop female

// logical expression equals 1 if it's true and 0 if it's false
local x = (1 + 1 == 2)
    display `x'
local x = (1 + 2 == 4)
    display `x'
local x = (1 + 1 == 2) + (1 + 2 == 4) 
    display `x'



*** Chapter 2: Explicit Subscripting
browse if hhid == "1802011"

// using for loop to see the differences
foreach var of varlist _all {
        display "`var'"
        display `var'[597]
        display `var'[598]
        display
    } 

// [Observation number] depends on the sort order
display hhid[597]
display surveyorid[597]



*** Chapter 3: For-Loops and Macros
// run from 1 to 10
	foreach i of numlist 1/10 {
        display "`i'"
    }

// run from 10 to 50 in steps of 5
foreach i of numlist 10(5)50 {
        display "`i'"
    }

foreach i of varlist var1-var20 {
        tabulate `i'
    }

// give details about the commands Stata is executing	
set trace on
foreach var in sex age educ {
        display "Checking `var' for missing values..."
        list hhid `var' if `var' == .
    }
	
local i = 1 // set initial value to 1
    while  `i' < 15 {
        display "Round `i'"
        local i = `i' + 1 // ensure the loop progresses toward the stopping condition (i < 15)
    }



*** Chapter 4: if vs if Qualifier
foreach var of varlist _all {
        display "`var'"
        display `var'[597]
        display `var'[598]
        display
    }
	
// using if to only show the differences
foreach var of varlist _all {
        if `var'[597] != `var'[598] {
            display "The two observations of 1802011 differ on `var'."
        }
    }
	
foreach var of varlist _all {
        display "The two observations of 1802011 differ on `var'." if `var'[597] != `var'[598]
    } // didn't work because display doesn't allow if qualifier

// since 1 + 1 == 2 is true, the summarize command is executed
if 1 + 1 == 2 {
        summarize age
    }



*** Chapter 5: _N and _n
display _N

tab hhid
return list // show r(r) and r(N) Stata saved from the last command
display r(r) // unique values of hhid

generate order = _n, after(hhid) // observation number based on sorting order
browse order
sort sex
sort order

generate previousid = hhid[_n - 1], after(hhid) // use _n to refer to the previous observation

// create dummy variable to check unique IDs
sort hhid
generate iddup = (hhid == hhid[_n - 1]), after(hhid)



*** Chapter 6: by
tabulate castecode, missing nolabel

foreach i of numlist 1/6 . {
        summarize educ if castecode == `i'
    }

sort castecode
by castecode: summarize educ 

sort castecode sex
by castecode sex: summarize educ

// by requires dataset to be sorted by the by-variables, so we combine by and sort into one command
bysort castecode sex: summarize educ

sort sex
generate datasetn = _n
by sex: list datasetn if _n == 1 // _n is the observation number within groups of sex

by sex: generate byn = _n // assign obs number within each sex group
browse sex datasetn byn



*** Chapter 7: egen
// creates variables calculated from multiple observations in dataset
sort age
generate maxage = age[_N]
drop maxage

egen maxage = max(age) 

bysort sex: egen minage = min(age) // minimum age within each group of sex
browse sex age minage

// creates a new variable "literate" that contains the sum of literate individuals for each group
bysort surveyorid: egen literate = total(literateyn)
browse surveyorid literateyn literate

