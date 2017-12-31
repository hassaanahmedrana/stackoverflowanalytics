--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'dbo' AND SPECIFIC_NAME = 'DimDate')
BEGIN
	DROP PROCEDURE DimDate
END
GO

CREATE PROCEDURE DimDate
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @dtStartTime DATETIME = '19900101'
	DECLARE @dtEndTime DATETIME = '20201231'

	WHILE(@dtStartTime <= @dtEndTime)
	BEGIN
		
	INSERT INTO Dim.[Date]([Date], DateDescription, [Year], YearDescription, [MonthOfYear], MonthDescription, WeekOfYear, WeekDescription)
	SELECT 
		CONVERT(DATE, @dtStartTime)
		,FORMAT(@dtStartTime , 'd', 'en-gb' )
		, DATEPART(YEAR, @dtStartTime)
		,'Year ' + DATENAME(YEAR, @dtStartTime)
		,DATEPART(MONTH, @dtStartTime)
		,DATENAME(MONTH, @dtStartTime)
		,DATEPART(WEEK, @dtStartTime)
		,'Week ' + DATENAME(WEEK, @dtStartTime)
		SET @dtStartTime = DATEADD(D, 1, @dtStartTime)
	END	

	Exec Etl.UpdateActiveStatus 'DimDate', 0

END
GO