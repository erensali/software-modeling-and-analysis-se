USE master;
GO

-- Za reset na vruzkıte na bazata !!!!
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'MyTubeDB')
BEGIN
    ALTER DATABASE MyTubeDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MyTubeDB;
    PRINT '💥 Базата MyTubeDB беше изтрита напълно. Сега започни от Файл 1.';
END
ELSE
BEGIN
    PRINT 'ℹ️ Базата не съществува, можеш да започнеш от Файл 1.';
END
GO