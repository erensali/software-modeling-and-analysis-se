USE MyTubeDB;
GO


-- 1. ИЗЧИСТВАНЕ НА ВСИЧКИ СТАРИ ДАННИ (RESET)


DELETE FROM mytube.Reactions;
DELETE FROM mytube.Subscriptions;
DELETE FROM mytube.Comments;
DELETE FROM mytube.PlaylistVideos;
DELETE FROM mytube.Playlists;
DELETE FROM mytube.VideoTags;
DELETE FROM mytube.Tags;
DELETE FROM mytube.VideoDailyStats;
DELETE FROM mytube.VideoLog;
DELETE FROM mytube.Videos;
DELETE FROM mytube.Categories;
DELETE FROM mytube.Channels;
DELETE FROM mytube.Users;

-- Нулиране на ID броячите (за да започват от 1)
DBCC CHECKIDENT ('mytube.Users', RESEED, 0);
DBCC CHECKIDENT ('mytube.Channels', RESEED, 0);
DBCC CHECKIDENT ('mytube.Categories', RESEED, 0);
DBCC CHECKIDENT ('mytube.Videos', RESEED, 0);
DBCC CHECKIDENT ('mytube.Tags', RESEED, 0);
DBCC CHECKIDENT ('mytube.Playlists', RESEED, 0);
DBCC CHECKIDENT ('mytube.Comments', RESEED, 0);
DBCC CHECKIDENT ('mytube.Reactions', RESEED, 0);
GO


-- 2. СЪЗДАВАНЕ НА ПОТРЕБИТЕЛИ (БГ + СВЯТ)



-- Български
INSERT INTO mytube.Users (Username, Email, PasswordHash, FullName, Country, IsVerified) VALUES
(N'Ivan123', N'ivan@example.com', N'hash1', N'Ivan Petrov', N'Bulgaria', 1),
(N'MariaBG', N'maria@example.com', N'hash2', N'Maria Georgieva', N'Bulgaria', 1),
(N'AlexTech', N'alex@example.com', N'hash3', N'Alex Ivanov', N'UK', 0);

-- Чуждестранни (За Картата и Донут чарта)
INSERT INTO mytube.Users (Username, Email, PasswordHash, FullName, Country, IsVerified) VALUES
(N'JohnUSA', N'john@usa.com', N'h1', N'John Smith', N'USA', 1),
(N'HansGermany', N'hans@de.com', N'h2', N'Hans Muller', N'Germany', 0),
(N'YukiJapan', N'yuki@jp.com', N'h3', N'Yuki Tanaka', N'Japan', 1),
(N'CarlosBrazil', N'carlos@br.com', N'h4', N'Carlos Silva', N'Brazil', 0),
(N'PierreFrance', N'pierre@fr.com', N'h5', N'Pierre Dupont', N'France', 0),
(N'RajIndia', N'raj@in.com', N'h6', N'Raj Patel', N'India', 1);
GO


-- 3. СЪЗДАВАНЕ НА КАНАЛИ

PRINT '📥 Зареждане на канали...';

-- Взимаме ID-тата динамично, за да няма грешки
DECLARE @Ivan INT = (SELECT UserID FROM mytube.Users WHERE Username = 'Ivan123');
DECLARE @Maria INT = (SELECT UserID FROM mytube.Users WHERE Username = 'MariaBG');
DECLARE @Alex INT = (SELECT UserID FROM mytube.Users WHERE Username = 'AlexTech');
DECLARE @John INT = (SELECT UserID FROM mytube.Users WHERE Username = 'JohnUSA');
DECLARE @Hans INT = (SELECT UserID FROM mytube.Users WHERE Username = 'HansGermany');
DECLARE @Yuki INT = (SELECT UserID FROM mytube.Users WHERE Username = 'YukiJapan');
DECLARE @Carlos INT = (SELECT UserID FROM mytube.Users WHERE Username = 'CarlosBrazil');
DECLARE @Pierre INT = (SELECT UserID FROM mytube.Users WHERE Username = 'PierreFrance');
DECLARE @Raj INT = (SELECT UserID FROM mytube.Users WHERE Username = 'RajIndia');

INSERT INTO mytube.Channels (OwnerUserID, ChannelName, Description) VALUES
(@Ivan, N'IvanTech', N'BG Tech Reviews'),
(@Maria, N'MariaTravel', N'Vlogs around the world'),
(@Alex, N'AlexGaming', N'Gaming clips'),
(@John, N'Tech USA', N'Silicon Valley News'),
(@Hans, N'German Engineering', N'Cars & Machines'),
(@Yuki, N'Tokyo Life', N'Vlogs form Japan'),
(@Carlos, N'Rio Football', N'Joga Bonito'),
(@Pierre, N'French Cuisine', N'Cooking Masterclass'),
(@Raj, N'Bollywood Hits', N'Music & Dance');


-- 4. СЪЗДАВАНЕ НА КАТЕГОРИИ И ТАГОВЕ

INSERT INTO mytube.Categories (Name, Description) VALUES 
(N'Технологии', N'IT'), (N'Пътувания', N'Vlog'), (N'Гейминг', N'Games'), (N'Спорт', N'Sport'), (N'Музика', N'Music');

INSERT INTO mytube.Tags (TagName) VALUES 
(N'tech'), (N'vlog'), (N'game'), (N'travel'), (N'food'), (N'music'), (N'football');

-- 5. СЪЗДАВАНЕ НА ВИДЕА (С МНОГО ГЛЕДАНИЯ)


