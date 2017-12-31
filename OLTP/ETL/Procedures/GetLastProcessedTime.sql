--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'Etl' AND SPECIFIC_NAME = 'GetLastProcessedTime')
BEGIN
	DROP PROCEDURE Etl.GetLastProcessedTime
END
GO

CREATE PROCEDURE Etl.GetLastProcessedTime
	@rvcName				VARCHAR(80)
	,@rdtLastProcessedDate	DATETIME OUTPUT
	,@rdtEndDate			DATETIME OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @dtLastProcessedDate	DATETIME
			,@dtEndDate				DATETIME

	SELECT
		@dtLastProcessedDate = LastExecutedOn
		,@dtEndDate = EndDate
	FROM
		Etl.[Procedure]
	WHERE
		[Name] = @rvcName

	SET @rdtLastProcessedDate = @dtLastProcessedDate
	SET @rdtEndDate = @dtEndDate

END
GO