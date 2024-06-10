--Week 3 Task

--Task 1: Date Overlap Detection

WITH Overlaps AS (
    SELECT 
        p1.Task_ID AS Task_ID1, 
        p2.Task_ID AS Task_ID2
    FROM 
        Projects p1
    JOIN 
        Projects p2
    ON 
        p1.Task_ID < p2.Task_ID
        AND p1.End_Date >= p2.Start_Date
        AND p1.Start_Date <= p2.End_Date
)
SELECT * FROM Overlaps;

--================================================
-- Task 2: Friends Network

WITH DirectFriends AS (
    SELECT ID, Friend_ID
    FROM Friends
), FriendsOfFriends AS (
    SELECT 
        df1.ID, 
        df2.Friend_ID AS Friend_of_Friend_ID
    FROM 
        DirectFriends df1
    JOIN 
        DirectFriends df2
    ON 
        df1.Friend_ID = df2.ID
    WHERE 
        df1.ID != df2.Friend_ID
        AND NOT EXISTS (
            SELECT 1
            FROM DirectFriends df3
            WHERE df3.ID = df1.ID
            AND df3.Friend_ID = df2.Friend_ID
        )
)
SELECT * FROM FriendsOfFriends;

--=====================================================

--Task 3: Square Calculation 
SELECT 
    X, 
    X * X AS X_Squared
FROM 
    X;

--===================================================

--Task 4: SQL Join on Students and Packages

SELECT 
    c.college_id, 
    c.contact_id, 
    c.challenge_id, 
    c.num_students, 
    ch.num_students_required
FROM 
    Colleges c
JOIN 
    Challenges ch
ON 
    c.challenge_id = ch.challenge_id
WHERE 
    c.num_students >= ch.num_students_required;



--=================================================

--Task 5: College Challenge Matches

SELECT 
    s.submission_date, 
    s.hacker_id, 
    h.name, 
    COUNT(s.submission_id) AS number_of_submissions
FROM 
    Submissions s
JOIN 
    Hackers h
ON 
    s.hacker_id = h.hacker_id
GROUP BY 
    s.submission_date, 
    s.hacker_id, 
    h.name
ORDER BY 
    s.submission_date, 
    s.hacker_id;

--================================================

--Task 6: Creating a Table and Inserting Data

-- Create the table
CREATE TABLE STATION (
    ID NUMBER,
    CITY VARCHAR2(21),
    STATE VARCHAR2(2),
    LAT_N NUMBER,
    LONG_W NUMBER
);

-- Insert data into the table
INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES (1, 'New York', 'NY', 40.7128, -74.0060);
INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES (2, 'Los Angeles', 'CA', 34.0522, -118.2437);
INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES (3, 'Chicago', 'IL', 41.8781, -87.6298);
INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES (4, 'Houston', 'TX', 29.7604, -95.3698);
INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES (5, 'Phoenix', 'AZ', 33.4484, -112.0740);

--================================================
--Task 7: Finding Missing Values in a Table

SELECT n AS missing_value
FROM (
    SELECT LEVEL + (SELECT MIN(P) - 1 FROM P) AS n
    FROM dual
    CONNECT BY LEVEL <= (SELECT MAX(P) - MIN(P) + 1 FROM P)
)
WHERE n NOT IN (SELECT P FROM P)
ORDER BY missing_value;


--===============================================

--Task 8: Creating and Populating the OCCUPATIONS Table

-- Create the table
CREATE TABLE OCCUPATIONS (
    Name VARCHAR2(50),
    Occupation VARCHAR2(50)
);

-- Insert data into the table
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Samantha', 'Doctor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Anna', 'Professor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Maria', 'Actor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('James', 'Actor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Emily', 'Professor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Robert', 'Actor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Sophia', 'Doctor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Alice', 'Professor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Ethan', 'Singer');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Jack', 'Singer');


--==============================================

--Task 9: Handling Employee Hierarchy Data

-- Create Company table
CREATE TABLE Company (
    company_code VARCHAR2(10),
    company_name VARCHAR2(50)
);

-- Create Employee table
CREATE TABLE Employee (
    employee_code VARCHAR2(10),
    company_code VARCHAR2(10),
    lead_manager_code VARCHAR2(10),
    senior_manager_code VARCHAR2(10),
    manager_code VARCHAR2(10),
    employee_name VARCHAR2(50)
);

-- Insert data into the Company table
INSERT INTO Company (company_code, company_name) VALUES ('CMP01', 'TechCorp');
INSERT INTO Company (company_code, company_name) VALUES ('CMP02', 'InnovateLtd');

