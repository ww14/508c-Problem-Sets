********* WWS508c PS2 *********
*  Spring 2018			      *
*  Author : William Willoughby*
*  Email: ww14@princeton.edu  *
*******************************

//any disclaimer...//
//credit: Andrew Moyseowicz, Graham Simpson

//Set directory etc//
clear all
cd "C:\Users\William Willoughby\Documents\Princeton\Spring 2018\508\psets\ps2"

//Clear and start log//
clear all
capture log close
log using ps2.log, replace

//Housekeeping//
set more off
ssc install outreg2

//Run do file for CPS data//
do "ps2_cps08.do"



********************************************************************************
**                                   P1                                       **
********************************************************************************
*** No Code Required ****

********************************************************************************
**                                   P2                                       **
********************************************************************************
*** Asked to generate log hourly wage variable, race dummies for categories  ///
/// categories "white", "black", "other". Asked to generate education variabl///
///e to measure years of schooling, "potential experience" variable, and     ///
/// squared experience variable.

**code**
*Dropped observations with 35> hour work week, missing wages, education
drop if uhrswork<35
drop if inc==0
drop if educ==0
*Added numlabel to show codings for each output
numlabel, add

*** DROPPED THIS PART AS I DIDN'T READ THE WHOLE QUESTION AND DROP OBSERVATIONS///
***Created new variables to recode 0 values as 1 values for income///
*gen revincwage=incwage
*replace revin=1 if incwage==0
****Created new variables to recode 0 values as 1 values for hours worked///
*gen revuhrswork=uhrswork
*replace revuh=1 if uhrswork==0
****Created new variables to recode 0 values as 1 values for weeks worked///
*gen revwkswork1=wkswork1
*replace revwk=1 if wkswork1==0

****Created logged hourly-wage variable
*gen logwage=ln(revinc/(revwk*revuh))
*label var logwage "Logged Hourly Wages"
gen logwage=ln(inc/(wk*uh))

*Race Dummies
gen white= (race==100)
gen black= (race==200)
gen other= (race>200)

*Sex dummies
gen male= (sex==1)

*Education Dummies
gen yearseduc=.
replace yearseduc=0 if (educ==2)
replace yearseduc=2.5 if (educ==10)
replace yearseduc=5.5 if (educ==20)
replace yearseduc=7.5 if (educ==30)
replace yearseduc=9 if (educ==40)
replace yearseduc=10 if (educ==50)
replace yearseduc=11 if (educ==60)
replace yearseduc=11.5 if (educ==71)
replace yearseduc=12 if (educ==73)
replace yearseduc=13 if (educ==81)
replace yearseduc=14 if (educ==91)
replace yearseduc=14 if (educ==92)
replace yearseduc=16 if (educ==111)
replace yearseduc=17 if (educ==123)
replace yearseduc=18 if (educ==124)
replace yearseduc=19 if (educ==125)

*Experience Variable
gen exper=age-yearseduc-5

*Experience-Squared Variable
gen exper2=exper^2

*Summarize Data
sum


********************************************************************************
**                                   P#3                                      **
********************************************************************************
//comment// Univariate regression of the log hourly wage on education.

**code**
reg logwage years
//Estimated return: 1 year of Education ==> .1069% increase in hourly wages
//Manually calculate correlation coefficient between education, log-hourly wage//
//Corr. Coefficient= Cov(X,Y)/Sd(X)Sd(Y) = Beta*SD(X)/Sd(Y)
disp (.1077203)*(2.625352)/(0.6985908)
//Corr. Coefficient manually calculates to .4048
//Find correlation coefficient of logwage and years of education//
corr logwage years
reg logwage years, beta
//R^2=.163 and Corr. Coefficient=.4048
//Square the Corr. Coefficient, and you get R^2 value
disp .4048^2

**code**
********************************************************************************
**                                   P#4                                      **
********************************************************************************
//comment//Estimate the Mincerian Equation
**code**
reg logwage years exper exper2
//Estimated return to education=11.3%

********************************************************************************
**                                   P#5                                      **
********************************************************************************
//comment//Estimate "extended" Mincerian Equation adjusting for race and sex too.
**code**
reg logwage years exper exper2 male black other
//Doesn't appear to change the return to education after controlling for sex,//
//race. Goes from .116 to .113. Ran t-test:
disp (.1165253-.1136149)/sqrt(.0009075+.0009281)
// output .0783, doesn't meet significance.

********************************************************************************
**                                   P#6                                      **
********************************************************************************
//Calculuate averages//
sum years
* Average = 13.63499
sum male
*Aveage = .5571477
sum black
*Average = .1111096
sum other
*Average = .0847391
//Run regression//
//Generate predicted values and graph//
sum years, meanonly
scalar yearsmean = r(mean)
sum male, meanonly
scalar malemean=  r(mean)
sum black, meanonly
scalar blackmean= r(mean)
sum other, meanonly
scalar othermean= r(mean)
reg logwage years exper exper2 male black other
gen predicted_wages =_b[years]*yearsmean+_b[male]*malemean+ _b[black]*blackmean +_b[other]*othermean+_b[exper]*exper+_b[exper2]*exper2
//gen yhat = .8204573 +  .1165253*13.63499 +  .2700227*.5571477 +  -.1073554*.1111096+  -.0465935*.0847391 + .0247365*exper + -.0003481 *exper2
sort exper
scatter predicted_wages exper, c(L) ytitle(log wages) xtitle(years of experience)
//scatter yhat exper, c(L) ytitle(log wages) xtitle(years of experience)
 graph export "problem 6.png", as(png) replace

********************************************************************************
**                                   P#7                                      **
********************************************************************************
//Use NLSY data//
use "nlsy79.dta", replace

//Dropped observations with 35> hour work week, missing wages, education//
drop if hours07<(35*50)

//Generate log hourly wage variable//
gen logwage=ln(laborinc07/hours07)

//Generate potential experience//
gen exper=age79+28-educ-5
gen exper2=exper^2

//Summarize data//
sum

********************************************************************************
**                                   P#8                                      **
********************************************************************************
//Estimate extended Mincerian Wage Equation//
reg logwage educ exper exper2 male black hisp, r

/* Smaller longitudinal dataset that tracks specific age cohort (age 14-22 in 1979)
In 2007, they are aged 42-50.
Experience maxes out at 44 years (with some questionable outliers - only 15 individuals with more than 34 years of experience)
As a result, dataset does not include wages at older ages and thus is unlikely to capture negative returns to experience at older ages */

********************************************************************************
**                                   P#9                                      **
********************************************************************************
//Correlation of experience and education//
corr exper educ
scatter exper educ
*correlation =-.7530
/*Not causal.
Experience variable is "potential experience" which is calculated as age-educ-5 and is thus directly negatively proportionally related to education.
By construction, education predicts experience
Because they are correlated, (*it can't be causal --- review notes from class*)
Also, there's probably some ovb*/

********************************************************************************
**                                   P#10                                     **
********************************************************************************


foreach var of varlist foreign urban14 mag14 news14 lib14 educ_mom educ_dad numsibs selfesteem80 afqt81 {
corr logwage `var'
}

/*Not sure how useful AFQT is because people varied so much in age when they 
took it (16-24). However AFQT has the highest correlation with wages than any 
other variable in the dataset, even mom and dad education. 
Same with self-esteem score (ages 15-23)*/

reg logwage educ exper exper2 male black hisp afqt81 educ_dad urban14 mag14 news14 lib14, r
reg logwage educ exper exper2 male black hisp  educ_dad urban14 mag14 news14 lib14, r


//education of the mother appears to have low predictive power of child's wages. 
//comment//
**code**

*/
