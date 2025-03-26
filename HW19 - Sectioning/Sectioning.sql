-- Выбрала таблицу [Warehouse].[StockItemTransactions]

USE WideWorldImporters;

-- 1. Создадим файловые группы

ALTER DATABASE WideWorldImporters ADD FILEGROUP FG_OtherTypes;  -- Для TransactionTypeID = 1-9
ALTER DATABASE WideWorldImporters ADD FILEGROUP FG_MainTypes;   -- Для TransactionTypeID = 10, 11, 12
ALTER DATABASE WideWorldImporters ADD FILEGROUP FG_FutureTypes; -- Для TransactionTypeID = 13+

-- 2. Создадим файлы для групп

ALTER DATABASE WideWorldImporters ADD FILE 
(
    NAME = 'OtherTypes',
    FILENAME = 'E:\sql\OtherTypes.ndf',
    SIZE = 50MB, FILEGROWTH = 10MB
) TO FILEGROUP FG_OtherTypes;

ALTER DATABASE WideWorldImporters ADD FILE 
(
    NAME = 'MainTypes',
    FILENAME = 'E:\sql\MainTypes.ndf',
    SIZE = 50MB, FILEGROWTH = 10MB
) TO FILEGROUP FG_MainTypes;

ALTER DATABASE WideWorldImporters ADD FILE 
(
    NAME = 'FutureTypes',
    FILENAME = 'E:\sql\FutureTypes.ndf',
    SIZE = 50MB, FILEGROWTH = 10MB
) TO FILEGROUP FG_FutureTypes;

-- 3. Создадим функцию секционирования

CREATE PARTITION FUNCTION pf_TransactionTypeID (int)
AS RANGE LEFT FOR VALUES (9, 12); 

-- 4. Создадим схему секционирования

CREATE PARTITION SCHEME ps_TransactionTypeID 
AS PARTITION pf_TransactionTypeID 
TO (FG_OtherTypes, FG_MainTypes, FG_FutureTypes);

-- 5. Создадим саму таблицу секционирования

CREATE TABLE [Warehouse].[StockItemTransactions_Partitioned] (
    StockItemTransactionID INT NOT NULL,
    TransactionTypeID INT NOT NULL,
    StockItemID INT NOT NULL,
    CustomerID INT NULL,
    InvoiceID INT NULL,
    SupplierID INT NULL,
    PurchaseOrderID INT NULL,
    TransactionOccurredWhen DATETIME NOT NULL,
    Quantity INT NOT NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME NOT NULL,
    CONSTRAINT PK_StockItemTransactions_Partitioned 
        PRIMARY KEY CLUSTERED (TransactionTypeID, StockItemTransactionID) 
        ON ps_TransactionTypeID (TransactionTypeID) -- секционирование по TransactionTypeID
);

-- 6. Перенесем данные в секционированную таблицу

INSERT INTO [Warehouse].[StockItemTransactions_Partitioned] (
    StockItemTransactionID, StockItemID, TransactionTypeID, CustomerID, InvoiceID, 
    SupplierID, PurchaseOrderID, TransactionOccurredWhen, Quantity, LastEditedBy, LastEditedWhen
)
SELECT StockItemTransactionID, StockItemID, TransactionTypeID, CustomerID, InvoiceID, 
       SupplierID, PurchaseOrderID, TransactionOccurredWhen, Quantity, LastEditedBy, LastEditedWhen
FROM [Warehouse].[StockItemTransactions];

-- 7. Проверим, как у нас распределились данные при помощи запроса, показывающего количество строк в каждой секции

SELECT p.partition_number, 
       fg.name AS Filegroup, 
       p.rows AS 'RowCount'
FROM sys.partitions p
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.destination_data_spaces dds ON i.data_space_id = dds.partition_scheme_id AND p.partition_number = dds.destination_id
JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
WHERE i.object_id = OBJECT_ID('[Warehouse].[StockItemTransactions_Partitioned]')
ORDER BY p.partition_number;

-- 8. Обновим данные в оригинальной таблице

  update [Warehouse].[StockItemTransactions]
  set [TransactionTypeID] = 8
  where [TransactionTypeID] = 11

  --update [Warehouse].[StockItemTransactions]
  --set [TransactionTypeID] = 11
  --where [TransactionTypeID] = 8

-- 9. Добавим обновленные данные в секционированную таблицу, чтобы проверить, как теперь отработает

INSERT INTO [Warehouse].[StockItemTransactions_Partitioned] (
    StockItemTransactionID, StockItemID, TransactionTypeID, CustomerID, InvoiceID, 
    SupplierID, PurchaseOrderID, TransactionOccurredWhen, Quantity, LastEditedBy, LastEditedWhen
)
SELECT StockItemTransactionID, StockItemID, TransactionTypeID, CustomerID, InvoiceID, 
       SupplierID, PurchaseOrderID, TransactionOccurredWhen, Quantity, LastEditedBy, LastEditedWhen
FROM [Warehouse].[StockItemTransactions]
where [TransactionTypeID] = 8;

-- 10. На этот раз проверим через группировку строк по секциям

SELECT 
    TransactionTypeID, 
    COUNT(*) AS 'RowCount', 
    $PARTITION.pf_TransactionTypeID(TransactionTypeID) AS PartitionNumber
FROM [Warehouse].[StockItemTransactions_Partitioned]
GROUP BY TransactionTypeID, $PARTITION.pf_TransactionTypeID(TransactionTypeID)
ORDER BY PartitionNumber;

-- Из запроса видим, что с TransactionTypeID = 8 данные попали в 1 секцию,
-- остальные типы транзакций распределились во вторую секцию

