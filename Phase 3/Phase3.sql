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
DECLARE tmp NUMBER := 0;
begin
    SELECT COUNT(*) INTO tmp
    FROM Room_Service, Stays_In, Inspect
    WHERE :new.Admission_ID = Stays_In.Admission_ID
    AND Stays_In.Room_No = Room_Service.Room_No
    AND Room_Service.Service = 'ICU';
    IF(tmp :new.comment = null AND tmp != 0) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Comment may not be left null!')
    END IF;
end;
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
        RAISE_APPLICATION_ERROR(-20004, 'Incompatible rank for regular employee supervisor')
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
        RAISE_APPLICATION_ERROR(-20004, 'Incompatible rank for division manager supervisor')
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
        UPDATE Admission SET Next_Visit = ADD_MONTHS(oneDate, 2) WHERE Admission_ID = :new.Admission_ID
    END IF;
end;
/
