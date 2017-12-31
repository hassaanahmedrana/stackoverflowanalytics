--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'dbo' AND SPECIFIC_NAME = 'FactPost')
BEGIN
	DROP PROCEDURE dbo.FactPost
END
GO

CREATE PROCEDURE dbo.FactPost
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

	EXEC Etl.GetLastProcessedTime 'FactPost', @dtLastUpdatedOn OUTPUT, @dtEndDate OUTPUT

	EXEC Etl.GetReprocessStatus 'FactPost', @bPerformReprocessing OUTPUT

	EXEC Etl.GetUseBusinessKeyStatus 'FactPost', @bUseBusinessKey OUTPUT

	EXEC Etl.GetBusinessKeyRange 'FactPost', @vcFromBusinessKey OUTPUT, @vcToBusinessKey OUTPUT

	EXEC Etl.GetLastProcessedID 'FactPost', @vcLastProcessedID OUTPUT

	SET @iFromBusinessKey = CONVERT(INT, @vcFromBusinessKey)

	SET @iToBusinessKey = CONVERT(INT, @vcToBusinessKey)

	SET @iLastProcessedID = CONVERT(INT, @vcLastProcessedID)

	SET @dtNullDateReplacement = '1990-01-01'

	select @iFromBusinessKey, @iToBusinessKey, @iLastProcessedID, @bPerformReprocessing, @bUseBusinessKey
	
	CREATE TABLE #FactPostTemp
	(
		CreationDate				DATETIME
		,ClosedDate					DATETIME
		,CommunityOwnedDate			DATETIME
		,BkOwnerUserId				INT
		,BkLastEditorUserId			INT
		,PostType					NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
		,AnswerCount				INT
		,CommentCount				INT
		,FavouriteCount				INT
		,ViewCount					INT
		,Score						INT
		,BkPostId					INT
	)
	
	IF (@bUseBusinessKey = 1 AND @bPerformReprocessing = 1)
	BEGIN

		INSERT INTO #FactPostTemp
		(
			CreationDate
			,ClosedDate
			,CommunityOwnedDate
			,BkOwnerUserId
			,BkLastEditorUserId
			,PostType
			,AnswerCount
			,CommentCount
			,FavouriteCount
			,ViewCount
			,Score	
			,BkPostId
		)
		SELECT
			P.CreationDate
			,ISNULL(P.ClosedDate, @dtNullDateReplacement)
			,ISNULL(P.CommunityOwnedDate, @dtNullDateReplacement)
			,P.OwnerUserId
			,P.LastEditorUserId
			,PT.[Type]
			,P.AnswerCount
			,P.CommentCount
			,P.FavoriteCount
			,P.ViewCount
			,P.Score
			,P.Id
		FROM
			StackOverflow..Posts P
			INNER JOIN StackOverflow..PostTypes PT
			ON P.PostTypeId = PT.Id
		WHERE
			P.Id >= @iFromBusinessKey AND P.Id <= @iToBusinessKey
	END

	IF (@bUseBusinessKey = 1 AND @bPerformReprocessing = 0)
	BEGIN

		INSERT INTO #FactPostTemp
		(
			CreationDate
			,ClosedDate
			,CommunityOwnedDate
			,BkOwnerUserId
			,BkLastEditorUserId
			,PostType
			,AnswerCount
			,CommentCount
			,FavouriteCount
			,ViewCount
			,Score	
			,BkPostId
		)
		SELECT
			P.CreationDate
			,ISNULL(P.ClosedDate, @dtNullDateReplacement)
			,ISNULL(P.CommunityOwnedDate, @dtNullDateReplacement)
			,P.OwnerUserId
			,P.LastEditorUserId
			,PT.[Type]
			,P.AnswerCount
			,P.CommentCount
			,P.FavoriteCount
			,P.ViewCount
			,P.Score
			,P.Id
		FROM
			StackOverflow..Posts P
			INNER JOIN StackOverflow..PostTypes PT
			ON P.PostTypeId = PT.Id
		WHERE
			P.Id > @iLastProcessedID

	END

	IF (@bUseBusinessKey = 0 AND @bPerformReprocessing = 1)
	BEGIN

		INSERT INTO #FactPostTemp
		(
			CreationDate
			,ClosedDate
			,CommunityOwnedDate
			,BkOwnerUserId
			,BkLastEditorUserId
			,PostType
			,AnswerCount
			,CommentCount
			,FavouriteCount
			,ViewCount
			,Score	
			,BkPostId
		)
		SELECT
			P.CreationDate
			,ISNULL(P.ClosedDate, @dtNullDateReplacement)
			,ISNULL(P.CommunityOwnedDate, @dtNullDateReplacement)
			,P.OwnerUserId
			,P.LastEditorUserId
			,PT.[Type]
			,P.AnswerCount
			,P.CommentCount
			,P.FavoriteCount
			,P.ViewCount
			,P.Score
			,P.Id
		FROM
			StackOverflow..Posts P
			INNER JOIN StackOverflow..PostTypes PT
			ON P.PostTypeId = PT.Id
		WHERE
			P.CreationDate >= @dtLastUpdatedOn AND P.CreationDate <= @dtEndDate

	END

	IF (@bUseBusinessKey = 0 AND @bPerformReprocessing = 0)
	BEGIN

		INSERT INTO #FactPostTemp
		(
			CreationDate
			,ClosedDate
			,CommunityOwnedDate
			,BkOwnerUserId
			,BkLastEditorUserId
			,PostType
			,AnswerCount
			,CommentCount
			,FavouriteCount
			,ViewCount
			,Score	
			,BkPostId
		)
		SELECT
			P.CreationDate
			,ISNULL(P.ClosedDate, @dtNullDateReplacement)
			,ISNULL(P.CommunityOwnedDate, @dtNullDateReplacement)
			,P.OwnerUserId
			,P.LastEditorUserId
			,PT.[Type]
			,P.AnswerCount
			,P.CommentCount
			,P.FavoriteCount
			,P.ViewCount
			,P.Score
			,P.Id
		FROM
			StackOverflow..Posts P
			INNER JOIN StackOverflow..PostTypes PT
			ON P.PostTypeId = PT.Id
		WHERE
			P.LastEditDate >= @dtLastUpdatedOn

	END

	--INSERT INTO #FactPostTemp
	--(
	--	CreationDate
	--	,ClosedDate
	--	,CommunityOwnedDate
	--	,BkOwnerUserId
	--	,BkLastEditorUserId
	--	,PostType
	--	,AnswerCount
	--	,CommentCount
	--	,FavouriteCount
	--	,ViewCount
	--	,Score	
	--	,BkPostId
	--)
	--SELECT
	--	P.CreationDate
	--	,P.ClosedDate
	--	,P.CommunityOwnedDate
	--	,P.OwnerUserId
	--	,P.LastEditorUserId
	--	,PT.[Type]
	--	,P.AnswerCount
	--	,P.CommentCount
	--	,P.FavoriteCount
	--	,P.ViewCount
	--	,P.Score
	--	,P.Id
	--FROM
	--	StackOverflow..Posts P
	--	INNER JOIN StackOverflow..PostTypes PT
	--	ON P.PostTypeId = PT.Id
	--WHERE
	--	( @bUseBusinessKey = 0
	--		AND 
	--		(
	--			(P.LastEditDate >= @dtLastUpdatedOn AND (@dtEndDate IS NULL OR P.LastEditDate <= @dtEndDate) AND @bPerformReprocessing = 0)
	--				OR 
	--			(P.CreationDate >= @dtLastUpdatedOn AND (@dtEndDate IS NULL OR P.CreationDate <= @dtEndDate) AND @bPerformReprocessing = 1)
	--		)
	--	)
	--	OR
	--	( @bUseBusinessKey = 1
	--		AND 
	--		(
	--			(@bPerformReprocessing = 1 AND P.Id >= @iFromBusinessKey AND P.Id <= @iToBusinessKey)
	--				OR
	--			(
	--				@bPerformReprocessing = 0				 
	--					AND 
	--				(P.Id > @iLastProcessedID)
	--			)
	--		)
	--	)
		
	INSERT INTO #FactPostTemp
	(
		CreationDate
		,ClosedDate
		,CommunityOwnedDate
		,BkOwnerUserId
		,BkLastEditorUserId
		,PostType
		,AnswerCount
		,CommentCount
		,FavouriteCount
		,ViewCount
		,Score	
		,BkPostId
	)
	SELECT
		P.CreationDate
		,P.ClosedDate
		,P.CommunityOwnedDate
		,P.BkOwnerUserId
		,P.BkLastEditorUserId
		,P.PostType
		,P.AnswerCount
		,P.CommentCount
		,P.FavouriteCount
		,P.ViewCount
		,P.Score
		,P.BkPostId
	FROM
		Stag.PostDetail P
		LEFT JOIN #FactPostTemp FPt
		ON P.BkPostId = FPt.BkPostId
	WHERE
		FPt.BkPostId IS NULL

	TRUNCATE TABLE Stag.PostDetail
	
	DELETE
	FROM FPt
	OUTPUT
		deleted.CreationDate
		,deleted.ClosedDate
		,deleted.CommunityOwnedDate
		,deleted.BkOwnerUserId
		,deleted.BkLastEditorUserId
		,deleted.PostType
		,deleted.AnswerCount
		,deleted.CommentCount
		,deleted.FavouriteCount
		,deleted.ViewCount
		,deleted.Score
		,deleted.BkPostId
		,'CreationDate does not exist in dimension'
	INTO Stag.PostDetail
	FROM
		#FactPostTemp FPt
	WHERE
		NOT EXISTS(SELECT 1 FROM Dim.[Date] D WHERE FPt.CreationDate >= D.[Date] AND FPt.CreationDate < D.NextDate)

	DELETE
	FROM FPt
	OUTPUT
		deleted.CreationDate
		,deleted.ClosedDate
		,deleted.CommunityOwnedDate
		,deleted.BkOwnerUserId
		,deleted.BkLastEditorUserId
		,deleted.PostType
		,deleted.AnswerCount
		,deleted.CommentCount
		,deleted.FavouriteCount
		,deleted.ViewCount
		,deleted.Score
		,deleted.BkPostId
		,'ClosedDate does not exist in dimension'
	INTO Stag.PostDetail
	FROM
		#FactPostTemp FPt
	WHERE
		NOT EXISTS(SELECT 1 FROM Dim.[Date] D WHERE FPt.ClosedDate >= D.[Date] AND FPt.ClosedDate < D.NextDate)

	DELETE
	FROM FPt
	OUTPUT
		deleted.CreationDate
		,deleted.ClosedDate
		,deleted.CommunityOwnedDate
		,deleted.BkOwnerUserId
		,deleted.BkLastEditorUserId
		,deleted.PostType
		,deleted.AnswerCount
		,deleted.CommentCount
		,deleted.FavouriteCount
		,deleted.ViewCount
		,deleted.Score
		,deleted.BkPostId
		,'CommunityOwnedDate does not exist in dimension'
	INTO Stag.PostDetail
	FROM
		#FactPostTemp FPt
	WHERE
		NOT EXISTS(SELECT 1 FROM Dim.[Date] D WHERE FPt.CommunityOwnedDate >= D.[Date] AND FPt.CommunityOwnedDate < D.NextDate)
		
	DELETE
	FROM FPt
	OUTPUT
		deleted.CreationDate
		,deleted.ClosedDate
		,deleted.CommunityOwnedDate
		,deleted.BkOwnerUserId
		,deleted.BkLastEditorUserId
		,deleted.PostType
		,deleted.AnswerCount
		,deleted.CommentCount
		,deleted.FavouriteCount
		,deleted.ViewCount
		,deleted.Score
		,deleted.BkPostId
		,'PostType does not exist in dimension'
	INTO Stag.PostDetail
	FROM
		#FactPostTemp FPt
	WHERE
		NOT EXISTS(SELECT 1 FROM Dim.PostType PT WHERE PT.PostType = FPt.PostType)
	
	DELETE
		PD
	FROM
		Fact.PostDetail PD
		INNER JOIN #FactPostTemp FPt
		ON PD.BkPostId = FPt.BkPostId

	INSERT INTO Fact.PostDetail
	(
		SkCreationDateId
		,SkClosedDateId
		,SkCommunityOwnedDate
		,BkOwnerUserId
		,BkLastEditorUserId
		,SkPostTypeId			
		,AnswerCount			
		,CommentCount			
		,FavouriteCount			
		,ViewCount				
		,Score					
		,BkPostId				
	)
	SELECT
		CD.pkDimDateId
		,CLD.pkDimDateId
		,COD.pkDimDateId
		,FPT.BkOwnerUserId
		,ISNULL(FPT.BkLastEditorUserId, 0)
		,PT.pkDimPostTypeId
		,FPT.AnswerCount
		,FPT.CommentCount
		,FPT.FavouriteCount
		,FPT.ViewCount
		,FPT.Score
		,FPT.BkPostId
	FROM
		#FactPostTemp FPt
		INNER JOIN Dim.[Date] CD ON FPt.CreationDate >= CD.[Date] AND FPt.CreationDate < CD.NextDate
		INNER JOIN Dim.[Date] CLD ON FPt.ClosedDate >= CLD.[Date] AND FPt.ClosedDate < CLD.NextDate
		INNER JOIN Dim.[Date] COD ON FPt.CommunityOwnedDate >= COD.[Date] AND FPt.CommunityOwnedDate < COD.NextDate
		INNER JOIN Dim.PostType PT ON PT.PostType = FPt.PostType

END
GO