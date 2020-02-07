DROP TABLE Employee CASCADE CONSTRAINTS;
DROP TABLE Patient CASCADE CONSTRAINTS;
DROP TABLE Room CASCADE CONSTRAINTS;
DROP TABLE Admission CASCADE CONSTRAINTS;
DROP TABLE Equipment_Type CASCADE CONSTRAINTS;
DROP TABLE Equipment CASCADE CONSTRAINTS;
DROP TABLE Doctor CASCADE CONSTRAINTS;
DROP TABLE Stays_In CASCADE CONSTRAINTS;
DROP TABLE Inspect CASCADE CONSTRAINTS;
DROP TABLE Room_Service CASCADE CONSTRAINTS;
DROP TABLE Room_Access CASCADE CONSTRAINTS;
 
CREATE TABLE Employee(
    EmployeeID INTEGER NOT NULL PRIMARY KEY,
    BossID INTEGER, /* Corresponds to the employee's manager. Gen. manager won't have a boss! */
    Title CHAR(20) NOT NULL,
    First_Name CHAR(30) NOT NULL,
    Last_Name CHAR(30) NOT NULL,
    Salary REAL NOT NULL,   /* Salary per hour */
    empEchelon INTEGER NOT NULL, /* I.E employees rank */
    Office_No VARCHAR2(5) NOT NULL UNIQUE,
    CONSTRAINT chk_empEchelon CHECK (empEchelon = 0 OR empEchelon = 1 OR empEchelon = 2)
);
 
CREATE TABLE Patient(
    SSN VARCHAR2(11) NOT NULL PRIMARY KEY, /* Formatted as ***-**-**** */
    First_Name CHAR(30) NOT NULL,
    Last_Name CHAR(30) NOT NULL,
    Patient_Address VARCHAR2(60),
    Phone_No VARCHAR(12) NOT NULL /* Formatted as ***-***-**** */
);
 
CREATE TABLE Room (
    Room_No VARCHAR2(5) NOT NULL PRIMARY KEY,
    Occupation_Flag INTEGER NOT NULL,
    CONSTRAINT Occupation_Flag CHECK (Occupation_Flag = 0 OR Occupation_Flag = 1)
);
 
CREATE TABLE Admission(
    Admission_ID INTEGER NOT NULL PRIMARY KEY,
    Patient_SSN VARCHAR2(11) NOT NULL,
    Admission_Time DATE NOT NULL,
    Leave_Time DATE NOT NULL,
    Next_Visit DATE,
    Total_Payment REAL NOT NULL,
    Insurance_Payment REAL NOT NULL,
    CONSTRAINT chk_Paid CHECK (Insurance_Payment <= Total_Payment),
    CONSTRAINT chk_DATE CHECK (Leave_Time < Next_Visit),
    CONSTRAINT chk_Admission CHECK (Admission_Time < Leave_Time),
    FOREIGN KEY (Patient_SSN) REFERENCES Patient(SSN)
);
 
CREATE TABLE Equipment_Type(
    EquipmentID INTEGER NOT NULL PRIMARY KEY,
    Instructions CHAR(500),
    Description CHAR(500),
    ModelNo INTEGER NOT NULL,
    Number_Of_Units INTEGER NOT NULL
);
 
CREATE TABLE Equipment(
    Serial_Number VARCHAR2(7) NOT NULL PRIMARY KEY,
    EquipmentID INTEGER NOT NULL,
    Room_No VARCHAR2(5) NOT NULL,
    Purchase_Year INTEGER NOT NULL,
    Last_Inspection DATE NOT NULL,
    FOREIGN KEY (EquipmentID) REFERENCES Equipment_Type(EquipmentID),
    FOREIGN KEY (Room_No) REFERENCES Room(Room_No),
    /*CONSTRAINT ck_equipment CHECK (Last_Inspection >= Purchase_Year)*/
    CONSTRAINT pyearCheck1 CHECK (Purchase_Year > 999),
    CONSTRAINT pyearCheck2 CHECK (Purchase_Year < 10000)
);
 
CREATE TABLE Doctor (
    DoctorID INTEGER NOT NULL PRIMARY KEY,
    First_Name CHAR(30) NOT NULL,
    Last_Name CHAR(30) NOT NULL,
    Gender CHAR(8) NOT NULL,
    Specialty CHAR(30) NOT NULL,
    CONSTRAINT gCheck check(Gender in ('Male', 'Female', 'Other'))
);
 