DECLARE @Ch_Ivan INT = (SELECT ChannelID FROM mytube.Channels WHERE ChannelName = 'IvanTech');
DECLARE @Ch_Maria INT = (SELECT ChannelID FROM mytube.Channels WHERE ChannelName = 'MariaTravel');
DECLARE @Ch_Alex INT = (SELECT ChannelID FROM mytube.Channels WHERE ChannelName = 'AlexGaming');
DECLARE @Ch_John INT = (SELECT ChannelID FROM mytube.Channels WHERE ChannelName = 'Tech USA');
DECLARE @Ch_Yuki INT = (SELECT ChannelID FROM mytube.Channels WHERE ChannelName = 'Tokyo Life');
DECLARE @Ch_Raj INT = (SELECT ChannelID FROM mytube.Channels WHERE ChannelName = 'Bollywood Hits');
DECLARE @Ch_Hans INT = (SELECT ChannelID FROM mytube.Channels WHERE ChannelName = 'German Engineering');
DECLARE @Ch_Pierre INT = (SELECT ChannelID FROM mytube.Channels WHERE ChannelName = 'French Cuisine');
DECLARE @Ch_Carlos INT = (SELECT ChannelID FROM mytube.Channels WHERE ChannelName = 'Rio Football');

-- БГ Видеа
INSERT INTO mytube.Videos (ChannelID, Title, DurationSeconds, ViewsCount, UploadDate, CategoryID) VALUES
(@Ch_Ivan, N'Ревю на iPhone 15', 600, 15000, GETDATE(), 1),
(@Ch_Maria, N'Пътуване до Италия', 900, 25000, GETDATE(), 2),
(@Ch_Alex, N'GTA VI Gameplay', 1200, 100000, GETDATE(), 3);

-- Глобални Видеа (Милиони гледания за картата!)
INSERT INTO mytube.Videos (ChannelID, Title, DurationSeconds, ViewsCount, UploadDate, CategoryID) VALUES
(@Ch_John, N'Super Bowl Highlights', 5000, 5000000, GETDATE(), 4), -- 5М (САЩ)
(@Ch_Yuki, N'Sushi Masterclass', 800, 2500000, GETDATE(), 2),      -- 2.5М (Япония)
(@Ch_Raj, N'New Movie Trailer', 150, 8000000, GETDATE(), 5),        -- 8М (Индия)
(@Ch_Hans, N'BMW Factory Tour', 1200, 1200000, GETDATE(), 1),       -- 1.2М (Германия)
(@Ch_Pierre, N'Best Croissant Recipe', 600, 900000, GETDATE(), 2),  -- 900k (Франция)
(@Ch_Carlos, N'Neymar Best Goals', 300, 3500000, GETDATE(), 4);     -- 3.5М (Бразилия)


-- 6. СЪЗДАВАНЕ НА РЕАКЦИИ (ЗА ШАРЕНА ПОНИЧКА)



-- Взимаме ID-та на видеата
DECLARE @V_USA INT = (SELECT VideoID FROM mytube.Videos WHERE Title LIKE 'Super%');
DECLARE @V_IND INT = (SELECT VideoID FROM mytube.Videos WHERE Title LIKE 'New Movie%');
DECLARE @V_BRA INT = (SELECT VideoID FROM mytube.Videos WHERE Title LIKE 'Neymar%');
DECLARE @V_BG INT = (SELECT VideoID FROM mytube.Videos WHERE Title LIKE 'GTA%');

-- John (САЩ) е хипер активен (Харесва всичко)
INSERT INTO mytube.Reactions (UserID, VideoID, ReactionType) 
SELECT @John, VideoID, 1 FROM mytube.Videos; 

-- Raj (Индия) харесва само музика и спорт
INSERT INTO mytube.Reactions (UserID, VideoID, ReactionType) VALUES 
(@Raj, @V_IND, 1), (@Raj, @V_BRA, 1);

-- Yuki (Япония) харесва само БГ видеото
INSERT INTO mytube.Reactions (UserID, VideoID, ReactionType) VALUES 
(@Yuki, @V_BG, 1);

-- Carlos (Бразилия) харесва всичко спортно (няколко пъти симулирано)
INSERT INTO mytube.Reactions (UserID, VideoID, ReactionType) VALUES 
(@Carlos, @V_BRA, 1), (@Carlos, @V_USA, 1);

-- Ivan (БГ) харесва техниката
INSERT INTO mytube.Reactions (UserID, VideoID, ReactionType) VALUES 
(@Ivan, @V_USA, 1);

-- Hans (Германия) дислайква (за разнообразие)
INSERT INTO mytube.Reactions (UserID, VideoID, ReactionType) VALUES 
(@Hans, @V_BG, 0);


-- 7. ПЛЕЙЛИСТИ, КОМЕНТАРИ, АБОНАМЕНТИ (ЗА ПЪЛНОТА)

INSERT INTO mytube.Playlists (OwnerUserID, Title, Description) VALUES
(@Ivan, N'My Tech Reviews', N'Best tech');
INSERT INTO mytube.PlaylistVideos (PlaylistID, VideoID, SortOrder) VALUES (1, @V_USA, 1);

INSERT INTO mytube.Comments (VideoID, UserID, Text) VALUES 
(@V_BG, @John, N'Awesome gameplay!'),
(@V_USA, @Ivan, N'Great video man!'),
(@V_BRA, @Raj, N'Legend!');

INSERT INTO mytube.Subscriptions (SubscriberUserID, ChannelID) VALUES 
(@John, @Ch_Ivan), (@Raj, @Ch_Carlos), (@Ivan, @Ch_John);

-- Дневна статистика (за пълнеж)
INSERT INTO mytube.VideoDailyStats (VideoID, StatDate, ViewsCount, WatchSeconds, LikesCount, DislikesCount) VALUES
(@V_BG, GETDATE(), 500, 10000, 50, 2);
GO