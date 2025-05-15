clear // clear out any previous dataset 
cd "/Users/puengapiwan/Desktop/Github Repositories/ipa-stata-training"

*** Chapter 1-2: Inspecting Data (sum, tab, list)
summarize math // n, mean, sd, min, max
summarize math, detail // percentiles

tabulate school // list unique values
tabulate school, missing

list reading 

*** Chapter 3: Imposing Condition (if, and, or)
sum math if female == 1
bysort female: sum math

sum math if female == 1 & school == 3
sum math if school == 1 | school == 2
bysort school: sum math

sum reading if (math < 65 | math > 90) & school == 1
sum math if inrange(school, 1,2)

*** Chapter 4: Saving & Sorting (save, sort)
save intro_modified.dta, replace

browse
sort student // rearrange into ascending order
sort school student // rearrange from left to roght variables

*** Chapter 5: Manipulating Data
gen private = 1 if school == 3
replace private = 0 if school == 2 | school == 4

drop private
gen private = (school == 3) if !missing(school)
replace private = . if school == 1 

save intro_modified.dta, replace
