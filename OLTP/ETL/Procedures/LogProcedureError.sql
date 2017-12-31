--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'Log' AND SPECIFIC_NAME = 'ProcedureError')
BEGIN
	DROP PROCEDURE [Log].ProcedureError
END
GO

CREATE PROCEDURE [Log].ProcedureError
	@rvcName	VARCHAR(80)
AS
BEGIN

	SET NOCOUNT ON

	INSERT INTO [Log].[Procedure]([Name], enmType, Severity, [Description], CreatedOn)
	SELECT @rvcName, 101, ERROR_SEVERITY(), ERROR_MESSAGE(), GETDATE()

END
GO