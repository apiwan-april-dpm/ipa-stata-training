
clear all
set more off
use "baroda_0102_1obs.dta",clear

*** Chapter 1: Basic Parametric Example

** 1.1 Sample size given the minimum effect size
global power = 0.8
global alpha = 0.05
sum pre_totnorm

/*

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
 pre_totnorm |     10,198    .0039315    1.011013  -1.911375   3.405892

*/

global baseline_mean = r(mean)
global baseline_sd = r(sd)

// Assume we expect an effect size of a third of sd, the sample size to detect this effect size:
global effect = $baseline_sd/3
global treat = $baseline_mean + $effect

// The minimum sample size will also depend on nratio = treatment size/control size
global nratio = 1

// To estimate the required sample size for two-sample t-test, m1 = mean(control), m2 = mean(treat)
power twomeans $baseline_mean $treat, power($power) alpha($alpha) nratio($nratio) sd($baseline_sd) table

/* Estimated sample sizes for a two-sample means test
t test assuming sd1 = sd2 = sd
H0: m2 = m1  versus  Ha: m2 != m1

  +---------------------------------------------------------+
  |   alpha   power       N      N1      N2  nratio   delta |
  |---------------------------------------------------------|
  |     .05      .8     286     143     143       1    .337 |
  +---------------------------------------------------------+
  +-------------------------+
  |      m1      m2      sd |
  |-------------------------|
  |  .00393   .3409   1.011 |
  +-------------------------+

*/

global samplesize = r(N)
global effect = round($effect, 0.001) // 0.337

display as error "The minimum sample size needed is $samplesize to detect an effect size of $effect with a probability of $power if the effect is true and the ratio of units in treatment and control is $nratio"


** 1.2 Minimum effect size given the sample size
global N = 2000
power twomeans $baseline_mean, power($power) alpha($alpha) nratio($nratio) n($N) sd($baseline_sd) table
global mde = round(r(delta),0.01)
display as error "The MDE is $mde given a sample size of $N, ratio of units in treatment and control of $nratio, and power $power" // MDE is 0.13 



*** Chapter 2: Relationship between power and its components

// When an effect size become half as large, The minimum sample required is four times as large
global new_effect = $effect/2
global new_treat = $baseline_mean + $new_effect
power twomeans $baseline_mean $new_treat, power($power) alpha($alpha) nratio($nratio) sd($baseline_sd) table

/* Estimated sample sizes for a two-sample means test
t test assuming sd1 = sd2 = sd
H0: m2 = m1  versus  Ha: m2 != m1

  +---------------------------------------------------------------------------------+
  |   alpha   power       N      N1      N2  nratio   delta      m1      m2      sd |
  |---------------------------------------------------------------------------------|
  |     .05      .8   1,134     567     567       1   .1685  .00393   .1724   1.011 |
  +---------------------------------------------------------------------------------+

*/

*** Chapter 3: Parametric power calculation with controls
// Now we control for baseline covariates in our main specification

global power = 0.8
global alpha = 0.05

sum pre_totnorm
global baseline_sd = r(sd)
global baseline_mean = r(mean)

global effect_cov = $baseline_sd/3
global treat = $baseline_mean + $effect_cov
global nratio = 1

global covariates "pre_math pre_verb"
reg pre_totnorm $covariates

/*
      Source |       SS           df       MS      Number of obs   =    10,198
-------------+----------------------------------   F(2, 10195)     =  31648.36
       Model |    8976.951         2   4488.4755   Prob > F        =    0.0000
    Residual |  1445.88891    10,195  .141823336   R-squared       =    0.8613
-------------+----------------------------------   Adj R-squared   =    0.8612
       Total |  10422.8399    10,197  1.02214768   Root MSE        =    .37659

------------------------------------------------------------------------------
 pre_totnorm | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
    pre_math |   .0357198   .0004987    71.62   0.000     .0347422    .0366974
    pre_verb |   .0505229   .0005762    87.68   0.000     .0493934    .0516524
       _cons |   -1.34841   .0065794  -204.94   0.000    -1.361307   -1.335513
------------------------------------------------------------------------------

*/

predict res, res // generate residuals from the regression and stores in "res"
sum res

/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         res |     10,198   -3.31e-10    .3765575  -.6695715   .8672673

*/

global res_sd = r(sd)

power twomeans $baseline_mean $treat, power($power) alpha($alpha) nratio($nratio) sd($res_sd) table

/* Estimated sample sizes for a two-sample means test
t test assuming sd1 = sd2 = sd
H0: m2 = m1  versus  Ha: m2 != m1

  +---------------------------------------------------------------------------------+
  |   alpha   power       N      N1      N2  nratio   delta      m1      m2      sd |
  |---------------------------------------------------------------------------------|
  |     .05      .8      42      21      21       1    .337  .00393   .3409   .3766 |
  +---------------------------------------------------------------------------------+
*/

global effect_cov = round($effect_cov,0.0001)
global samplesize_cov = r(N)
display as error "The minimum sample size needed is $samplesize_cov to detect an effect of $effect_cov with a probability of $power if the effect is true if the residual standard deviation is $res_sd after accounting for covariates: $covariates"

/* The minimum sample size needed is 42 to detect an effect of .337 with 
a probability of .8 if the effect is true if the residual standard deviation 
is .3765574580294905 after accounting for covariates: pre_math pre_verb
*/

*** Chapter 4: EXAMPLE of parametric power calculation with partial take-up
*** Chapter 5: Overview of how MDE and sample size change as we add covariates and take-up changes 
*** Chapter 6: Parametric power calculation for cluster RCTs 