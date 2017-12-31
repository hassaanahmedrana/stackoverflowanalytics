--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'dbo' AND SPECIFIC_NAME = 'FactVote')
BEGIN
	DROP PROCEDURE dbo.FactVote
END
GO

CREATE PROCEDURE dbo.FactVote
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @dtLastUpdatedOn			DATETIME
			,@dtEndDate					DATETIME
			,@dtNullDateReplacement		DATETIME
			,@bPerformReprocessing		BIT
			,@bUseBusinessKey			BIT
			,@vcFromBusinessKey			VARCHAR(80)
			,@vcToBusinessKey			VARCHAR(80)
			,@vcLastProcessedID			VARCHAR(80)
			,@iFromBusinessKey			INT
			,@iToBusinessKey			INT
			,@iLastProcessedID			INT

	EXEC Etl.GetLastProcessedTime 'FactVote', @dtLastUpdatedOn OUTPUT, @dtEndDate OUTPUT

	EXEC Etl.GetReprocessStatus 'FactVote', @bPerformReprocessing OUTPUT

	EXEC Etl.GetUseBusinessKeyStatus 'FactVote', @bUseBusinessKey OUTPUT

	EXEC Etl.GetBusinessKeyRange 'FactVote', @vcFromBusinessKey OUTPUT, @vcToBusinessKey OUTPUT

	EXEC Etl.GetLastProcessedID 'FactVote', @vcLastProcessedID OUTPUT

	SET @iFromBusinessKey = CONVERT(INT, @vcFromBusinessKey)

	SET @iToBusinessKey = CONVERT(INT, @vcToBusinessKey)

	SET @iLastProcessedID = CONVERT(INT, @vcLastProcessedID)

	SET @dtNullDateReplacement = '1990-01-01'

	CREATE TABLE #FactVoteTemp
	(
		BkVoteId			INT
		,PostId				INT
		,UserId				INT
		,VoteType			NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
		,BountyAmount		INT
	)

	IF (@bUseBusinessKey = 1 AND @bPerformReprocessing = 1)
	BEGIN
		INSERT INTO #FactVoteTemp
		(
			BkVoteId
			,PostId
			,UserId
			,VoteType
			,BountyAmount
		)
		SELECT
			V.Id
			,V.PostId
			,V.UserId
			,VT.[Name]
			,V.BountyAmount
		FROM
			StackOverflow..Votes V
			INNER JOIN StackOverflow..VoteTypes VT
			ON V.VoteTypeId = VT.Id
		WHERE
			V.Id >= @iFromBusinessKey AND V.Id <= @iToBusinessKey
			AND V.UserId IS NOT NULL
	END

	IF (@bUseBusinessKey = 1 AND @bPerformReprocessing = 0)
	BEGIN
		INSERT INTO #FactVoteTemp
		(
			BkVoteId
			,PostId
			,UserId
			,VoteType
			,BountyAmount
		)
		SELECT
			V.Id
			,V.PostId
			,V.UserId
			,VT.[Name]
			,V.BountyAmount
		FROM
			StackOverflow..Votes V
			INNER JOIN StackOverflow..VoteTypes VT
			ON V.VoteTypeId = VT.Id
		WHERE
			V.Id > @iLastProcessedID
			AND V.UserId IS NOT NULL
	END

	IF (@bUseBusinessKey = 0 AND @bPerformReprocessing = 1)
	BEGIN
		INSERT INTO #FactVoteTemp
		(
			BkVoteId
			,PostId
			,UserId
			,VoteType
			,BountyAmount
		)
		SELECT
			V.Id
			,V.PostId
			,V.UserId
			,VT.[Name]
			,V.BountyAmount
		FROM
			StackOverflow..Votes V
			INNER JOIN StackOverflow..VoteTypes VT
			ON V.VoteTypeId = VT.Id
		WHERE
			V.CreationDate >= @dtLastUpdatedOn AND V.CreationDate <= @dtEndDate
			AND V.UserId IS NOT NULL
	END

	IF (@bUseBusinessKey = 0 AND @bPerformReprocessing = 0)
	BEGIN
		INSERT INTO #FactVoteTemp
		(
			BkVoteId
			,PostId
			,UserId
			,VoteType
			,BountyAmount
		)
		SELECT
			V.Id
			,V.PostId
			,V.UserId
			,VT.[Name]
			,V.BountyAmount
		FROM
			StackOverflow..Votes V
			INNER JOIN StackOverflow..VoteTypes VT
			ON V.VoteTypeId = VT.Id
		WHERE
			V.CreationDate > @dtLastUpdatedOn
			AND V.UserId IS NOT NULL
	END

	INSERT INTO #FactVoteTemp
	(
		BkVoteId
		,PostId
		,UserId
		,VoteType
		,BountyAmount
	)
	SELECT
		V.BkVoteId
		,V.PostId
		,V.UserId
		,V.VoteType
		,V.BountyAmount
	FROM
		Stag.VoteDetail V
		LEFT JOIN #FactVoteTemp FVt
		ON V.BkVoteId = FVt.BkVoteId

	TRUNCATE TABLE Stag.VoteDetail

	DELETE
	FROM FVt
	OUTPUT
		deleted.PostId
		,deleted.UserId
		,deleted.VoteType
		,deleted.BountyAmount
		,deleted.BkVoteId
		,'VoteType does not exist in dimension'
	INTO
		Stag.VoteDetail
	FROM
		#FactVoteTemp FVt
	WHERE
		NOT EXISTS(SELECT 1 FROM Dim.VoteType VT WHERE FVt.VoteType = VT.VoteType)

	DELETE
	FROM FVt
	OUTPUT
		deleted.PostId
		,deleted.UserId
		,deleted.VoteType
		,deleted.BountyAmount
		,deleted.BkVoteId
		,'OwnerUser does not exist in dimension'
	INTO
		Stag.VoteDetail
	FROM
		#FactVoteTemp FVt
	WHERE
		NOT EXISTS(SELECT 1 FROM Fact.UserDetail UD WHERE UD.BkUserId = FVt.UserId)

	DELETE
		VD
	FROM 
		Fact.VoteDetail VD
		INNER JOIN #FactVoteTemp FVt
		ON VD.BkVoteId = FVt.BkVoteId

	INSERT Fact.VoteDetail
	(
		SkOwnerUserId
		,SkPostId
		,SkVoteTypeId
		,BountyAmount
		,BkVoteId
	)
	SELECT
		FVt.UserId
		,FVt.PostId
		,VT.pkDimVoteTypeId
		,FVt.BountyAmount
		,FVt.BkVoteId
	FROM
		#FactVoteTemp FVt
		INNER JOIN Dim.VoteType VT ON VT.VoteType = FVt.VoteType
END
GO