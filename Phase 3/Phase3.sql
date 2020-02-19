--part 1 create view

/* Critical cases, admitted at least 2wice */
CREATE VIEW CriticalCases AS
    SELECT SSN as Patient_SSN, First_Name, Last_Name, NumberOfAdmissionsToICU
    From Patient Natural Join (
        SELECT Patient_SSN, Count(Patient_SSN) as NumberOfAdmissionsToICU
        From Admission Natural JOIN (
            SELECT Admission_ID
            FROM Stays_In Natural Join (
                SELECT Room_no
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
