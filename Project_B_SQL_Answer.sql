--PART B. SQL Answer
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 255
SET PAGESIZE 999

--Question 1
SELECT clientno,
	 fname || ' ' || lname AS name,
	 rentalno,
	 startdate,
	 ROUND((returndate - startdate)*24,0) AS duration,
	 TO_CHAR(Round(returndate - startdate)*dailyrate, '$999990.99') AS rentalcost 
FROM client JOIN ragreement USING (clientno)
		JOIN vehicle USING (licenseno)
WHERE UPPER(state) = 'PA'
ORDER BY name, startdate;

--Question2
COLUMN Name FORMAT A20
SELECT EmpNo, FName || ', ' || LName Name, NVL(count(ReportNum),0)  Fault_Reports, 
		Dense_RANK () OVER (ORDER BY NVL(count(ReportNum),0) DESC) RANK
FROM EMPLOYEE LEFT JOIN FAULTREPORT USING (EmpNo)
GROUP BY EmpNo, FName || ', ' || LName
ORDER BY Fault_Reports DESC;

--Question 3
SELECT outno,
	 COUNT(rentalno) AS numofrental,
	 TO_CHAR(SUM((returndate - startdate)*dailyrate), '$999990.99') AS revenue,
	 Dense_RANK () OVER (ORDER BY SUM((returndate - startdate)*dailyrate) DESC) RANK
FROM outlet JOIN vehicle USING (outno)
		JOIN ragreement USING (licenseno)
GROUP BY outno
ORDER BY revenue DESC
FETCH FIRST 2 ROWS ONLY;

--Question4
SELECT RentalNo, StartDate, ReturnDate, clientNo, Fname, Lname, OUTLET.Street
FROM RAGREEMENT JOIN CLIENT USING (clientNo)
				JOIN VEHICLE USING (LicenseNo)
				JOIN OUTLET USING (outNo)
WHERE  outNo = (SELECT outNo
					FROM RAGREEMENT JOIN VEHICLE USING (LicenseNo)
									JOIN OUTLET USING (outNo)
					GROUP BY outNo
					HAVING COUNT(RentalNo) = (SELECT MAX(RentalCount) 
												FROM(SELECT outNo,COUNT(RentalNo) AS RentalCount
														FROM RAGREEMENT JOIN VEHICLE USING (LicenseNo)
																		JOIN OUTLET USING (outNo)
														GROUP BY outNo) t1))
ORDER BY RentalNo; 

--Question 5
SELECT clientno,
	 fname || ' ' || lname AS name,
	 NVL(COUNT(rentalno),0) AS numofrentals,
	 NVL(reports, 0) AS numofreports
FROM client LEFT OUTER JOIN (SELECT rentalno, clientno, COUNT(reportnum) AS reports
				     FROM ragreement JOIN faultreport USING (rentalno)
				     GROUP BY rentalno, clientno) USING (clientno)
GROUP BY clientno, fname, lname, reports
ORDER BY clientno;

