PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_SCHEDULE AS 
   SELECT DISTINCT t1.Customer, 
          t1.Solution, 
          t1.Tier, 
          t1.Host_Name, 
          t1.Configuration_Name, 
          t1.Healthcheck, 
          t1.Param1, 
          t1.Param2, 
          t1.Param3, 
          t1.Param4, 
          t1.Active, 
		  t2.schedule_directory,
          t2.Configuration_directory
      FROM WORK.SCHEDULE t1
           LEFT JOIN WORK.ONBOARDING t2 ON (t1.Customer = t2.Customer) AND (t1.Solution = t2.Solution_Name) AND 
          (t1.Configuration_Name = t2.Configuration_name)
      WHERE t1.Active = 1;
QUIT;
