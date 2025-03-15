USE WideWorldImporters;
GO

-- Создаем таблицу для хранения отчетов по заказам клиентов
CREATE TABLE Sales.CustomerOrderReports (
    ReportID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    OrderCount INT NOT NULL,
    ReportGeneratedAt DATETIME DEFAULT GETDATE()
);

-- Включаем Service Broker, если не включен
--USE master;
--GO
--ALTER DATABASE WideWorldImporters SET ENABLE_BROKER WITH ROLLBACK IMMEDIATE;
--ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

--Авторизуемся под учётной записью, созданной специально под обработку очередей
--ALTER AUTHORIZATION    
--   ON DATABASE::WideWorldImporters TO QueueUser;

-- Создаем тип сообщений для запроса отчета
CREATE MESSAGE TYPE [//WWI/SB/RequestMessage]
VALIDATION = WELL_FORMED_XML;

-- Создаем тип сообщений для ответа
CREATE MESSAGE TYPE [//WWI/SB/ReplyMessage]
VALIDATION = WELL_FORMED_XML;

-- Создаем контракт для взаимодействия между сервисами
CREATE CONTRACT [//WWI/SB/Contract]
(
    [//WWI/SB/RequestMessage] SENT BY INITIATOR,
    [//WWI/SB/ReplyMessage] SENT BY TARGET
);

-- Создаем очередь и сервис для получателя (Target)
CREATE QUEUE TargetQueueWWI;
CREATE SERVICE [//WWI/SB/TargetService]
       ON QUEUE TargetQueueWWI
       ([//WWI/SB/Contract]);

-- Создаем очередь и сервис для инициатора (Initiator)
CREATE QUEUE InitiatorQueueWWI;
CREATE SERVICE [//WWI/SB/InitiatorService]
       ON QUEUE InitiatorQueueWWI
       ([//WWI/SB/Contract]);

-- Создаем процедуру для отправки заявки на отчет

CREATE PROCEDURE Sales.SendReportRequest
    @CustomerID INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    DECLARE @DialogHandle UNIQUEIDENTIFIER;
    BEGIN TRANSACTION;

    -- Открываем диалог между инициатором и получателем
    BEGIN DIALOG @DialogHandle
    FROM SERVICE [//WWI/SB/InitiatorService]
    TO SERVICE '//WWI/SB/TargetService'
    ON CONTRACT [//WWI/SB/Contract]
    WITH ENCRYPTION = OFF;

    -- Создаем XML-запрос
    DECLARE @Message XML;
    SET @Message = 
    '<ReportRequest>
        <CustomerID>' + CAST(@CustomerID AS NVARCHAR) + '</CustomerID>
        <StartDate>' + CAST(@StartDate AS NVARCHAR) + '</StartDate>
        <EndDate>' + CAST(@EndDate AS NVARCHAR) + '</EndDate>
    </ReportRequest>';

    -- Отправляем сообщение
    SEND ON CONVERSATION @DialogHandle
    MESSAGE TYPE [//WWI/SB/RequestMessage]
    (@Message);

    COMMIT TRANSACTION;
END;

-- Создаем процедуру для обработки сообщений из очереди
CREATE PROCEDURE Sales.ProcessReportQueue
AS
BEGIN
    DECLARE @DialogHandle UNIQUEIDENTIFIER;
    DECLARE @MessageBody XML;
    DECLARE @CustomerID INT, @StartDate DATE, @EndDate DATE;

    -- Получаем сообщение из очереди
    RECEIVE TOP (1) 
        @DialogHandle = conversation_handle,
        @MessageBody = CAST(message_body AS XML)
    FROM dbo.TargetQueueWWI;

    IF @MessageBody IS NOT NULL
    BEGIN
        -- Извлекаем данные из XML
        SET @CustomerID = @MessageBody.value('(/ReportRequest/CustomerID)[1]', 'INT');
        SET @StartDate = @MessageBody.value('(/ReportRequest/StartDate)[1]', 'DATE');
        SET @EndDate = @MessageBody.value('(/ReportRequest/EndDate)[1]', 'DATE');

        -- Записываем отчет в таблицу
        INSERT INTO Sales.CustomerOrderReports (CustomerID, StartDate, EndDate, OrderCount)
        SELECT 
            @CustomerID, @StartDate, @EndDate, COUNT(*)
        FROM Sales.Invoices
        WHERE CustomerID = @CustomerID AND InvoiceDate BETWEEN @StartDate AND @EndDate;

        -- Отправляем подтверждение
        SEND ON CONVERSATION @DialogHandle
        MESSAGE TYPE [//WWI/SB/ReplyMessage] (N'<Success/>');

        END CONVERSATION @DialogHandle;
    END;
END;

-- Добавляем процедуру для обработки ответов в InitiatorQueue

CREATE PROCEDURE Sales.ProcessReplyQueue
AS
BEGIN
    DECLARE @ConversationHandle UNIQUEIDENTIFIER;
    DECLARE @MessageTypeName SYSNAME;
    DECLARE @MessageBody XML;

    WHILE (1 = 1)
    BEGIN
        -- Получаем сообщение из очереди инициатора
        WAITFOR (
            RECEIVE TOP(1)
                @ConversationHandle = conversation_handle,
                @MessageTypeName = message_type_name,
                @MessageBody = CAST(message_body AS XML)
            FROM dbo.InitiatorQueueWWI
        ), TIMEOUT 5000;

        -- Если нет сообщений, выходим
        IF @@ROWCOUNT = 0
            BREAK;

        -- Обработка типа сообщения
        IF @MessageTypeName = '//WWI/SB/ReplyMessage'
        BEGIN

            -- Завершаем диалог
            END CONVERSATION @ConversationHandle;
        END
        ELSE IF @MessageTypeName IN ('http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog',
                                     'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
        BEGIN
            -- Завершаем диалог
            END CONVERSATION @ConversationHandle;
        END
    END
END;

-- Активируем очередь для автоматической обработки
ALTER QUEUE dbo.TargetQueueWWI 
WITH ACTIVATION (
    STATUS = ON, 
    PROCEDURE_NAME = Sales.ProcessReportQueue, 
    MAX_QUEUE_READERS = 1, 
    EXECUTE AS OWNER
);

--  Активируем очередь для обработки ответов
ALTER QUEUE dbo.InitiatorQueueWWI 
WITH ACTIVATION (
    STATUS = ON, 
    PROCEDURE_NAME = Sales.ProcessReplyQueue, 
    MAX_QUEUE_READERS = 1, 
    EXECUTE AS OWNER
);

-- Отправляем заявки на отчеты за разные периоды
EXEC Sales.SendReportRequest @CustomerID = 88, @StartDate = '2013-01-01', @EndDate = '2013-12-31';
EXEC Sales.SendReportRequest @CustomerID = 88, @StartDate = '2014-01-01', @EndDate = '2014-12-31';
EXEC Sales.SendReportRequest @CustomerID = 88, @StartDate = '2015-01-01', @EndDate = '2015-12-31';
EXEC Sales.SendReportRequest @CustomerID = 88, @StartDate = '2016-01-01', @EndDate = '2016-12-31';

-- Даем системе время на обработку, затем проверяем созданные отчеты
SELECT * FROM Sales.CustomerOrderReports WHERE CustomerID = 88;

-- Проверяем, есть ли необработанные сообщения в очереди
SELECT * FROM dbo.TargetQueueWWI;
SELECT * FROM dbo.InitiatorQueueWWI;

-- Проверяем активные диалоги
SELECT conversation_handle, is_initiator, state_desc
FROM sys.conversation_endpoints;