-- Insert data into the Employee table
INSERT INTO Employee (employee_code, company_code, lead_manager_code, senior_manager_code, manager_code, employee_name) VALUES ('E001', 'CMP01', NULL, 'SM01', 'M01', 'John Doe');
INSERT INTO Employee (employee_code, company_code, lead_manager_code, senior_manager_code, manager_code, employee_name) VALUES ('E002', 'CMP01', NULL, 'SM01', 'M02', 'Jane Smith');
INSERT INTO Employee (employee_code, company_code, lead_manager_code, senior_manager_code, manager_code, employee_name) VALUES ('E003', 'CMP01', NULL, 'SM02', 'M01', 'Emily Davis');
INSERT INTO Employee (employee_code, company_code, lead_manager_code, senior_manager_code, manager_code, employee_name) VALUES ('E004', 'CMP02', 'LM01', 'SM03', 'M03', 'Michael Brown');


--=========================================

--Task 10: List Employees and Their Respective Managers

-- List of employees and their managers
SELECT 
    e.employee_name AS Employee,
    lm.employee_name AS Lead_Manager,
    sm.employee_name AS Senior_Manager,
    m.employee_name AS Manager
FROM 
    Employee e
LEFT JOIN 
    Employee lm ON e.lead_manager_code = lm.employee_code
LEFT JOIN 
    Employee sm ON e.senior_manager_code = sm.employee_code
LEFT JOIN 
    Employee m ON e.manager_code = m.employee_code;

--===========================================

--Task 11:

SELECT S1.Name
FROM Students S1
JOIN Friends F ON S1.ID = F.ID
JOIN Packages P1 ON S1.ID = P1.ID
JOIN Packages P2 ON F.Friend_ID = P2.ID
WHERE P2.Salary > P1.Salary;


--==============================================

--Task 12:

SELECT 
    JobFamily,
    Country,
    (SUM(Cost) / (SELECT SUM(Cost) FROM JobCosts)) * 100 AS CostRatePercentage
FROM JobCosts
GROUP BY JobFamily, Country;

--===============================================

--Task 13:

SELECT 
    BU, 
    Month, 
    SUM(CASE WHEN EmployeeStatus = 'Old' THEN 1 ELSE 0 END) AS OldCount,
    SUM(CASE WHEN EmployeeStatus = 'New' THEN 1 ELSE 0 END) AS NewCount,
    (SUM(CASE WHEN EmployeeStatus = 'Old' THEN 1 ELSE 0 END) * 1.0 / SUM(CASE WHEN EmployeeStatus = 'New' THEN 1 ELSE 0 END)) AS RatioOldToNew
FROM Headcount
GROUP BY BU, Month;

--=============================================

--Task 14:

SELECT 
    BU, 
    COUNT(*) AS Headcount,
    (COUNT() * 100.0 / SUM(COUNT()) OVER ()) AS PercentageHeadcount
FROM Staff
GROUP BY BU;

--==========================================

--Task 15:

SELECT *
FROM (
    SELECT EmployeeID, Salary,
           ROW_NUMBER() OVER (ORDER BY Salary DESC) AS rn
    FROM Employees
) AS ranked
WHERE rn <= 5;

--===========================================

--Task 16:

UPDATE MyTable
SET Column1 = Column1 + Column2,
    Column2 = Column1 - Column2,
    Column1 = Column1 - Column2;

--========================================

--Task 17:

SELECT UserID, 
       EXTRACT(YEAR FROM LoginDate) AS Year, 
       AVG(LoginCount) AS AvgLogin
FROM UserLogins
WHERE LoginDate >= CURRENT_DATE - INTERVAL '3 years'
GROUP BY UserID, EXTRACT(YEAR FROM LoginDate)
ORDER BY UserID, Year;

--==========================================

--Task 18:

SELECT 
    BU,
    Month,
    SUM(Cost * Weight) / SUM(Weight) AS WeightedAvgCost
FROM EmployeeCosts
GROUP BY BU, Month;

--======================================

--Task 19:

WITH ActualAvg AS (
    SELECT AVG(Salary) AS ActualAverage
    FROM Employees
),
MiscalculationAvg AS (
    SELECT AVG(Salary) AS MiscalculatedAverage
    FROM Employees
    WHERE Salary > 0
)
SELECT 
    ROUND(ABS(A.ActualAverage - M.MiscalculatedAverage), 0) AS Error
FROM ActualAvg A, MiscalculationAvg M

--===============================================

--Task 20:

INSERT INTO NewTable (Column1, Column2, Column3, ...)
SELECT Column1, Column2, Column3, ...
FROM OldTable;

--===============================================