CREATE TABLE Stays_In (
    Start_Date DATE NOT NULL PRIMARY KEY,
    Room_No VARCHAR2(5) NOT NULL,
    Admission_ID INTEGER,
    End_Date DATE NOT NULL,
    FOREIGN KEY (Room_No) REFERENCES Room (Room_No),
    FOREIGN KEY (Admission_ID) REFERENCES Admission (Admission_ID)
);
 
CREATE TABLE Inspect (
    Admission_ID INTEGER,
    DoctorID INTEGER NOT NULL,
    Comments CHAR(30),
    FOREIGN KEY (Admission_ID) REFERENCES Admission (Admission_ID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor (DoctorID)
);
 
CREATE TABLE Room_Service (
    Room_No VARCHAR2(5),
    Service CHAR(20),
    CONSTRAINT pk_Room_Service PRIMARY KEY (Room_No, Service),
    FOREIGN KEY (Room_No) REFERENCES Room (Room_No)
);
 
CREATE TABLE Room_Access (
    Room_No VARCHAR(5),
    EmployeeID INTEGER,
    FOREIGN KEY (Room_No) REFERENCES Room (Room_No),
    FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID)
);
 
/*Employee*/    
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10000', '100', 'Regular Employee', 'Luke', 'Gebler', '45000', '0', '305');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10001', '100', 'Regular Employee', 'Marcus', 'Chalmers', '45000', '0', '306');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10002', '100', 'Regular Employee', 'Felix', 'Chen', '45000', '0', '307');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10003', '103', 'Regular Employee', 'Reshawn', 'George', '45000', '0', '308');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10004', '104', 'Regular Employee', 'Brian', 'Katz', '35000', '0', '405');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10005', '105', 'Regular Employee', 'Nihal', 'Patel', '35000', '0', '406');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10006', '106', 'Regular Employee', 'Jacob', 'Ross', '35000', '0', '407');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10007', '107', 'Regular Employee', 'Marcello', 'Merrit', '40000', '0', '505');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10008', '108', 'Regular Employee', 'Crhis', 'Meyer', '40000', '0', '506');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10009', '109', 'Regular Employee', 'Vincent', 'Ant', '40000', '0', '507');
 
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10010', '110', 'Division Manager', 'Elon', 'Musk', '65000', '1', '605');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10011', '111', 'Division Manager', 'Optimus', 'Prime', '65000', '1', '606');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10012', '112', 'Division Manager', 'Kazuma', 'Satao', '65000', '1', '607');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10013', '113', 'Division Manager', 'Budika', 'Paris', '65000', '1', '608');
 
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10014', '114', 'General Manager', 'Sean', 'Barry', '85000', '2', '1000');
INSERT INTO Employee(EmployeeID, BossID, Title, First_Name, Last_Name, Salary, empEchelon, Office_No) VALUES('10015', '115', 'General Manager', 'Hamayel', 'Qureshi', '85000', '2', '1001');
 
/*Patients*/
INSERT INTO Patient(SSN,First_Name,Last_Name,Patient_Address,Phone_No) VALUES('111-22-3333','Abdul','Kareem','15 Wherever Ave','111-111-1111');
INSERT INTO Patient(SSN,First_Name,Last_Name,Patient_Address,Phone_No) VALUES('222-22-2222','Jonathan','Leandoer','24 WTFrick Street','222-222-2222');
INSERT INTO Patient(SSN,First_Name,Last_Name,Patient_Address,Phone_No) VALUES('333-33-3333','Lil','Tracy','LeanWorld, LeanPlanet, LeanGalaxy','333-333-3333');
INSERT INTO Patient(SSN,First_Name,Last_Name,Patient_Address,Phone_No) VALUES('444-44-4444','Fish','Narc','Trap House, Atlanta','444-444-4444');
INSERT INTO Patient(SSN,First_Name,Last_Name,Patient_Address,Phone_No) VALUES('555-55-5555','Julian','Casablancas','11th Dimension, Astral Plane','555-555-5555');
INSERT INTO Patient(SSN,First_Name,Last_Name,Patient_Address,Phone_No) VALUES('666-66-6666','Pop','Tart','Toaster Oven Street','666-666-6666');
INSERT INTO Patient(SSN,First_Name,Last_Name,Patient_Address,Phone_No) VALUES('777-77-7777','Toilet','Paper','TP Manufacturing Inc, Lahore, Pakistan','777-777-7777');
INSERT INTO Patient(SSN,First_Name,Last_Name,Patient_Address,Phone_No) VALUES('888-88-8888','Jeff','Mangum','In An Aeroplane Over The Sea','888-888-8888');
INSERT INTO Patient(SSN,First_Name,Last_Name,Patient_Address,Phone_No) VALUES('999-99-9999','Kutta','KaBacha','In Da Hood, The 5th One In Chiraq','999-999-9999');
INSERT INTO Patient(SSN,First_Name,Last_Name,Patient_Address,Phone_No) VALUES('000-00-0000','Donald','Drumpf','Drumpf Towers, Cringe York','000-000-0000');
 
