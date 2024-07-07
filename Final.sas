
***************************************************************
* PH 305 Final Exam	        
* Name: Minxing Huang
* Date: 12/2/2023
***************************************************************;

title1 "PH 305 Final Exam";
options nofmterr nodate;

title2 "Problem 1";
***************************************************************
Problem 1: 
***************************************************************;

/*a*/
/*import data*/
libname class "\\apporto.com\dfs\NTHW\Users\mhv2108_nthw\Downloads";
data lab;
	set class.lab;
run;
data qst;
	set class.questionnaire;
run;
data smk;
	set class.smoke;
run;

/*sort data*/
proc sort data = lab;
	by seqn;
run;
proc sort data = qst;
	by seqn;
run;
proc sort data = smk;
	by seqn;
run;

/*merge data*/
data merged;
	merge lab qst smk;
	by seqn;
run;

/*b*/
/*create variable*/
data merged2 (drop = num);
	set merged;
	bmi = weight / (height / 100) ** 2;
	num = input(scan(CigPerDay, 1, " "), 8.);
	totalcigar = num * 365 * (age - agestart);
run;

title2 "Problem 2";
***************************************************************
Problem 2: 
***************************************************************;

/*a*/
/*print variable type*/
proc contents data = merged2;
run;

/*check normality*/
proc univariate data = merged2 normal;
	qqplot age bmi cholesterol glucose triglycerides agestart totalcigar / normal (mu = est sigma = est) square;
	var age bmi cholesterol glucose triglycerides agestart totalcigar;
run;

/*normal: cholesterol
This variable is normally distributed because the data points in QQ-plot do not deviate away from the reference line.

non-normal: age bmi glucose triglycerides agestart totalcigar
These variables are not normally distributed because the data points in QQ-plot deviate away from the reference line.

categorical: gender race education diabetes eversmoke
These variables are categorical because they can only take limited (2-3) values.*/

/*b*/
/*create macro*/
%macro vbp(var);
title1 "&var by heart attack status";
proc sgplot data = merged2;
	vbox &var / category = heartattack;
	xaxis label = "heart attack status";
	yaxis label = "&var";
run;
%mend;

/*run macro*/
%vbp(cholesterol);
%vbp(age);
%vbp(bmi);
%vbp(glucose);
%vbp(triglycerides);
%vbp(agestart);
%vbp(totalcigar);

title2 "Problem 3";
***************************************************************
Problem 3: 
***************************************************************;

/*a*/
/*create macro*/
%macro cattbl(var, mis, wd2);
proc freq data = merged2;
	table &var * heartattack / chisq nocol nocum nopercent;
	ods output CrossTabFreqs = tbl;
run;
data tbl2 (keep = &var heartattack Frequency Perc);
	set tbl;
	format Perc $17.;
	if &var = &mis then delete;
	if heartattack = . then delete;
	Perc = "(" || trim(left(put(RowPercent, 8.1))) || ")";
run;
proc sort data = tbl2; 
	by &var; 
run;
proc transpose data = tbl2
	out = wide1
	prefix = N;
	by &var;
	id heartattack;
	var frequency;
run;
proc transpose data = tbl2 
	out = wide2
	prefix = Perc;
	by &var;
	id heartattack;
	var perc;
run;
data wd;
	format varname $14.;
	merge wide1 wide2;
	by &var;
	varname = "&var";
	levels = put(&var, 12.);
run;
data &wd2 (keep = Varname Levels N0 N1 Perc0 Perc1);
	retain Varname Levels N0 Perc0 N1 Perc1;
	set wd;
run;
%mend;

/*run macro*/
%cattbl(gender, ., gend_wd);
%cattbl(race, " ", race_wd);
%cattbl(education, " ", edu_wd);
%cattbl(diabetes, ., diab_wd);
%cattbl(eversmoke, ., evsm_wd);

/*append data*/
data cattbl;
	set gend_wd race_wd edu_wd diab_wd evsm_wd;
run;

/*b*/
/*generate result*/
proc means data = merged2;
	class heartattack;
	var cholesterol;
	ods output summary = summary;
run;

/*format value*/
data summary2 (keep = varname heartattack Mean SD);
	set summary;
	format SD $17. varname $14.;
	cholesterol_Mean = round(cholesterol_Mean, 0.1);
	cholesterol_StdDev = round(cholesterol_StdDev, 0.1);
	Mean = cholesterol_Mean;
	SD = "(" || trim(left(put(cholesterol_StdDev, 8.1))) || ")";
	varname = "cholesterol";
