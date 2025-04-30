/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT 
PersonID AS 'Код сотрудника', 
FullName AS 'Полное имя'
FROM Application.People P
WHERE IsSalesperson = 1
AND NOT EXISTS (SELECT 1
FROM Sales.Invoices SI
WHERE SI.InvoiceDate = '2015-07-04'
AND SI.SalespersonPersonID = P.PersonID)

-- через CTE

;WITH SalesOnDate AS (
SELECT DISTINCT SalespersonPersonID
FROM Sales.Invoices 
WHERE InvoiceDate = '2015-07-04'
)
SELECT 
PersonID AS 'Код сотрудника', 
FullName AS 'Полное имя'
FROM Application.People P
WHERE IsSalesperson = 1
AND NOT EXISTS (SELECT 1
FROM SalesOnDate SOD
WHERE SOD.SalespersonPersonID = P.PersonID)

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

SELECT
StockItemID AS 'Код товара',
StockItemName AS 'Наименование товара',
UnitPrice  AS 'Цена'
FROM Warehouse.StockItems
WHERE UnitPrice = (SELECT MIN(UnitPrice) FROM Warehouse.StockItems)

-- через CTE 

;WITH MinPrice AS (
SELECT MIN(UnitPrice) AS MinUnitPrice
FROM Warehouse.StockItems
)
SELECT
StockItemID AS 'Код товара',
StockItemName AS 'Наименование товара',
UnitPrice  AS 'Цена'
FROM Warehouse.StockItems
WHERE UnitPrice = (SELECT MinUnitPrice FROM MinPrice)

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

SELECT
CustomerID AS 'Код клиента',
(SELECT CustomerName
FROM Sales.Customers
WHERE Customers.CustomerID = CustomerTransactions.CustomerID) AS 'Имя клиента',
TransactionAmount  AS 'Сумма платежа'
FROM Sales.CustomerTransactions
WHERE TransactionAmount IN 
(SELECT DISTINCT TOP 5 TransactionAmount
FROM Sales.CustomerTransactions
ORDER BY TransactionAmount DESC)

-- через CTE

;WITH MaxTransactions AS (
SELECT TOP 5 TransactionAmount
FROM Sales.CustomerTransactions
ORDER BY TransactionAmount DESC)
SELECT
CustomerID AS 'Код клиента',
(SELECT CustomerName 
FROM Sales.Customers 
WHERE Customers.CustomerID = CustomerTransactions.CustomerID) AS 'Имя клиента',
TransactionAmount AS 'Сумма платежа'
FROM Sales.CustomerTransactions
WHERE TransactionAmount IN (
SELECT TransactionAmount
FROM MaxTransactions
)

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

SELECT 
City.CityID AS 'Код города',
City.CityName AS 'Название города',
(SELECT FullName
FROM Application.People
WHERE People.PersonID = I.PackedByPersonID) AS 'Имя упаковщика'
FROM Application.Cities City
JOIN Sales.Customers Cust
ON City.CityID = Cust.DeliveryCityID
JOIN Sales.Invoices I
ON I.CustomerID = Cust.CustomerID
WHERE I.OrderID IN(
SELECT DISTINCT OrderID
FROM Sales.OrderLines OL
WHERE OL.StockItemID IN (
SELECT TOP 3 StockItemID
FROM Warehouse.StockItems
ORDER BY UnitPrice DESC
)
AND I.PackedByPersonID IS NOT NULL
)

-- через CTE

;WITH ExpensiveItems AS (
SELECT TOP 3 StockItemID
FROM Warehouse.StockItems
ORDER BY UnitPrice DESC
),
ExpensiveOrders AS (
SELECT DISTINCT OL.OrderID
FROM Sales.OrderLines OL
WHERE OL.StockItemID IN (SELECT StockItemID FROM ExpensiveItems)
),
NotNullPackedPerson AS (
SELECT OrderID, I.PackedByPersonID, I.CustomerID
FROM Sales.Invoices I
WHERE I.OrderID IN (SELECT OrderID FROM ExpensiveOrders)
AND I.PackedByPersonID IS NOT NULL
)
SELECT
City.CityID AS 'Код города',
City.CityName AS 'Название города',
(SELECT FullName
FROM Application.People
WHERE People.PersonID = NNPP.PAckedByPersonID) AS 'Имя упаковщика'
FROM Application.Cities City
JOIN Sales.Customers Cust
ON City.CityID = Cust.DeliveryCityID
JOIN NotNullPackedPerson NNPP
ON NNPP.CustomerID = Cust.CustomerID

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SET STATISTICS IO, TIME ON
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

/* Данный запрос отбирает код, дату счета, 
имя продавца по коду из таблицы Application.People,
общую сумму счета через таблицу Sales.InvoiceLines,
сумму подобранных товаров через таблицу Sales.OrderLines при усоловии, что заказ завершен.
Выбираются только те счета, где общая сумма должна быть больше 27000,
после чего сортируются по убыванию общей суммы */

SET STATISTICS IO, TIME ON
;WITH InvoiceTotals AS (
    SELECT 
        InvoiceId, 
        SUM(Quantity * UnitPrice) AS TotalSumm
    FROM Sales.InvoiceLines
    GROUP BY InvoiceId
    HAVING SUM(Quantity * UnitPrice) > 27000
),
PickedItemsTotals AS (
    SELECT 
        Orders.OrderId,
        SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice) AS TotalSummForPickedItems
    FROM Sales.OrderLines
    JOIN Sales.Orders
        ON Orders.OrderId = OrderLines.OrderId
    WHERE Orders.PickingCompletedWhen IS NOT NULL
    GROUP BY Orders.OrderId
)
SELECT 
    Invoices.InvoiceID, 
    Invoices.InvoiceDate,
    People.FullName AS SalesPersonName,
    InvoiceTotals.TotalSumm AS TotalSummByInvoice,
    PickedItemsTotals.TotalSummForPickedItems
FROM Sales.Invoices
JOIN InvoiceTotals
    ON Invoices.InvoiceID = InvoiceTotals.InvoiceID
LEFT JOIN PickedItemsTotals
    ON Invoices.OrderID = PickedItemsTotals.OrderId
LEFT JOIN Application.People
    ON People.PersonID = Invoices.SalespersonPersonID
ORDER BY InvoiceTotals.TotalSumm DESC;

/*
+ Оптимизация направлена на улучшение читабельности запроса для дальнейшего сопровождения.
Сложные вычисления были размещены во врменных таблицах,
благодаря join вычисления выполняются 1 раз для всех строк.
- Join создает дополнительные этапы, план выполнения стал сложнее,
из-за чего это может стать узким местом,
если БД неоптимально настроена (нет индексов).
*/