/*Rooms*/
INSERT INTO Room(Room_No,Occupation_Flag) VALUES('111','1');
INSERT INTO Room(Room_No,Occupation_Flag) VALUES('222','1');
INSERT INTO Room(Room_No,Occupation_Flag) VALUES('333','1');
INSERT INTO Room(Room_No,Occupation_Flag) VALUES('444','0');
INSERT INTO Room(Room_No,Occupation_Flag) VALUES('555','0');
INSERT INTO Room(Room_No,Occupation_Flag) VALUES('666','0');
INSERT INTO Room(Room_No,Occupation_Flag) VALUES('777','1');
INSERT INTO Room(Room_No,Occupation_Flag) VALUES('888','1');
INSERT INTO Room(Room_No,Occupation_Flag) VALUES('999','1');
INSERT INTO Room(Room_No,Occupation_Flag) VALUES('000','0');
 
/*Admission*/
INSERT INTO Admission(Admission_ID, Patient_SSN, Admission_Time, Leave_Time, Next_Visit, Total_Payment, Insurance_Payment) VALUES('1010', '111-22-3333', DATE '2002-01-01', DATE '2002-01-03', '', '200', '50');
INSERT INTO Admission(Admission_ID, Patient_SSN, Admission_Time, Leave_Time, Next_Visit, Total_Payment, Insurance_Payment) VALUES('1011', '111-22-3333', DATE '2002-02-01', DATE '2002-02-03', DATE '2019-02-07', '200', '50');
INSERT INTO Admission(Admission_ID, Patient_SSN, Admission_Time, Leave_Time, Next_Visit, Total_Payment, Insurance_Payment) VALUES('1012', '222-22-2222', DATE '2002-03-01', DATE '2002-03-03', '', '150', '25');
INSERT INTO Admission(Admission_ID, Patient_SSN, Admission_Time, Leave_Time, Next_Visit, Total_Payment, Insurance_Payment) VALUES('1013', '222-22-2222', DATE '2002-04-01', DATE '2002-04-03', '', '150', '25');
INSERT INTO Admission(Admission_ID, Patient_SSN, Admission_Time, Leave_Time, Next_Visit, Total_Payment, Insurance_Payment) VALUES('1014', '111-22-3333', DATE '2002-05-01', DATE '2002-05-03', '', '250', '75');
INSERT INTO Admission(Admission_ID, Patient_SSN, Admission_Time, Leave_Time, Next_Visit, Total_Payment, Insurance_Payment) VALUES('1015', '111-22-3333', DATE '2002-06-01', DATE '2002-06-03', '', '250', '75');
INSERT INTO Admission(Admission_ID, Patient_SSN, Admission_Time, Leave_Time, Next_Visit, Total_Payment, Insurance_Payment) VALUES('1016', '111-22-3333', DATE '2002-07-01', DATE '2002-07-03', '', '50', '5');
INSERT INTO Admission(Admission_ID, Patient_SSN, Admission_Time, Leave_Time, Next_Visit, Total_Payment, Insurance_Payment) VALUES('1017', '444-44-4444', DATE '2002-08-01', DATE '2002-08-03', '', '50', '5');
INSERT INTO Admission(Admission_ID, Patient_SSN, Admission_Time, Leave_Time, Next_Visit, Total_Payment, Insurance_Payment) VALUES('1018', '555-55-5555', DATE '2002-09-01', DATE '2002-09-03', DATE '2002-11-01', '15000', '500');
INSERT INTO Admission(Admission_ID, Patient_SSN, Admission_Time, Leave_Time, Next_Visit, Total_Payment, Insurance_Payment) VALUES('1019', '555-55-5555', DATE '2002-10-01', DATE '2002-10-03', DATE '2002-12-01', '0', '0');
 
