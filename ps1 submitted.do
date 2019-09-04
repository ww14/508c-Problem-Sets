********* WWS508c PS1 *********
*  Spring 2018			      *
*  Author : William Willoughby*
*  Email: ww14@princeton.edu  *
*******************************
//any disclaimer...//
//credit: Andrew Moyseowicz, Graham Simpson//

set more off
cap cd "C:\Users\William Willoughby\Documents\Princeton\Spring 2018\508\psets\ps1"
set matsize 800
clear
capture log close
log using ps1.log, replace
local data 
use project_star_ps1.dta, clear 




********************************************************************************
**                                   P1                                       **
********************************************************************************
//Simple Tab
foreach var of varlist ssex srace sesk cltypek hdegk totexpk tracek schtypek {
tab `var'
}

//Tab with missing values 
foreach var of varlist ssex srace sesk cltypek hdegk totexpk tracek schtypek {
tab `var', missing 
}

//Look at percentiles 
sum tcombssk treadssk tmathssk, detail

misstable sum tcombssk treadssk tmathssk 
// missing 539 observations for total score 


//Create rural, non-rural dummy variable
gen rural=1
replace rural=0 if schtypek !=3


********************************************************************************
**                                   P2                                       **
********************************************************************************
//Conduct simple chi2 tests comparing classroom types to demographics 
tab cltypek ssex, row chi2 expected  //cannot reject 
tab cltypek srace, row chi2 expected //cannot reject 
tab cltypek sesk, row chi2 expected  //can reject at p<.10

********************************************************************************
**                                   P3                                       **
********************************************************************************
//comment//
bysort cltypek: sum treadssk
bysort cltypek: sum tmathssk

* Calculate t-statistics mannually
display (440.5474-434.7323)/(sqrt(((32.49738^2)/1739)+((30.9359^2)/2006)))  
//reading, 5.58
display (490.9313-483.1993)/(sqrt(((49.51013^2)/1762)+((47.63593^2)/2032))) 
//math, 4.88

/*Do t-tests*/
ttest treadssk if cltypek !=3, by (cltypek) //reading, 5.85
ttest tmathssk if cltypek !=3, by (cltypek) //math, 7.732
ttest treadssk if cltypek !=3, by (cltypek) unequal 
//reading, 5.58 cannot treat variances of differing class size as equal
ttest tmathssk if cltypek !=3, by (cltypek) unequal //math, 4.88 ibid.


********************************************************************************
**                                   P4                                       **
********************************************************************************
ttest treadssk if cltypek !=1, by (cltypek) unequal
ttest tmathssk if cltypek !=1, by (cltypek) unequal
//ttest treadssk if cltypek !=1, by (cltypek) 
//ttest tmathssk if cltypek !=1, by (cltypek) 

********************************************************************************
**                                   P5                                       **
************************************************************************

//make race a dummy
replace srace = . if srace == 6


/*General Formula: Tstat = (avg1-avg2)/sqrt(se1^2+se2^2), 
this assumes iid across students*/

//race
ttest tcombssk if cltypek !=3 & srace==1, by (cltypek)
//white, effect size =12.79
ttest tcombssk if cltypek !=3 & srace==2, by (cltypek) 
//black, effect size =15.85
display ( 15.84935- 12.79163)/(sqrt((2.929459^2)+(4.269511^2))) 
//tstat=0.59053498 difference is not statistically significant 

//SES
ttest tcombssk if cltypek !=3 & sesk==1, by (cltypek) 
//frl, effect size =13.78526 (3.336679)
ttest tcombssk if cltypek !=3 & sesk==2, by (cltypek) 
//non-frl, effect size =14.26328 (3.340742)
display (14.26328- 13.78526)/(sqrt((3.336679^2)+(3.340742^2))) 

//tstat=0.10124002 difference is not statistically significant 
//rural-urban
ttest tcombssk if cltypek !=3 & schtypek==3, by (cltypek) 
//rural, effect size =13.74826 (3.518212)
ttest tcombssk if cltypek !=3 & schtypek!=3, by (cltypek) 
//non-rural, effect size =14.5062 (3.404465)
display ( 14.5062- 13.74826)/(sqrt((3.518212^2)+(3.404465^2))) 
//tstat=0.15481646 difference is not statistically significant 


