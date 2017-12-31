--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'Etl' AND SPECIFIC_NAME = 'GetLastProcessedID')
BEGIN
	DROP PROCEDURE Etl.GetLastProcessedID
END
GO

CREATE PROCEDURE Etl.GetLastProcessedID
	@rvcName				VARCHAR(80)
	,@rvcLastProcessedID	VARCHAR(80) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
		@rvcLastProcessedID = LastProcessedID
	FROM
		Etl.[Procedure]
	WHERE
		[Name] = @rvcName

	RETURN

END
GO