/*EquipType*/
INSERT INTO Equipment_Type(EquipmentID, Instructions, Description, ModelNo, Number_Of_Units) VALUES('1000','Turn on.', 'MRI machine.','500', '3');
INSERT INTO Equipment_Type(EquipmentID, Instructions, Description, ModelNo, Number_Of_Units) VALUES('1001','Do stuff.', 'Cat scan.','501', '5');
INSERT INTO Equipment_Type(EquipmentID, Instructions, Description, ModelNo, Number_Of_Units) VALUES('1002','Weigh people.', 'Scale.','502', '20');
 
/*Equipment*/
INSERT INTO Equipment(Serial_Number, EquipmentID, Room_No, Purchase_Year, Last_Inspection) VALUES('A01-02X', '1000', '111', '2000', DATE '2000-01-01');
INSERT INTO Equipment(Serial_Number, EquipmentID, Room_No, Purchase_Year, Last_Inspection) VALUES('100501', '1001', '222', '2001', DATE '2000-02-02');
INSERT INTO Equipment(Serial_Number, EquipmentID, Room_No, Purchase_Year, Last_Inspection) VALUES('100502', '1002', '333', '2002', DATE '2000-03-03');
INSERT INTO Equipment(Serial_Number, EquipmentID, Room_No, Purchase_Year, Last_Inspection) VALUES('100503', '1001', '222', '2010', DATE '2000-02-02');
INSERT INTO Equipment(Serial_Number, EquipmentID, Room_No, Purchase_Year, Last_Inspection) VALUES('100504', '1001', '333', '2011', DATE '2000-03-03');

/*Doctor*/
INSERT INTO Doctor(DoctorID,First_Name,Last_Name,Gender,Specialty) VALUES('1111','Mother','Someones','Female','Heart');
INSERT INTO Doctor(DoctorID,First_Name,Last_Name,Gender,Specialty) VALUES('2222','Yung','Bruh','Other','Brain');
INSERT INTO Doctor(DoctorID,First_Name,Last_Name,Gender,Specialty) VALUES('3333','Soulja','Witch','Male','Reproductive');
INSERT INTO Doctor(DoctorID,First_Name,Last_Name,Gender,Specialty) VALUES('4444','Kanye','East','Male','Ear');
INSERT INTO Doctor(DoctorID,First_Name,Last_Name,Gender,Specialty) VALUES('5555','Tommy','Cash','Other','Feet');
INSERT INTO Doctor(DoctorID,First_Name,Last_Name,Gender,Specialty) VALUES('6666','Billy','Bob','Male','Psychiatrist');
INSERT INTO Doctor(DoctorID,First_Name,Last_Name,Gender,Specialty) VALUES('7777','Your','Ahhhh','Female','Lips');
INSERT INTO Doctor(DoctorID,First_Name,Last_Name,Gender,Specialty) VALUES('8888','Master','Chief','Male','Liposuction');
INSERT INTO Doctor(DoctorID,First_Name,Last_Name,Gender,Specialty) VALUES('9999','Flixzy','Peters','Male','Drug Abuse');
INSERT INTO Doctor(DoctorID,First_Name,Last_Name,Gender,Specialty) VALUES('0000','M','Asif','Other','General');
 
/*Stays In*/
INSERT INTO Stays_In(Start_Date, Room_No, Admission_ID, End_Date) VALUES(DATE '2003-01-01', '111', '1010', DATE '2003-01-03');
INSERT INTO Stays_In(Start_Date, Room_No, Admission_ID, End_Date) VALUES(DATE '2003-02-01', '222', '1011', DATE '2003-02-03');
INSERT INTO Stays_In(Start_Date, Room_No, Admission_ID, End_Date) VALUES(DATE '2003-03-01', '333', '1012', DATE '2003-03-03');
INSERT INTO Stays_In(Start_Date, Room_No, Admission_ID, End_Date) VALUES(DATE '2003-04-01', '444', '1013', DATE '2003-04-03');
 
/*Inspections*/
INSERT INTO Inspect(Admission_ID,DoctorID,Comments) VALUES('1010','1111','Just plain dumb');
INSERT INTO Inspect(Admission_ID,DoctorID,Comments) VALUES('1011','3333','Fractured earlobe');
INSERT INTO Inspect(Admission_ID,DoctorID,Comments) VALUES('1011','1111','Fractured pelvis');
INSERT INTO Inspect(Admission_ID,DoctorID,Comments) VALUES('1011','1111','Fractured belly');
INSERT INTO Inspect(Admission_ID,DoctorID,Comments) VALUES('1012','0000','Sexually induced tinnitus');
INSERT INTO Inspect(Admission_ID,DoctorID,Comments) VALUES('1013','7777','Sexually induced bronchitis');

