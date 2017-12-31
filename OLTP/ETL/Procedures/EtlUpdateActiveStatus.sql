--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'Etl' AND SPECIFIC_NAME = 'UpdateActiveStatus')
BEGIN
	DROP PROCEDURE Etl.UpdateActiveStatus
END
GO

CREATE PROCEDURE Etl.UpdateActiveStatus
	@rvcName		VARCHAR(80)
	,@rbIsActive	BIT
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE		
		Etl.[Procedure]
	SET
		IsActive = @rbIsActive
	WHERE
		Name = @rvcName

	RETURN
END
GO