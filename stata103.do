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
*** Chapter 6: by
*** Chapter 7: egen
