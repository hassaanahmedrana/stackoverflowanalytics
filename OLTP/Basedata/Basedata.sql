USE StackOverflowAnalytics
GO

IF NOT EXISTS (SELECT 1 FROM Dim.[Time])
BEGIN
	INSERT INTO Dim.[Time] SELECT 0, 1, 'AM', 'Night', '00:00'
	INSERT INTO Dim.[Time] SELECT 1, 2, 'AM', 'Night', '01:00'
	INSERT INTO Dim.[Time] SELECT 2, 3, 'AM', 'Night', '02:00'
	INSERT INTO Dim.[Time] SELECT 3, 4, 'AM', 'Night', '03:00'
	INSERT INTO Dim.[Time] SELECT 4, 5, 'AM', 'Morning', '04:00'
	INSERT INTO Dim.[Time] SELECT 5, 6, 'AM', 'Morning', '05:00'
	INSERT INTO Dim.[Time] SELECT 6, 7, 'AM', 'Morning', '06:00'
	INSERT INTO Dim.[Time] SELECT 7, 8, 'AM', 'Morning', '07:00'
	INSERT INTO Dim.[Time] SELECT 8, 9, 'AM', 'Morning', '08:00'
	INSERT INTO Dim.[Time] SELECT 9, 10, 'AM', 'Morning', '09:00'
	INSERT INTO Dim.[Time] SELECT 10, 11, 'AM', 'Morning', '10:00'
	INSERT INTO Dim.[Time] SELECT 11, 12, 'AM', 'Morning', '11:00'
	INSERT INTO Dim.[Time] SELECT 12, 13, 'PM', 'Afternoon', '12:00'
	INSERT INTO Dim.[Time] SELECT 13, 14, 'PM', 'Afternoon', '13:00'
	INSERT INTO Dim.[Time] SELECT 14, 15, 'PM', 'Afternoon', '14:00'
	INSERT INTO Dim.[Time] SELECT 15, 16, 'PM', 'Afternoon', '15:00'
	INSERT INTO Dim.[Time] SELECT 16, 17, 'PM', 'Afternoon', '16:00'
	INSERT INTO Dim.[Time] SELECT 17, 18, 'PM', 'Evening', '17:00'
	INSERT INTO Dim.[Time] SELECT 18, 19, 'PM', 'Evening', '18:00'
	INSERT INTO Dim.[Time] SELECT 19, 20, 'PM', 'Evening', '19:00'
	INSERT INTO Dim.[Time] SELECT 20, 21, 'PM', 'Evening', '20:00'
	INSERT INTO Dim.[Time] SELECT 21, 22, 'PM', 'Night', '21:00'
	INSERT INTO Dim.[Time] SELECT 22, 23, 'PM', 'Night', '22:00'
	INSERT INTO Dim.[Time] SELECT 23, 24, 'PM', 'Night', '23:00'
END
GO

IF NOT EXISTS (SELECT 1 FROM Etl.[Procedure] WHERE Name = 'DimDate')
BEGIN
	INSERT INTO Etl.[Procedure](Name, LastExecutedOn, LastProcessedID, SequenceNumber, IsActive, PerformReprocessing)
	SELECT 'DimDate', '19000101', NULL, 1, 1, 0
END
GO

IF NOT EXISTS (SELECT 1 FROM Etl.[Procedure] WHERE Name = 'DimPostType')
BEGIN
	INSERT INTO Etl.[Procedure](Name, LastExecutedOn, LastProcessedID, SequenceNumber, IsActive, PerformReprocessing)
	SELECT 'DimPostType', '19000101', NULL, 2, 1, 0
END
GO

IF NOT EXISTS (SELECT 1 FROM Etl.[Procedure] WHERE Name = 'DimVoteType')
BEGIN
	INSERT INTO Etl.[Procedure](Name, LastExecutedOn, LastProcessedID, SequenceNumber, IsActive, PerformReprocessing)
	SELECT 'DimVoteType', '19000101', NULL, 3, 1, 0
END
GO

IF NOT EXISTS (SELECT 1 FROM Etl.[Procedure] WHERE Name = 'FactUser')
BEGIN
	INSERT INTO Etl.[Procedure](Name, LastExecutedOn, LastProcessedID, SequenceNumber, IsActive, PerformReprocessing)
	SELECT 'FactUser', '19000101', NULL, 4, 1, 1
END
GO

IF NOT EXISTS (SELECT 1 FROM Etl.[Procedure] WHERE Name = 'FactPost')
BEGIN
	INSERT INTO Etl.[Procedure](Name, LastExecutedOn, LastProcessedID, SequenceNumber, IsActive, PerformReprocessing)
	SELECT 'FactPost', '19000101', NULL, 5, 1, 1
END
GO

IF NOT EXISTS (SELECT 1 FROM Etl.[Procedure] WHERE Name = 'FactVote')
BEGIN
	INSERT INTO Etl.[Procedure](Name, LastExecutedOn, LastProcessedID, SequenceNumber, IsActive, PerformReprocessing)
	SELECT 'FactVote', '19000101', NULL, 6, 1, 1
END
GO

IF NOT EXISTS (SELECT 1 FROM Etl.[Procedure] WHERE Name = 'FactBadge')
BEGIN
	INSERT INTO ETl.[Procedure](Name, LastExecutedOn, LastProcessedID, SequenceNumber, IsActive, PerformReprocessing)
	SELECT 'FactBadge', '19000101', NULL, 7, 1, 1
END
GO

IF NOT EXISTS(SELECT 1 FROM Etl.MeasureGroupPartition WHERE DataSourceID = 'StackOverflowAnalytics' AND CubeID = 'StackOverflowAnalytics' AND MeasureGroupID = 'PostDetail')
BEGIN
	INSERT INTO Etl.MeasureGroupPartition(DataSourceID, CubeID, MeasureGroupID, BindingType, BindingSource, Slice, PeriodCovered)
	SELECT 'StackOverflowAnalytics', 'StackOverflowAnalytics', 'PostDetail', 'Query',
	'SELECT * FROM Fact.PostDetail PD WHERE EXISTS( SELECT 1 FROM Dim.[Date] D WHERE PD.SkCreationDateId = D.pkDimDateId AND D.[Year] = @Year AND D.[MonthOfYear] = @Month AND D.[WeekOfYear] = @Week)',
	'[Date].[Calendar].[Week].&[@Week].&[@Month].&[@Year]', '@Year,@Month,@Week'

END
GO