run;

/*transpose and merge*/
proc transpose data = summary2 
	out = mean_wide
	prefix = mean;
	by varname;
	id heartattack;
	var Mean;
run;
proc transpose data = summary2 
	out = sd_wide 
	prefix = sd;
	by varname;
	id heartattack;
	var SD;
run;
Data wd;
	merge mean_wide sd_wide;
	by varname;
run;

/*Final Formatting*/
data nortbl (keep = Varname mean0 mean1 sd0 sd1);
	retain Varname mean0 sd0 mean1 sd1;
	set wd;
run;

/*c*/
/*create macro*/
%let med = _median;
%let q1 = _q1;
%let q3 = _q3;
%macro nontbl(var, wd2);
proc means data = merged2 median q1 q3;
	class heartattack;
	var &var;
	ods output summary = summary;
run;
data summary2 (keep = varname heartattack Median IQR);
	set summary;
	format IQR $17. varname $14.;
	&var&med = round(&var&med, 1);
	&var&q1 = round(&var&q1, 1);
	&var&q3 = round(&var&q3, 1);
	Median = &var&med;
	IQR = "[" || trim(left(put(&var&q1, 8.))) || " - " || trim(left(put(&var&q3, 8.))) || "]";
	varname = "&var";
run;
proc transpose data = summary2 
	out = median_wide
	prefix = median;
	by varname;
	id heartattack;
	var Median;
run;
proc transpose data = summary2 
	out = iqr_wide 
	prefix = IQR;
	by varname;
	id heartattack;
	var IQR;
run;
Data wd;
	merge median_wide iqr_wide;
	by varname;
run;
data &wd2 (keep = Varname median0 median1 iqr0 iqr1);
	retain Varname median0 iqr0 median1 iqr1;
	set wd;
run;
%mend;

/*run macro*/
%nontbl(age, age_wd);
%nontbl(bmi, bmi_wd);
%nontbl(glucose, glu_wd);
%nontbl(triglycerides, trig_wd);
%nontbl(agestart, agst_wd);
%nontbl(totalcigar, ttci_wd);

/*append data*/
data nontbl;
	set age_wd bmi_wd glu_wd trig_wd agst_wd ttci_wd;
run;

/*d*/
/*rename column*/
data cattbl2;
	set cattbl;
	rename N0 = N0_Mean0_Median0
		   Perc0 = Perc0_SD0_IQR0
		   N1 = N1_Mean1_Median1
		   Perc1 = Perc1_SD1_IQR1;
run;
data nortbl2;
	set nortbl;
	rename Mean0 = N0_Mean0_Median0
		   SD0 = Perc0_SD0_IQR0
		   Mean1 = N1_Mean1_Median1
		   SD1 = Perc1_SD1_IQR1;
run;
data nontbl2;
	set nontbl;
	rename Median0 = N0_Mean0_Median0
		   IQR0 = Perc0_SD0_IQR0
		   Median1 = N1_Mean1_Median1
		   IQR1 = Perc1_SD1_IQR1;
run;

/*append data*/
data table1;
	set cattbl2 nortbl2 nontbl2;
run;

/*export data*/
proc export data = table1
	outfile = "\\apporto.com\dfs\NTHW\Users\mhv2108_nthw\Downloads\Table1.xlsx"
	dbms = xlsx replace;
run;

title2 "Problem 4";
***************************************************************
Problem 4: 
***************************************************************;

/*perform chi-squared test*/
proc freq data = merged2;
	table gender * heartattack 
		  race * heartattack 
		  education * heartattack 
		  diabetes * heartattack 
		  eversmoke * heartattack / chisq norow nocol;
run;

/*perform 2-sample t-test*/
proc ttest data = merged2;
	class heartattack;
	var cholesterol;
run;

/*perform Mann Whitney U-test*/
proc npar1way data = merged2 wilcoxon;
	class heartattack;
	var age bmi glucose triglycerides agestart totalcigar;
run;

/*The result is significant for gender by heartattack (p = 0.0010).
The result is significant for race by heartattack (p = 0.0036).
The result is significant for education by heartattack (p = 0.010).
The result is significant for diabetes by heartattack (p < 0.0001).
The result is significant for eversmoke by heartattack (p < 0.0001).

The result is significant for cholesterol by heartattack (p < 0.0001).

The result is significant for age by heartattack (p < 0.0001).
The result is significant for bmi by heartattack (p = 0.015).
The result is significant for glucose by heartattack (p = 0.0018).
The result is not significant for triglycerides by heartattack (p = 0.19).
The result is significant for agestart by heartattack (p = 0.0040).
The result is not significant for totalcigar by heartattack (p = 0.69).*/

