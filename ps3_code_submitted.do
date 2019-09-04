********* WWS508c PS1 *********
*  Spring 2018			      *
*  Author : William Willoughby*
*  Email: ww14@princeton.edu  *
*******************************
//credit: Andrew Myseowicz, Graham Simpson, William Willoughby //

clear all
cd "C:\Users\William Willoughby\Documents\Princeton\Spring 2018\508\psets\ps1"
capture log close
log using ps3.log, replace

set more off
ssc install outreg2

//Install dlogit2 - file downloaded from https://ideas.repec.org/c/boc/bocode/s343501.html//

do "dlogit\DLOG_AT.ADO"
do "dlogit\DLOG_DPR.ADO"
do "dlogit\DLOGIT2.ADO"
do "dlogit\DMLOGIT2.ADO"
do "dlogit\DPROBIT2.ADO"


//Use 2000 National Health Interview Survey data//
use "nhis2000.dta", replace

********************************************************************************
**                                   P1                                       **
********************************************************************************
**Generate dummy variable for if respondent reports fair or poor health. Label
//variable. 																  **
tab health, nolabel
gen poorhealth=0
replace poorhealth=1 if health>=4
replace poorhealth = . if missing(health)
tab poor
label var poorhealth "Dummy Variable for Poor or Fair Health"

********************************************************************************
**                                   P2                                       **
********************************************************************************
**Generate line graphs. 
graph twoway (lfit mort5 age if sex==1) (lfit mort5 age if sex==2), ///
  legend(label(1 Male) label(2 Female)) 
  
**comment: Mortality rate gets higher for males as age increases compared with//
//females. ** 

graph twoway (lfit poor age if sex==1) (lfit poor age if sex==2), ///
  legend(label(1 Male) label(2 Female))  
 **comment: female health tends to be worse than than male until cross over at//
 //~65, after which males have worse health.

********************************************************************************
**                                   P3                                       **
********************************************************************************
/*
**Generate binary variable for high income. Label.
gen highincome =0
replace highincome=1 if faminc_gt75
replace highincome=. if missing(faminc_gt75)
label var highincome "Dummy Variable for Low/High Income"
label define high 0 "Low" 1 "High"
label values highincome high
*/

*Graham - I replaced above with creating a categorical income variable
gen income = 0
replace income = 2 if faminc_gt75
replace income = 1 if faminc_20t75
replace income = . if missing(faminc_gt75)
label define incomelevels 0 "Low" 1 "Middle" 2 "High"
label values income incomelevels

/*
**Graph poorhealth status by income
graph bar (mean) poor, over(highincome) ytitle(percent reporting poor health) title(Health Outcomes by Income)
//Mean of poor health is higher if you're poor, lower if you're rich.

**Graph motrality status by income
graph bar (mean) mort5, over(highincome) ytitle(five year mortality rate) title(Five Year Mortality Outcomes by Income)
//Mean of mortality is higher if you're poor, lower if you're rich

*/

**Graph poorhealth status by income
graph bar (mean) poor, over(income) ytitle(percent reporting poor health) title(Health Outcomes by Income)
//Mean of poor health is higher if you're poor, lower if you're rich.

**Graph motrality status by income
graph bar (mean) mort5, over(income) ytitle(five year mortality rate) title(Five Year Mortality Outcomes by Income)
//Mean of mortality is higher if you're poor, lower if you're rich


**Generate categorical variable for education levels. Label.
gen edlevel=0
replace edlevel=1 if edyrs==12
replace edlevel=2 if edyrs>13
replace edlevel=3 if edyrs==16
replace edlevel=4 if edyrs>16
replace edlevel = . if edyrs==.
label var edlevel "Categorical Variable for Education Level"
label define ed 0 "< HS" 1 "HS" 2 "Some college" 3 "BA" 4"Post Grad"
label values edlevel ed

**Graph poorhealth status by education level.
graph bar (mean) poor, over(edlevel) ytitle(percent reporting poor health) title(Health Outcomes by Education)
//Mean of poor health has two clusters; higher for people with edlevel=<1, lower//

