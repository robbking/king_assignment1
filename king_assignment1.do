capture log close

log using "assignment1.log", replace

// NAME: Class Assignments-1
// AUTH: Robb King
// INIT: January 12, 2017
// LAST: January 14, 2017

// Set directory 
global in "/fs0/TNCRED_Projects/TNCRED_Projects_Mobility/Mobility I/Data"
use "/fs0/TNCRED_Projects/TNCRED_Projects_Mobility/Mobility I/Data/mobility_analysisfile_161122.dta", clear

global workdir `c(pwd)'
 

//I. CLEAN DATA
//Ia. Select Variables That Will Be Used For Analysis

* Keep only variables that will be used
keep year deident_tchnum districtno sch_id tch_yrsexp tch_salaryamt tch_ethnicity ///
	tch_female tch_age sch_type sch_ulocal sch_status sch_high_poverty sch_high_minority ///
	dist_urbanicity left_school2

* Change teacher ethnicity from categorical to numerical
encode tch_ethnicity, generate (ntch_ethnicity)

drop tch_ethnicity

mdesc

//Ib. Drop Variables That Are Missing Observations In The Dataset
* Set local for variables to drop missing observations from
local dropmisvar year deident_tchnum districtno sch_id tch_yrsexp tch_salaryamt ///
	ntch_ethnicity tch_female tch_age sch_ulocal sch_status ///
	sch_high_poverty sch_high_minority dist_urbanicity

* Drop missing data in local
foreach var of local dropmisvar {
	drop if `var'==.
	}
	
mdesc

* Drop if teacher salary is below 22,000
drop if tch_salaryamt < 22000

* Correct teacher age
drop if tch_age < 22

* Drop Observations That Are Missing Information On The Dependent Variable
drop if year==2014
drop if year==2015
drop if ntch_ethnicity==6

sum deident_tchnum

//Ic. Group Teachers Into Years Of Experience
gen ntch_yrsexp=tch_yrsexp
recode ntch_yrsexp 0/3 = 1
recode ntch_yrsexp 4/6 = 2
recode ntch_yrsexp 7/9 = 3
recode ntch_yrsexp 10/12 = 4
recode ntch_yrsexp 13/15 = 5
recode ntch_yrsexp 16/max = 6

tab ntch_yrsexp

//Id. One Observation That May Have Been Typed In Wrong
drop if ntch_yrsexp==-3

********************************************************************************
********************************************************************************

// CLASS ASSIGNMENT 1
// Part 1 of the assignment
*District Urbanicity
local dist_urbanicity_names city suburb town rural

tab(dist_urbanicity), gen(dist_urbanicity_)

local i=1

