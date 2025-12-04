USE MyTubeDB;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dw')
    EXEC('CREATE SCHEMA dw');
GO

-- ЧАСТ 1: ИЗМЕРЕНИЯ (DIMENSIONS)


CREATE OR ALTER VIEW dw.DimUser AS
SELECT UserID AS UserKey, Username, Country, IsPremium, CreatedAt AS DateJoined FROM mytube.Users;
GO

CREATE OR ALTER VIEW dw.DimChannel AS
SELECT ChannelID AS ChannelKey, ChannelName, OwnerUserID FROM mytube.Channels;
GO

CREATE OR ALTER VIEW dw.DimVideo AS
SELECT VideoID AS VideoKey, Title, DurationSeconds, CategoryID, Language, UploadDate FROM mytube.Videos;
GO

CREATE OR ALTER VIEW dw.DimDate AS
SELECT DISTINCT CAST(UploadDate AS DATE) AS DateKey, YEAR(UploadDate) AS [Year], MONTH(UploadDate) AS [Month], DAY(UploadDate) AS [Day]
FROM mytube.Videos;
GO

CREATE OR ALTER VIEW dw.DimGeography AS
SELECT DISTINCT Country AS GeoKey FROM mytube.Users WHERE Country IS NOT NULL;
GO


-- ЧАСТ 2: ФАКТИ (FACTS)


CREATE OR ALTER VIEW dw.FactVideoViews AS
SELECT VideoID AS VideoKey, ViewsCount, (ViewsCount * DurationSeconds) AS WatchSeconds FROM mytube.Videos;
GO

CREATE OR ALTER VIEW dw.FactVideoReactions AS
SELECT VideoID AS VideoKey, UserID AS UserKey, ReactionType, 1 AS ReactionCount FROM mytube.Reactions;
GO


-- ЧАСТ 3: ГОТОВИ ОТЧЕТИ ЗА POWER BI (REPORTING VIEWS)


--  1. Топ 10 най-гледани видеа (Bar Chart)
CREATE OR ALTER VIEW dw.vw_TopVideos AS
SELECT TOP 10 v.Title, SUM(f.ViewsCount) AS TotalViews
FROM dw.FactVideoViews f
JOIN dw.DimVideo v ON f.VideoKey = v.VideoKey
GROUP BY v.Title
ORDER BY TotalViews DESC;
GO

-- 2. Активност на потребителите (Donut Chart)
CREATE OR ALTER VIEW dw.vw_UserEngagement AS
SELECT u.Username, COUNT(fr.UserKey) AS TotalReactions
FROM dw.DimUser u
LEFT JOIN dw.FactVideoReactions fr ON fr.UserKey = u.UserKey
GROUP BY u.Username;
GO

--  3. Карта на света (Map Data)
CREATE OR ALTER VIEW dw.vw_MapData AS
SELECT 
    u.Country,
    SUM(v.ViewsCount) AS TotalViews
FROM mytube.Videos v
JOIN mytube.Channels c ON v.ChannelID = c.ChannelID
JOIN mytube.Users u ON c.OwnerUserID = u.UserID
WHERE u.Country IS NOT NULL
GROUP BY u.Country;
GO

-- 4. Гледания по Категории (Treemap)
USE MyTubeDB;
GO
CREATE OR ALTER VIEW dw.vw_CategoryStats AS
SELECT 
    c.Name AS CategoryName,
    SUM(v.ViewsCount) AS TotalViews
FROM mytube.Videos v
JOIN mytube.Categories c ON v.CategoryID = c.CategoryID
GROUP BY c.Name;
GO

