/******************** Homework 2 - Complex Sampling Methods ********************/
libname homework "C:/Irene Hsueh's Documents/MS Applied Biostatistics/BS 728 - Public Health Surveillance/Class 2 - Sampling/Homework 2";
proc format;
	value $sex_format "M"="Male" "F"="Female";
	value age_cat_format 0="0-4 Years" 1="5-14 Years" 2="15-39 Years" 3=">40 Years";
	value $bmi_format "malnourished"="Malnourished" "underweight"="Underweight" "healthy"="Healthy" "overweight"="Overweight" "obese"="Obese";
	value format 0="No" 1="Yes";
run;

data dhs;
	set homework.dhs_india;
	drop sex cookingfuel smoking;
	rename gender=sex;
	id=_n_;

	attrib 
		id				label="ID"
		hv005			label="National Household Weight"
		hv022			label="Sample Stratum Number"
		sh021			label="Primary Sampling Unit"
		wgtdhs			label="Weighting Variable"
		gender			label="Sex"								format=$sex_format.
		age				label="Age"								
		age_cat			label="Age Category"					format=age_cat_format.
		bmi				label="BMI"								
		bmi_cat			label="BMI Category"					format=$bmi_format.
		tb				label="Tuberculosis"					format=format.
		smoker			label="Smoker"							format=format.
		windows			label="Windows at Home"					format=format.
		wood_fuel		label="Wood Fuel Used in Cooking"		format=format.
	;
	set homework.dhs_india;
run;


title "DHS India Data";
proc print data=dhs (obs=20) label
	style(header) = {just=center verticalalign=middle};
	id id;
run;
title;




ODS HTML close;
ODS HTML;




/* Unweighted Analysis */
title "Overall Descriptive Statistics";
proc freq data=dhs;
	tables sex age_cat bmi_cat tb smoker windows wood_fuel / nocum;
run;
title;

title "Overall Descriptive Statistics";
proc means data=dhs mean std clm;
	var age bmi;
run;
title;


proc sort data=dhs;
	by tb;
run;

title "Descriptive Statistics by TB Status";
proc freq data=dhs;
	tables tb*(sex age_cat bmi_cat smoker windows wood_fuel) / nocol nopercent nocum chisq;
run;
title;

title "Descriptive Statistics by TB Status";
proc means data=dhs mean std clm;
	class tb;
	var age bmi;
run;

proc ttest data=dhs;
	class tb;
	var age bmi;
run;
title;


title "Multivariate Logstic Regression";
proc logistic data=dhs descending;
	class tb (ref="No") sex (ref="Male") age_cat (ref=">40 Years") windows (ref="No") wood_fuel (ref="No") / param=ref;
	model tb (event="Yes") = sex age_cat windows wood_fuel / risklimits cl;
run;
title;




ODS HTML close;
ODS HTML;




/* Weighted Analysis */
title "Overall Descriptive Statistics for Weighted Data";
proc surveyfreq data=dhs;
	weight wgtdhs;
	stratum hv022;
	cluster sh021;
	tables sex age_cat bmi_cat tb smoker windows wood_fuel;
run;
title;

title "Overall Descriptive Statistics for Weighted Data";
proc surveymeans data=dhs;
	weight wgtdhs;
	stratum hv022;
	cluster sh021;
	var age bmi;
run;
title;


title "Descriptive Statistics by TB Status for Weighted Data";
proc surveyfreq data=dhs;
	weight wgtdhs;
	stratum hv022;
	cluster sh021;
	tables tb*(sex age_cat bmi_cat smoker windows wood_fuel) / chisq;
run;
title;

title "Descriptive Statistics by TB Status for Weighted Data";
proc surveymeans data=dhs;
	weight wgtdhs;
	stratum hv022;
	cluster sh021;
	domain tb;
	var age bmi;
run;

proc surveyreg data=dhs;
	weight wgtdhs;
	stratum hv022;
	cluster sh021;
	class TB;
	model bmi = TB;
run;

proc surveyreg data=dhs;
	weight wgtdhs;
	stratum hv022;
	cluster sh021;
	class TB;
	model age = TB;
run;
title;


title "Multivariate Logstic Regression for Weighted Data";
proc surveylogistic data=dhs;
	weight wgtdhs;
	stratum hv022;
	cluster sh021;
	class tb (ref="No") sex (ref="Male") age_cat (ref=">40 Years") windows (ref="No") wood_fuel (ref="No") / param=ref;
	model tb (event="Yes") = sex age_cat windows wood_fuel;
run;
title;
