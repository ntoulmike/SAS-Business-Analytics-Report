/*CSV LOAD  */
proc import file='/home/u59859401/sasuser.v94/Task2/players_stats_by_season_full_details.csv'
	out=task2
	dbms=csv
	replace;
	delimiter=";";
run;
/*CSV LOAD  */

/* Data Pre-Processing */
data task2keep;
	set task2;
	drop draft_team nationality high_school birth_year birth_month
	birth_date League Stage Player Team height season draft_round draft_pick weight;
	rename height_cm=HEI weight_kg=WEI draft_round=DRR draft_pick=DRP;
run;
proc print data=task2keep;
run;
/* Data Pre-Processing */

/*EFFICIENCY */
libname task2 '/home/u59859401/sasuser.v94/Task2';
sasfile task2keep load;
proc print data=task2keep;
run;
sasfile task2keep close;
/*EFFICIENCY */

/*FINDING HOW MANY MISSING VALUES THERE ARE*/
proc means data=task2keep N NMISS ;
VAR GPP MIN FGM FGA TPM TPA FTM FTA TOV PF ORB DRB REB AST STL BLK PTS HEI WEI;
RUN;
/*FINDING HOW MANY MISSING VALUES THERE ARE*/

/*DELETING OBSERVATIONS WITH MISSING VLAUES*/
Data task2keepclean;
	set task2keep;
	array var _numeric_;
	do over var;
		if missing(var) then delete;
	end;
run;
/*DELETING OBSERVATIONS WITH MISSING VLAUES*/

/* CHECKING FOR ANY MISSING VALUES AGAIN */
proc means data=task2keepclean N NMISS ;
VAR GPP MIN FGM FGA TPM TPA FTM FTA TOV PF ORB DRB REB AST STL BLK PTS HEI WEI;
RUN;
/* CHECKING FOR ANY MISSING VALUES AGAIN */

/*CANNONICAL CORRELATION */
proc cancorr data=task2keepclean all;
var GPP;
with MIN FGM FGA TPM TPA FTM FTA TOV PF ORB DRB REB AST STL BLK PTS HEI WEI;
RUN;
/*CANNONICAL CORRELATION */

/* DROP HEI WEI */
Data task2keepclean2;
	set task2keepclean;
	drop WEI HEI;
run;
/* DROP HEI WEI */

/*SPLITING*/
proc surveyselect data=task2keepclean2 rate=0.7
out= select outall
method=SRS;
run;
data train test;
	set select;
	if selected=1 then output train;
	else output test;
run;
/*SPLITING*/

/*LINEAR REGRESSION MODEL */
ods noproctitle;
ods graphics;
proc glmselect data=train outdesign(addinputvars)=Work.reg_design 
		plots=(criterionpanel);
	model GPP=MIN FGM FGA TPM TPA FTM FTA TOV PF ORB DRB REB AST STL BLK PTS / 
		showpvalues selection=backward
    
   (slstay=0.05 select=sl stop=sl) details=steps;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=all PLOTS(MAXPOINTS=50000);
	ods select DiagnosticsPanel ResidualPlot RStudentByPredicted DFFITSPlot 
		DFBETASPanel ObservedByPredicted;
	model GPP=&_GLSMOD /;
	output out=work.Reg_stats0001 p=p_ r=r_;
	run;
quit;
/*LINEAR REGRESSION MODEL */




