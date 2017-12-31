--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'dbo' AND SPECIFIC_NAME = 'DimVoteType')
BEGIN
	DROP PROCEDURE dbo.DimVoteType
END
GO

CREATE PROCEDURE dbo.DimVoteType
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE
		DVT
	SET
		DVT.VoteType = VT.[Name]
	FROM
		Dim.VoteType DVT
		INNER JOIN StackOverflow..VoteTypes VT
		ON DVT.VoteType = VT.[Name]

	INSERT INTO Dim.VoteType
	(
		VoteType
	)
	SELECT
		[Name]
	FROM
		StackOverflow..VoteTypes VT
		LEFT JOIN Dim.VoteType DVT
		ON VT.[Name] = DVT.[VoteType]
	WHERE
		DVT.pkDimVoteTypeId IS NULL

END
GO