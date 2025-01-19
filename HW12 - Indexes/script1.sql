USE [master]
GO
/****** Object:  Database [TuvaBuddaBook]    Script Date: 19.01.2025 18:02:57 ******/
CREATE DATABASE [TuvaBuddaBook]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TuvaBuddaBook', FILENAME = N'C:\developer\MSSQL16.SQL2022\MSSQL\DATA\TuvaBuddaBook.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'TuvaBuddaBook_log', FILENAME = N'C:\developer\MSSQL16.SQL2022\MSSQL\DATA\TuvaBuddaBook_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [TuvaBuddaBook] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TuvaBuddaBook].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TuvaBuddaBook] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET ARITHABORT OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [TuvaBuddaBook] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TuvaBuddaBook] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TuvaBuddaBook] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET  DISABLE_BROKER 
GO
ALTER DATABASE [TuvaBuddaBook] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TuvaBuddaBook] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET RECOVERY FULL 
GO
ALTER DATABASE [TuvaBuddaBook] SET  MULTI_USER 
GO
ALTER DATABASE [TuvaBuddaBook] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TuvaBuddaBook] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TuvaBuddaBook] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TuvaBuddaBook] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [TuvaBuddaBook] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [TuvaBuddaBook] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'TuvaBuddaBook', N'ON'
GO
ALTER DATABASE [TuvaBuddaBook] SET QUERY_STORE = OFF
GO
USE [TuvaBuddaBook]
GO
/****** Object:  User [BuddaAdmin]    Script Date: 19.01.2025 18:02:57 ******/
CREATE USER [BuddaAdmin] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [BuddaAdmin]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [BuddaAdmin]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [BuddaAdmin]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [BuddaAdmin]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [BuddaAdmin]
GO
ALTER ROLE [db_datareader] ADD MEMBER [BuddaAdmin]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [BuddaAdmin]
GO
ALTER ROLE [db_denydatareader] ADD MEMBER [BuddaAdmin]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [BuddaAdmin]
GO
/****** Object:  FullTextCatalog [BookCatalog]    Script Date: 19.01.2025 18:02:57 ******/
CREATE FULLTEXT CATALOG [BookCatalog] WITH ACCENT_SENSITIVITY = ON
AS DEFAULT
GO
/****** Object:  Table [dbo].[Books]    Script Date: 19.01.2025 18:02:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Books](
	[BookID] [int] IDENTITY(1,1) NOT NULL,
	[BookName] [nvarchar](255) NOT NULL,
	[Price] [money] NOT NULL,
	[Author] [nvarchar](100) NULL,
	[Weight] [float] NULL,
	[CategoryID] [int] NOT NULL,
	[ISBN] [nvarchar](25) NULL,
	[New] [bit] NOT NULL,
	[AddCategory] [bit] NOT NULL,
	[Bestseller] [bit] NOT NULL,
	[Description] [varchar](max) NULL,
 CONSTRAINT [PK_Books] PRIMARY KEY CLUSTERED 
(
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 19.01.2025 18:02:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 19.01.2025 18:02:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerName] [nvarchar](150) NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[PhoneNumber] [varchar](20) NOT NULL,
	[PasswordHash] [varchar](256) NOT NULL,
	[Address] [nvarchar](180) NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderDetails]    Script Date: 19.01.2025 18:02:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetails](
	[OrderDetailID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[BookID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[PricePerUnit] [money] NOT NULL,
 CONSTRAINT [PK_OrderDetails] PRIMARY KEY CLUSTERED 
(
	[OrderDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_OrderDetails_OrderID_BookID] UNIQUE NONCLUSTERED 
(
	[OrderID] ASC,
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 19.01.2025 18:02:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[TotalAmount] [money] NOT NULL,
	[OrderStatus] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PhotoBooks]    Script Date: 19.01.2025 18:02:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhotoBooks](
	[PhotoID] [int] IDENTITY(1,1) NOT NULL,
	[BookID] [int] NOT NULL,
	[PhotoLink] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_PhotoBooks] PRIMARY KEY CLUSTERED 
(
	[PhotoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_PhotoBooks_PhotoLink] UNIQUE NONCLUSTERED 
(
	[PhotoLink] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Books_Category_Author]    Script Date: 19.01.2025 18:02:58 ******/
