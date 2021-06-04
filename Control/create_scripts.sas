

/* query all healthchecks to be performed */

proc sql;
     create table execution as
     select customer, solution, host_name, configuration_name, configuration_directory, schedule_directory, frequency, healthcheck, param1, param2, param3, param4
     from &syslast
	 where active=1
	 order by customer, solution, host_name, configuration_name, 
              configuration_directory,
              healthcheck;
quit;

data execution;
  set execution;
  by customer solution host_name configuration_name configuration_directory healthcheck ;
  if first.healthcheck then schedule_seq=0; 
  schedule_seq+1;
run;

/* copy templates to project directory */


/* create directories for storing execution scripts */

options dlcreatedir;
%MACRO initialize_environment;

/* customer/solution/host */

proc sql;
     select distinct translate(strip(customer),'_',' '), 
     catt(translate(strip(customer),'_',' '),"\",catt(translate(strip(solution),'_',' '))), 
	 catt(translate(strip(customer),'_',' '),"\",catt(translate(strip(solution),'_',' ')),"\",translate(strip(host_name),'_',' '))
     
	 into :customer1-, :customersolution1-, :hostname1-
     from execution;
quit;
%put &=customersolution1;
%do i=1 %to &sqlobs;
    %put "&root\&output\&&customer&i";
    %put "&root\&output\&&customersolution&i";
    %put "&root\&output\&&hostname&i";
	libname customer ("&root\&output\&&customer&i", 
                      "&root\&output\&&customersolution&i", 
                      "&root\&output\&&hostname&i",
                      "&root\&output\&&hostname&i\Daily",
				      "&root\&output\&&hostname&i\Monthly",
					  "&root\&output\&&hostname&i\HealthcheckLibrary_local",
					  );
%end;

%MEND initialize_environment;

%initialize_environment;


%MACRO create_healthcheck_call_scripts;
data control;
  set execution;
  hostdirectory=catt("&root.\&output\",translate(strip(customer),'_',' '),
                      "\",catt(translate(strip(solution),'_',' ')),
                      "\",translate(strip(host_name),'_',' '));
  batchfile=catt(hostdirectory,'\', frequency, '\',healthcheck,"_",configuration_name,"_",schedule_seq,'.bat');
  batchfileoutput=catt(healthcheck,"_",configuration_name,"_",schedule_seq,'.txt');
  if upcase(configuration_name)='FOUNDATION' then compute=quote(catt(configuration_directory,"\SASFoundation\9.4\sas.exe"));
  else if upcase(substr(configuration_name,1,3))='LEV' then compute=quote(catt(configuration_directory,"\SASApp\BatchServer\sasbatch.bat"));
  configuration_directory=quote(strip(configuration_directory));
  put compute=;
  put configuration_directory=;
  file script filevar=batchfile;
  put "call " schedule_directory +(-1) "\healthchecklibrary_local\" healthcheck +(-1) ".bat " schedule_directory +(-1) "\" frequency +(-1) "\\" +(-1) batchfileoutput compute configuration_directory param1 param2 param3 param4 +(-1);	
run;

proc sql noprint;
  create table control2 as select distinct healthcheck,hostdirectory
  from control;
quit;



%MEND create_healthcheck_call_scripts;




%MACRO cleanup_previous_run;

data _null_;
   call symput('tmp', sysget('TEMP'));
run;

filename tmp "&tmp\rm.bat"; 

data _null_;
  file tmp linesize=300;
  set execution;
  hostdirectory=catt("&root.\&output\",translate(strip(customer),'_',' '),
                      "\",catt(translate(strip(solution),'_',' ')),
                      "\",translate(strip(host_name),'_',' '));
  put "del " hostdirectory +(-1) "\healthchecklibrary_local\*.bat /Q";
  put "del " hostdirectory +(-1) "\Daily\*.* /Q";
  put "del " hostdirectory +(-1) "\Monthly\*.* /Q";
  i=sleep(1);
run;

x "&tmp\rm.bat";

%MEND cleanup_previous_run;


%MACRO copy_HC_to_local_deployment;

data _null_;
   call symput('tmp', sysget('TEMP'));
run;

filename tmp "&tmp\copy.bat"; 

data _null_;
  file tmp linesize=300;
  set control2;
  put "copy &root\&hc_library\" healthcheck +(-1) ".bat " hostdirectory +(-1) "\healthchecklibrary_local\" healthcheck +(-1) ".bat"; 
  i=sleep(1);
run;

x "&tmp\copy.bat";

%MEND copy_HC_to_local_deployment;




%initialize_environment;
%cleanup_previous_run;
%create_healthcheck_call_scripts;
%copy_HC_to_local_deployment;

