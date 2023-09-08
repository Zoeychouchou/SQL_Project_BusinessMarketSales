--PART A. Script#1

DROP TABLE EMPLOYEE   	CASCADE CONSTRAINTS;
DROP TABLE FAULTREPORT  CASCADE CONSTRAINTS;
DROP TABLE OUTLET 		CASCADE CONSTRAINTS;
DROP TABLE VEHICLE     	CASCADE CONSTRAINTS;
DROP TABLE CLIENT   	CASCADE CONSTRAINTS;
DROP TABLE RAGREEMENT 	CASCADE CONSTRAINTS;

CREATE TABLE CLIENT
(clientNo 	Number(5),
 Fname    	Varchar2(25),
 Lname     	Varchar2(25),
 Phone 		Char(14),
 Email     	Varchar2(25), 
 Street    	Varchar2(25),
 city      	Varchar2(25),
 State     	Char(2),
 Zip_Code  	Char(5),
 CONSTRAINT CLIENT_clientNo_PK  PRIMARY KEY (clientNo),
 CONSTRAINT CLIENT_Phone_ck CHECK (Phone LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
 CONSTRAINT CLIENT_Email_ck CHECK (Email LIKE '%_@_%._%'));
 
CREATE TABLE EMPLOYEE
(EmpNo 		Number(5),
 Fname    	Varchar2(25),
 Lname     	Varchar2(25),
 Position  	Varchar2(20),
 Phone 		Char(14),
 Email     	Varchar2(40), 
 DOB       	Date,
 Gender 	Char(10),
 Salary 	Number(20),
 HireDate  	Date DEFAULT SYSDATE, 
 OutNo 		Number(5),
 Super_No 	Number(5),
 CONSTRAINT Employee_EmpNo_PK  PRIMARY KEY (EmpNo),
 CONSTRAINT Employee_Super_No_FK FOREIGN KEY (Super_No) REFERENCES EMPLOYEE (EmpNo),
 CONSTRAINT Employee_Phone_ck CHECK ((Phone LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')),
 CONSTRAINT Employee_Email_ck CHECK (Email LIKE '%_@heinz.com'),
 CONSTRAINT Employee_DOB_ck CHECK ((HireDate - DOB) > 14),
 CONSTRAINT Employee_Salary_ck CHECK ((Salary > 0)),
 CONSTRAINT Employee_OutNo_nn CHECK ((OutNo IS NOT NULL)));
  
 CREATE TABLE OUTLET
(outNo    	Number(5),
 Street    	Varchar2(25),
 city      	Varchar2(25),
 State     	Char(2),
 Zip_Code  	Char(5),
 Phone 		Char(14),
 ManagerNo 	Number(5),
 CONSTRAINT OUTLET_outNo_PK  PRIMARY KEY (outNo),
 CONSTRAINT OUTLET_ManagerNo_FK FOREIGN KEY (ManagerNo) REFERENCES EMPLOYEE (EmpNo),
 CONSTRAINT OUTLET_Phone_ck CHECK (Phone LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
 CONSTRAINT OUTLET_ManagerNo_nn CHECK (ManagerNo IS NOT NULL)); 
 
 
CREATE TABLE VEHICLE
(LicenseNo  	Number(5),
 Make    		Date DEFAULT SYSDATE,
 Model      	Varchar2(25),
 Color  		Varchar2(25),
 Year 			Number(4),
 NoDoors 		Number(3),
 Capacity 		Number(6),
 DailyRate 		Number(6),
 InspectionDate 	Date DEFAULT SYSDATE,
 outNo 		Number(5),
 CONSTRAINT VEHICLE_LicenseNo  PRIMARY KEY (LicenseNo),
 CONSTRAINT VEHICLE_outNo_FK FOREIGN KEY (outNo) REFERENCES OUTLET (outNo),
 CONSTRAINT VEHICLE_Year_ck CHECK (Year < 10),
 CONSTRAINT VEHICLE_outNo_nn CHECK (outNo IS NOT NULL));
 
 
 CREATE TABLE RAGREEMENT
(RentalNo 		Number(5),
 StartDate 		Date DEFAULT SYSDATE,
 ReturnDate 	Date DEFAULT SYSDATE,
 MileageBefore 	Number(10),
 MileageAfter 	Number(10),
 InsuranceType 	Varchar2(25), 
 ClientNo 		Number(5),
 LicenseNo 		Number(5),
 CONSTRAINT RAGREEMENT_RentalNo_PK  PRIMARY KEY (RentalNo),
 CONSTRAINT RAGREEMENT_ClientNo_FK FOREIGN KEY (ClientNo) REFERENCES CLIENT (ClientNo),
 CONSTRAINT RAGREEMENT_Mileage_ck CHECK (MileageAfter > MileageBefore),
 CONSTRAINT RAGREEMENT_ClientNo_nn CHECK (ClientNo IS NOT NULL),
 CONSTRAINT RAGREEMENT_LicenseNo_nn CHECK (LicenseNo IS NOT NULL));
 
 CREATE TABLE FAULTREPORT
(ReportNum 		Number(5),
 DateChecked 	Date DEFAULT SYSDATE, 
 Comments 		Varchar2(100),
 EmpNo 			Number(5),
 LicenseNo 		Number(5),
 RentalNo 		Number(5),
 CONSTRAINT FAULTREPORT_ReportNum_PK  PRIMARY KEY (ReportNum),
 CONSTRAINT FAULTREPORT_EmpNo_FK FOREIGN KEY (EmpNo) REFERENCES EMPLOYEE (EmpNo),
 CONSTRAINT FAULTREPORT_LicenseNo_FK FOREIGN KEY (LicenseNo) REFERENCES VEHICLE (LicenseNo),
 CONSTRAINT FAULTREPORT_RentalNo_FK FOREIGN KEY (RentalNo) REFERENCES RAGREEMENT (RentalNo),
 CONSTRAINT FAULTREPORT_EmpNo_nn CHECK (EmpNo IS NOT NULL),
 CONSTRAINT FAULTREPORT_LicenseNo_nn CHECK (LicenseNo IS NOT NULL),
 CONSTRAINT FAULTREPORT_RentalNo_nn CHECK (RentalNo IS NOT NULL));

 
ALTER TABLE RAGREEMENT
ADD CONSTRAINT RAGREEMENT_LicenseNo_FK FOREIGN KEY (LicenseNo) REFERENCES VEHICLE (LicenseNo);
ALTER TABLE EMPLOYEE
ADD CONSTRAINT Employee_OutNo_FK FOREIGN KEY (OutNo) REFERENCES OUTLET (OutNo);









