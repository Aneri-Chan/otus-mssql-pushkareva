/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

CREATE FUNCTION GetMaxSum()
RETURNS TABLE
AS RETURN
(SELECT TOP 1
c.CustomerName AS 'Имя клиента',
SUM(ol.Quantity * ol.UnitPrice) AS 'Сумма покупки'
FROM Sales.Customers c
JOIN Sales.Orders o ON c.CustomerID = o.CustomerID
JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
GROUP BY c.CustomerName
ORDER BY 2 DESC);
GO

SELECT * FROM GetMaxSum();

--drop function if exists GetMaxSum

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE PROCEDURE GetClientSum
@CustomerID INT 
AS BEGIN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT c.CustomerName 'Имя клиента',
SUM(il.Quantity * il.UnitPrice) AS 'Сумма покупки'
FROM Sales.Customers c
JOIN Sales.Invoices i ON c.CustomerID = i.CustomerID
JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
WHERE c.CustomerID = @CustomerID 
GROUP BY c.CustomerName;
END;

EXEC GetClientSum @CustomerID = 25;

--drop procedure if exists GetClientSum

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.

Вывести 10 любых клиентов с общей суммой их покупок, а также список товаров предоставить в формате: название товара, цена, количество.
*/

CREATE FUNCTION dbo.GetOrderSummary()
RETURNS TABLE
AS RETURN
(SELECT
c.CustomerID AS 'Код клиента', 
c.CustomerName AS 'Имя клиента',
SUM(il.Quantity * il.UnitPrice) AS 'Общая сумма',
(SELECT 
si.StockItemName AS 'Название товара',
il.UnitPrice AS 'Цена',
SUM(il.Quantity) AS 'Количество'
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
WHERE il.InvoiceID IN (
SELECT i.InvoiceID 
FROM Sales.Invoices i 
WHERE i.CustomerID = c.CustomerID)
GROUP BY si.StockItemName, il.UnitPrice
FOR JSON PATH) AS Goods
FROM (SELECT TOP 10 CustomerID FROM Sales.Customers ORDER BY CustomerID) AS TopCustomers
JOIN Sales.Customers c ON c.CustomerID = TopCustomers.CustomerID
JOIN Sales.Invoices i ON c.CustomerID = i.CustomerID
JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
GROUP BY c.CustomerID, c.CustomerName);


CREATE PROCEDURE dbo.GetOrderSummaryProc
AS BEGIN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT 
c.CustomerID AS 'Код клиента', 
c.CustomerName AS 'Имя клиента',
SUM(il.Quantity * il.UnitPrice) AS 'Общая сумма',
(SELECT 
si.StockItemName AS 'Название товара',
il.UnitPrice AS 'Цена',
SUM(il.Quantity) AS 'Количество'
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
WHERE il.InvoiceID IN (
SELECT i.InvoiceID 
FROM Sales.Invoices i 
WHERE i.CustomerID = c.CustomerID)
GROUP BY si.StockItemName, il.UnitPrice
FOR JSON PATH) AS Goods
FROM (SELECT TOP 10 CustomerID FROM Sales.Customers ORDER BY CustomerID) AS TopCustomers
JOIN Sales.Customers c ON c.CustomerID = TopCustomers.CustomerID
JOIN Sales.Invoices i ON c.CustomerID = i.CustomerID
JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
GROUP BY c.CustomerID, c.CustomerName
END;

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

EXEC dbo.GetOrderSummaryProc;

SELECT * 
FROM dbo.GetOrderSummary();

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

/*
С точки зрения производительности, процедура выигрывает у функции,
поскольку может кэшировать данные запроса и при повторном обращении к ней затрачивать те же ресурсы,
обрабатывая данные быстрее; в то время как функция будет производить операции на каждой строчке
по-отдельности и затрачивать гораздо больше ресурсов, отчего она выполняется медленнее.
Если объем данных не слишком большой, то функция и процедура будут затрачивать примерно одинаковое время,
однако чем больше данных - тем медленнее работа функции.
Минус процедуры в том, что придётся добавлять временные таблицы для хранения результата её выполнения,
а вот результат функции можно напрямую встраивать в запросы при необходимости.
*/

--drop procedure if exists dbo.GetOrderSummaryProc
--drop function if exists GetOrderSummary

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 

Вывести информацию по 25 клиентам о том, где они живут: код клиента, имя клиента, страна, город 
*/

CREATE FUNCTION dbo.GetCustomerLocationInfo (@CustomerID INT)
RETURNS TABLE
AS RETURN
(SELECT
c.CustomerID,
c.CustomerName,
co.CountryName,
ci.CityName
FROM Sales.Customers c
JOIN Application.Cities ci 
ON c.DeliveryCityID = ci.CityID
JOIN Application.Countries co ON ci.StateProvinceID = co.CountryID
WHERE c.CustomerID = @CustomerID);

SELECT TOP (25)
c.CustomerID AS 'Код клиента',
c.CustomerName AS 'Имя клиента',
cli.CountryName AS 'Страна',
cli.CityName AS 'Город'
FROM [Sales].[Customers] c
CROSS APPLY dbo.GetCustomerLocationInfo(c.CustomerID) cli
ORDER BY c.CustomerID;

	--drop function if exists GetCustomerLocationInfo

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/

/*
Я бы использовала READ COMMITTED,
который используется по-умолчанию конкретно в данной ситуации со статичной БД.
Однако в случае динамической БД я бы предпочла, наверное, SNAPSHOT,
поскольку он минимизирует блокировку и обеспечивает консистентность данных на момент начала транзакции.
*/