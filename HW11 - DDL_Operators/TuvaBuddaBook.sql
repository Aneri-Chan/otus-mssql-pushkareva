USE [TuvaBuddaBook]
GO
/****** Object:  Table [dbo].[Books]    Script Date: 08.01.2025 19:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Books]( -- Таблица книг
	[BookID] [int] IDENTITY(1,1) NOT NULL, -- Код книги
	[BookName] [nvarchar](255) NOT NULL, -- Наимменование книги
	[Price] [money] NOT NULL, -- Стоимость книги
	[Author] [nvarchar](100) NULL, -- Автор книги
	[Weight] [float] NULL, -- Вес книги
	[CategoryID] [int] NOT NULL, -- Код категории
	[ISBN] [nvarchar](25) NULL, -- ISBN книги
	[New] [bit] NOT NULL,  -- Тип книги "Новинка"
	[AddCategory] [bit] NOT NULL, -- Тип книги "Мы советуем"
	[Bestseller] [bit] NOT NULL, -- Тип книги "Хит продаж"
	[Description] [varchar](max) NULL, -- Описание книги
	/* Изменила тип данных, поскольку решила не хранить ссылки на файлы с описанием книг. 
	Описания книг занимают меньше 5Кб, поэтому остановилась на варианте хранения данных в таблице. */
 CONSTRAINT [PK_Books] PRIMARY KEY CLUSTERED 
