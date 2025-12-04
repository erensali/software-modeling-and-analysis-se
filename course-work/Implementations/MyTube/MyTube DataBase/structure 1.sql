USE master;
GO

-- Проверка дали базата съществува.IF NOT CREATE
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MyTubeDB')
BEGIN
    CREATE DATABASE MyTubeDB;
END
GO

USE MyTubeDB;
GO

-- Създаваm  'mytube' за по-добра организация
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'mytube')
    EXEC('CREATE SCHEMA mytube');
GO

-- 1. Таблица (Users)
-- Основна таблица за всички акаунти
CREATE TABLE mytube.Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL, -- Тук пазим хеш, а не чиста парола
    FullName NVARCHAR(150),
    DateOfBirth DATE,
    Country NVARCHAR(100),
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsVerified BIT DEFAULT 0,
    IsPremium BIT DEFAULT 0
);
GO

-- 2. Таблица Канали (Channels)
-- Всеки канал си има собственик (OwnerUserID)
CREATE TABLE mytube.Channels (
    ChannelID INT IDENTITY(1,1) PRIMARY KEY,
    OwnerUserID INT NOT NULL,
    ChannelName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(1000),
    CreatedAt DATETIME DEFAULT GETDATE(),
    SubscribersCount INT DEFAULT 0,
    TotalVideos INT DEFAULT 0,
    CONSTRAINT FK_Channels_Owner FOREIGN KEY (OwnerUserID) REFERENCES mytube.Users(UserID)
);
GO

-- 3. Таблица Категории (Categories)
-- Използва се за филтриране на видеата
CREATE TABLE mytube.Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500)
);
GO

-- 4. Таблица Видеа (Videos)
-- Централната таблица. Свързана е с Канал и Категория.
CREATE TABLE mytube.Videos (
    VideoID INT IDENTITY(1,1) PRIMARY KEY,
    ChannelID INT NOT NULL,
    CategoryID INT NULL,
    Title NVARCHAR(250) NOT NULL,
    Description NVARCHAR(MAX),
    UploadDate DATETIME DEFAULT GETDATE(),
    DurationSeconds INT,
    ViewsCount BIGINT DEFAULT 0,
    LikesCount INT DEFAULT 0,
    DislikesCount INT DEFAULT 0,
    IsPublic BIT DEFAULT 1,
    Language NVARCHAR(10),
    CONSTRAINT FK_Videos_Channel FOREIGN KEY (ChannelID) REFERENCES mytube.Channels(ChannelID),
    CONSTRAINT FK_Videos_Category FOREIGN KEY (CategoryID) REFERENCES mytube.Categories(CategoryID)
);
GO

-- 5. Таблица Тагове (Tags)
CREATE TABLE mytube.Tags (
    TagID INT IDENTITY(1,1) PRIMARY KEY,
    TagName NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- 6. Връзка Видео-Тагове (VideoTags)
-- Междинна таблица за M:N връзка.
-- ON DELETE CASCADE: Ако изтрия видеото, се маха и връзката с тага.
CREATE TABLE mytube.VideoTags (
    VideoID INT NOT NULL,
    TagID INT NOT NULL,
    PRIMARY KEY (VideoID, TagID),
    CONSTRAINT FK_VideoTags_Video FOREIGN KEY (VideoID) REFERENCES mytube.Videos(VideoID) ON DELETE CASCADE,
    CONSTRAINT FK_VideoTags_Tag FOREIGN KEY (TagID) REFERENCES mytube.Tags(TagID) ON DELETE CASCADE
);
GO

-- 7. Таблица Плейлисти (Playlists)
CREATE TABLE mytube.Playlists (
    PlaylistID INT IDENTITY(1,1) PRIMARY KEY,
    OwnerUserID INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000),
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsPublic BIT DEFAULT 1,
    CONSTRAINT FK_Playlists_Owner FOREIGN KEY (OwnerUserID) REFERENCES mytube.Users(UserID)
);
GO