INSERT INTO Inspect(Admission_ID,DoctorID,Comments) VALUES('1014','8888','Blindness');
INSERT INTO Inspect(Admission_ID,DoctorID,Comments) VALUES('1015','8888','Is Deaf');
INSERT INTO Inspect(Admission_ID,DoctorID,Comments) VALUES('1016','8888','Lost sense of touch');
 
/*RoomServices*/
INSERT INTO Room_Service(Room_No,Service) VALUES('111','ER');
INSERT INTO Room_Service(Room_No,Service) VALUES('111','XRAY');
INSERT INTO Room_Service(Room_No,Service) VALUES('111','MRI');
INSERT INTO Room_Service(Room_No,Service) VALUES('444','Urinal');
INSERT INTO Room_Service(Room_No,Service) VALUES('444','Disinfection');
INSERT INTO Room_Service(Room_No,Service) VALUES('888','XRAY');
INSERT INTO Room_Service(Room_No,Service) VALUES('888','Heart Surgery');
INSERT INTO Room_Service(Room_No,Service) VALUES('888','Spleen Surgery');
 
/*Room Access*/
INSERT INTO Room_Access(Room_No,EmployeeID) VALUES('222','10000');
INSERT INTO Room_Access(Room_No,EmployeeID) VALUES('333','10000');
INSERT INTO Room_Access(Room_No,EmployeeID) VALUES('444','10006');
INSERT INTO Room_Access(Room_No,EmployeeID) VALUES('999','10007');
 
/*SQL Queries*/
 
/* Question 1 */
SELECT Room_No
FROM Room
WHERE Occupation_Flag = 1;
 
/* Question 2 */
SELECT EmployeeID, First_Name, Last_Name, Salary
FROM Employee
WHERE BossID = 100
AND empEchelon = 0;
 
/* Question 3 */
SELECT Patient_SSN, SUM(Insurance_Payment) AS totalPaid
FROM Admission
GROUP BY Patient_SSN
UNION
    (SELECT SSN, 0 AS totalPaid  /* Reporting patients */
     FROM Patient
     MINUS
        (SELECT Patient_SSN, 0 AS totalPaid             /* Removing patients with insurance payments */
        FROM Admission));
 
/* Question 4 */
SELECT SSN, First_Name, Last_Name, numVisits
FROM Patient NATURAL JOIN (
    SELECT Patient_SSN AS SSN, COUNT(*) AS numVisits
    FROM Admission
    GROUP BY Patient_SSN
)
UNION(
    SELECT SSN, First_Name, Last_Name, 0 AS numVisits   /* Return all patients */
    FROM Patient
    MINUS(
        SELECT SSN, First_Name, Last_Name, numVisits    /* Remove patients with visits */
        FROM Patient NATURAL JOIN(
            SELECT Patient_SSN AS SSN, 0 AS numVisits
            FROM ADMISSION
        )
    )
);
 
/* Question 5 */
SELECT Room_No
FROM Equipment
WHERE Serial_Number = 'A01-02X';
 
/* Question 6 (DOES NOT WORK) */
SELECT EmployeeID, MAX(numRooms) AS numRooms
FROM(
    SELECT EmployeeID, COUNT(Room_No) AS numRooms
    FROM Room_Access
    GROUP BY EmployeeID
)
GROUP BY EmployeeID;
 
/* Question 7 */
SELECT Title AS empType, COUNT(Title) AS empCount
FROM Employee
GROUP BY Title;
 
/* Question 8 */
SELECT SSN, First_Name, Last_Name, Next_Visit
FROM Patient NATURAL JOIN (
    SELECT Patient_SSN AS SSN, Next_Visit
    FROM ADMISSION
    WHERE Next_Visit IS NOT NULL
);
 
/* Question 9 */
SELECT EquipmentID, ModelNo, Number_Of_Units
FROM Equipment_Type
WHERE Number_Of_Units > 3;
 
/* Question 10 */
SELECT Next_Visit
FROM Admission
WHERE Patient_SSN = '111-22-3333' AND Next_Visit IS NOT NULL
 
/* Question 11 */
SELECT DoctorID
FROM Inspect E, Admission A
WHERE E.Admission_ID = A.Admission_ID AND A.Patient_SSN = '111-22-3333'
GROUP BY DoctorID
HAVING COUNT(A.Patient_SSN) > 2;
 
/* Question 12 */
SELECT EquipmentID
FROM Equipment
WHERE Purchase_Year = 2010
INTERSECT(
    SELECT EquipmentID
    FROM Equipment
    WHERE Purchase_Year = 2011
)