title2 "Problem 5";
***************************************************************
Problem 5: 
***************************************************************;

/*a*/
/*transform variable*/
data merged3;
	set merged2;
	logage = log(age);
	logbmi = log(bmi);
	logglucose = log(glucose);
	logtriglycerides = log(triglycerides);
	logagestart = log(agestart);
	logtotalcigar = log(totalcigar);
run;

/*b*/
/*create macro*/
%macro conlog(x);
proc logistic data = merged3 desc;
	model heartattack = &x;
run;
%mend;

/*run macro*/
%conlog(cholesterol);
%conlog(logage);
%conlog(logbmi);
%conlog(logglucose);
%conlog(logtriglycerides);
%conlog(logagestart);
%conlog(logtotalcigar);

/*c*/
/*create macro*/
%macro catlog(x);
proc logistic data = merged3 desc;
	class &x;
	model heartattack = &x;
run;
%mend;

/*run macro*/
%catlog(gender);
%catlog(race);
%catlog(education);
%catlog(diabetes);
%catlog(eversmoke);

/*d*/
/*create macro*/
%macro logis(cls, var, ortbl3);
proc logistic data = merged3 desc;
	&cls
	model heartattack = &var;
	ods output oddsratios = ortbl;
run;
data ortbl2;
	set ortbl;
	rename effect = temp;
	OddsRatioEst = round(OddsRatioEst, 0.01);
	LowerCL = round(LowerCL, 0.01);
	UpperCL = round(UpperCL, 0.01);
run;
data &ortbl3 (keep = Effect OR CI);
	retain Effect OR CI;
	set ortbl2;
	format effect $33.;
	effect = temp;
	OR = OddsRatioEst;
	CI = "(" || trim(left(put(LowerCL, 8.2))) || ", " || trim(left(put(UpperCL, 8.2))) || ")";
run;
%mend;

/*run macro*/
%logis(, cholesterol, chol_or);
%logis(, logage, logage_or);
%logis(, logbmi, logbmi_or);
%logis(, logglucose, logglu_or);
%logis(, logtriglycerides, logtrig_or);
%logis(, logagestart, logagst_or);
%logis(, logtotalcigar, logttci_or);
%logis(class gender;, gender, gend_or);
%logis(class race;, race, race_or);
%logis(class education;, education, edu_or);
%logis(class diabetes;, diabetes, diab_or);
%logis(class eversmoke;, eversmoke, evsm_or);

/*append data*/
data table2;
	set chol_or logage_or logbmi_or logglu_or logtrig_or logagst_or logttci_or gend_or race_or edu_or diab_or evsm_or;
run;

/*e*/
/*export data*/
proc export data = table2
	outfile = "\\apporto.com\dfs\NTHW\Users\mhv2108_nthw\Downloads\Table2.xlsx"
	dbms = xlsx replace;
run;

title2 "Problem 6";
***************************************************************
Problem 6: 
***************************************************************;

/*a*/
/*check collinearity (linear regression is used because vif option is not applicable in logistic regression)*/
proc reg data = merged3;
	model heartattack = cholesterol logage logbmi logglucose logtriglycerides logagestart logtotalcigar / vif;
run;
quit;

/*b*/
/*Since vif values < 10 for all continuous variables, no variables are highly correlated.*/

/*c*/
/*save scatterplot*/
ods pdf file = "\\apporto.com\dfs\NTHW\Users\mhv2108_nthw\Downloads\Plot.pdf" 
	style = harvest;
proc sgscatter data = merged3;
	matrix cholesterol logage logbmi logglucose logtriglycerides logagestart logtotalcigar;
run;
ods pdf close;

title2 "Problem 7";
***************************************************************
Problem 7: 
***************************************************************;

/*create macro*/
%Macro conf(cls, z);
proc logistic data = merged3 desc;
	&cls
	model heartattack = &z;
run;
proc logistic data = merged3 desc;
	&cls
	model eversmoke = &z;
run;
%Mend;

/*run macro*/
%conf(, cholesterol);
%conf(, logage);
%conf(, logbmi);
%conf(, logglucose);
%conf(, logtriglycerides);
%conf(class gender;, gender);
%conf(class race;, race);
%conf(class education;, education);
%conf(class diabetes;, diabetes);

