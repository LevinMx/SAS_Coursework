***************************************************************
*** Program Name: PH 305 Midterm Exam
*** Author: Minxing Huang 
*** Initial Date: 10/25/2023
*** Last Updated: 10/27/2023
*** Description: This is the code file for Midterm Exam
***************************************************************;

/***********************************************************/

***   change log   ***

* Here, we can track changes/versions of the code if we 
* create multiple versions over time;


/***********************************************************/
title1 "Class: PH 305  Program: Midterm";
options ls = 105 ps = 64 nofmterr nodate;



title2 "Problem 1";
***************************************************************
1.
***************************************************************;

/*a*/
/*import data*/
libname class "\\apporto.com\dfs\NTHW\Users\mhv2108_nthw\Desktop\SAS";
data demo;
	set class.demo;
run;
data cbc;
	set class.cbc;
run;
data bp;
	set class.bp;
run;
data nbp;
	set class.newbp;
run;
data lik;
	set class.lab_id_key;
run;
Proc Import out = bped
	Datafile = "\\apporto.com\dfs\NTHW\Users\mhv2108_nthw\Desktop\SAS\bp_exam_dates.xlsx"
	DBMS = EXCEL REPLACE;
	GETNAMES = YES;
RUN;

/*split "panel" variable*/
data cbc2 (drop = panel panel2 panel3);
	set cbc;
	panel2 = compress(panel, "-");
	panel3 = compress(panel2, ":");
	LBXLYPCT = input(scan(panel3, 1, " "), 8.);
	LBXMOPCT = input(scan(panel3, 2, " "), 8.);
	LBXNEPCT = input(scan(panel3, 3, " "), 8.);
	LBXEOPCT = input(scan(panel3, 4, " "), 8.);
	LBXBAPCT = input(scan(panel3, 5, " "), 8.);
	LBXPLTSI = input(scan(panel3, 6, " "), 8.);
run;

/*print variable*/
proc contents data = demo;
run;
proc contents data = cbc2;
run;
proc contents data = bp;
run;
proc contents data = nbp;
run;
proc contents data = bped;
run;
proc contents data = lik;
run;

/*b*/
/*identify error and missing for "Exam_date" variable*/
data bped2;
	set bped;
	format Exam_date date9.;
run;
proc sort data = bped2;
	by Exam_date;
run;
proc print data = bped2 (obs = 10);
run;
proc sort data = bped2;
	by descending Exam_date;
run;
proc print data = bped2 (obs = 10);
run;

/*identify error and missing*/
proc print data = demo;
	where SEQN < 62161 or SEQN > 71916 or
		  RIASEX not in ("Male", "Female") or
		  RIDAGEYR < 0 or RIDAGEYR > 80 or
		  (RIDAGEMN not in (.) and RIDAGEMN < 0) or RIDAGEMN > 24 or
		  RIDRETH1 not in (1, 2, 3, 4, 5, .) or
		  DMDEDUC2 not in (1, 2, 3, 4, 5, 7, 9, .) or
		  DMDMARTL not in (1, 2, 3, 4, 5, 6, 77, 99, .) or
		  RIDEXPRG not in (1, 2, 3, .);
run;
proc print data = cbc2;
	where Lab_ID < 1 or Lab_ID > 9338 or
		  (LBXLYPCT not in (.) and LBXLYPCT < 3) or LBXLYPCT > 83 or
		  (LBXMOPCT not in (.) and LBXMOPCT < 0.5) or LBXMOPCT > 67 or
		  (LBXNEPCT not in (.) and LBXNEPCT < 0.5) or LBXNEPCT > 97 or
		  (LBXEOPCT not in (.) and LBXEOPCT < 0) or LBXEOPCT > 29 or
		  (LBXBAPCT not in (.) and LBXBAPCT < 0) or LBXBAPCT > 14 or
		  (LBXPLTSI not in (.) and LBXPLTSI < 13) or LBXPLTSI > 700;
run;
proc print data = bp;
	where SEQN < 62161 or SEQN > 71916 or
		  BPAARM not in (1, 2, .) or
		  (BPXSY1 not in (.) and BPXSY1 < 74) or BPXSY1 > 238 or
		  (BPXSY2 not in (.) and BPXSY2 < 74) or BPXSY2 > 238 or
		  (BPXSY3 not in (.) and BPXSY3 < 74) or BPXSY3 > 238 or
		  (BPXSY4 not in (.) and BPXSY4 < 74) or BPXSY4 > 238 or
		  (BPXDI1 not in (.) and BPXDI1 < 60) or BPXDI1 > 134 or
		  (BPXDI2 not in (.) and BPXDI2 < 60) or BPXDI2 > 134 or
		  (BPXDI3 not in (.) and BPXDI3 < 60) or BPXDI3 > 134 or
		  (BPXDI4 not in (.) and BPXDI4 < 60) or BPXDI4 > 134;
