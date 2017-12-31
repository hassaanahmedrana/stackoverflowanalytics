--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'dbo' AND SPECIFIC_NAME = 'FactUser')
BEGIN
	DROP PROCEDURE dbo.FactUser
END
GO

CREATE PROCEDURE dbo.FactUser
AS
BEGIN



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

	EXEC Etl.GetLastProcessedTime 'FactUser', @dtLastUpdatedOn OUTPUT, @dtEndDate OUTPUT

	EXEC Etl.GetReprocessStatus 'FactUser', @bPerformReprocessing OUTPUT

	EXEC Etl.GetUseBusinessKeyStatus 'FactUser', @bUseBusinessKey OUTPUT

	EXEC Etl.GetBusinessKeyRange 'FactUser', @vcFromBusinessKey OUTPUT, @vcToBusinessKey OUTPUT

	EXEC Etl.GetLastProcessedID 'FactUser', @vcLastProcessedID OUTPUT

	SET @iFromBusinessKey = CONVERT(INT, @vcFromBusinessKey)

	SET @iToBusinessKey = CONVERT(INT, @vcToBusinessKey)

	SET @iLastProcessedID = CONVERT(INT, @vcLastProcessedID)

	SET @dtNullDateReplacement = '1990-01-01'

	CREATE TABLE #FactUserTemp
	(
		CreationDate				DATETIME
		,LastAccessDate				DATETIME
		,Reputation					INT
		,UpVotes					INT
		,DownVotes					INT
		,[Views]					INT
		,Age						INT
		,DisplayName				NVARCHAR(40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
		,BkUserId					INT
	)

	IF (@bUseBusinessKey = 1 AND @bPerformReprocessing = 1)
	BEGIN
	print 'da'
		INSERT INTO #FactUserTemp
		(
			CreationDate
			,LastAccessDate
			,Reputation
			,UpVotes
			,DownVotes
			,[Views]
			,Age	
			,DisplayName
			,BkUserId
		)
		SELECT
			U.CreationDate
			,U.LastAccessDate
			,U.Reputation
			,U.UpVotes
			,U.DownVotes
			,U.[Views]
			,U.Age
			,U.DisplayName
			,U.Id
		FROM
			StackOverflow..Users U
	END

	INSERT INTO #FactUserTemp
	(
		CreationDate
		,LastAccessDate
		,Reputation
		,UpVotes
		,DownVotes
		,[Views]
		,Age	
		,DisplayName
		,BkUserId
	)
	SELECT
		UD.CreationDate
		,UD.LastAccessDate
		,UD.Reputation
		,UD.UpVotes
		,UD.DownVotes
		,UD.[Views]
		,UD.Age
		,UD.DisplayName
		,UD.BkUserId
	FROM
		Stag.UserDetail UD
		LEFT JOIN #FactUserTemp FUt
		ON UD.BkUserId = FUt.BkUserId
	WHERE
		FUt.BkUserId IS NULL

	TRUNCATE TABLE Stag.UserDetail

	DELETE
	FROM FUt
	OUTPUT
		deleted.CreationDate
		,deleted.LastAccessDate
		,deleted.Reputation
		,deleted.UpVotes
		,deleted.DownVotes
		,deleted.[Views]
		,deleted.Age
		,deleted.DisplayName
		,deleted.BkUserId
		,'CreationDate does not exist in dimension'
	INTO Stag.UserDetail
	FROM
		#FactUserTemp FUt
		LEFT JOIN Dim.[Date] D ON CONVERT(DATE,FUt.CreationDate) = D.[Date]
	WHERE
		D.pkDimDateId IS NULL

	DELETE
	FROM FUt
	OUTPUT
		deleted.CreationDate
		,deleted.LastAccessDate
		,deleted.Reputation
		,deleted.UpVotes
		,deleted.DownVotes
		,deleted.[Views]
		,deleted.Age
		,deleted.DisplayName
		,deleted.BkUserId
		,'LastAccessDate does not exist in dimension'
	INTO Stag.UserDetail
	FROM
		#FactUserTemp FUt
		LEFT JOIN Dim.[Date] D ON CONVERT(DATE,FUt.LastAccessDate) = D.[Date]
	WHERE
		D.pkDimDateId IS NULL

	DELETE
		UD
	FROM 
		Fact.UserDetail UD
		INNER JOIN #FactUserTemp FUt
		ON UD.BkUserId = FUt.BkUserId

	INSERT INTO Fact.UserDetail
	(
		SkCreationDateId
		,SkLastAccessDateId
		,Reputation
		,UpVotes
		,DownVotes
		,[Views]
		,Age
		,DisplayName
		,BkUserId
	)
	SELECT
		ISNULL(CD.pkDimDateId, 1)
		,ISNULL(LAD.pkDimDateId, 1)
		,FUt.Reputation
		,FUt.UpVotes
		,FUt.DownVotes
		,FUt.[Views]
		,FUt.Age
		,FUt.DisplayName
		,FUt.BkUserId
	FROM
		#FactUserTemp FUt
		INNER JOIN Dim.[Date] CD
		ON CONVERT(DATE,FUt.CreationDate) = CD.[Date]
		INNER JOIN Dim.[Date] LAD
		ON CONVERT(DATE,FUt.LastAccessDate) = LAD.[Date]
END
GO