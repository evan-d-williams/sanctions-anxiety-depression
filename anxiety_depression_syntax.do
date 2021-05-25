
*================*
* Import Dataset *
*================*

import excel "$Path\\Quarterly_Sanctions_Dataset_Anxiety_Depression.xlsx", sheet("Sheet1") firstrow

*==========================
* Reshape to longform
*==========================

reshape long anxiety anxiety_65_plus ///
		origadv ///
		age1624_ age2529_ age3034_ age3539_ age4044_ age4549_ age5054_ age5559_ age6064_ age65plus_ ///
		female white ///
		claimant unemp employ inact ///
		gva gdhi ///
		wca ///
		, i(la_code) j(quarter)

*=================*
* Create Variables*
*=================*

* Urban / Rural

gen urban_2011=.
replace urban_2011=1 if rural_2011 < 3
replace urban_2011=2 if rural_2011 == 3
replace urban_2011=3 if rural_2011 > 3

* age

gen age1629_ = age1624_ + age2529_
gen age3049_ = age3034_ + age3539_ + age4044_ + age4549_
gen age5064_ = age5054_ + age5559_ + age6064_

* Reform

gen reform=.
replace reform=0 if quarter < 14
replace reform=1 if quarter >= 14

* Question change

gen question=.
replace question=0 if quarter < 16
replace question=1 if quarter >= 16

* Reform interaction

generate origadv_post = reform*origadv

* Timetrend interactions

generate imd_2=0 
replace imd_2=1 if imd_2010==2

generate imd_3=0 
replace imd_3=1 if imd_2010==3

generate imd_4=0 
replace imd_4=1 if imd_2010==4

generate imd_5=0 
replace imd_5=1 if imd_2010==5

generate imd_2b = imd_2*quarter
generate imd_3b = imd_3*quarter
generate imd_4b = imd_4*quarter
generate imd_5b = imd_5*quarter

generate urban_2=0 
replace urban_2=1 if urban_2011==2

generate urban_3=0 
replace urban_3=1 if urban_2011==3

generate urban_2b = urban_2*quarter
generate urban_3b = urban_3*quarter

*================================*
* Specify time period and sample *
*================================*

* time period

keep if quarter < 23
keep if quarter > 4

* drop small local authorities

drop if la_code == 61 // City of London
drop if la_code == 138 // Isles of Scilly

* deal with Universal Credit rollout
// Substantive results unchanged if these LA quarters are retained

drop if la_code == 271 & quarter >= 16 // Tameside
drop if la_code == 312 & quarter >= 17 // Wigan
drop if la_code == 195 & quarter >= 17 // Oldham
drop if la_code == 295 & quarter >= 17 // Warrington
drop if la_code == 116 & quarter >= 18 // Hammersmith & Fulham
drop if la_code == 217 & quarter >= 18 // Rugby
drop if la_code == 120 & quarter >= 19 // Harrogate
drop if la_code == 16 & quarter >= 19 // Bath
drop if la_code == 287 & quarter >= 21 // Trafford
drop if la_code == 227 & quarter >= 21 // Sefton
drop if la_code == 24 & quarter >= 21 // Bolton
drop if la_code == 316 & quarter >= 21 // Wirral
drop if la_code == 202 & quarter >= 21 // Preston
drop if la_code == 246 & quarter >= 21 // South Ribble
drop if la_code == 41 & quarter >= 21 // Bury
drop if la_code == 223 & quarter >= 21 // Salford
drop if la_code == 146 & quarter >= 21 // Knowsley
drop if la_code == 256 & quarter >= 21 // St. Helens
drop if la_code == 55 & quarter >= 21 // Cheshire West and Chester
drop if la_code == 54 & quarter >= 21 // Cheshire East 
drop if la_code == 160 & quarter >= 22 // Manchester
drop if la_code == 212 & quarter >= 22 // Rochdale
drop if la_code == 21 & quarter >= 22 // Blackburn with Darwen
drop if la_code == 114 & quarter >= 22 // Halton
drop if la_code == 260 & quarter >= 22 // Stockport
drop if la_code == 40 & quarter >= 22 // Burnley
drop if la_code == 135 & quarter >= 22 // Hyndburn
drop if la_code == 197 & quarter >= 22 // Pendle
drop if la_code == 214 & quarter >= 22 // Rossendale
drop if la_code == 306 & quarter >= 22 // West Lancashire
drop if la_code == 155 & quarter >= 22 // Liverpool

* Deal with zero values in anxiety and sanctions

replace anxiety=. if anxiety==0
replace origadv=. if origadv==0

*========================*
* Descriptive Statistics *
*========================*

* Table 1

summarize anxiety origadv anxiety_65_plus claimant unemp inact employ wca gva gdhi age015_ age1629_ age3049_ age5064_ age65plus_ female white
tabulate imd_2010
tabulate urban_2011

* Figure 2

pwcorr anxiety origadv, sig