**Graph mortality status by education level.
graph bar (mean) mort5, over(edlevel) ytitle(five year mortality rate) title(Five Year Mortality Outcomes by Race)
//Mean of mortality has two clusters; higher for people with edlevel=<1, lower//
//for people with edlevel>=2. However, trend is less pronounced than poor health.

**Generate categorical variable for races. Label.
gen race=0
replace race=1 if white==1
replace race=2 if black==1
replace race=3 if hisp==1
replace race=4 if other==1
label var race "Categorical Variable for Race"
label define ethn 1 "white" 2 "black" 3 "hispanic" 4 "other"
label values race ethn

**Graph poorhealth status by race.
graph bar (mean) poor, over(race) ytitle(percent reporting poor health) title(Health Outcomes by Race)
//From low to high, mean of poor health is lowest for whites, other, hispanics,//
// and blacks. 

graph bar (mean) mort5, over(race) ytitle(five year mortality rate) title(Five Year Mortality Outcomes by Race)
//From low to high, mean of mortality is lowest for others, hispanics, blacks,//
// and whites. Whites experienced the highest mortality rates, which is in //
// contrast to the results of the poor health query.


********************************************************************************
**                                   P4                                       **
********************************************************************************
/* Linear Perdiction: Treat age is continuous, edlevel and race as categorical, 
faminc as binary. But how do we do this? Does it require a special form of OLS?*/

/* Notes from Graham: If we're treating edlevel and race as categorical, we need
to either include the different edlevels/races or put an i. in front of them to
make them dummies (I think)
I'm not trying to run weighted least squares for now as I
couldn't get the code below to work and confused myself when I tried to do it a
different way */

/*
//Linear Mort5
reg mort5 age edlevel highincome race, r 
predict mort5_a_hat
gen v_a=mort5_ols_hat*(1-mort5_a_hat)
gen w_a=1/v_a
reg mort5 age edlevel highincome race [aw=w_a] //run weighted least squares 
predict mort5_ols_hat
label var mort5_ols_hat "OLS Mort5"


//Linear Poorhealth
reg poor age edlevel highincome race, r 
predict poor_ols_hat
gen v_1b=poor_ols_hat*(1-poor_ols_hat)
gen w_1b=1/v_1b
reg poor age edlevel highincome race [aw=w_1b]
predict poor_ols_hat
label var poor_ols_hat "OLS Poor Health"

//Probit Mort5 
probit mort5 age edlevel highincome race
predict mort5_probit_hat
label var mort5_ols_hat "Probit Mort5"
mfx compute

//Probit Poorhealth
probit poor age edlevel highincome race
predict poor_probit_hat
label var poor_ols_hat "Probit Poor Health"
mfx compute
 
//Logit Mort5 
probit mort5 age edlevel highincome race
predict mort5_logit_hat
label var mort5_ols_hat "Logit Mort5"
mfx compute

//Logit Poorhealth
probit poor age edlevel highincome race
predict poor_logit_hat
label var poor_ols_hat "Logit Poor Health"
mfx compute

*/

//Linear Mort5
reg mort5 age edyrs faminc_20t75 faminc_gt75 black hisp other, r 
outreg2 using p4regs.xls, replace

//Linear Poorhealth
reg poor age edyrs faminc_20t75 faminc_gt75 black hisp other, r 
outreg2 using p4regs.xls, append

//Probit Mort5 
probit mort5 age edyrs faminc_20t75 faminc_gt75 black hisp other
dprobit mort5 age edyrs faminc_20t75 faminc_gt75 black hisp other
outreg2 using p4regs.xls, append

//Probit Poorhealth
probit poor age edyrs faminc_20t75 faminc_gt75 black hisp other
dprobit poor age edyrs faminc_20t75 faminc_gt75 black hisp other
outreg2 using p4regs.xls, append
 
//Logit Mort5 
logit mort5 age edyrs faminc_20t75 faminc_gt75 black hisp other
dlogit2 mort5 age edyrs faminc_20t75 faminc_gt75 black hisp other
outreg2 using p4regs.xls, append

