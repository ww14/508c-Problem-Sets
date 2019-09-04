********* WWS508c PS1 *********
*  Spring 2018		      *
*  Author : William Willoughby*
*  Email: ww14@princeton.edu  *
*******************************
//credit: William Willoughby, Andrew Myseowicz //

**Housekeeping
clear all
cd "C:\Users\William Willoughby\Documents\Princeton\Spring 2018\508\psets\ps1"
set more off
ssc install outreg2
cap ssc install copydesc
cap ssc install diff
cap ssc install estout

**Create log
capture log close
log using ps5.log, replace

**Open dataset
use "wws508c_crime_ps5.dta", clear

********************************************************************************
**                                   P1                                       **
********************************************************************************

**Summarize variables**
tab birthyr, missing

/*
sum  
sum, det 
*/

sum conscripted
sum crimerate
sum property
sum murder
sum drug
sum sexual
sum threat
sum arms
sum whitecollar
sum argentine
sum indigenous
sum naturalized

**Take a look at crime and conscription rates by birth year
sort birthyr
tab birthyr, sum(crimerate)
tab birthyr, sum(conscripted)


/*Crime rates look close to an untrained eye.
People born in 1958 seem much more likely to get conscripted,
especially compared to 1959-60.*/

**Comparisons of means
mvtest means crimerate, by(birthyr) heterogeneous
mvtest means conscripted, by(birthyr) heterogeneous

/*Crime rates and conscription rates differ by birth year, especially conscription rates.*/

/*Alternate measure:
estpost tabstat * , by( ) statistics(mean sd n) columns(statistics)

esttab using _means.txt, cells("mean sd count") replace

*break down scores by birth year
estpost tabstat conscripted crimerate arms property sexual murder threat drug, by(birthyr) statistics(mean sd n) columns(statistics)

esttab using crim_by_birth.txt, cells("mean sd count") replace
*/



********************************************************************************
**                                   P2                                       **
********************************************************************************

*Run regresssions of conscripted on crimes w/controls
reg crimerate conscripted birthyr argentine indigenous naturalized i.birthyr, r
outreg2 using p2reg.xls, replace
foreach var of varlist property murder drug sexual threat arms whitecollar{
reg `var' conscripted birthyr argentine indigenous naturalized i.birthyr, r
outreg2 using p2reg.xls, append
}

/* Exempted young men are likely correlated with omitted variables.
For example, wealthier men may be work the system and claim medical excuses or that family members are dependent upon them.
Those going into religious service may differ in their likelihood later in life.


Because of timing of data, we are only looking at crimes committed later in life (ages 38-47),
which may be more likely to be white collar crime and less likely to be 'crimes of passion'
*/

********************************************************************************
**                                   P3                                       **
********************************************************************************

**Generate binary variable for eligibility
gen eligible=0
replace eligible=1 if (draftnumber>=175 & birthyr==1958)
replace eligible=1 if (draftnumber>=320 & birthyr==1959)
replace eligible=1 if (draftnumber>=341 & birthyr==1960)
replace eligible=1 if (draftnumber>=350 & birthyr==1961)
replace eligible=1 if (draftnumber>=320 & birthyr==1962)

********************************************************************************
**                                   P4                                       **
********************************************************************************

**Regress conscription on eligibility (first stage)
reg conscripted eligible, r
outreg2 using p4reg.xls, replace
reg conscripted eligible argentine indigenous naturalized, r
outreg2 using p4reg.xls, append
reg conscripted eligible i.birthyr, r
outreg2 using p4reg.xls, append

/*
Shouldn't need to incude ethnic compostion because eligibility random by year.
However, eligibility differs by birth year so we think should include birth year.

Coefficient doesn't change when including either.

Thinking ahead to 2SLS, instrument should be unrelated to any variables that affect crime rate if it is going to be a valid instrument.
Promising that coefficent doesn't change; seems to confirm instrument exogeneity condition/exclusion restriction.
However, because eligibility differs by birth year, exclusion restriction may not hold if birth year affects crime rates

For now, we are going to include birth year and not ethnic composition.
*/
reg conscripted eligible i.birthyr, r

********************************************************************************
**                                   P5                                       **
********************************************************************************

**Regress crime rate on eligibility (reduced stage)
/*reg crimerate elig argentine indigenous naturalized, r
outreg2 using p5reg.xls, replace
foreach var of varlist property murder drug sexual threat arms whitecollar{
reg `var' eligible argentine indigenous naturalized, r
outreg2 using p5reg.xls, append
} */
reg crimerate elig argentine indigenous naturalized i.birthyr, r
outreg2 using p5reg.xls, replace
foreach var of varlist property murder drug sexual threat arms whitecollar{
reg `var' eligible argentine indigenous naturalized i.birthyr, r
outreg2 using p5reg.xls, append
}

/*Is not causal effect of conscription because eligibility does not perfectly predict conscription.*/

********************************************************************************
**                                   P6                                       **
********************************************************************************

**Divide coefficient from reduced form by coefficient from first stage
foreach var of varlist crimerate property murder drug sexual threat arms whitecollar{
quietly{
reg conscripted eligible, r
scalar denominator = _b[eligible]
reg `var' eligible argentine indigenous naturalized, r
scalar numerator = _b[eligible]
}
disp numerator/denominator
}

/*
Not sure about including/excluding birth year.
Currently excluding.
Need to exclude to make answers line up with #7
*/


********************************************************************************
**                                   P7                                       **
********************************************************************************

**Run 2SLS
ivregress 2sls crimerate (conscripted = eligible) argentine indigenous naturalized, r
outreg2 using p7reg.xls, replace
foreach var of varlist property murder drug sexual threat arms whitecollar{
ivregress 2sls `var' (conscripted = eligible) argentine indigenous naturalized, r
outreg2 using p7reg.xls, append
}

/*Answers line up with #6*/

********************************************************************************
**                                   P8                                       **
********************************************************************************
/* birth year ???? */

********************************************************************************
**                                   P9                                       **
********************************************************************************
/*
Treatment effect for those who are actually conscripted compared to those who would be conscripted if eligible
Excludes those who are eligible and do not serve (never takers)

We can think of this as a LATE for those who would be conscripted if eligible

[come back to]

*/


********************************************************************************
**                                   P10                                      **
********************************************************************************
/*



 
 