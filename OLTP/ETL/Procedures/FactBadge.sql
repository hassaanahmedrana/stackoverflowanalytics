--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'dbo' AND SPECIFIC_NAME = 'FactBadge')
BEGIN
	DROP PROCEDURE dbo.FactBadge
END
GO

CREATE PROCEDURE dbo.FactBadge
AS
BEGIN

	SET NOCOUNT ON

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

	EXEC Etl.GetLastProcessedTime 'FactBadge', @dtLastUpdatedOn OUTPUT, @dtEndDate OUTPUT

	EXEC Etl.GetReprocessStatus 'FactBadge', @bPerformReprocessing OUTPUT

	EXEC Etl.GetUseBusinessKeyStatus 'FactBadge', @bUseBusinessKey OUTPUT

	EXEC Etl.GetBusinessKeyRange 'FactBadge', @vcFromBusinessKey OUTPUT, @vcToBusinessKey OUTPUT

	EXEC Etl.GetLastProcessedID 'FactBadge', @vcLastProcessedID OUTPUT

	SET @iFromBusinessKey = CONVERT(INT, @vcFromBusinessKey)

	SET @iToBusinessKey = CONVERT(INT, @vcToBusinessKey)

	SET @iLastProcessedID = CONVERT(INT, @vcLastProcessedID)

	SET @dtNullDateReplacement = '1990-01-01'

	CREATE TABLE #FactBadgeTemp
	(
		[Name]				NVARCHAR(50)
		,UserId				INT
		,CreationDate		DATE
		,BkBadgeId			INT
	)

	IF (@bUseBusinessKey = 1 AND @bPerformReprocessing = 1)
	BEGIN

		INSERT INTO #FactBadgeTemp
		(
			[Name]
			,UserId
			,CreationDate
			,BkBadgeId
		)
		SELECT
			B.[Name]
			,B.UserId
			,B.[Date]
			,B.Id
		FROM
			StackOverflow..Badges B
		WHERE
			B.Id >= @iFromBusinessKey AND B.Id <= @iToBusinessKey
	END		

	IF (@bUseBusinessKey = 1 AND @bPerformReprocessing = 0)
	BEGIN

		INSERT INTO #FactBadgeTemp
		(
			[Name]
			,UserId
			,CreationDate
			,BkBadgeId
		)
		SELECT
			B.[Name]
			,B.UserId
			,B.[Date]
			,B.Id
		FROM
			StackOverflow..Badges B
		WHERE
			B.Id > @iLastProcessedID
	END		

	IF (@bUseBusinessKey = 0 AND @bPerformReprocessing = 1)
	BEGIN

		INSERT INTO #FactBadgeTemp
		(
			[Name]
			,UserId
			,CreationDate
			,BkBadgeId
		)
		SELECT
			B.[Name]
			,B.UserId
			,B.[Date]
			,B.Id
		FROM
			StackOverflow..Badges B
		WHERE
			B.[Date] >= @dtLastUpdatedOn AND B.[Date] <= @dtEndDate
	END		

	IF (@bUseBusinessKey = 0 AND @bPerformReprocessing = 0)
	BEGIN

		INSERT INTO #FactBadgeTemp
		(
			[Name]
			,UserId
			,CreationDate
			,BkBadgeId
		)
		SELECT
			B.[Name]
			,B.UserId
			,B.[Date]
			,B.Id
		FROM
			StackOverflow..Badges B
		WHERE
			B.[Date] >= @dtLastUpdatedOn
	END		

	INSERT INTO #FactBadgeTemp
	(
		[Name]
		,UserId
		,CreationDate
		,BkBadgeId
	)
	SELECT
		B.[Name]
		,B.UserId
		,B.CreationDate
		,B.BkBadgeId
	FROM
		Stag.BadgeDetail B
		LEFT JOIN #FactBadgeTemp FBt
		ON B.BkBadgeId = FBt.BkBadgeId
	
	TRUNCATE TABLE Stag.BadgeDetail

	DELETE
	FROM FBt
	OUTPUT
		deleted.[Name]
		,deleted.UserId
		,deleted.CreationDate
		,deleted.BkBadgeId
		,'User does not exist in the dimension'
	FROM
		#FactBadgeTemp FBt
	WHERE
		NOT EXISTS(SELECT 1 FROM Fact.UserDetail UD WHERE UD.BkUserId = FBt.UserId)

	DELETE
	FROM FBt
	OUTPUT
		deleted.[Name]
		,deleted.UserId
		,deleted.CreationDate
		,deleted.BkBadgeId
		,'Date does not exist in the dimension'
	FROM
		#FactBadgeTemp FBt
	WHERE
		NOT EXISTS(SELECT 1 FROM Dim.[Date] D WHERE D.[Date] >= FBt.CreationDate AND D.[Date] <= FBt.CreationDate)

	DELETE
		BD
	FROM
		Fact.BadgeDetail BD
		INNER JOIN #FactBadgeTemp FBt
		ON BD.BkBadgeId = FBt.BkBadgeId

	INSERT INTO Fact.BadgeDetail
	(
		[Name]
		,SkOwnerUserId
		,SkDateId
		,BkBadgeId
	)
	SELECT
		FBt.[Name]
		,FBt.UserId
		,D.pkDimDateId
		,FBt.BkBadgeId
	FROM
		#FactBadgeTemp FBt
		INNER JOIN Dim.[Date] D ON FBT.CreationDate >= D.[Date] AND FBT.CreationDate <= D.[Date]
END
GO