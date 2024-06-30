CREATE PROCEDURE UpdateSubjectAllotment
AS
BEGIN
    DECLARE @StudentID VARCHAR(10), @SubjectID VARCHAR(10), @CurrentSubjectID VARCHAR(10)

    -- Get the requested subject change details
    SELECT @StudentID = StudentId, @SubjectID = SubjectId
    FROM SubjectRequest

    -- Check if the requested subject is already the current subject
    SELECT @CurrentSubjectID = SubjectId
    FROM SubjectAllotments
    WHERE StudentID = @StudentID AND Is_valid = 1

    IF @CurrentSubjectID = @SubjectID
    BEGIN
        -- The requested subject is the same as the current valid subject, no need to change
        PRINT 'The requested subject is already the current valid subject.'
    END
    ELSE
    BEGIN
        -- Mark the current subject as invalid
        UPDATE SubjectAllotments
        SET Is_valid = 0
        WHERE StudentID = @StudentID AND Is_valid = 1
        
        -- Check if the requested subject already exists for the student in the allotments table
        IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = @StudentID AND SubjectId = @SubjectID)
        BEGIN
            -- Update the existing record to be valid
            UPDATE SubjectAllotments
            SET Is_valid = 1
            WHERE StudentID = @StudentID AND SubjectId = @SubjectID
        END
        ELSE
        BEGIN
            -- Insert the new subject as a valid record
            INSERT INTO SubjectAllotments (StudentID, SubjectId, Is_valid)
            VALUES (@StudentID, @SubjectID, 1)
        END
    END
END