run;
proc print data = nbp;
	where SEQN < 62161 or SEQN > 71916 or
		  (BPXSY1 not in (.) and BPXSY1 < 74) or BPXSY1 > 245 or
		  (BPXSY2 not in (.) and BPXSY2 < 74) or BPXSY2 > 245 or
		  (BPXDI1 not in (.) and BPXDI1 < 60) or BPXDI1 > 180 or
		  (BPXDI2 not in (.) and BPXDI2 < 60) or BPXDI2 > 180;
run;
proc print data = bped2;
	where Lab_ID < 1 or Lab_ID > 9338 or
		  Hour < 8 or Hour > 17 or
		  Minute < 0 or Minute > 60;
run;
proc print data = lik;
	where Lab_ID < 1 or Lab_ID > 9338 or
		  SEQN < 62161 or SEQN > 71916;
run;

/*identify duplicate*/
proc freq data = demo
	order = freq;
	table SEQN / maxlevels = 10;
run;
proc freq data = cbc2
	order = freq;
	table Lab_ID / maxlevels = 10;
run;
proc freq data = bp
	order = freq;
	table SEQN / maxlevels = 10;
run;
proc freq data = nbp
	order = freq;
	table SEQN / maxlevels = 10;
run;
proc freq data = bped2
	order = freq;
	table Lab_ID / maxlevels = 10;
run;
proc freq data = lik
	order = freq;
	table Lab_ID SEQN / maxlevels = 10;
run;

/*c*/
/*apply format*/
data demo;
	set demo;
	format RIASEX $8.;
run;
data bped2;
	set bped2;
	format Exam_date date9.;
run;

/*summary:
demo:
4 errors: 2 errors in RIASEX, 1 error in RIDRETH1, 1 error in RIDAGEYR

cbc:
8 errors: 7 errors in LBXLYPCT, 1 error in LBXBAPCT

bp:
4 errors: 1 error in BPXSY1, 1 error in BPXSY2, 1 error in BPXDI1, 1 error in BPXDI2
6 duplicates: 6 duplicates for ID 67761

newbp:
clean

bped:
1 error: 1 error in minute
8 duplicates: 2 duplicates for ID 337, 2 duplicates for ID 338, 2 duplicates for ID 339, 2 duplicates for ID 340

lik:
l error: 1 error in lab_id*/

title2 "Problem 2";
***************************************************************
2.	
***************************************************************;

/*see error report
newbp is clean*/

title2 "Problem 3";
***************************************************************
3.	
***************************************************************;

/*correct error and missing*/
data demo2;
	set demo;
	if SEQN = 64902 or SEQN = 64903 then RIASEX = "Male";
	if SEQN = 68433 then RIDRETH1 = 1;
	if SEQN = 69190 then RIDAGEYR = 80;
	if SEQN = 63046 then RIDAGEMN = 12;
run;
data cbc3;
	set cbc2;
	if lab_id = 101 or lab_id = 102 or lab_id = 103 or lab_id = 104 or lab_id = 105 then lbxlypct = .;
	if lab_id = 514 then lbxlypct = 20.7;
	if lab_id = 4897 then lbxlypct = 63.2;
	if lab_id = 5970 then lbxbapct = 13.4;
run;
data bp2;
	set bp;
	if SEQN = 66077 then do;
	   BPXSY1 = .; 
	   BPXSY2 = .;
	end;
	if SEQN = 66083 then do;
	   BPXDI1 = .; 
	   BPXDI2 = .;
	end;
run;
data bped3;
	set bped2;
	if lab_id = 151 then minute = 4;
run;
data lik2;
	set lik;
	if SEQN = 71779 then lab_id = 8829;
run;

/*delete duplicate*/ 
Proc Sort Data = bp2 nodup;
	By SEQN;
Run;
Proc Sort Data = bped3 nodup;
	By lab_id;
Run;

/*create variable*/
data bp3;
	set bp2;
	asbp = mean(BPXSY1, BPXSY2, BPXSY3, BPXSY4);
	adbp = mean(BPXDI1, BPXDI2, BPXDI3, BPXDI4);
	pp = asbp - adbp;
	format cbp $6.;
	if asbp = . or adbp = . then cbp = "";
	else if asbp < 120 and adbp < 80 then cbp = "Normal";
	else if asbp < 140 and adbp < 90 then cbp = "Prehyp";
	else if asbp < 160 and adbp < 100 then cbp = "HBPS1";
	else cbp = "HBPS2";
run;

/*create table*/
proc freq data = bp3;
	table cbp / nopercent;