foreach val of local dist_urbanicity_names {
	rename dist_urbanicity_`i' `val'
	local i=`i' + 1
}

label variable city "City District"
label variable suburb "Suburban District"
label variable town "Town District"
label variable rural "Rural District"

*School Type
local sch_type_names reg sped voc alt

tab(sch_type), gen(sch_type_)

local i=1

foreach val of local sch_type_names {
	rename sch_type_`i' `val'
	local i=`i' + 1
}

label variable reg "Regular School"
label variable sped "Special Education School"
label variable voc "Vocational Education School"
label variable alt "Alternative/Other School"

// Part 2 of the assignment
sort tch_age

graph twoway scatter tch_salaryamt tch_age, msize(vtiny)

egen uncond_mean_salary=mean(tch_salaryamt)

gen uncond_mean_error_salary=tch_salaryamt-uncond_mean_salary

gen uncond_mean_error_sq_salary=uncond_mean_error_salary*uncond_mean_error_salary

quietly sum uncond_mean_error_sq_salary

scalar uncond_mean_mse_salary=r(mean)

graph twoway (scatter tch_salaryamt tch_age, msize(vtiny) mcolor(black)) ///
	(line uncond_mean_salary tch_age, lcolor(blue)), legend(order(2 "Unconditional Mean"))

graph save "uncond_mean_salary.gph", replace

// Conditional Mean: 2 Groups
egen tch_age2=cut(tch_age), group(2)

egen cond_mean2_salary=mean(tch_salaryamt), by(tch_age2)

gen cond_mean2_error_salary=tch_salaryamt-cond_mean2_salary

gen cond_mean2_error_sq_salary=cond_mean2_error_salary*cond_mean2_error_salary

quietly sum cond_mean2_error_sq_salary

scalar cond_mean2_mse_salary=r(mean)

graph twoway (scatter tch_salaryamt tch_age, msize(vtiny) mcolor(black)) ///
	(line uncond_mean_salary tch_age, lcolor(blue)) ///
	(line cond_mean2_salary tch_age, lcolor(orange)), ///
	legend(order(2 "Unconditional Mean" 3 "Conditional Mean, 2 Groups") )
	
graph save "cond_mean2_salary.gph", replace

// Conditional Mean: Quartiles 
egen tch_age4=cut(tch_age), group(4)

egen cond_mean4_salary=mean(tch_salaryamt), by(tch_age4)

gen cond_mean4_error_salary=tch_salaryamt-cond_mean4_salary

gen cond_mean4_error_sq_salary=cond_mean4_error_salary*cond_mean4_error_salary

quietly sum cond_mean4_error_sq_salary

scalar cond_mean4_mse_salary=r(mean)

graph twoway (scatter tch_salaryamt tch_age, msize(vtiny) mcolor(black)) ///
	(line uncond_mean_salary tch_age, lcolor(blue)) ///
	(line cond_mean2_salary tch_age, lcolor(orange)) ///
	(line cond_mean4_salary tch_age, lcolor(yellow)), ///
	legend(order(2 "Unconditional Mean" 3 "Conditional Mean, 2 Groups" 4 "Conditional Mean, 4 Groups") )
	
graph save "cond_mean4_salary.gph", replace

// 10
egen tch_age10=cut(tch_age), group(10)

egen cond_mean10_salary=mean(tch_salaryamt), by(tch_age10)

gen cond_mean10_error_salary=tch_salaryamt-cond_mean10_salary

gen cond_mean10_error_sq_salary=cond_mean10_error_salary*cond_mean10_error_salary

quietly sum cond_mean10_error_sq_salary

scalar cond_mean10_mse_salary=r(mean)

graph twoway (scatter tch_salaryamt tch_age, msize(vtiny) mcolor(black)) ///
	(line uncond_mean_salary tch_age, lcolor(blue)) ///
	(line cond_mean2_salary tch_age, lcolor(orange)) ///
	(line cond_mean4_salary tch_age, lcolor(yellow)) ///
	(line cond_mean10_salary tch_age, lcolor(red)), ///
	legend(order(2 "Unconditional Mean" 3 "Conditional Mean, 2 Groups" 4 "Conditional Mean, 4 Groups" 5 "Conditional Mean, 10 Groups"))
	
graph save "cond_mean4_salary.gph", replace

// Conditional Mean: Regression
reg tch_salaryamt tch_age

predict reg_predict_salary

predict reg_error_salary, residual

gen reg_error_sq_salary=reg_error_salary*reg_error_salary

quietly sum reg_error_sq_salary

scalar reg_mse_salary=r(mean)

graph twoway (scatter tch_salaryamt tch_age, msize(vtiny) mcolor(black)) ///
	(line uncond_mean_salary tch_age, lcolor(blue)) ///
	(line cond_mean2_salary tch_age, lcolor(orange)) ///
	(line cond_mean4_salary tch_age, lcolor(yellow)) ///
	(line cond_mean10_salary tch_age, lcolor(red)) ///
	(line reg_predict_salary tch_age, lcolor(purple)), ///
	legend(order(2 "Unconditional Mean" 3 "Conditional Mean, 2 Groups" 4 "Conditional Mean, 4 Groups" ///
	5 "Conditional Mean, 10 Groups" 6 "Conditional Mean, Regression"))
	
graph save "reg_predict_salary.gph", replace

scalar li

exit

/*Comments: As I continued to break down the dependent variable (tch_salaryamt) into more groups,
the mean squared errors increasingly got smaller and all of the conditional mean squared errors were 
much smaller than the unconditional mean squared error. The regression mean squared error was closer
to the unconditional mean squared error for 4 groups than the unconditional mean squared error for 10 groups.*/