regress anxiety origadv
local r2: display %4.3f e(r2)
twoway scatter anxiety origadv, jitter(10) msymbol(oh) mcolor(gs9) ///
				|| lfit anxiety origadv, lwidth(medthick) lcolor(black) ///
				xtitle("Sanctions per" "100,000 working age population", height(10)) ///
				xlabel(, format(%9.0fc)) ///
				ytitle("Anxiety/Depression per" "100,000 working age population", height(10)) ///
				ylabel(, format(%9.0fc)) ///
				legend(off) ///
				graphregion(color(white)) ///
				caption("R{superscript:2} = `r2'", ring(0) position(2) height(10))

*======================*
* Fixed Effects Models *
*======================*

xtset la_code quarter

* Multicollinearity check

corr origadv claimant
corr origadv unemp

* Initial models (Table A2/A5)
// Two versions of models - xtreg / xtscc

xtreg anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white, fe
xtreg anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xtreg anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white  i.imd_2010 i.urban_2011, re

xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white, fe
xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white  i.imd_2010 i.urban_2011, re

* FE/RE comparison - Hausman test

xtreg anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
estimates store fixed
xtreg anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question i.imd_2010 i.urban_2011, re
estimates store random
hausman fixed random
hausman fixed random, sigmamore

* Pre and Post Reform (Table 2)

xtreg anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
xtreg anxiety origadv c.origadv#reform unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
lincom origadv + 1.reform#c.origadv

xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xtscc anxiety origadv c.origadv#reform unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
lincom origadv + 1.reform#c.origadv

* GVA / GDHI check

xtreg anxiety origadv unemp inact wca gdhi i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xtreg anxiety origadv c.origadv#reform unemp inact wca gdhi i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
lincom origadv + 1.reform#c.origadv

xtscc anxiety origadv unemp inact wca gdhi i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xtscc anxiety origadv c.origadv#reform unemp inact wca gdhi i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
lincom origadv + 1.reform#c.origadv

*===================================
* Visualise the regression estimates
*===================================

/*
ssc install coefplot
ssc install lincomest
*/

// Version 1

gen origadvb=origadv
gen origadvc=origadv
gen reformb=reform

quietly xtreg anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white  quarter c.quarter#i.imd_2010 c.quarter#i.urban_2011, fe robust
estimates store full
quietly xtreg anxiety origadvb c.origadvb#reform unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white  quarter c.quarter#i.imd_2010 c.quarter#i.urban_2011, fe robust
estimates store before
quietly xtreg anxiety origadvc c.origadvc#reformb unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white  quarter c.quarter#i.imd_2010 c.quarter#i.urban_2011, fe robust
lincomest origadvc + 1.reformb#c.origadvc
estimates store after
coefplot(full, label(Full) offset(.0)) (before, label(Before)) (after, label(After)), ///
		keep(origadv origadvb (1)) ///
		yline(0) vertical legend(off) graphregion(color(white)) levels(95) ///
		ytitle("Increase in Anxiety/Depression" "per 100,000 working age population", height(10)) ///
		coeflabels(origadv = "Full Time Period" ///
		origadvb = "Pre-Welfare Reform Act 2012" ///
		(1) = "Post-Welfare Reform Act 2012", ///
		wrap(20) labgap(3))

// Version 2
		
quietly xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
estimates store full
quietly xtscc anxiety origadvb origadv_post unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
estimates store before
quietly xtscc anxiety origadvc origadv_post unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
lincomest origadvc + origadv_post
estimates store after
coefplot(full, label(Full) offset(.0)) (before, label(Before)) (after, label(After)), ///
		keep(origadv origadvb (1)) ///
		yline(0) vertical legend(off) graphregion(color(white)) levels(95) ///
		ytitle("Increase in Anxiety/Depression" "per 100,000 working age population", height(10)) ///
		coeflabels(origadv = "Full Time Period" ///
		origadvb = "Pre-Welfare Reform Act 2012" ///
		(1) = "Post-Welfare Reform Act 2012", ///
		wrap(20) labgap(3))
		
*====================*
* Falsification Test *
*====================*

// Version 1

xtreg anxiety_65_plus origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
xtreg anxiety_65_plus origadv c.origadv#reform unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
lincom origadv + 1.reform#c.origadv

quietly xtreg anxiety_65_plus origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
estimates store full
quietly xtreg anxiety_65_plus origadvb c.origadvb#reform unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
estimates store before
quietly xtreg anxiety_65_plus origadvc c.origadvc#reformb unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
lincomest origadvc + 1.reformb#c.origadvc
estimates store after
coefplot(full, label(Full) offset(.0)) (before, label(Before)) (after, label(After)), ///
		keep(origadv origadvb (1)) ///
		yline(0) vertical legend(off) graphregion(color(white)) levels(95) ///
		ytitle("Increase in Anxiety/Depression (Aged 65+)" "per 100,000 working age population", height(10)) ///
		coeflabels(origadv = "Full Time Period" ///
		origadvb = "Pre-Welfare Reform Act 2012" ///
		(1) = "Post-Welfare Reform Act 2012", ///
		wrap(20) labgap(3))
		
