// Compare two datasets, optionally saving the list of differences to file
ssc install cfout

// List characters present in string variable
ssc install charlist

// Display number and proportion of missing values for each variable
ssc install mdesc

// Match strings based on their Levenshtein edit distance
ssc install strgroup

// Outputes summary stats and orthogonality tables
ssc install orth_out

// Makes regression tables from stored estimates
ssc install estout

// Plots estimates with confidence limits
ssc install eclplot



*** Chapter 1: Saved Results 
use "Stata 104", clear

// r() and return list for non-estimation commands
summarize cycleownnum
return list
generate cyclenumstd = (cycleownnum - r(mean)) / r(sd)

// e() and ereturn list for estimation commands like regress anova probit
regress cycleownnum sex
ereturn list

// r() saved results can disappear after the next command, so we should utilize them immediately or store in macros
summarize cycleownnum
return list
local mean = r(mean)
local sd = r(sd)

describe cycleownnum
return list

generate cyclenumstd = (cycleownnum - `mean') / `sd'
tabulate cyclenumstd, missing

// variable names with ... type
ds, has(type numeric)
ds, has(type long)
ds, has(vallab yes1no0) // value label yes1no0
ds, has(varlab *victim*) // variable labels that contain the string "victim"

// r(varlist) is a string value, it should be enclosed by single quotes (` and ')
ds, has(type numeric)
return list
display "`r(varlist)'"

/* create local macros with initial value of 0 
- loop over sequence of numbers from r(min) = 1 to r(max) = 5
- update the value of sum by adding i
- `r()' refer to the value stored in a macro */
local sum 0 
    summarize cycleownnum
    foreach i of numlist `r(min)'/`r(max)' { 
        local sum = `sum' + `i'
    }
    display "The sum is: `sum'" // 1 + 2 + 3 + 4 + 5 = 15

ds, has(type numeric)
    foreach var in `r(varlist)' {
        if `var'[597] != `var'[598] {
            display "The two observations of 1802011 differ on numeric variable `var'."
        }
    }
	
	
	
*** Chapter 2: Recoding
ds, has(vallabel yesno)
ds, has(vallabel yes1no0)

// recode all variables with the value label yes1no0, and attach the value label yesno to them.
codebook sex
recode sex (2 = 0)
rename sex male

// alternate solutions
ds, has(vallabel yesno)
    local varl `r(varlist)' // save those variables into local macro
    recode `varl' (2 = 0)
    label values `varl' yesno
	
ds, has(vallabel yes1no0)
    local varl `r(varlist)' 
    label values `varl' yesno
	
describe occupation
label list occup
recode occupation (1=2) (2=1)

describe own2wheelertheft
label list yesno
recode own2wheelertheft (2=0)
tabulate own2wheelertheft, nolabel
summarize own2wheelertheft if own2wheelertheft != 97 & own2wheelertheft != 99

// extended missing values and removes labels for 97 and 99 from the yesno label 
recode own2wheelertheft (97=.r) (99=.d)
label define yesno .d "Don't know" .r "Refusal", add 
label define yesno 97 "" 99 "", modify 

label list yesno
summarize own2wheelertheft

// make these changes to all variables
ds, has(vallabel yesno)
recode `r(varlist)' (97=.r) (99=.d)



*** Chapter 3: Logic Check
*** Chapter 4: Other Data Checks
*** Chapter 5: String Cleaning

