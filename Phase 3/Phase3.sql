--part 1 create view

/* Critical cases, admitted at least 2wice */
CREATE VIEW CriticalCases AS
    SELECT SSN as Patient_SSN, First_Name, Last_Name, NumberOfAdmissionsToICU
    From Patient Natural Join (
        SELECT Patient_SSN, Count(Patient_SSN) as NumberOfAdmissionsToICU
        From Admission Natural JOIN (
            SELECT Admission_ID
            FROM Stays_In Natural Join (
                SELECT Room_No
                FROM Room_Service
                Where Service = 'ICU'
            )
        )
        Group by Patient_SSN
    )
    WHERE NumberOfAdmissionsToICU >= 2 AND Patient_SSN = SSN;

/* Underloaded or overloaded doctor */
CREATE VIEW DoctorsLoad AS
    SELECT DoctorID, Gender, 'Underloaded' AS Load
    FROM Doctor NATURAL JOIN (
        SELECT DoctorID, Count(Admission_ID) AS numLoad
        FROM Inspect
        GROUP BY DoctorID
    ) WHERE numLoad <= 10
    UNION (
    SELECT DoctorID, Gender, 'Overloaded' AS Load
    FROM Doctor NATURAL JOIN(
        SELECT DoctorID, Count(Admission_ID) AS numLoad
        FROM Inspect
        GROUP BY DoctorID
    ) WHERE numLoad > 10
);

/* Patients with >4 ICU visit */
SELECT *
FROM CriticalCases
WHERE numberOfAdmissionsToICU > 4;

/* Female overloaded doctors */
SELECT Doctor.DoctorID, Doctor.First_Name, Doctor.Last_Name
FROM Doctor, DoctorsLoad
WHERE DoctorsLoad.DoctorID = Doctor.DoctorID 
AND DoctorsLoad.Gender = 'Female'
AND DoctorsLoad.Load = 'Overloaded';

/* Comments from doctors */
SELECT Doctor.DoctorID, Admission.Patient_SSN, Inspect.Comments
FROM DoctorsLoad, CriticalCases, Admission, Inspect
WHERE DoctorsLoad.DoctorID = Inspect.DoctorID
AND Inspect.Admission_ID = Admission.Admission_ID
AND CriticalCases.Patient_SSN = Admission.Patient_SSN;

--part 2 triggers

/* Leave Comment */
CREATE OR REPLACE TRIGGER CommentLeft
BEFORE INSERT OR UPDATE ON Inspect
FOR EACH ROW
DECLARE temp NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO temp
    FROM Room_Service, Stays_In, Inspect
    WHERE :new.Admission_ID = Stays_In.Admission_ID
    AND Stays_In.Room_No = Room_Service.Room_No
    AND Room_Service.Service = 'ICU';
    IF(temp != 0 AND :new.comments = null) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Comment may not be left null!');
    END IF;
END;
/

/* Insurance 65% */
CREATE OR REPLACE TRIGGER InsurancePayPercent
BEFORE INSERT OR UPDATE ON Admission
FOR EACH ROW
begin
    :new.Insurance_Payment := (:new.Total_Payment * 0.65);
end;
/

/* Regular employee supervisor */
CREATE OR REPLACE TRIGGER RegRank
BEFORE INSERT OR UPDATE ON Employee
FOR EACH ROW
WHEN (new.empEchelon = 0)
DECLARE superRank NUMBER := 1;
begin
    SELECT empEchelon INTO superRank FROM Employee WHERE EmployeeID = :new.BossID;
    IF(superRank != 1) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Incompatible rank for regular employee supervisor');
    END IF;
end;
/

/* Division manager supervisor */
CREATE OR REPLACE TRIGGER DivRank
BEFORE INSERT OR UPDATE ON Employee
FOR EACH ROW
WHEN (new.empEchelon = 1)
DECLARE superRank NUMBER := 2;
begin
    SELECT empEchelon INTO superRank FROM Employee WHERE EmployeeID = :new.BossID;
    IF(superRank != 2) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Incompatible rank for division manager supervisor');
    END IF;
end;
/

/* 2 month later visit after emergency visit */
CREATE OR REPLACE TRIGGER VisitAfterER
BEFORE INSERT ON Stays_In
FOR EACH ROW
DECLARE roomVers varchar(25);
oneDate date;
begin
    SELECT Room_Service.Service, Admission.Admission_Time INTO roomVers, oneDate
    FROM Admission, Room_Service, Stays_In
    WHERE :new.Admission_ID = Admission.Admission_ID
    AND :new.Room_No = Room_Service.Room_No
    AND Room_Service.Service = 'Emergency';
    IF(roomVers != NULL) THEN
        UPDATE Admission SET Next_Visit = ADD_MONTHS(oneDate, 2) WHERE Admission_ID = :new.Admission_ID;
    END IF;
end;
/

/* CtUltra sound after 2006*/
CREATE OR REPLACE TRIGGER CTUltra
BEFORE INSERT OR UPDATE ON Equipment
FOR EACH ROW
DECLARE 
CT char(15);
Ultra char(15);
begin
    SELECT EquipmentID INTO CT
    FROM Equipment_Type
    WHERE Description = 'CT Scanner';
    
    SELECT EquipmentID INTO Ultra
    FROM Equipment_Type
    WHERE Description = 'Ultrasound';
    
    If :new.EquipmentID = CT or :new.EquipmentID = Ultra THEN
        If :new.Purchase_Year IS NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'Equipment does not meet requirments');
        End If;
        If (:new.Purchase_Year < 2007) THEN
            RAISE_APPLICATION_ERROR(-20004, 'Equipment does not meet requirments');
        End if;
    End If;
end;
/

/* Print Patient Info*/
CREATE OR REPLACE TRIGGER PrintPatientInfo
AFTER UPDATE ON Admission
For Each Row
DECLARE
FirstName1 char(20);
LastName1 char(20);
Address1 char(20);
Comments1 char(50);
CURSOR c1 Is Select DoctorID, Comments From Inspect Order By DoctorID;
begin
    If :new.Leave_Time IS NOT NULL THEN
        Select First_Name Into FirstName1 From Patient Where :new.Patient_SSN = SSN;
        Select Last_Name Into LastName1 From Patient Where :new.Patient_SSN = SSN;
        Select Patient_Address Into Address1 From Patient Where :new.Patient_SSN = SSN;
        
        dbms_output.put_line(FirstName1 || ' ' || LastName1);
		dbms_output.put_line(Address1);
		
        FOR record IN c1
		LOOP
			dbms_output.put_line(record.DoctorID);
			dbms_output.put_line(record.Comments);
		END LOOP;
    End If;
end;
/
