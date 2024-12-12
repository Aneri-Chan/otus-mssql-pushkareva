/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

;WITH FilteredCustomers AS (
SELECT
CustomerID,
SUBSTRING(CustomerName, CHARINDEX('(', CustomerName) + 1,
CHARINDEX(')', CustomerName) - CHARINDEX('(', CustomerName) - 1) AS CustomerDetail
FROM Sales.Customers
WHERE CustomerID BETWEEN 2 AND 6),
MonthlyPurchases AS (
SELECT
FORMAT(DATEFROMPARTS(YEAR(i.InvoiceDate),
MONTH(i.InvoiceDate), 1), 'dd.MM.yyyy') AS InvoiceMonth,
fc.CustomerDetail,
COUNT(i.InvoiceID) AS PurchaseCount
FROM Sales.Invoices i
JOIN FilteredCustomers fc
ON i.CustomerID = fc.CustomerID
GROUP BY FORMAT(DATEFROMPARTS(YEAR(i.InvoiceDate), 
MONTH(i.InvoiceDate), 1), 'dd.MM.yyyy'), fc.CustomerDetail),
PivotedData AS (
SELECT 
InvoiceMonth,
[Peeples Valley, AZ],
[Medicine Lodge, KS],
[Gasport, NY],
[Sylvanite, MT],
[Jessie, ND]
FROM MonthlyPurchases
PIVOT (
MAX(PurchaseCount)
FOR CustomerDetail IN (
[Peeples Valley, AZ],
[Medicine Lodge, KS],
[Gasport, NY],
[Sylvanite, MT],
[Jessie, ND])) AS pvt)
SELECT 
InvoiceMonth AS 'Дата начала месяца',
[Peeples Valley, AZ] AS 'Peeples Valley, AZ',
[Medicine Lodge, KS] AS 'Medicine Lodge, KS',
[Gasport, NY] AS 'Gasport, NY',
[Sylvanite, MT] AS 'Sylvanite, MT',
[Jessie, ND] AS 'Jessie, ND'
FROM PivotedData
ORDER BY CONVERT(DATE, InvoiceMonth, 104);

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT 
c.CustomerName AS 'CustomerName',
addr.AddressLine AS 'AddressLine'
FROM 
Sales.Customers c
CROSS APPLY 
(VALUES (c.DeliveryAddressLine1), (c.DeliveryAddressLine2)) AS addr(AddressLine)
WHERE 
c.CustomerName LIKE '%Tailspin Toys%'
ORDER BY 
c.CustomerName, addr.AddressLine

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT 
CountryId,
CountryName,
Code
FROM 
(SELECT 
CountryId,
CountryName,
CAST(IsoAlpha3Code AS VARCHAR(10)) AS IsoAlpha3Code,
CAST(IsoNumericCode AS VARCHAR(10)) AS IsoNumericCode
FROM Application.Countries) AS src
UNPIVOT
(Code FOR CountryCode IN (IsoAlpha3Code, IsoNumericCode)) AS unpvt
ORDER BY CountryId, Code;

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;WITH RankedProducts AS (
SELECT
c.CustomerID AS CustomerId,
c.CustomerName AS CustomerName,
si.StockItemName AS ProductName,
il.UnitPrice AS Price,
il.Quantity * il.UnitPrice AS Cost,
i.InvoiceDate AS DateSale,
ROW_NUMBER() OVER (
PARTITION BY c.CustomerID, si.StockItemID
ORDER BY il.UnitPrice DESC) AS ProductRank
FROM Sales.Customers c
JOIN Sales.Invoices i 
ON c.CustomerID = i.CustomerID
JOIN Sales.InvoiceLines il 
ON i.InvoiceID = il.InvoiceID
JOIN Warehouse.StockItems si 
ON il.StockItemID = si.StockItemID),
UniqueRankedProducts AS (
SELECT
CustomerId,
CustomerName,
ProductName,
Price,
Cost,
DateSale,
ROW_NUMBER() OVER (
PARTITION BY CustomerId
ORDER BY Price DESC) AS UniqueRank
FROM RankedProducts
WHERE ProductRank = 1)
SELECT 
pvt.CustomerId AS 'Код клиента',
pvt.CustomerName AS 'Имя клиента',
pvt.[1] AS 'Товар 1',
pvt.[2] AS 'Товар 2',
details.Price1 AS 'Цена товара 1',
details.Price2 AS 'Цена товара 2',
details.DateSale1 AS 'Дата покупки товара 1',
details.DateSale2 AS 'Дата покупки товара 2'
FROM (
SELECT
CustomerId,
CustomerName,
ProductName,
UniqueRank
FROM UniqueRankedProducts) src
PIVOT (
MAX(ProductName) FOR UniqueRank IN ([1], [2])) AS pvt
JOIN (
SELECT 
CustomerId,
MAX(CASE WHEN UniqueRank = 1 THEN Price END) AS Price1,
MAX(CASE WHEN UniqueRank = 2 THEN Price END) AS Price2,
MAX(CASE WHEN UniqueRank = 1 THEN DateSale END) AS DateSale1,
MAX(CASE WHEN UniqueRank = 2 THEN DateSale END) AS DateSale2
FROM UniqueRankedProducts
GROUP BY CustomerId) details
ON pvt.CustomerId = details.CustomerId;
