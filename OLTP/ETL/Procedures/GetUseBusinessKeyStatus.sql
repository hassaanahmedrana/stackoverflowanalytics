--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'Etl' AND SPECIFIC_NAME = 'GetUseBusinessKeyStatus')
BEGIN
	DROP PROCEDURE Etl.GetUseBusinessKeyStatus
END
GO

CREATE PROCEDURE Etl.GetUseBusinessKeyStatus
	@rvcName				VARCHAR(80)
	,@rbUseBusinessKey		BIT OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
		@rbUseBusinessKey = UseBusinessKey
	FROM
		Etl.[Procedure]
	WHERE
		[Name] = @rvcName

	RETURN

END
GO