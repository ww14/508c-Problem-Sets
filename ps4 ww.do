********* WWS508c PS1 *********
*  Spring 2018		      *
*  Author : William Willoughby*
*  Email: ww14@princeton.edu  *
*******************************
//credit: Andrew Myseowicz, Graham Simpson, William Willoughby //

clear all
cd "C:\Users\William Willoughby\Documents\Princeton\Spring 2018\508\psets\ps4"
capture log close
log using ps4.log, replace

set more off
ssc install outreg2

//Use NLSY Data including Head Start Participants//
use "wws508c_deming.dta", replace

********************************************************************************
**                                   P1                                       **
********************************************************************************
//Tab with missing values 
foreach var of varlist head_start sibdiff hispanic black male firstborn momed dadhome ppvt lnbw comp_score_5 comp_score_7 comp_score_11 repeat learndis hsgrad somecoll idle fphealth HS2{
tab `var', missing 
}

/* Missing (null) values % for Momed=14.0, dadhome=37.58, ppvt=84.2, lnbw=3.4, 
compscore5-6=43.3, compscore7-10=23.9, compscore11-14=32.45, repeat=24.1, 
learndis=2.8, hsgrad=25.3, somecoll=25.3, idle=25.3, fphealth-25.3, HS2=55.9
Appear dadhome, ppvt, comp_score 5-6, and HS2 are our biggest issues*/

//Tab with missing values for Head Start Participants (n=881)
foreach var of varlist head_start sibdiff hispanic black male firstborn momed dadhome ppvt lnbw comp_score_5 comp_score_7 comp_score_11 repeat learndis hsgrad somecoll idle fphealth HS2{
tab `var' if head_start==1, missing 
}

/*Missing (null) values % for dadhome=44%, pvt=85, birthweight=2.38, 
compscore5-6=42, compscore7-10=16.1, compscore11-14=22, repeat=15, learndis=0.11, 
hsgrad=17, somecoll==17, idle=17, fphealth=17, HS2=44 
Appears that dadhome, compscore for 5-6, and HS2 are our biggest issues. */

sum lninc, detail
sum lninc if head_start==1, detail
//

//Look at percentiles 
sum comp_score_5 comp_score_7 comp_score_11
sum comp_score_5 comp_score_7 comp_score_11 if head_==1

misstable sum comp_score_5 comp_score_7 comp_score_11 
// missing 539 observations for total score

foreach var of varlist head_start sibdiff hispanic black male firstborn momed dadhome ppvt lnbw comp_score_5 comp_score_7 comp_score_11 repeat learndis hsgrad somecoll idle fphealth HS2{
di `var'
ttest `var', by(head_) unpaired unequal
}



********************************************************************************
**                                   P2                                       **
********************************************************************************
/*All regressions will have limited power given the amount of null observations 
on test scores; did not include HH income b/c HS is means tested, 
never include post treatment variables--. no HS or college indicators */

xtreg comp_score_5to6 head_start, i(mom_id) re robust
// B=-2.5 HS is assoc w/ lowered test score by this many points 
outreg2 using p2results.xls, replace
xtreg comp_score_5to6 head_start sibdiff, i(mom_id) re robust
//Not significant 
outreg2 using p2results.xls, append
xtreg comp_score_5to6 head_start black hispanic male, i(mom_id) re robust
//Not significant 
outreg2 using p2results.xls, append
xtreg comp_score_5to6 head_start sibdiff black hispanic male learndis first lnbw, i(mom_id) re robust
//Not significant 
outreg2 using p2results.xls, append
/*Head Start is not exogeneous b/c it's means-tested, 
also only the simple/naive regression is significant */





********************************************************************************
**                                   P3                                       **
********************************************************************************

xtreg comp_score_5to6 head_start, i(mom_id) fe robust 
//B=+7.63***
outreg2 using p3results.xls, replace
xtreg comp_score_5to6 head_start sibdiff first lnbw, i(mom_id) fe robust
//B=7.07***
outreg2 using p3results.xls, append
xtreg comp_score_5to6 head_start black hispanic male, i(mom_id) fe robust
//B=7.78***
outreg2 using p3results.xls, append

xtreg comp_score_5to6 head_start sibdiff first lnbw black hispanic male learndis, i(mom_id) fe robust
outreg2 using p3results.xls, append
/*B=7.32*** (black, hispanic and sibdiff dropped due to collinearity)
--> we cant include vars that pretty much predict/highly overlap with family 
characteristics 

Now shows that HS increases test scores, whereas the only significant result we 
saw in RE (the naive regression) indciated a decline in test scores. However, 
there was clearly correlation in the error term with X at the family  level 
resulting in OVB */




********************************************************************************
**                                   P4                                       **
********************************************************************************
/*Causality relies on the counterfacutal-- what wouldve happened to someone 
in the absense of treatment (here HS). Unconfoundedness principle stiupaltes 
that outcome should be independent of treatment conditional on individual 
characteristics 
Maybe a way to get at this is to test 
differences between those eligible for HS but did not participate in HS 
(assuming they were not different in any other way from pariticipants that we 
cannot control for) this would be equivalent to fin counterfactual of outcomes 
based on intent to treat. How to do this? 
Test to see if theres a significant difference between outcome conditional 
on HS participation and sibdiff.*/

