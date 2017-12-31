--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'Etl' AND SPECIFIC_NAME = 'GetBusinessKeyRange')
BEGIN
	DROP PROCEDURE Etl.GetBusinessKeyRange
END
GO

CREATE PROCEDURE Etl.GetBusinessKeyRange
	@rvcName				VARCHAR(80)
	,@rvcFromBusinessKey	VARCHAR(80) OUTPUT
	,@rvcToBusinessKey		VARCHAR(80) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @vcFromBusinessKey		VARCHAR(80)
			,@vcToBusinessKey		VARCHAR(80)

	SELECT
		@vcFromBusinessKey = FromBusinessKey
		,@vcToBusinessKey = ToBusinessKey
	FROM
		Etl.[Procedure]
	WHERE
		[Name] = @rvcName

	SET @rvcFromBusinessKey = @vcFromBusinessKey
	SET @rvcToBusinessKey = @vcToBusinessKey

END
GO