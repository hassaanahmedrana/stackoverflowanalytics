--Created By - Hassaan Ahmed Rana

--Modified By


USE StackOverflowAnalytics
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'Etl' AND SPECIFIC_NAME = 'GetMeasureGroupPartition')
BEGIN
	DROP PROCEDURE Etl.GetMeasureGroupPartition
END
GO

CREATE PROCEDURE Etl.GetMeasureGroupPartition
	@rvcCubeID				VARCHAR(80)
	,@rvcMeasureGroupID		VARCHAR(80) 
	,@rdtStartDate			DATETIME
	,@rdtEndDate			DATETIME
AS
BEGIN

	SET NOCOUNT ON;

	WITH MeasureGroupDetail
	AS
	(
		SELECT
			MGP.DataSourceID
			,MGP.BindingType
			,MGP.BindingSource
			,MGP.Slice
			,CASE
				WHEN PATINDEX('%@Year%', MGP.PeriodCovered) > 0 THEN D.[Year]
				ELSE NULL END [Year]
			,CASE
				WHEN PATINDEX('%@Month%', MGP.PeriodCovered) > 0 THEN D.[MonthOfYear]
				ELSE NULL END [MonthOfYear]
			,CASE
				WHEN PATINDEX('%@Week%', MGP.PeriodCovered) > 0 THEN D.[WeekOfYear]
				ELSE NULL END [WeekOfYear]
		FROM
			Etl.MeasureGroupPartition MGP
			CROSS JOIN 
			(
				SELECT
					DISTINCT
					D.[Year]
					,D.MonthOfYear
					,D.WeekOfYear
				FROM
					Dim.[Date] D
				WHERE
					D.[Date] BETWEEN @rdtStartDate AND @rdtEndDate
			) D
		WHERE
			MGP.CubeID = @rvcCubeID
			AND MGP.MeasureGroupID = @rvcMeasureGroupID
	)

	SELECT
		MGD.DataSourceID
		,MGD.BindingType
		,REPLACE(
			REPLACE(
				REPLACE(MGD.BindingSource ,'@Week', ISNULL(MGD.WeekOfYear, '')), '@Month', ISNULL(MGD.MonthOfYear,'')), '@Year', ISNULL(MGD.[Year],'')) BindingSource
		,REPLACE(
			REPLACE(
				REPLACE(MGD.Slice ,'@Week', ISNULL(MGD.WeekOfYear, '')), '@Month', ISNULL(MGD.MonthOfYear,'')), '@Year', ISNULL(MGD.[Year],'')) Slice
		,@rvcMeasureGroupID 
			+ ISNULL('_Y' + CAST(MGD.[Year] AS CHAR(4)), '')
			+ ISNULL('_M' + CAST(MGD.MonthOfYear AS CHAR(2)), '')
			+ ISNULL('_W' + CAST(MGD.WeekOfYear AS CHAR(2)), '') PartitionName
	FROM
		MeasureGroupDetail MGD

END
GO