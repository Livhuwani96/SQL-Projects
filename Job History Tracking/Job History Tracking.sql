USE [YourDW]
GO

/*
===========================================
 Author:        [Livhuwani Munyai]
 Created Date:  [2025-01-15]
 Description:   
   - This stored procedure tracks SQL Agent job execution history.
   - It retrieves job run details, success/failure counts, and updates the history table.
   - Uses MERGE to update existing records or insert new ones.
   
 Database:      Microsoft SQL Server (MSSQL)
 Language:      Transact-SQL (T-SQL)

 Business Need:
   - Helps the BI team monitor job executions as part of their KPI for data administration.
   - Stores a historical log for job performance analysis to use when calculating KPI scores.

===========================================
*/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [maint].[pSQL_JobHistory]
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare a table variable to store job history execution data
    DECLARE @JobHistory TABLE (
        JobName NVARCHAR(255) NOT NULL,
        RunDate DATE NOT NULL,
        SuccessCount INT NOT NULL,
        FailureCount INT NOT NULL,
        SuccessRate INT NOT NULL,
        FailureRate INT NOT NULL
    );

    -- Insert job execution details into the table variable
    INSERT INTO @JobHistory (JobName, RunDate, SuccessCount, FailureCount, SuccessRate, FailureRate)
    SELECT 
        jv.name AS JobName,
        CONVERT(DATE, FORMAT(jh.run_date, '0000-00-00')) AS RunDate,  -- Convert run_date correctly
        SUM(CASE WHEN jh.run_status = 1 THEN 1 ELSE 0 END) AS SuccessCount,
        SUM(CASE WHEN jh.run_status = 0 THEN 1 ELSE 0 END) AS FailureCount,
        CAST((SUM(CASE WHEN jh.run_status = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS INT) AS SuccessRate,
        CAST((SUM(CASE WHEN jh.run_status = 0 THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS INT) AS FailureRate
    FROM 
        msdb.dbo.sysjobs_view jv
    INNER JOIN 
        msdb.dbo.sysjobhistory jh ON jv.job_id = jh.job_id
    WHERE 
        jh.step_name <> '(Job outcome)' -- Exclude summary step
        AND CONVERT(DATE, FORMAT(jh.run_date, '0000-00-00')) = CAST(GETDATE() AS DATE) -- Only today’s jobs
    GROUP BY 
        jv.name,
        jh.run_date;

    -- Use MERGE to update existing records or insert new ones
    MERGE dbo.SQL_JobHistory AS Target
    USING @JobHistory AS Source
    ON Target.JobName = Source.JobName 
    AND Target.RunDate = Source.RunDate -- Matching on job name and run date

    WHEN MATCHED THEN
        UPDATE SET 
            Target.SuccessCount = Source.SuccessCount,
            Target.FailureCount = Source.FailureCount,
            Target.SuccessRate = Source.SuccessRate,
            Target.FailureRate = Source.FailureRate,
            Target.InsertedOn = GETDATE()  -- Update timestamp

    WHEN NOT MATCHED THEN
        INSERT (JobName, RunDate, SuccessCount, FailureCount, SuccessRate, FailureRate, InsertedOn)
        VALUES (Source.JobName, Source.RunDate, Source.SuccessCount, Source.FailureCount, Source.SuccessRate, Source.FailureRate, GETDATE());

END;
GO


