--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'dbo' AND SPECIFIC_NAME = 'DimPostType')
BEGIN
	DROP PROCEDURE dbo.DimPostType
END
GO

CREATE PROCEDURE dbo.DimPostType
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE
		DPT
	SET
		DPT.PostType = PT.Type
	FROM
		Dim.PostType DPT
		INNER JOIN StackOverflow..PostTypes PT
		ON PT.Type = DPT.PostType

	INSERT INTO Dim.PostType
	(
		PostType
	)
	SELECT
		[Type]
	FROM
		StackOverflow..PostTypes PT
		LEFT JOIN Dim.PostType DPT
		ON PT.Type = DPT.PostType
	WHERE
		DPT.pkDimPostTypeId IS NULL

END
GO