(
	[BookID] ASC -- Ограничение в виде кластеризированного первичного ключа по коду книг
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 08.01.2025 19:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories]( -- Таблица категорий
	[CategoryID] [int] IDENTITY(1,1) NOT NULL, -- Код категории
	[CategoryName] [nvarchar](50) NOT NULL, -- Наименование категории
 CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED  
(
	[CategoryID] ASC -- Ограничение в виде кластеризированного первичного ключа по коду категории
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 08.01.2025 19:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](  -- Таблица заказчиков
	[CustomerID] [int] IDENTITY(1,1) NOT NULL, -- Код заказчика
	[CustomerName] [nvarchar](150) NOT NULL, -- ФИО заказчика 
	[Email] [nvarchar](50) NOT NULL, -- Электронная почта заказчика
	[PhoneNumber] [varchar](20) NOT NULL, -- Номер телефона заказчика
	[PasswordHash] [varchar](256) NOT NULL,  -- Хэшированный пароль заказчика
	[Address] [nvarchar](180) NULL, -- Адрес заказчика
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC -- Ограничение в виде кластеризированного первичного ключа по коду заказчика
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderDetails]    Script Date: 08.01.2025 19:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetails]( -- Таблица деталей о заказе
	[OrderDetailID] [int] IDENTITY(1,1) NOT NULL, -- Код деталей заказа
	[OrderID] [int] NOT NULL, -- Код заказа
	[BookID] [int] NOT NULL, -- Код книги
	[Quantity] [int] NOT NULL, -- Количество заказанных книг
	[PricePerUnit] [money] NOT NULL, -- Стоимость книги за штуку
 CONSTRAINT [PK_OrderDetails] PRIMARY KEY CLUSTERED 
(
	[OrderDetailID] ASC -- Ограничение в виде кластеризированного первичного ключа по коду деталей заказа
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_OrderDetails_OrderID_BookID] UNIQUE NONCLUSTERED 
(/* Ограничение в виде некластеризированного уникального индекса по коду заказа и коду книги
(чтобы быстрее осуществлять поиск по всем книгам конкретного заказа)*/
	[OrderID] ASC,
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 08.01.2025 19:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders]( -- Таблица заказов
	[OrderID] [int] IDENTITY(1,1) NOT NULL, -- Код заказа
	[CustomerID] [int] NOT NULL, -- Код заказчика
	[TotalAmount] [money] NOT NULL, -- Общая сумма заказа
	[OrderStatus] [nvarchar](30) NOT NULL, -- Статус заказа
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC -- Ограничение в виде кластеризированного первичного ключа по коду заказа
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PhotoBooks]    Script Date: 08.01.2025 19:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhotoBooks]( -- Таблица с изображениями книг
	[PhotoID] [int] IDENTITY(1,1) NOT NULL, -- Код изображения
	[BookID] [int] NOT NULL, -- Код книги
	[PhotoLink] [nvarchar](150) NOT NULL, -- Ссылка на изображение (относительный путь до изображения в папке)
 CONSTRAINT [PK_PhotoBooks] PRIMARY KEY CLUSTERED 
(
	[PhotoID] ASC -- Ограничение в виде кластеризированного первичного ключа по коду изображения
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_PhotoBooks_PhotoLink] UNIQUE NONCLUSTERED 
(-- Ограничение в виде уникального некластеризированного индекса для запроса к изображениям для вывода на сайт по определенной книге 
	[PhotoLink] ASC 
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Books_Category_Author]    Script Date: 08.01.2025 20:32:52 ******/
CREATE NONCLUSTERED INDEX [IDX_Books_Category_Author] ON [dbo].[Books]
(-- Некластеризированный составной индекс для категории и автора (может использоваться для фильтров на сайте)
	[CategoryID] ASC,
	[Author] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Books_ISBN]    Script Date: 08.01.2025 20:32:52 ******/
CREATE NONCLUSTERED INDEX [IDX_Books_ISBN] ON [dbo].[Books]
( -- Некластеризированный индекс для ISBN книги (может использоваться для поиска по ISBN книги на сайте)
	[ISBN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Books_ISBN_Category]    Script Date: 08.01.2025 20:32:52 ******/
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
/****** Object:  Index [UQ_Categories_CategoryName]    Script Date: 08.01.2025 20:32:52 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Categories_CategoryName] ON [dbo].[Categories]
( -- Некластеризированный уникальный индекс для запроса категорий (может использоваться для сортировки книг)
	[CategoryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Customers_Email]    Script Date: 08.01.2025 20:32:52 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Customers_Email] ON [dbo].[Customers]
( -- Некластеризированный уникальный индекс для проверки уникальности Email заказчика
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Customers_PhoneNumber]    Script Date: 08.01.2025 20:32:52 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Customers_PhoneNumber] ON [dbo].[Customers]
(  -- Некластеризированный уникальный индекс для проверки уникальности номера телефона заказчика
	[PhoneNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_OrderDetails_BookID]    Script Date: 08.01.2025 20:32:52 ******/
CREATE NONCLUSTERED INDEX [IDX_OrderDetails_BookID] ON [dbo].[OrderDetails]
(  -- Возможно, не столь обязательный некластеризированный индекс для поиска заказов по конкретной книге
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_OrderDetails_OrderID_BookID]    Script Date: 08.01.2025 20:32:52 ******/
CREATE NONCLUSTERED INDEX [IDX_OrderDetails_OrderID_BookID] ON [dbo].[OrderDetails]
(  -- Некластеризированный индекс для ускорения поиска всех книг для конкретного заказа
	[OrderID] ASC,
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Orders_CustomerID]    Script Date: 08.01.2025 20:32:52 ******/
CREATE NONCLUSTERED INDEX [IDX_Orders_CustomerID] ON [dbo].[Orders]
( -- Некластеризированный индекс для ускорения поиска заказов по конкретному клиенту
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Orders_OrderStatus]    Script Date: 08.01.2025 20:32:52 ******/
CREATE NONCLUSTERED INDEX [IDX_Orders_OrderStatus] ON [dbo].[Orders]
( -- Некластеризированный индекс для ускорения поиска заказов по определенному статусу заказа
	[OrderStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_PhotoBooks_BookID]    Script Date: 08.01.2025 20:32:52 ******/
CREATE NONCLUSTERED INDEX [IDX_PhotoBooks_BookID] ON [dbo].[PhotoBooks]
( -- Некластеризированный индекс для ускорения поиска изображений для конкретной книги
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_PhotoBooks_PhotoLink]    Script Date: 08.01.2025 20:32:52 ******/
CREATE NONCLUSTERED INDEX [IDX_PhotoBooks_PhotoLink] ON [dbo].[PhotoBooks]
( -- Некластеризированный индекс для ускорения проверки изображений
	[PhotoLink] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Books]  WITH CHECK ADD  CONSTRAINT [FK_Books_CategoryID] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID]) -- Создание внешнего ключа по коду категории
GO
ALTER TABLE [dbo].[Books] CHECK CONSTRAINT [FK_Books_CategoryID] -- Ограничение в виде связи таблиц книг и категорий по коду категории
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_BookID] FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID]) -- Создание внешнего ключа по коду книги
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_BookID] -- Ограничение в виде связи таблиц книг и деталей заказа по коду книги
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_OrderID] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID]) -- Создание внешнего ключа по коду заказа
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_OrderID] -- Ограничение в виде связи таблиц заказа и деталей заказа по коду заказа
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_CustomerID] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID]) -- Создание внешнего ключа по коду заказчика
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_CustomerID] -- Ограничение в виде связи таблиц заказа и заказчика по коду заказчика
GO
ALTER TABLE [dbo].[PhotoBooks]  WITH CHECK ADD  CONSTRAINT [FK_PhotoBooks_BookID] FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID]) -- Создание внешнего ключа по коду книги
GO
ALTER TABLE [dbo].[PhotoBooks] CHECK CONSTRAINT [FK_PhotoBooks_BookID] -- Ограничение в виде связи таблиц книг и изображений по коду книги
GO 
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [CHK_OrderDetails_PricePerUnit] CHECK  (([PricePerUnit]>(0))) 
GO -- Ограничение по цене за книгу таблицы деталей заказа (должна быть больше нуля при создании заказа)
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [CHK_OrderDetails_PricePerUnit]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [CHK_OrderDetails_Quantity] CHECK  (([Quantity]>(0)))
GO -- Ограничение по количеству книг таблицы деталей заказа (должно быть больше нуля при создании заказа)
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [CHK_OrderDetails_Quantity]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [CHK_Orders_TotalAmount] CHECK  (([TotalAmount]>(0)))
GO -- Ограничение по общей стоимости заказа таблицы заказа (должно быть больше нуля при создании заказа)
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [CHK_Orders_TotalAmount]
GO