CREATE NONCLUSTERED INDEX [IDX_Books_Category_Author] ON [dbo].[Books]
(
	[CategoryID] ASC,
	[Author] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Books_ISBN]    Script Date: 19.01.2025 18:02:58 ******/
CREATE NONCLUSTERED INDEX [IDX_Books_ISBN] ON [dbo].[Books]
(
	[ISBN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Books_ISBN_Category]    Script Date: 19.01.2025 18:02:58 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Books_ISBN_Category] ON [dbo].[Books]
(
	[CategoryID] ASC,
	[ISBN] ASC
)
WHERE ([ISBN] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Categories_CategoryName]    Script Date: 19.01.2025 18:02:58 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Categories_CategoryName] ON [dbo].[Categories]
(
	[CategoryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Customers_Email]    Script Date: 19.01.2025 18:02:58 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Customers_Email] ON [dbo].[Customers]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Customers_PhoneNumber]    Script Date: 19.01.2025 18:02:58 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Customers_PhoneNumber] ON [dbo].[Customers]
(
	[PhoneNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_OrderDetails_BookID]    Script Date: 19.01.2025 18:02:58 ******/
CREATE NONCLUSTERED INDEX [IDX_OrderDetails_BookID] ON [dbo].[OrderDetails]
(
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_OrderDetails_OrderID_BookID]    Script Date: 19.01.2025 18:02:58 ******/
CREATE NONCLUSTERED INDEX [IDX_OrderDetails_OrderID_BookID] ON [dbo].[OrderDetails]
(
	[OrderID] ASC,
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Orders_CustomerID]    Script Date: 19.01.2025 18:02:58 ******/
CREATE NONCLUSTERED INDEX [IDX_Orders_CustomerID] ON [dbo].[Orders]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Orders_OrderStatus]    Script Date: 19.01.2025 18:02:58 ******/
CREATE NONCLUSTERED INDEX [IDX_Orders_OrderStatus] ON [dbo].[Orders]
(
	[OrderStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_PhotoBooks_BookID]    Script Date: 19.01.2025 18:02:58 ******/
CREATE NONCLUSTERED INDEX [IDX_PhotoBooks_BookID] ON [dbo].[PhotoBooks]
(
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_PhotoBooks_PhotoLink]    Script Date: 19.01.2025 18:02:58 ******/
CREATE NONCLUSTERED INDEX [IDX_PhotoBooks_PhotoLink] ON [dbo].[PhotoBooks]
(
	[PhotoLink] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Books]  WITH CHECK ADD  CONSTRAINT [FK_Books_CategoryID] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])
GO
ALTER TABLE [dbo].[Books] CHECK CONSTRAINT [FK_Books_CategoryID]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_BookID] FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_BookID]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_OrderID] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_OrderID]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_CustomerID] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_CustomerID]
GO
ALTER TABLE [dbo].[PhotoBooks]  WITH CHECK ADD  CONSTRAINT [FK_PhotoBooks_BookID] FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID])
GO
ALTER TABLE [dbo].[PhotoBooks] CHECK CONSTRAINT [FK_PhotoBooks_BookID]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [CHK_OrderDetails_PricePerUnit] CHECK  (([PricePerUnit]>(0)))
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [CHK_OrderDetails_PricePerUnit]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [CHK_OrderDetails_Quantity] CHECK  (([Quantity]>(0)))
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [CHK_OrderDetails_Quantity]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [CHK_Orders_TotalAmount] CHECK  (([TotalAmount]>(0)))
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [CHK_Orders_TotalAmount]
GO
USE [master]
GO
ALTER DATABASE [TuvaBuddaBook] SET  READ_WRITE 
GO


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