//Logit Poorhealth
logit poor age edyrs faminc_20t75 faminc_gt75 black hisp other
dlogit2 poor age edyrs faminc_20t75 faminc_gt75 black hisp other
outreg2 using p4regs.xls, append

/* In table p4regs.xls, Columns 1 and 2 are Linear Probability Model, 3 and 4
are Marginal Effects for Probit, and 5 and 6 and Marginal Effects for Logit.
Columns 3 and 5 should be very close and reasonably close to Column 1
Columns 4 and 6 should be very close and reasonably close to Column 2 */


********************************************************************************
**                                   P5                                       **
********************************************************************************

/*If race and income are independent, we should be able to add coefficients on
High-Income and Black from any of the regressions in Problem 4
to compare High-Income Blacks to Low-Income Whites

If not independent, we can't do this and need interaction term(s) */

//Run with Interaction Terms
gen blackmid = faminc_20t75*black
gen blackhigh = faminc_gt75*black
gen hispmid = faminc_20t75*hisp
gen hisphigh = faminc_gt75*hisp
gen othermid = faminc_20t75*other
gen otherhigh = faminc_gt75*other

reg mort5 age edyrs faminc_20t75 faminc_gt75 black hisp other blackmid blackhigh hispmid hisphigh othermid otherhigh, r
outreg2 using p5results.xls, replace
dprobit mort5 age edyrs faminc_20t75 faminc_gt75 black hisp other blackmid blackhigh hispmid hisphigh othermid otherhigh
outreg2 using p5results.xls, append
dlogit2 mort5 age edyrs faminc_20t75 faminc_gt75 black hisp other blackmid blackhigh hispmid hisphigh othermid otherhigh
outreg2 using p5results.xls, append

/*According to linear probability model, high-income African Americans 3.8 percentage points
more likely to die within 5 years than low-income Whites (statistiaclly significant at 5% level.
Not significant for probit or logit (point estimates 1.7 - 2.6 percentage points)*/





********************************************************************************
**                                   P6                                       **
********************************************************************************
/*

No. High-income households and low-income households may differ in behavioral and
environmental factors unaccounted for in this model.

*/




********************************************************************************
**                                   P7                                       **
********************************************************************************
/*Look at uninsured, alc5upyr, smokev, vig10fwk, bacon*/
reg mort5 age edyrs faminc_20t75 faminc_gt75 black hisp other blackmid blackhigh hispmid hisphigh othermid otherhigh, r 
outreg2 using p7results.xls, replace
reg poor age edyrs faminc_20t75 faminc_gt75 black hisp other blackmid blackhigh hispmid hisphigh othermid otherhigh, r 
outreg2 using p7results.xls, append
reg mort5 age edyrs faminc_20t75 faminc_gt75 black hisp other blackmid blackhigh hispmid hisphigh othermid otherhigh uninsured alc5upyr smokev vig10fwk bacon, r 
outreg2 using p7results.xls, append
reg poor age edyrs faminc_20t75 faminc_gt75 black hisp other blackmid blackhigh hispmid hisphigh othermid otherhigh uninsured alc5upyr smokev vig10fwk bacon, r 
outreg2 using p7results.xls, append

/*
It changes point estimates which means there likely was OVB by not including
behavioral factors. Does not change sign of any significant coefficients.
*/

********************************************************************************
**                                   P8                                       **
********************************************************************************
graph bar (mean) mort5, over(health) ytitle(mortality rate) title(Mortality Rate by Self-Reported Health Status)

/*
Yes, graph suggests that self-reported health predicts mortality.
Relationship is monotonic.
This suggets we threw out useful info when recategorizing health status as binary variabl
*/



********************************************************************************
**                                   P9                                       **
********************************************************************************

probit poorhealth age edyrs faminc_20t75 faminc_gt75 black hisp other 
mfx compute
outreg2 using p9results.xls, replace
outreg2 using p9results.xls, mfx
dprobit poorhealth age edyrs faminc_20t75 faminc_gt75 black hisp other 
outreg2 using p9results.xls, append
oprobit health age edyrs faminc_20t75 faminc_gt75 black hisp other 
mfx compute
outreg2 using p9results.xls, append
outreg2 using p9results.xls, mfx append