********************************************************************************
**                                   P6                                       **
********************************************************************************
/*Previous question assumed black and white, etc. are iid. independence is a 
bad assumption. let's look at classroom averages instead*/


preserve 
collapse(mean) tcombssk tmathssk treadssk , by(classid)

//Race 
ttest treadssk if cltypek!=3 & srace==1, by(cltypek) 
    //white, effect size=4.625434 (1.291542)
ttest treadssk if cltypek!=3 & srace==2, by(cltypek) 
    //black, effect size=8.106193 (1.643729)
display (  8.106193- 4.625434)/(sqrt((1.643729^2)+(1.291542^2))) 
    //tstat=1.665087, statistically significant at p<0.05


ttest tmathssk if cltypek!=3 & srace==1, by(cltypek) 
    //white, effect size=7.86221    1.848872
ttest tmathssk if cltypek!=3 & srace==2, by(cltypek) 
    //black, effect size=7.125029    2.912646
display (7.86221- 7.125029)/(sqrt((1.848872^2)+(2.912646^2))) 
    //tstat=0.213, not statistically significant 
	
//SES 
ttest treadssk if cltypek!=3 & sesk==1, by(cltypek) 
   //FRL, effect size=6.473186 (1.300176)
ttest treadssk if cltypek!=3 & sesk==2, by(cltypek) 
   //non-FRL, effect size=5.299736 (1.502824)
display ( 6.473186 - 5.299736)/(sqrt((1.300176^2)+(1.502824^2))) 
    //tstat=0.5905, not statistically significant

ttest tmathssk if cltypek!=3 & sesk==1, by(cltypek) 
   //FRL, effect size=7.327184    2.255135
ttest tmathssk if cltypek!=3 & sesk==2, by(cltypek) 
   //non-FRL, effect size=8.173848    2.101653 
display (8.173848 - 7.327184)/(sqrt((2.101653^2)+(2.255135^2))) 
    //tstat=0.27465679, not statistically significant
	
//Rural
ttest treadssk if cltypek!=3 & rural==1, by(cltypek) 
   //Rural, effect size=4.764341    (1.537562)
ttest treadssk if cltypek!=3 & rural==0, by(cltypek) 
   //non-Rural, effect size=6.919931 (1.403588)
display (6.919931 - 4.764341)/(sqrt((1.403588^2)+(1.537562^2))) 
    //tstat=1.0354136, not statistically significant

ttest tmathssk if cltypek!=3 & rural==1, by(cltypek) 
   //Rural, effect size=8.903971    2.245724 
ttest tmathssk if cltypek!=3 & rural==0, by(cltypek) 
   //non-Rural, effect size=7.037139     2.21681 
display (8.903971 - 7.037139)/(sqrt((2.245724^2)+(2.21681^2))) 
    //tstat=0.59160193, not statistically significant
	
	
//Sex
ttest treadssk if cltypek!=3 & ssex==1, by(cltypek) 
   //Male, effect size=8.339467 (1.388795)
ttest treadssk if cltypek!=3 & ssex==2, by(cltypek) 
   //Female, effect size=3.172258    1.528327
display (8.339467 - 3.172258)/(sqrt((1.388795^2)+(1.528327^2))) 
    //tstat=2.5021894, statistically significant at p<0.01

ttest tmathssk if cltypek!=3 & ssex==1, by(cltypek) 
   //Male, effect size=13.08696    2.196824
ttest tmathssk if cltypek!=3 & ssex==2, by(cltypek) 
   //Female, effect size=2.12696    2.248693 
display (13.08696 - 2.12696)/(sqrt((2.196824^2)+(2.248693^2))) 
    //tstat=3.4863719, statistically significant at p<0.01
	
	
	
restore


********************************************************************************
**                                   P7                                       **
********************************************************************************

foreach var of varlist rural srace sesk ssex {

ttest tcombssk, by(`var') unequal
ttest treadssk, by(`var') unequal
ttest tmathssk, by(`var') unequal

}

//all results are statistically significant for p<0.05

ttest tcombssk if cltypek !=3, by (cltypek) unequal

cap log close 
