use "Stata 104", clear

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

// Find variable names with ... type
ds, has(type numeric)
ds, has(type long)
ds, has(vallab yes1no0) // value label yes1no0
ds, has(varlab *victim*) // variable labels that contain the string "victim"

// r(varlist) is a string value, it should be enclosed by single quotes (` and ')
ds, has(type numeric)
return list
display "`r(varlist)'"

/* Create local macros with initial value of 0 
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

// Recode all variables with the value label yes1no0, and attach the value label yesno to them
codebook sex
recode sex (2 = 0)
rename sex male

// Alternate solutions
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

// Extend missing values and remove labels for 97 and 99 from the yesno label 
recode own2wheelertheft (97=.r) (99=.d)
label define yesno .d "Don't know" .r "Refusal", add 
label define yesno 97 "" 99 "", modify 

label list yesno
summarize own2wheelertheft

// Make these changes to all variables
ds, has(vallabel yesno)
recode `r(varlist)' (97=.r) (99=.d)



*** Chapter 3: Checking Skip Patterns and Logical Consistency
// evaluates logical expression
assert own4wheelernum != . if own4wheeleryn == 1
assert own4wheelernum == . if own4wheeleryn == 2

// Generate new variable to check
generate problem = 0
replace  problem = 1 if own4wheeleryn == 1 & own4wheelernum == .
replace  problem = 1 if own4wheeleryn == 2 & own4wheelernum != .

browse hhid own4wheeleryn own4wheelernum if problem 
list hhid own4wheeleryn own4wheelernum if problem
tabulate own4wheeleryn own4wheelernum if problem, missing

// Suppress error message
display "Hello world!"

display Hello world!
capture display Hello world!

// Add "capture noisily" to suppress errors but not suppresses output, and a do-file would not stop at this line
capture noisily assert own4wheelernum != . if own4wheeleryn == 1

// Suppress error message, return error code instead
capture display Hello world!
display _rc



*** Chapter 4: Other Data Checks
// Check unique values of a variable
levelsof cycleownyn
return list
assert "`r(levels)'" == "1 2"
assert inrange(cycleownyn, 1, 2)

// Check missing value: missing(varlist) == 1
foreach var of varlist sex scrutinizedyn educ {
        display "Checking `var' for missing values..."
        list hhid `var' if missing(`var')
    }

// Check missing value: missing(varlist) == 0
foreach var of varlist sex scrutinizedyn educ {
        display "Checking `var' for missing values..."
        assert !missing(`var')
    }

codebook sex scrutinizedyn educ

// List potential problems in dataset 
codebook, problems

misstable summarize

ssc install mdesc
mdesc



*** Chapter 5: String Cleaning
tabulate castename
local oldr = r(r)
display "There are `oldr' unique values of castename."

bysort castename: generate oldn = _N // Find number of observations for each group
tab oldn

// Converts to uppercase
generate newcaste = upper(castename) 
bysort newcaste: generate newn = _N

sort newcaste oldn
browse castename newcaste oldn newn if oldn != newn

quietly tabulate newcaste 
local newr = r(r) 
display "Letter case has been standardized. newcaste now has " `oldr' - `newr' " fewer values than castename."

// Replaces "." and "," with string substitution function
// . tells Stata to replace all occurrences (not just the first one)
replace newcaste = subinstr(newcaste, ".", "", .)
replace newcaste = subinstr(newcaste, ",", "", .)

quietly tabulate newcaste
local newr = r(r)
display "Punctuation has been removed. newcaste now has " `oldr' - `newr' " fewer values than castename."

// Remove all spaces at the start or end
replace newcaste = trim(newcaste)
	
// Replaces multiple and consecutive internal space
replace newcaste = itrim(newcaste)

quietly tabulate newcaste
local newr = r(r)
display "Spaces have been trimmed. newcaste now has " `oldr' - `newr' " fewer values than castename."

replace newcaste = subinstr(newcaste, " ", "", .)

ssc install charlist
charlist castename
charlist newcaste



*** Chapter 6: Exporting
// Export data
export excel hhid surveyid sex age educ using "test", firstrow(variables) replace
export delimited using "test2", replace // export csv

// Export summary statistics or orthogonality tables
ssc install orth_out
orth_out age literateyn educ using "summary_stat", by(sex) se colnum replace

// Export regression results 
ssc install estout
eststo: regress literateyn sex age
eststo: regress literateyn sex age educ
esttab using "regression_table", se replace

// Export graphs
graph box age, over(occupation, label(angle(45))) // boxplot

graph bar age, over(occupation, label(angle(45))) ///
    title("Mean Age by Occupation") ///
    ytitle("Mean of Age") ///
    blabel(bar, format(%9.1f))
	
graph export "barchart.png", replace