gen elig=0
replace elig=1 if sibdiff==1&head_start==0
replace elig =1 if head_start==1


corr head_start elig
//Good news, there isn't perfect overlap

mean ppvt_3 if elig==1, over(head_start)
//mean ppvt_3 if head_start==0, 

ttest ppvt_3 if elig==1, by(head_)
ttest comp_score_5to if elig==1, by(head_)
//No difference before treatment p>.1, but we see a difference after treatment, p<<.01!

/*eligibility is a bad instrument for participation, suggesting HS does 
something (at least in the short term) */


/*
(Another way is to test parallel trends.
Ideally we would have time series allowing us to see if parallel trends 
assumption holds prior to the intervention, but this is not available) */




********************************************************************************
**                                   P5                                       **
********************************************************************************
foreach var of varlist comp* {
 cap egen std_`var'=std(`var') //standardize test score
 xtreg std_`var' head_start male learndis lnbw firstborn, i(mom_id) fe robust
 outreg2 using p5fullresults.xls, append
 xtreg std_`var' head_start male learndis, i(mom_id) fe robust
 outreg2 using p5narrowresults.xls, append
}

/*we see no significant in the first specification for later tests.
we find smaller, but statistically significant effects on test scores later on 
in second specification. The first specicifation may be more accurate though */

********************************************************************************
**                                   P6                                       **
********************************************************************************
foreach var of varlist repeat hsgrad somecoll fphealth { 

	xtreg `var' head_start male learndis lnbw firstborn, i(mom_id) fe robust
	outreg2 using p6results.xls, append
}

/* repeat head_start effect insignificant 
head_start has postive significant coeff on hsgrad B=0.105**
not significant for somecoll
head_start has negative significant coeff on hsgrad B=-.064*
*/


********************************************************************************
**                                   P7                                       **
********************************************************************************

foreach var of varlist rep hsgrad somecoll fphealth { 

	di "______________________black__________________________________________"
	xtreg `var' head_start black head_start##black male lnbw first , i(mom_id) fe robust
	outreg2 using p7model1results.xls, replace
	di "______________________hispanic_______________________________________"
	xtreg `var' head_start hisp head_start##hisp male lnbw first , i(mom_id) fe robust
	outreg2 using p7model1results.xls, append
	di "______________________white__________________________________________"
	xtreg `var' head_start male lnbw first if black == 0 & hisp == 0, i(mom_id) fe robust
	outreg2 using p7model1results.xls, append
	di "______________________sex___________________________________________"	
	xtreg `var' head_start male head_start##male lnbw first, i(mom_id) fe robust
    outreg2 using p7model1results.xls, append 
	}

/*
Repeat: 
   significant for:
   not significant for: black, hisp, white, sex
HSGrad: 
   significant for: female (p<0.05)
   not significant for: black, hisp, white 
SomeColl: 
   significant for: black (p<0.01), hisp (p<0.1)
   not significant for: white, sex
Fphealth: 
   significant for: white (p<0.01), female (p<0.1)
   not significant for: black, hisp, 
*/
	
	
	

foreach var of varlist rep hsgrad somecoll fphealth { 

	di "______________________black__________________________________________"
	xtreg `var' head_start male lnbw first if black==1, i(mom_id) fe robust
	outreg2 using p7model2results.xls, replace
	di "______________________hispanic_______________________________________"
	xtreg `var' head_start hisp head_start##hisp male lnbw first if hisp==1, i(mom_id) fe robust
	outreg2 using p7model2results.xls, append
	di "______________________white__________________________________________"
	xtreg `var' head_start male lnbw first if black == 0 & hisp == 0, i(mom_id) fe robust
	outreg2 using p7model2results.xls, append
	di "______________________sex___________________________________________"	
	xtreg `var' head_start male head_start##male lnbw first, i(mom_id) fe robust
    outreg2 using p7model2results.xls, append
	}

/*
Repeat: 
   significant for:
   not significant for: black, hisp, white, sex
HSGrad: 
   significant for: black (p<<0.01), female (p<0.05)
   not significant for: hisp, white 
SomeColl: 
   significant for: black (p=0.01), hisp (p<0.1)
   not significant for: white, sex
Fphealth: 
   significant for: white (p<0.01), female (p<0.1)
   not significant for: black, hisp, 

   
   We see similarities across specifications, except for HSGrad for black, 
   which is odd given how significant it is in the second specification*/


********************************************************************************
**                                   P8                                       **
********************************************************************************
/* Is the policy objective to improve long run outcomes? If so, we would need 
models that are less noisy to specifications. 

Howeever, policymakers may only care about short run outcomes. There are many 
confounding variables and life experiences between HS at age 3/4 and the 
outcome measures we are use as our benchmark in this analysis. HS clearly is 
associated with higher test scores amount young children. Policymakers don't
 hold the inlcusion of other grade in K-12 to the long run outcomes standard. 
 
 */
 
 cap log close
 
 
 