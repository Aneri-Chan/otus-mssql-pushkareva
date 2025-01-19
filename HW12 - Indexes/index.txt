-- Создание полнотекстового индекса по BookName таблицы Books для поиска книг на сайте
CREATE FULLTEXT INDEX ON Books (BookName LANGUAGE 1033)
KEY INDEX PK_Books;

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Books_ISBN_Category] ON [dbo].[Books]
( -- Некластеризированный составной уникальный индекс для категории и ISBN (может использоваться для фильтров на сайте)
	[CategoryID] ASC,
	[ISBN] ASC
)
WHERE ([ISBN] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Categories_CategoryName] ON [dbo].[Categories]
( -- Некластеризированный уникальный индекс для запроса категорий (может использоваться для сортировки книг)
	[CategoryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Customers_Email] ON [dbo].[Customers]
( -- Некластеризированный уникальный индекс для проверки уникальности Email заказчика
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Customers_PhoneNumber] ON [dbo].[Customers]
(  -- Некластеризированный уникальный индекс для проверки уникальности номера телефона заказчика
	[PhoneNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


CREATE NONCLUSTERED INDEX [IDX_Orders_CustomerID] ON [dbo].[Orders]
( -- Некластеризированный индекс для ускорения поиска заказов по конкретному клиенту
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IDX_Orders_OrderStatus] ON [dbo].[Orders]
( -- Некластеризированный индекс для ускорения поиска заказов по определенному статусу заказа
	[OrderStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-- Для проверки индексов использовала запрос на поиск статистики применения индексов, включая планы запросов

SELECT 
    OBJECT_NAME(ix.object_id) AS TableName,
    ix.name AS IndexName,
    ius.user_seeks AS Seeks,
    ius.user_scans AS Scans,
    ius.user_lookups AS Lookups,
    ius.user_updates AS Updates,
    ius.last_user_seek AS LastSeek,
    ius.last_user_scan AS LastScan,
    ius.last_user_lookup AS LastLookup
FROM sys.dm_db_index_usage_stats ius
JOIN sys.indexes ix
    ON ius.object_id = ix.object_id AND ius.index_id = ix.index_id
WHERE OBJECTPROPERTY(ix.object_id, 'IsUserTable') = 1
ORDER BY Seeks DESC, Scans DESC, Lookups DESC;

-- результат прикрепила отдельным скрином