-- 8. Връзка Плейлист-Видеа (PlaylistVideos)
-- Още една M:N таблица. Едно видео може да е в много плейлисти.
CREATE TABLE mytube.PlaylistVideos (
    PlaylistID INT NOT NULL,
    VideoID INT NOT NULL,
    SortOrder INT DEFAULT 0,
    PRIMARY KEY (PlaylistID, VideoID),
    CONSTRAINT FK_PlaylistVideos_Playlist FOREIGN KEY (PlaylistID) REFERENCES mytube.Playlists(PlaylistID) ON DELETE CASCADE,
    CONSTRAINT FK_PlaylistVideos_Video FOREIGN KEY (VideoID) REFERENCES mytube.Videos(VideoID) ON DELETE CASCADE
);
GO

-- 9. Таблица Коментари (Comments)
-- Има ParentCommentID за отговори на коментари (Self-Referencing)
CREATE TABLE mytube.Comments (
    CommentID INT IDENTITY(1,1) PRIMARY KEY,
    VideoID INT NOT NULL,
    UserID INT NOT NULL,
    ParentCommentID INT NULL,
    Text NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    Likes INT DEFAULT 0,
    CONSTRAINT FK_Comments_Video FOREIGN KEY (VideoID) REFERENCES mytube.Videos(VideoID) ON DELETE NO ACTION,
    CONSTRAINT FK_Comments_User FOREIGN KEY (UserID) REFERENCES mytube.Users(UserID) ON DELETE NO ACTION,
    CONSTRAINT FK_Comments_Parent FOREIGN KEY (ParentCommentID) REFERENCES mytube.Comments(CommentID) ON DELETE NO ACTION
);
GO

-- 10. Таблица Абонаменти (Subscriptions)
-- M:N връзка между User и Channel
CREATE TABLE mytube.Subscriptions (
    SubscriberUserID INT NOT NULL,
    ChannelID INT NOT NULL,
    SubscribedAt DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (SubscriberUserID, ChannelID),
    CONSTRAINT FK_Subscriptions_User FOREIGN KEY (SubscriberUserID) REFERENCES mytube.Users(UserID) ON DELETE CASCADE,
    CONSTRAINT FK_Subscriptions_Channel FOREIGN KEY (ChannelID) REFERENCES mytube.Channels(ChannelID) ON DELETE CASCADE
);
GO

-- 11. Таблица Реакции (Reactions)
-- Пази кой user какво е харесал. UNIQUE гарантира само 1 лайк на видео.
CREATE TABLE mytube.Reactions (
    ReactionID INT IDENTITY(1,1) PRIMARY KEY,
    VideoID INT NOT NULL,
    UserID INT NOT NULL,
    ReactionType TINYINT NOT NULL, -- 1=Like, 0=Dislike
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Reactions_Video FOREIGN KEY (VideoID) REFERENCES mytube.Videos(VideoID) ON DELETE CASCADE,
    CONSTRAINT FK_Reactions_User FOREIGN KEY (UserID) REFERENCES mytube.Users(UserID) ON DELETE NO ACTION,
    CONSTRAINT UQ_Reaction_UserVideo UNIQUE (VideoID, UserID)
);
GO

-- 12. Дневна Статистика (VideoDailyStats)
CREATE TABLE mytube.VideoDailyStats (
    StatID INT IDENTITY(1,1) PRIMARY KEY,
    VideoID INT NOT NULL,
    StatDate DATE NOT NULL,
    ViewsCount INT DEFAULT 0,
    WatchSeconds BIGINT DEFAULT 0,
    LikesCount INT DEFAULT 0,
    DislikesCount INT DEFAULT 0,
    CONSTRAINT FK_VideoDailyStats_Video FOREIGN KEY (VideoID) REFERENCES mytube.Videos(VideoID)
);
GO

-- 13. Таблица за Логове (VideoLog)
-- Тази таблица е нужна специално за Тригера
CREATE TABLE mytube.VideoLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    VideoID INT,
    ActionType NVARCHAR(255),
    LogDate DATETIME DEFAULT GETDATE()
);
GO

-- Индекси за по-бързо търсене
CREATE INDEX IX_Videos_UploadDate ON mytube.Videos(UploadDate);
CREATE INDEX IX_Users_Country ON mytube.Users(Country);
GO