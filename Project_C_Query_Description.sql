--PART C. Query 

COLUMN Make FORMAT A20
SELECT Make,Capacity, Report_Count,TO_CHAR(Revenue,'$99999990.99') Total_Revenue,
		TO_CHAR(NVL((RATIO_TO_REPORT(Revenue) OVER()), 0) * 100,'999990.99') "REVENUE(%)"
FROM(SELECT Make,Capacity, COUNT(DISTINCT ReportNum) AS Report_Count,
		SUM((ReturnDate- StartDate)* DailyRate) Revenue
		FROM VEHICLE JOIN RAGREEMENT USING (LicenseNo)
				JOIN FAULTREPORT USING (LicenseNo)
GROUP BY Make, Capacity)			
ORDER BY Revenue DESC;
--



COLUMN Make FORMAT A20
SELECT Make,Capacity, Report_Count,TO_CHAR(Revenue,'$99999990.99') Total_Revenue,
		Y2021,Y2022,
		TO_CHAR(NVL((RATIO_TO_REPORT(Revenue) OVER()), 0) * 100,'999990.99') "REVENUE(%)"
FROM(SELECT Make,Capacity, COUNT(DISTINCT ReportNum) AS Report_Count,
		SUM((ReturnDate- StartDate)* DailyRate) Revenue
		FROM VEHICLE JOIN RAGREEMENT USING (LicenseNo)
				JOIN FAULTREPORT USING (LicenseNo)
GROUP BY Make, Capacity)			
ORDER BY Revenue DESC;



SELECT Make,Capacity, COUNT(DISTINCT ReportNum) AS Report_Count,
		SUM((ReturnDate- StartDate)* DailyRate) Y2021,Y2022
		FROM VEHICLE JOIN RAGREEMENT USING (LicenseNo)
				JOIN FAULTREPORT USING (LicenseNo)
				JOIN (SELECT Make,Capacity, COUNT(DISTINCT ReportNum) AS Report_Count,
						SUM((ReturnDate- StartDate)* DailyRate) Y2022
						FROM VEHICLE JOIN RAGREEMENT USING (LicenseNo)
									JOIN FAULTREPORT USING (LicenseNo)
						WHERE EXTRACT(YEAR from ReturnDate) in (2022)
						GROUP BY Make, Capacity)
WHERE EXTRACT(YEAR from ReturnDate) in (2021)
GROUP BY Make, Capacity;

;

--------------------------------------------
--Question, Query, Result, explanation 

--Q1.Which outlets get the best revenue versus employee numbers?
--For year-end bonus calculation

--A1.Get revenues of each outlets, 
--employee number of each outlets, 
--revenue versus emp_number,
--percentage of revenue versus emp_number

--1.
--TOTAL SUM OF Revenues_per_Employee($) = 5824, 1/5824*100% = 1/58.24
--2.
SELECT outNo,  NVL(Revenues,0) "Revenues", NVL(Employee_Number,0) "Employee_Number", 
		ROUND(NVL(Revenues/Employee_Number,0),0) "Revenues_per_Employee($)", 
		ROUND(NVL(Revenues/Employee_Number,0)/58.24,0) "Percentage(%)"
FROM OUTLET LEFT JOIN (SELECT outNo, SUM((ReturnDate- StartDate)* DailyRate) Revenues
						FROM VEHICLE JOIN RAGREEMENT USING (LicenseNo)
						GROUP BY outNo)
			USING (outNo)
			LEFT JOIN (SELECT outNo, COUNT(EmpNo) Employee_Number
						FROM OUTLET JOIN EMPLOYEE USING (OutNo)
						GROUP BY outNo)
			USING (outNo)
ORDER BY  "Percentage(%)" DESC;
			

-------------
--Q3.Analyze sales of each vehicle maker and capacity for the past years of each outlet to develop strategies for future purchases of vehicles from the head quarter.  
--Also, list the daily rate for each vehicle maker.

--A3.
--Table1:lists the sales groups by the vehicle maker of each outlet. 

COLUMN  CAPACITY FORMAT '9990'
COLUMN  DAILYRATE FORMAT '9990'
COLUMN  INSPECTION FORMAT '9990'
COLUMN  OUTNO FORMAT '99999'

SELECT outNo, Make, NVL(Sales,0) "Sales"
FROM OUTLET LEFT JOIN (SELECT outNo,Make, SUM((ReturnDate- StartDate)* DailyRate) Sales
						FROM VEHICLE JOIN RAGREEMENT USING (LicenseNo)
						GROUP BY outNo,Make)
			USING (outNo)
ORDER BY outNo,"Sales" DESC;


--Table2:lists the sales groups by the capacity of each outlet. The list is sorted by outlet number first and then by capacity.
SELECT outNo, Capacity, SUM(NVL(Sales,0)) "Sales"
FROM OUTLET LEFT JOIN (SELECT outNo,Capacity, SUM((ReturnDate- StartDate)* DailyRate) Sales
						FROM VEHICLE JOIN RAGREEMENT USING (LicenseNo)
						GROUP BY outNo,Capacity)
			USING (outNo)
GROUP BY outNo, Capacity
ORDER BY Capacity DESC, "Sales" DESC;

--------------------Final

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 255
SET PAGESIZE 999

COLUMN  CAPACITY FORMAT '9990'
COLUMN  DAILYRATE FORMAT '9990'
COLUMN  INSPECTION FORMAT '9990'
COLUMN  OUTNO FORMAT '99999'
--------
SELECT TO_CHAR(outNo) AS OutletNo, Make, NVL(Sales,0) "Sales"
FROM OUTLET LEFT JOIN (SELECT outNo,Make, SUM((ReturnDate- StartDate)* DailyRate) Sales
						FROM VEHICLE JOIN RAGREEMENT USING (LicenseNo)
						GROUP BY outNo,Make)
			USING (outNo)
UNION
SELECT 'TOTAL SALES',MAKE, Sum(NVL(Sales,0)) "Sales"
FROM OUTLET LEFT JOIN (SELECT outNo,Make, SUM((ReturnDate- StartDate)* DailyRate) Sales
						FROM VEHICLE JOIN RAGREEMENT USING (LicenseNo)
						GROUP BY outNo,Make)
			USING (outNo)
WHERE MAKE = 'Mercedes-Benz'
GROUP BY 'TOTAL SALES',MAKE
UNION
SELECT 'TOTAL SALES',MAKE, Sum(NVL(Sales,0)) "Sales"
FROM OUTLET LEFT JOIN (SELECT outNo,Make, SUM((ReturnDate- StartDate)* DailyRate) Sales
						FROM VEHICLE JOIN RAGREEMENT USING (LicenseNo)
						GROUP BY outNo,Make)
			USING (outNo)
WHERE MAKE = 'Toyota'
GROUP BY 'TOTAL SALES',MAKE
ORDER BY outNo;
-----------------------------



