--Created By - Hassaan Ahmed Rana - 22-12-2016

--Modified By


IF NOT EXISTS (SELECT 1 FROM master.dbo.sysdatabases WHERE name = 'StackOverflowAnalytics')
BEGIN
	CREATE DATABASE StackOverflowAnalytics
END
GO

USE StackOverflowAnalytics
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'Dim')
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA Dim'
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'Fact')
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA Fact'
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'Stag')
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA Stag'
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'Etl')
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA Etl'
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'Log')
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA Log'
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Dim' AND TABLE_NAME = 'Date')
BEGIN
	CREATE TABLE Dim.[Date]
	(
		pkDimDateId				INT IDENTITY(1,1) PRIMARY KEY
		,[Year]					INT
		,[MonthOfYear]			TINYINT
		,[WeekOfYear]			TINYINT
		,[Date]					DATE
		,YearDescription		VARCHAR(20)
		,WeekDescription		VARCHAR(20)
		,MonthDescription		VARCHAR(20)
		,DateDescription		VARCHAR(20)
	)
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Dim' AND TABLE_NAME = 'Time')
BEGIN
	CREATE TABLE Dim.[Time]
	(
		pkDimTimeId				INT IDENTITY(1,1) PRIMARY KEY
		,StartHour				TINYINT
		,EndHour				TINYINT
		,Meridian				CHAR(2)
		,[Description]			VARCHAR(20)
		,HourDescription		VARCHAR(5)
	)
END
GO


IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Dim' AND TABLE_NAME = 'PostType')
BEGIN
	CREATE TABLE Dim.PostType
	(
		pkDimPostTypeId			INT IDENTITY(1,1) PRIMARY KEY
		,PostType				NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
	)
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Dim' AND TABLE_NAME = 'VoteType')
BEGIN
	CREATE TABLE Dim.VoteType
	(
		pkDimVoteTypeId			INT IDENTITY(1,1) PRIMARY KEY
		,VoteType				NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
	)
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Dim' AND TABLE_NAME = 'Technology')
BEGIN
	CREATE TABLE Dim.Technology
	(
		pkDimTechnologyId	INT IDENTITY(1,1) PRIMARY KEY
		,[Name]				NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
	)
END
GO

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Fact' AND TABLE_NAME = 'UserDetail')
BEGIN
	CREATE TABLE Fact.UserDetail
	(
		SkCreationDateId			INT
		,SkLastAccessDateId			INT
		,Reputation					INT
		,UpVotes					INT
		,DownVotes					INT
		,[Views]					INT
		,Age						INT
		,DisplayName				NVARCHAR(40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL	
		,BkUserId					INT
	)								
END
GO

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Stag' AND TABLE_NAME = 'UserDetail')
BEGIN
	CREATE TABLE Stag.UserDetail
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
		,Reason						VARCHAR(160)
	)
END
GO

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Fact' AND TABLE_NAME = 'PostDetail')
BEGIN
	CREATE TABLE Fact.PostDetail
	(
		SkCreationDateId			INT
		,SkClosedDateId				INT
		,SkCommunityOwnedDate		INT
		,BkOwnerUserId				INT
		,BkLastEditorUserId			INT
		,SkPostTypeId				INT
		,AnswerCount				INT
		,CommentCount				INT
		,FavouriteCount				INT
		,ViewCount					INT
		,Score						INT
		,BkPostId					INT
	)
END
GO

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Stag' AND TABLE_NAME = 'PostDetail')
BEGIN
	CREATE TABLE Stag.PostDetail
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
		,Reason						VARCHAR(160)
	)
END
GO

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Fact' AND TABLE_NAME = 'VoteDetail')
BEGIN
	CREATE TABLE Fact.VoteDetail
	(
		SkOwnerUserId			INT
		,SkPostId				INT
		,SkVoteTypeId			INT
		,BountyAmount			INT
		,BkVoteId				INT
	)
END
GO

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Stag' AND TABLE_NAME = 'VoteDetail')
BEGIN
	CREATE TABLE Stag.VoteDetail
	(
		PostId				INT
		,UserId				INT
		,VoteType			NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
		,BountyAmount		INT
		,BkVoteId			INT
		,Reason				VARCHAR(160)
	)
END
GO

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Fact' AND TABLE_NAME = 'BadgeDetail')
BEGIN
	CREATE TABLE Fact.BadgeDetail
	(
		[Name]				NVARCHAR(50)
		,SkOwnerUserId		INT
		,SkDateId			INT
		,BkBadgeId			INT
	)
END
GO

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Stag' AND TABLE_NAME = 'BadgeDetail')
BEGIN
	CREATE TABLE Stag.BadgeDetail
	(
		[Name]				NVARCHAR(50)
		,UserId				INT
		,CreationDate		DATE
		,BkBadgeId			INT
		,Reason				VARCHAR(160)
	)
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Log' AND TABLE_NAME = 'Procedure')
BEGIN
	CREATE TABLE [Log].[Procedure]
	(
		pkProcedureId				INT IDENTITY(1,1) PRIMARY KEY
		,[Name]						VARCHAR(80)
		,enmType					INT
		,Severity					INT
		,[Description]				VARCHAR(1024)
		,[CreatedOn]				DATETIME
	)
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Etl' AND TABLE_NAME = 'Procedure')
BEGIN
	CREATE TABLE Etl.[Procedure]
	(
		pkProcedureId				INT IDENTITY(1,1) PRIMARY KEY
		,[Name]						VARCHAR(80)	UNIQUE
		,LastExecutedOn				DATETIME
		,LastProcessedID			VARCHAR(80)
		,SequenceNumber				INT
		,IsActive					BIT DEFAULT 1
		,PerformReprocessing		BIT DEFAULT 0
		,UseBusinessKey				BIT DEFAULT 0
		,StartDate					DATETIME
		,EndDate					DATETIME
		,FromBusinessKey			VARCHAR(80)
		,ToBusinessKey				VARCHAR(80)
	)
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Etl' AND TABLE_NAME = 'MeasureGroupPartition')
BEGIN
	CREATE TABLE Etl.MeasureGroupPartition
	(
		pkMeasureGroupPartitionId	INT IDENTITY(1,1) PRIMARY KEY
		,DataSourceID				VARCHAR(80)
		,CubeID						VARCHAR(80)
		,MeasureGroupID				VARCHAR(80)
		,BindingType				VARCHAR(80)
		,BindingSource				VARCHAR(MAX)
		,Slice						VARCHAR(80)
		,PeriodCovered				VARCHAR(80)
	)
END
GO