run;

title2 "Problem 4";
***************************************************************
4.	
***************************************************************;

/*drop variable*/
data demo3 (drop = RIDAGEMN);
	set demo2;
run;
data cbc4 (keep = lab_id LBXLYPCT LBXMOPCT);
	set cbc3;
run;
data bp4 (keep = seqn asbp adbp pp cbp);
	set bp3;
run;

/*sort and merge data*/
proc sort data = lik2;
	by SEQN;
run;
proc sort data = demo3;
	by SEQN;
run;
proc sort data = bp4;
	by SEQN;
run;
data table;
	merge lik2 demo3 bp4;
	by SEQN;
run;
proc sort data = table;
	by lab_id;
run;
proc sort data = cbc4;
	by lab_id;
run;
data table2;
	merge table cbc4;
	by lab_id;
run;

/*delete observation*/
data table3;
	set table2;
	if seqn = . or lab_id = . or RIDAGEYR < 25 then delete;
run;

/*summarize data*/
proc freq data = table3;
	table RIASEX RIDRETH1 DMDEDUC2 DMDMARTL RIDEXPRG cbp / nocum;
run;
proc means data = table3 mean stddev;
	var RIDAGEYR asbp adbp pp LBXLYPCT LBXMOPCT;
run;

/*see table 1 shell*/

title2 "Problem 5";
***************************************************************
5.	
***************************************************************;

/*drop variable*/
data table4 (drop = lab_id);
	set table3;
run;

/*save data*/
data class.table1;
	set table4;
run;

/*see table 1 dataset*/

title2 "Problem 6";
***************************************************************
6.	
***************************************************************;

/*drop and create variable*/
data bp5 (keep = seqn BPXSY1 BPXSY2 BPXDI1 BPXDI2 visit);
	set bp3;
	visit = "baseline";
run;
data nbp2;
	set nbp;
	visit = "24 weeks";
run;

/*append data*/
data bpall;
	set bp5 nbp2;
run;

title2 "Problem 7";
***************************************************************
7.	
***************************************************************;

/*sort data*/
proc sort data = bpall;
	by seqn;
run;

/*transpose data*/
proc transpose data = bpall
	out = bpall2
	prefix = sbp1_;
	by seqn;
	id visit;
	var BPXSY1;
run;
proc transpose data = bpall
	out = bpall3
	prefix = sbp2_;
	by seqn;
	id visit;
	var BPXSY2;
run;
proc transpose data = bpall
	out = bpall4
	prefix = dbp1_;
	by seqn;
	id visit;
	var BPXDI1;
run;
proc transpose data = bpall
	out = bpall5
	prefix = dbp2_;
	by seqn;
	id visit;
	var BPXDI2;
run;

/*merge data and create variable*/
data bpall6 (drop = _name_ _label_);
	merge bpall2 bpall3 bpall4 bpall5;
	by seqn;
	asbp_baseline = mean(sbp1_baseline, sbp2_baseline);
	asbp_24_weeks = mean(sbp1_24_weeks, sbp2_24_weeks);
	adbp_baseline = mean(dbp1_baseline, dbp2_baseline);
	adbp_24_weeks = mean(dbp1_24_weeks, dbp2_24_weeks);
	asbp_dif = asbp_24_weeks - asbp_baseline;
	adbp_dif = adbp_24_weeks - adbp_baseline;
run;

/*calculate mean*/
proc means data = bpall6 mean;
	var asbp_dif adbp_dif;
run;

/*the average difference in SBP is 4.51
the average difference in DBP is 3.93*/

title2 "Problem 8";
***************************************************************
8.	
***************************************************************;

/*create variable*/
data bpall7 (keep = seqn high_sbp_time high_dbp_time);
	set bpall6;
	high_sbp_time = 0;
	high_dbp_time = 0;
	if sbp1_baseline >= 140 then high_sbp_time = high_sbp_time + 1;
	if sbp1_24_weeks >= 140 then high_sbp_time = high_sbp_time + 1;
	if sbp2_baseline >= 140 then high_sbp_time = high_sbp_time + 1;
	if sbp2_24_weeks >= 140 then high_sbp_time = high_sbp_time + 1;
	if dbp1_baseline >= 90 then high_dbp_time = high_dbp_time + 1;
	if dbp1_24_weeks >= 90 then high_dbp_time = high_dbp_time + 1;
	if dbp2_baseline >= 90 then high_dbp_time = high_dbp_time + 1;
	if dbp2_24_weeks >= 90 then high_dbp_time = high_dbp_time + 1;
run;

/*create table*/
proc freq data = bpall7;
	table high_sbp_time * high_dbp_time;
run;

/*153 people had 4 observations of High SBP and 4 observations of High DBP*/