********************************************************************************
**                                   P10                                      **
********************************************************************************

//Calculate mean values
sum age, meanonly
scalar agemean = r(mean)
sum edyrs, meanonly
scalar edyrsmean = r(mean)
sum faminc_20t75, meanonly
scalar faminc_20t75mean = r(mean) 
sum faminc_gt75, meanonly
scalar faminc_gt75mean = r(mean) 
sum black, meanonly
scalar blackmean = r(mean) 
sum hisp, meanonly
scalar hispmean = r(mean) 
sum other, meanonly
scalar othermean = r(mean) 

//Run the ordered probit from #9 and generate predicted values
oprobit health age edyrs faminc_20t75 faminc_gt75 black hisp other
disp normal(-.9607023-(_b[age]*agemean+_b[edyrs]*edyrsmean+_b[faminc_20t75]*faminc_20t75mean+_b[faminc_gt75]*faminc_gt75mean+_b[black]*blackmean+_b[hisp]*hispmean+_b[other]*othermean))
disp normal(-.0413959-(_b[age]*agemean+_b[edyrs]*edyrsmean+_b[faminc_20t75]*faminc_20t75mean+_b[faminc_gt75]*faminc_gt75mean+_b[black]*blackmean+_b[hisp]*hispmean+_b[other]*othermean))-normal(-.9607023-(_b[age]*agemean+_b[edyrs]*edyrsmean+_b[faminc_20t75]*faminc_20t75mean+_b[faminc_gt75]*faminc_gt75mean+_b[black]*blackmean+_b[hisp]*hispmean+_b[other]*othermean))
disp normal(.8992188-(_b[age]*agemean+_b[edyrs]*edyrsmean+_b[faminc_20t75]*faminc_20t75mean+_b[faminc_gt75]*faminc_gt75mean+_b[black]*blackmean+_b[hisp]*hispmean+_b[other]*othermean))-normal(-.0413959-(_b[age]*agemean+_b[edyrs]*edyrsmean+_b[faminc_20t75]*faminc_20t75mean+_b[faminc_gt75]*faminc_gt75mean+_b[black]*blackmean+_b[hisp]*hispmean+_b[other]*othermean))
disp normal(1.710431-(_b[age]*agemean+_b[edyrs]*edyrsmean+_b[faminc_20t75]*faminc_20t75mean+_b[faminc_gt75]*faminc_gt75mean+_b[black]*blackmean+_b[hisp]*hispmean+_b[other]*othermean))-normal(.8992188-(_b[age]*agemean+_b[edyrs]*edyrsmean+_b[faminc_20t75]*faminc_20t75mean+_b[faminc_gt75]*faminc_gt75mean+_b[black]*blackmean+_b[hisp]*hispmean+_b[other]*othermean))
disp 1-normal(1.710431-(_b[age]*agemean+_b[edyrs]*edyrsmean+_b[faminc_20t75]*faminc_20t75mean+_b[faminc_gt75]*faminc_gt75mean+_b[black]*blackmean+_b[hisp]*hispmean+_b[other]*othermean))

/*
oprobit health age edyrs faminc_20t75 faminc_gt75 black hisp other 
predict health_hat
label var health_hat "Ordered Probit Poor Health"
*/

//Calculate mean values for whites
sum age if white==1, meanonly
scalar agemeanwhite = r(mean)
sum edyrs if white==1, meanonly
scalar edyrsmeanwhite = r(mean)
sum faminc_20t75 if white==1, meanonly
scalar faminc_20t75meanwhite = r(mean) 
sum faminc_gt75 if white==1, meanonly
scalar faminc_gt75meanwhite = r(mean) 

//Run ordered probt and calculate predicted values for whites
oprobit health age edyrs faminc_20t75 faminc_gt75 black hisp other 