/*Since p-values < 0.05 for both heartattack vs. cholesterol and eversmoke vs. cholesterol, cholesterol is significantly correlated with both the exposure and the outcome. Thus, cholesterol is a confounder.
Since p-values < 0.05 for both heartattack vs. logbmi and eversmoke vs. logbmi, logbmi is significantly correlated with both the exposure and the outcome. Thus, logbmi is a confounder.
Since p-values < 0.05 for both heartattack vs. gender and eversmoke vs. gender, gender is significantly correlated with both the exposure and the outcome. Thus, gender is a confounder.
Since p-values < 0.05 for both heartattack vs. race and eversmoke vs. race, race is significantly correlated with both the exposure and the outcome. Thus, race is a confounder.*/

title2 "Problem 8";
***************************************************************
Problem 8: 
***************************************************************;

/*transform variable*/
data merged4;
	set merged3;
	if education = "High School" then numedu = 0;
	else if education = "College" then numedu = 1;
run;

/*create macro*/
%macro efmo(z, cls);
data merged5; 
	set merged4;
	inter = eversmoke * &z;
Run;
proc logistic data = merged5 desc;
	class eversmoke &cls;
	model heartattack = eversmoke &z inter;
run;
%mend;

/*run macro*/
%efmo(cholesterol, );
%efmo(logage, );
%efmo(logbmi, );
%efmo(logglucose, );
%efmo(logtriglycerides, );
%efmo(gender, gender inter);
%efmo(numedu, numedu inter);
%efmo(diabetes, diabetes inter);

/*Since p-value < 0.05 for the interaction between eversmoke and gender to heartattack, the interaction between the exposure and gender is statistically significant to the outcome. Thus, gender is an effect modifier.*/

title2 "Problem 9";
***************************************************************
Problem 9: 
***************************************************************;

/*a*/
/*create interaction*/
data merged5; 
	set merged4;
	inter = eversmoke * gender;
Run;

/*create model*/
proc logistic data = merged5 desc;
	class eversmoke gender race inter education diabetes;
	model heartattack = eversmoke cholesterol logbmi gender race inter education diabetes logage logglucose logagestart;
run;

/*remove interaction because its p-value > 0.05 and it is no longer statistically significant*/
proc logistic data = merged5 desc;
	class eversmoke gender race education diabetes;
	model heartattack = eversmoke cholesterol logbmi gender race education diabetes logage logglucose logagestart;
run;

/*remove diabetes because its p-value > 0.05 and it is no longer statistically significant*/
proc logistic data = merged5 desc;
	class eversmoke gender race education;
	model heartattack = eversmoke cholesterol logbmi gender race education logage logglucose logagestart;
run;

/*remove logglucose because its p-value > 0.05 and it is no longer statistically significant*/
proc logistic data = merged5 desc;
	class eversmoke gender race education;
	model heartattack = eversmoke cholesterol logbmi gender race education logage logagestart;
run;

/*remove logagestart because its p-value > 0.05 and it is no longer statistically significant*/
proc logistic data = merged5 desc;
	class eversmoke gender race education;
	model heartattack = eversmoke cholesterol logbmi gender race education logage;
run;

/*remove gender because its p-value > 0.05 and it is no longer statistically significant*/
proc logistic data = merged5 desc;
	class eversmoke race education;
	model heartattack = eversmoke cholesterol logbmi race education logage;
run;

/*remove Education because its p-value > 0.05 and it is no longer statistically significant*/
proc logistic data = merged5 desc;
	class eversmoke race;
	model heartattack = eversmoke cholesterol logbmi race logage;
run;

/*remove logbmi because its p-value > 0.05 and it is no longer statistically significant*/
proc logistic data = merged5 desc;
	class eversmoke race;
	model heartattack = eversmoke cholesterol race logage;
run;

/*create dummy variable*/
data merged5; 
	set merged4;
	if race = "Black" then raceb = 1;
	else raceb = 0;
	if race = "Hispanic" then raceh = 1;
	else raceh = 0;
	if race = "White" then racew = 1;
	else racew = 0;
Run;

/*check collinearity (linear regression is used because vif option is not applicable in logistic regression)*/
proc reg data = merged5;
	model heartattack = eversmoke cholesterol raceh racew logage / vif;
run;
quit;

/*Since vif values < 10 for all variables, no variables are highly correlated.
My final model is: heartattack = eversmoke cholesterol race logage*/

/*b*/
/*save model*/
ods pdf file = "\\apporto.com\dfs\NTHW\Users\mhv2108_nthw\Downloads\Model.pdf";
proc logistic data = merged5 desc;
	class eversmoke race;
	model heartattack = eversmoke cholesterol race logage;
