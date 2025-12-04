USE MyTubeDB;
GO


-- ========================================================
-- ТЕСТ 1: ДЕМОНСТРАЦИЯ НА БАЗАТА И ДАННИТЕ
-- ========================================================
SELECT TOP 5 * FROM mytube.Users;
SELECT TOP 5 * FROM mytube.Videos ORDER BY ViewsCount DESC; -- Показваме най-гледаните (милиони)
SELECT * FROM mytube.Channels;

-- ========================================================
-- ТЕСТ 2: ТЕСТ НА ФУНКЦИЯ (Scalar Function)
-- "Тази функция пресмята лайковете на конкретно видео."
-- ========================================================

-- Нека проверим колко лайка има видео с ID = 1
SELECT mytube.fn_GetVideoLikes(1) AS [Broi_Likes_Video_1];

-- ========================================================
-- ТЕСТ 3: ТЕСТ НА ПРОЦЕДУРА И ТРИГЕР (2 в 1)
-- ========================================================

-- 1. Виждаме, че логът е празен (или има стари записи)
SELECT TOP 5 * FROM mytube.VideoLog ORDER BY LogDate DESC;

-- 2. Изпълняваме процедурата за добавяне на видео
EXEC mytube.sp_AddVideoWithLog 
    @ChannelID = 1, 
    @Title = 'DEMO VIDEO ZA PREPODAVATELYA2', 
    @DurationSeconds = 300,
    @CategoryID = 1,
    @Language = 'BG';

-- 3. ПРОВЕРКА: Виждаме дали Тригерът се е задействал

SELECT TOP 5 * FROM mytube.VideoLog ORDER BY LogDate DESC;

-- 4. ПРОВЕРКА: Виждаме дали видеото е влязло в таблицата
SELECT TOP 5 * FROM mytube.Videos ORDER BY VideoID DESC;

-- ТЕСТ 4: DATA WAREHOUSE & ANALYTICS (VIEWS)
-- "Тук са готовите справки, които захранват Power BI."


-- 1. Топ 10 най-гледани видеа (За Bar Chart)
SELECT * FROM dw.vw_TopVideos;

-- 2. Активност на потребителите (За Donut Chart)
SELECT * FROM dw.vw_UserEngagement;

-- 3. Данни за Картата (За Map)
SELECT * FROM dw.vw_MapData;

-- 4. Данни за Категориите (За Treemap - НОВО!)
SELECT * FROM dw.vw_CategoryStats;