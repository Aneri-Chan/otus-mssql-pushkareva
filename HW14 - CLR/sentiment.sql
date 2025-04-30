--включаем расширенные опции
sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO 
--подключаем работу с CLR
sp_configure 'clr enabled', 1;  
GO  
RECONFIGURE;  
GO

RECONFIGURE

--загружаем сборку анализа тональности отзывов пользователей
create assembly SentimentAnalysis
from 'E:\path_to_file\SentimentAnalysis.dll'
with permission_set = unsafe --для выполнения любых операций

--для работы с unsafe отключаем строгую безопасность
EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;

--создаём функцию для работы с подключенной clr
CREATE FUNCTION dbo.AnalyzeSentiment(@text NVARCHAR(MAX))
RETURNS NVARCHAR(20)
AS EXTERNAL NAME SentimentAnalysis.SentimentAnalysis.AnalyzeSentiment;

--обновляем данные таблицы с отзывами, чтобы увидеть результат программы
UPDATE [TuvaBuddaBook].[dbo].[Reviews]
SET Sentiment = dbo.AnalyzeSentiment(ReviewText);

/* Прим.: Лучше всего программа бы работала с анализом машинного обучения,
но в mssql не поддерживается работа с библиотекой ML С#, поэтому были использованы ограниченные словари.
Тем не менее, если словари будут обладать огромным запасом слов и богатой логикой,
то программа вполне была бы "костыльно" применима на практике.
Для изучения работы с CLR, думаю, что этого пока будет достаточно. */