run;
ods pdf close;

title2 "Problem 10";
***************************************************************
Problem 10: 
***************************************************************;

/*a*/
/*check goodness of fit*/
proc logistic data = merged5 desc;
	class eversmoke race;
	model heartattack = eversmoke cholesterol race logage / lackfit;
run;

/*Since p-value > 0.05, we fail to reject the null hypothesis and have no evidence of poor fit in the model.*/ 

/*b*/
/*Smoking history is associated with heart attack outcomes. (p = 0.0018)
People without smoking history have 0.56 times the odds of having heart attack compared to those with smoking history. (95% CI 0.39 - 0.81)*/

title2 "Problem 11";
***************************************************************
Problem 11: 
***************************************************************;

/*a*/
/*drop observation*/
data merged6 (keep = seqn cholesterol gender race bmi diabetes raceb raceh racew);
	set merged5;
	if eversmoke ^= 1 then delete;
run;

/*create plot*/
title1 "Scatterplot of Cholesterol vs. BMI by Gender";
proc sgplot data = merged6;
	scatter y = cholesterol x = bmi / 
	group = gender markerattrs = (symbol = trianglefilled);
	yaxis label = "Cholesterol (mg/dL)";
	xaxis label = "BMI (kg/m^2)";
run;

/*b*/
/*create dummy variable*/
data merged7;
	set merged6;
	if 0 <= bmi < 18.5 then Underweight = 1; 
	else Underweight = 0;
	if 18.5 <= bmi < 25 then Normalweight = 1; 
	else Normalweight = 0;
	if 25 <= bmi < 30 then Overweight = 1; 
	else Overweight = 0;
	if 30 <= bmi then Obese = 1; 
	else Obese = 0;
run;

/*c*/
/*create dummy variable (dummy variable for race is created in Problem 9 Part a)*/
data merged8;
	set merged7;
	if gender = 1 then genderm = 1;
	else genderm = 0;
	if gender = 2 then genderf = 1;
	else genderf = 0;

	if diabetes = 1 then diabetesy = 1;
	else diabetesy = 0;
	if diabetes = 0 then diabetesn = 1;
	else diabetesn = 0;
run;

/*d*/
/*create model*/
proc reg data = merged8;
	model cholesterol = genderm raceb raceh underweight overweight obese diabetesy;
run;
quit;

/*e*/
/*check collinearity*/
proc reg data = merged8;
	model cholesterol = genderm raceb raceh underweight overweight obese diabetesy / vif;
run;
quit;

/*Since vif values < 10 for all variables, no variables are highly correlated.*/

/*f*/
/*Normality is satisfied because there is no large deviation from the straight line in the QQ-plot.
Constant variance is satisfied because blobs are centered around 0 and there is no pattern.
Independence is satisfied because each observation is a single participant.*/

/*g*/
/*check influential point*/
proc reg data = merged8;
	model cholesterol = genderm raceb raceh underweight overweight obese diabetesy;
	output out = Diagnostics COOKD = Cooks;
run;
quit;
Proc means Data = Diagnostics;
	Where Cooks > 4 / 1157;
	var seqn;
Run;

/*There are 51 influential points.*/

/*h*/
/*Remove influential point*/
data Diagnostics2;
	set Diagnostics;
	if Cooks > 4 / 1157 then delete;
run;

/*re-run model*/
proc reg data = Diagnostics2;
	model cholesterol = genderm raceb raceh underweight overweight obese diabetesy;
run;
quit;

/*The beta estimate for male vs. female increases from -21.20 to -19.65 after removing influential points. Its significance does not change. (p < 0.05)
The beta estimate for black vs. white increases from -4.14 to -3.96 after removing influential points. Its significance does not change. (p > 0.05)
The beta estimate for hispanic vs. white increases from 9.28 to 10.97 after removing influential points. Its significance does not change. (p < 0.05)
The beta estimate for underweight vs. normal weight increases from 2.72 to 6.10 after removing influential points. Its significance does not change. (p > 0.05)
The beta estimate for overweight vs. normal weight decreases from 2.53 to 1.46 after removing influential points. Its significance does not change. (p > 0.05)
The beta estimate for obese vs. normal weight decreases from 1.09 to -0.42 after removing influential points. Its significance does not change. (p > 0.05)
The beta estimate for diabetes vs. no diabetes decreases from -22.02 to -24.93 after removing influential points. Its significance does not change. (p < 0.05)*/
