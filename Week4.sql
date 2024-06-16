--Week 4 Task

-- Create StudentDetails table
CREATE TABLE StudentDetails (
    StudentId INT PRIMARY KEY,
    StudentName VARCHAR(50),
    GPA FLOAT,
    Branch VARCHAR(50),
    Section CHAR(1)
);

-- Create StudentPreference table
CREATE TABLE StudentPreference (
    StudentId INT,
    SubjectId VARCHAR(10),
    Preference INT,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);

-- Create SubjectDetails table
CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(10) PRIMARY KEY,
    SubjectName VARCHAR(50),
    MaxSeats INT,
    RemainingSeats INT
);

-- Create Allotments table
CREATE TABLE Allotments (
    SubjectId VARCHAR(10),
    StudentId INT,
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);

-- Create UnallotedStudents table
CREATE TABLE UnallotedStudents (
    StudentId INT,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);

--==============================================

DELIMITER //

CREATE PROCEDURE AllocateSubjects()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE student_id INT;
    DECLARE subject_id VARCHAR(10);
    DECLARE preference INT;
    DECLARE max_seats INT;
    DECLARE remaining_seats INT;
    DECLARE pref_cursor CURSOR FOR 
        SELECT StudentId, SubjectId, Preference
        FROM StudentPreference
        ORDER BY Preference;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN pref_cursor;

    read_loop: LOOP
        FETCH pref_cursor INTO student_id, subject_id, preference;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Check if subject has remaining seats
        SELECT MaxSeats, RemainingSeats INTO max_seats, remaining_seats 
        FROM SubjectDetails
        WHERE SubjectId = subject_id;
        
        IF remaining_seats > 0 THEN
            -- Allocate subject to student
            INSERT INTO Allotments (SubjectId, StudentId)
            VALUES (subject_id, student_id);
            
            -- Decrement remaining seats
            UPDATE SubjectDetails
            SET RemainingSeats = RemainingSeats - 1
            WHERE SubjectId = subject_id;
        ELSE
            -- If no preference is satisfied, mark student as unallotted
            INSERT INTO UnallotedStudents (StudentId)
            VALUES (student_id);
        END IF;
    END LOOP;

    CLOSE pref_cursor;
END //

DELIMITER ;
