USE MyTubeDB;
GO

-- =============================================
-- 1. ФУНКЦИЯ (Scalar Function)
-- Цел: Изчислява общия брой лайкове за дадено видео
-- =============================================
CREATE OR ALTER FUNCTION mytube.fn_GetVideoLikes(@VideoID INT)
RETURNS INT
AS
BEGIN
    DECLARE @LikesCount INT;
    
    -- Броим само ReactionType = 1 (Like)
    SELECT @LikesCount = COUNT(*)
    FROM mytube.Reactions
    WHERE VideoID = @VideoID AND ReactionType = 1;

    RETURN ISNULL(@LikesCount, 0);
END;
GO

-- =============================================
-- 2. ТРИГЕР (Trigger)
-- Цел: Автоматично записва лог при качване на ново видео
-- =============================================
CREATE OR ALTER TRIGGER trg_VideoInsertLog
ON mytube.Videos
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Взимаме ID и Заглавие от новия запис (inserted)
    -- и го записваме в таблицата VideoLog
    INSERT INTO mytube.VideoLog (VideoID, ActionType, LogDate)
    SELECT 
        i.VideoID, 
        'New Video Uploaded: ' + i.Title, 
        GETDATE()
    FROM inserted i;
END;
GO

-- =============================================
-- 3. СЪХРАНЕНА ПРОЦЕДУРА (Stored Procedure)
-- Цел: Безопасно добавяне на видео чрез код
-- =============================================
CREATE OR ALTER PROCEDURE mytube.sp_AddVideoWithLog
    @ChannelID INT,
    @Title NVARCHAR(200),
    @DurationSeconds INT,
    @CategoryID INT = NULL,
    @Language NVARCHAR(10) = 'EN'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NewVideoID INT;

    -- Вмъкваме видеото (Тук тригерът ще се задейства сам!)
    INSERT INTO mytube.Videos (ChannelID, Title, DurationSeconds, CategoryID, Language, UploadDate, ViewsCount)
    VALUES (@ChannelID, @Title, @DurationSeconds, @CategoryID, @Language, GETDATE(), 0);

    -- Взимаме ID-то на току-що създаденото видео
    SET @NewVideoID = SCOPE_IDENTITY();

    -- Връщаме резултата
    SELECT @NewVideoID AS NewVideoID;
END;
GO