disp normal(-.9607023-(_b[age]*agemeanwhite+_b[edyrs]*edyrsmeanwhite+_b[faminc_20t75]*faminc_20t75meanwhite+_b[faminc_gt75]*faminc_gt75meanwhite))
disp normal(-.0413959-(_b[age]*agemeanwhite+_b[edyrs]*edyrsmeanwhite+_b[faminc_20t75]*faminc_20t75meanwhite+_b[faminc_gt75]*faminc_gt75meanwhite))-normal(-.9607023-(_b[age]*agemeanwhite+_b[edyrs]*edyrsmeanwhite+_b[faminc_20t75]*faminc_20t75meanwhite+_b[faminc_gt75]*faminc_gt75meanwhite))
disp normal(.8992188-(_b[age]*agemeanwhite+_b[edyrs]*edyrsmeanwhite+_b[faminc_20t75]*faminc_20t75meanwhite+_b[faminc_gt75]*faminc_gt75meanwhite))-normal(-.0413959-(_b[age]*agemeanwhite+_b[edyrs]*edyrsmeanwhite+_b[faminc_20t75]*faminc_20t75meanwhite+_b[faminc_gt75]*faminc_gt75meanwhite))
disp normal(1.710431-(_b[age]*agemeanwhite+_b[edyrs]*edyrsmeanwhite+_b[faminc_20t75]*faminc_20t75meanwhite+_b[faminc_gt75]*faminc_gt75meanwhite))-normal(.8992188-(_b[age]*agemeanwhite+_b[edyrs]*edyrsmeanwhite+_b[faminc_20t75]*faminc_20t75meanwhite+_b[faminc_gt75]*faminc_gt75meanwhite))
disp 1-normal(1.710431-(_b[age]*agemeanwhite+_b[edyrs]*edyrsmeanwhite+_b[faminc_20t75]*faminc_20t75meanwhite+_b[faminc_gt75]*faminc_gt75meanwhite))

//Calculate mean values for blacks

sum age if black==1, meanonly
scalar agemeanblack = r(mean)
sum edyrs if black==1, meanonly
scalar edyrsmeanblack = r(mean)
sum faminc_20t75 if black==1, meanonly
scalar faminc_20t75meanblack = r(mean) 
sum faminc_gt75 if black==1, meanonly
scalar faminc_gt75meanblack = r(mean) 

//Run ordered probit and calculate predicted values for blacks
oprobit health age edyrs faminc_20t75 faminc_gt75 black hisp other 

disp normal(-.9607023-(_b[age]*agemeanblack+_b[edyrs]*edyrsmeanblack+_b[faminc_20t75]*faminc_20t75meanblack+_b[faminc_gt75]*faminc_gt75meanblack+_b[black]))
disp normal(-.0413959-(_b[age]*agemeanblack+_b[edyrs]*edyrsmeanblack+_b[faminc_20t75]*faminc_20t75meanblack+_b[faminc_gt75]*faminc_gt75meanblack+_b[black]))-normal(-.9607023-(_b[age]*agemeanblack+_b[edyrs]*edyrsmeanblack+_b[faminc_20t75]*faminc_20t75meanblack+_b[faminc_gt75]*faminc_gt75meanblack+_b[black]))
disp normal(.8992188-(_b[age]*agemeanblack+_b[edyrs]*edyrsmeanblack+_b[faminc_20t75]*faminc_20t75meanblack+_b[faminc_gt75]*faminc_gt75meanblack+_b[black]))-normal(-.0413959-(_b[age]*agemeanblack+_b[edyrs]*edyrsmeanblack+_b[faminc_20t75]*faminc_20t75meanblack+_b[faminc_gt75]*faminc_gt75meanblack+_b[black]))
disp normal(1.710431-(_b[age]*agemeanblack+_b[edyrs]*edyrsmeanblack+_b[faminc_20t75]*faminc_20t75meanblack+_b[faminc_gt75]*faminc_gt75meanblack+_b[black]))-normal(.8992188-(_b[age]*agemeanblack+_b[edyrs]*edyrsmeanblack+_b[faminc_20t75]*faminc_20t75meanblack+_b[faminc_gt75]*faminc_gt75meanblack+_b[black]))
disp 1-normal(1.710431-(_b[age]*agemeanblack+_b[edyrs]*edyrsmeanblack+_b[faminc_20t75]*faminc_20t75meanblack+_b[faminc_gt75]*faminc_gt75meanblack+_b[black]))



