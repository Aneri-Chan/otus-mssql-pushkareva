-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.

-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.

SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

CREATE TABLE [Customers] (
    [CustomerID] int,  NOT NULL ,
    [CustomerName] nvarchar(150)  NOT NULL ,
    [Email] nvarchar(50)  NOT NULL ,
    [PhoneNumber] varchar(20)  NOT NULL ,
    [PasswordHash] varchar(256)  NOT NULL ,
    [Address] nvarchar(180)  NULL ,
    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED (
        [CustomerID] ASC
    )
)

CREATE TABLE [Orders] (
    [OrderID] int  NOT NULL ,
    [CustomerID] int  NOT NULL ,
    [TotalAmount] money  NOT NULL ,
    [OrderStatus] nvarchar(30)  NOT NULL ,
    CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED (
        [OrderID] ASC
    )
)

CREATE TABLE [Books] (
    [BookID] int  NOT NULL ,
    [BookName] nvarchar(255)  NOT NULL ,
    [Price] money  NOT NULL ,
    [Author] nvarchar(100)  NULL ,
    [Weight] float  NULL ,
    [CategoryID] int  NOT NULL ,
    [ISBN] nvarchar(25)  NULL ,
    [New] bit  NOT NULL ,
    [AddCategory] bit  NOT NULL ,
    [Bestseller] bit  NOT NULL ,
    [Description] nvarchar(255)  NOT NULL ,
    CONSTRAINT [PK_Books] PRIMARY KEY CLUSTERED (
        [BookID] ASC
    )
)

CREATE TABLE [Categories] (
    [CategoryID] int,  NOT NULL ,
    [CategoryName] nvarchar(50)  NOT NULL ,
    CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED (
        [CategoryID] ASC
    )
)

CREATE TABLE [PhotoBooks] (
    [PhotoID] int  NOT NULL ,
    [BookID] int  NOT NULL ,
    [PhotoLink] nvarchar(150)  NOT NULL ,
    CONSTRAINT [PK_PhotoBooks] PRIMARY KEY CLUSTERED (
        [PhotoID] ASC
    )
)

CREATE TABLE [OrderDetails] (
    [OrderDetailID] int  NOT NULL ,
    [OrderID] int  NOT NULL ,
    [BookID] int  NOT NULL ,
    [Quantity] int  NOT NULL ,
    [PricePerUnit] money  NOT NULL ,
    CONSTRAINT [PK_OrderDetails] PRIMARY KEY CLUSTERED (
        [OrderDetailID] ASC
    )
)

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_CustomerID] FOREIGN KEY([CustomerID])
REFERENCES [Customers] ([CustomerID])

ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_CustomerID]

ALTER TABLE [Books] WITH CHECK ADD CONSTRAINT [FK_Books_CategoryID] FOREIGN KEY([CategoryID])
REFERENCES [Categories] ([CategoryID])

ALTER TABLE [Books] CHECK CONSTRAINT [FK_Books_CategoryID]

ALTER TABLE [PhotoBooks] WITH CHECK ADD CONSTRAINT [FK_PhotoBooks_BookID] FOREIGN KEY([BookID])
REFERENCES [Books] ([BookID])

ALTER TABLE [PhotoBooks] CHECK CONSTRAINT [FK_PhotoBooks_BookID]

ALTER TABLE [OrderDetails] WITH CHECK ADD CONSTRAINT [FK_OrderDetails_OrderID] FOREIGN KEY([OrderID])
REFERENCES [Orders] ([OrderID])

ALTER TABLE [OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_OrderID]

ALTER TABLE [OrderDetails] WITH CHECK ADD CONSTRAINT [FK_OrderDetails_BookID] FOREIGN KEY([BookID])
REFERENCES [Books] ([BookID])

ALTER TABLE [OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_BookID]

COMMIT TRANSACTION QUICKDBD