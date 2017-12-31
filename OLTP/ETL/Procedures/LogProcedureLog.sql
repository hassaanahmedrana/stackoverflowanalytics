--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'Log' AND SPECIFIC_NAME = 'ProcedureLog')
BEGIN
	DROP PROCEDURE [Log].ProcedureLog
END
GO

CREATE PROCEDURE [Log].ProcedureLog
	@rvcName			VARCHAR(80),
	@rvcDescription		VARCHAR(180)
AS
BEGIN

	SET NOCOUNT ON

	INSERT INTO [Log].[Procedure]([Name], enmType, Severity, [Description], CreatedOn)
	SELECT @rvcName, 201, 0, @rvcDescription, GETDATE()

END
GO