// Version 2

xtscc anxiety_65_plus origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
xtscc anxiety_65_plus origadv c.origadv#reform unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
lincom origadv + 1.reform#c.origadv

quietly xtscc anxiety_65_plus origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
estimates store full
quietly xtscc anxiety_65_plus origadvb origadv_post unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
estimates store before
quietly xtscc anxiety_65_plus origadvc origadv_post unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
lincomest origadvc + origadv_post
estimates store after
coefplot(full, label(Full) offset(.0)) (before, label(Before)) (after, label(After)), ///
		keep(origadv origadvb (1)) ///
		yline(0) vertical legend(off) graphregion(color(white)) levels(95) ///
		ytitle("Increase in Anxiety/Depression (Aged 65+)" "per 100,000 working age population", height(10)) ///
		coeflabels(origadv = "Full Time Period" ///
		origadvb = "Pre-Welfare Reform Act 2012" ///
		(1) = "Post-Welfare Reform Act 2012", ///
		wrap(20) labgap(3))

*========================*
* Granger Causality Test *
*========================*

xtgcause anxiety origadv, l(4)
xtgcause origadv anxiety, l(4)

xtgcause anxiety origadv, l(aic)
xtgcause origadv anxiety, l(aic)

xtgcause anxiety origadv, l(bic)
xtgcause origadv anxiety, l(bic)

xtgcause anxiety origadv, l(hqic)
xtgcause origadv anxiety, l(hqic)

*===================================*
* Appendix / Regression Diagnostics *
*===================================*

* a) Normality of Dependent Variable

hist anxiety, norm
pnorm anxiety

sktest anxiety
swilk anxiety
sfrancia anxiety

* b) Normality of Residuals

// Version 1

xtreg anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
predict res1, e

histogram res1,	normal frequency fcolor(gs10) lcolor(gs12) ///
				xtitle("Residuals", height(6)) xlabel(, format(%9.0fc)) ///
				ytitle("Frequency", height(6))	ylabel(, format(%9.0fc)) ///
				graphregion(color(white))

// Version 2

xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
predict res2, residuals

histogram res2,	normal frequency fcolor(gs10) lcolor(gs12) ///
				xtitle("Residuals", height(6)) xlabel(, format(%9.0fc)) ///
				ytitle("Frequency", height(6))	ylabel(, format(%9.0fc)) ///
				graphregion(color(white))
				
pnorm res
qnorm res
kdensity res, normal

sktest res
swilk res
sfrancia res

* c) Cross-sectional dependence / contemporaneous correlation

preserve
replace unemp=0 if unemp==.
xtreg anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
xtcsd, pesaran abs
restore

* d) Homoscedasticity

xtreg anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xttest3

xtreg anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
predict res, e 
predict yhat1, xb

summarize res 

twoway scatter 	res yhat1, ///
				ytitle("Residuals", height(6)) ylabel(, format(%9.0fc)) ///
				xtitle("Predicted Values", height(6)) xlabel(, format(%9.0fc)) ///
				msize(medium) yline(0) graphregion(color(white)) ///
				jitter(10) msymbol(oh) mcolor(gs9)

* e) Serial correlation
// Lagrange Multiplier test

xtserial anxiety origadv unemp inact wca gva age3049_ age5064_ age65plus_ female white

* f) Unit root / stationarity

pescadf anxiety, lags(0) 
pescadf anxiety, lags(0) trend

pescadf origadv, lags(0)
pescadf origadv, lags(0) trend

* g) Outliers / Leverage / Influence

// Residuals +/- 2S.D. from mean

xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
predict res2, residual
summarize res2, detail // +/- 2SD = [XXXX, YYYY]
gen res_1 = .
replace res_1 = 1 if res2 > XXXX  & res2 < YYYY
xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b if res_1 == 1, fe

// Extreme observations > 99th percentile

summarize anxiety, detail // 1% = XXXX, 99% = YYYY
gen anxiety_new =.
replace anxiety_new = 1 if  anxiety > XXXX & anxiety < YYYY
xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b if anxiety_new == 1, fe

summarize origadv, detail // 1% = XXXX, 99% = YYYY
gen origadv_new =.
replace origadv_new = 1 if  origadv > XXXX & origadv < YYYY
xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b if origadv_new == 1, fe

* Coastal towns check

preserve
xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
drop if la_code == 22 // Blackpool
drop if la_code == 284 // Torbay
drop if la_code == 124 // Hastings
drop if la_code == 110 // Great Yarmouth
drop if la_code == 280 // Thanet
xtscc anxiety origadv unemp inact wca gva i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
restore

* h) Multicollinearity

pwcorr anxiety origadv claimant unemp inact wca gva age1629_ age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, sig

// Tolerance and VIF scores.

regress anxiety origadv claimant i.la_code i.quarter age3049_ age5064_ age65plus_ female white i.question imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b
estat vif
collin origadv claimant age3049_ age5064_ age65plus_ female white 
