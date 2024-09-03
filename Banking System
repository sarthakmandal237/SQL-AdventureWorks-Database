--Employee Chek IN and check out Calculation
--To meet the company's requirements, need to calculate the total work hours of employees in a day based on their check-in and check-out times.

WITH EmployeeWorkLog AS (
    SELECT
        EmpID,
        Name,
        TO_TIMESTAMP("CheckIn-CheckOut Time", 'DD-MM-YYYY HH24:MI') AS LogTime,
        Attendance
    FROM
        EmployeeLog
),
FirstCheckIn AS (
    SELECT
        EmpID,
        Name,
        MIN(LogTime) AS FirstCheckInTime
    FROM
        EmployeeWorkLog
    WHERE
        Attendance = 'IN'
    GROUP BY
        EmpID, Name
),
LastCheckOut AS (
    SELECT
        EmpID,
        Name,
        MAX(LogTime) AS LastCheckOutTime
    FROM
        EmployeeWorkLog
    WHERE
        Attendance = 'OUT'
    GROUP BY
        EmpID, Name
),
TotalOutCount AS (
    SELECT
        EmpID,
        Name,
        COUNT(*) AS TotalOutCount
    FROM
        EmployeeWorkLog
    WHERE
        Attendance = 'OUT'
    GROUP BY
        EmpID, Name
),
WorkSessions AS (
    SELECT
        e1.EmpID,
        e1.Name,
        e1.LogTime AS CheckInTime,
        MIN(e2.LogTime) AS CheckOutTime
    FROM
        EmployeeWorkLog e1
    JOIN
        EmployeeWorkLog e2 ON e1.EmpID = e2.EmpID
    WHERE
        e1.Attendance = 'IN'
        AND e2.Attendance = 'OUT'
        AND e1.LogTime < e2.LogTime
    GROUP BY
        e1.EmpID, e1.Name, e1.LogTime
),
TotalWorkHours AS (
    SELECT
        EmpID,
        Name,
        SUM(EXTRACT(HOUR FROM (CheckOutTime - CheckInTime)) * 60 + EXTRACT(MINUTE FROM (CheckOutTime - CheckInTime))) AS TotalWorkMinutes
    FROM
        WorkSessions
    GROUP BY
        EmpID, Name
)
SELECT
    FC.EmpID,
    FC.Name,
    FC.FirstCheckInTime,
    LC.LastCheckOutTime,
    TOC.TotalOutCount,
    TO_CHAR(FLOOR(TWH.TotalWorkMinutes / 60), 'FM00') || ':' || LPAD(MOD(TWH.TotalWorkMinutes, 60), 2, '0') AS TotalWorkHours
FROM
    FirstCheckIn FC
JOIN
    LastCheckOut LC ON FC.EmpID = LC.EmpID
JOIN
    TotalOutCount TOC ON FC.EmpID = TOC.EmpID
JOIN
    TotalWorkHours TWH ON FC.EmpID = TWH.EmpID;