SELECT clientno, fname || ' ' || lname AS name,NVL(reports,0),NVL(Mileage_Avg,0),NVL(numofrentals,0)
FROM client LEFT JOIN(SELECT clientno, AVG(MileageAfter-MileageBefore) Mileage_Avg,NVL(COUNT(rentalno),0) AS numofrentals
				     FROM ragreement JOIN faultreport USING (rentalno)
					 JOIN CLIENT USING(clientNo)
				    GROUP BY clientno) USING (clientNo
ORDER BY clientno;


 NVL(COUNT(reportnum),0) AS reports

--Question6
SELECT OutNo, Make, TO_CHAR(COUNT(LicenseNo)) Rentals
FROM OUTLET JOIN VEHICLE USING (OutNo) 
		JOIN RAGREEMENT USING (LicenseNo)         
GROUP BY OutNo,Make
ORDER BY OutNo, Make; 
----
SELECT NVL(TO_CHAR(outNo), '~~~~~') OutNo,
NVL(Make, LPAD('TOTAL:',15,'~')) Make,
TO_CHAR(SUM((ReturnDate- StartDate)* DailyRate), '$999990.99') Sales,
TO_CHAR(COUNT(LicenseNo)) NumOfRent
FROM OUTLET JOIN VEHICLE USING (OutNo)
 		     JOIN RAGREEMENT USING (LicenseNo)
GROUP BY CUBE(OutNo,Make)
ORDER BY OutNo, Make;



--Question 7
SELECT fname || ' ' || lname AS managername,
	 numofoutlets,
	 SUM(employees) AS numofemployees,
	 SUM(vehicles) AS numofvehicles
FROM (SELECT empno, fname, lname, outno
	FROM employee
	WHERE empno IN (SELECT managerno
			    FROM outlet)) m LEFT OUTER JOIN (SELECT managerno, COUNT(empno) AS employees
					 			       FROM outlet JOIN employee USING (outno)
								       GROUP BY managerno) e ON m.empno = e.managerno
		  				  LEFT OUTER JOIN (SELECT managerno, COUNT(licenseno) AS vehicles
					 			       FROM outlet JOIN vehicle USING (outno)
					 			       GROUP BY managerno) v ON m.empno = v.managerno
						  LEFT OUTER JOIN (SELECT managerno, COUNT(outno) AS numofoutlets
									 FROM outlet
									 GROUP BY managerno) o ON m.empno = o.managerno
GROUP BY fname, lname, numofoutlets;

-----------------------
--TABLE 1
SELECT outNo, Make, NVL(count(RentalNo),0)  Outlet_VehicleMake_TotalRentalNo
FROM RAGREEMENT JOIN VEHICLE USING (LicenseNo)
				JOIN OUTLET USING (outNo)
GROUP BY outNo, Make
ORDER BY outNo, Outlet_VehicleMake_TotalRentalNo DESC;

--TABLE 2
SELECT outNo, Make, NVL(count(RentalNo),0)  Outlet_VehicleMake_TotalRentalNo
FROM RAGREEMENT JOIN VEHICLE USING (LicenseNo)
				JOIN OUTLET USING (outNo)
GROUP BY outNo, Make
ORDER BY Make, Outlet_VehicleMake_TotalRentalNo DESC;

--Decision making strategy:
--First of all, we can create two tables. 
--The first table lists rental total amount group by outlet and vehicle make. 
--The list are sorted by outlet number first, and then by total rental number.
--The differencence in second table is ordered by vehicle maker first, and then total rental number.  
--In this way, we can decide different approach according to purchase strategy.
--If the company plan to purchase the car amounts of different types, they can see first table and purchase more cars from the maker which gets more rental.
--For example, if outlet A gets higher rental number with vehicles made from Tesla, then we should purchase more Tesla vehicles in outlet A.
--Another way to plan it is that if the company already has longer term contracts with each vehicle maker,which means fixed car purchase amount of each makers,
-- 		then we can see the second tables to decide how to put those car into each outlet.  
--For example, if the vehicle made by Tesla gets higher rental number in outlet A, then we should let outlet A purchase more vehicles made by Tesla.

--220725 update


--Question8

COLUMN Revenue FORMAT $99990.99
COLUMN City FORMAT 'A20'
SELECT OutNo, Street, City, COUNT(LicenseNo) VEHICLE_COUNT, NVL(Revenue, 0) Revenue,
		TO_CHAR(NVL((RATIO_TO_REPORT(Revenue) OVER()), 0) * 100,'990.99') "Percent_Score"
FROM OUTLET LEFT JOIN(SELECT OutNo, NVL(SUM((ReturnDate- StartDate)* DailyRate),0) Revenue
						FROM OUTLET JOIN VEHICLE USING (OutNo) 
									JOIN RAGREEMENT USING (LicenseNo)  
									WHERE EXTRACT(YEAR from startdate) = EXTRACT(YEAR from SYSDATE)	
									AND EXTRACT(MONTH from startdate) IN (4, 5, 6)
									GROUP BY OutNo
						) USING (OutNo) 
				JOIN VEHICLE USING (OutNo)
GROUP BY OutNo, Street, City,Revenue
ORDER BY Revenue DESC;


--Question 9
SELECT NVL(TO_CHAR(outno),'TOTALRENTAL') AS outno,
	 SUM((CASE WHEN EXTRACT(MONTH from startdate) IN (1, 2, 3) THEN 1 ELSE 0 END)) AS "Q1",
	 SUM((CASE WHEN EXTRACT(MONTH from startdate) IN (4, 5, 6) THEN 1 ELSE 0 END)) AS "Q2",
	 COUNT(rentalno) AS totalperoutlets
FROM outlet JOIN vehicle USING (outno)
		JOIN ragreement USING (licenseno)
WHERE EXTRACT(YEAR from startdate) = EXTRACT(YEAR from SYSDATE)
GROUP BY GROUPING SETS (outno,())
ORDER BY outno;