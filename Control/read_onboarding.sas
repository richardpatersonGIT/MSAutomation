

%macro read_excel(sheetname=);

proc import out= &sheetname replace

    datafile = "&root\&onboarding\onboarding.xls"

    dbms = xls;

    sheet = "&sheetname";

    getnames = yes;

run;

%mend read_excel;

%read_excel(sheetname=onboarding);
%read_excel(sheetname=schedule);
/*%read_Excel(sheetname=healthcheck_configuration);*/
/*%read_excel(sheetname=customer);*/
/*%read_excel(sheetname=installation);*/
/*%read_excel(sheetname=solution);*/
/*%read_excel(sheetname=host_server);*/
/*%read_excel(sheetname=site);*/
/*%read_excel(sheetname=healthcheck_definition);*/
/*%read_excel(sheetname=schedule_flow);*/
/*%read_excel(sheetname=connections);*/



