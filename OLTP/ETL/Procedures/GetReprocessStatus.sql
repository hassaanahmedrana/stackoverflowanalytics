--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'Etl' AND SPECIFIC_NAME = 'GetReprocessStatus')
BEGIN
	DROP PROCEDURE Etl.GetReprocessStatus
END
GO

CREATE PROCEDURE Etl.GetReprocessStatus
	@rvcName					VARCHAR(80)
	,@rbPerfromReprocessing		BIT OUTPUT
AS
BEGIN

	SET NOCOUNT ON

	SELECT
		@rbPerfromReprocessing = PerformReprocessing
	FROM
		Etl.[Procedure]
	WHERE
		[Name] = @rvcName

	RETURN

END
GO