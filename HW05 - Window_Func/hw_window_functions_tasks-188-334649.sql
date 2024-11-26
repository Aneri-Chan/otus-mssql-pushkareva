/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

set statistics time, io on
SELECT
i.InvoiceID AS 'Код продажи',
c.CustomerName AS 'Имя клиента',
i.InvoiceDate AS 'Дата продажи',
ol.Quantity * ol.UnitPrice AS 'Сумма продажи',
(SELECT SUM(ol2.Quantity * ol2.UnitPrice)
FROM Sales.Invoices i2
JOIN Sales.OrderLines ol2 
ON i2.OrderID = ol2.OrderID
WHERE YEAR(i2.InvoiceDate) = YEAR(i.InvoiceDate)
AND MONTH(i2.InvoiceDate) = MONTH(i.InvoiceDate)) AS 'Нарастающая сумма'
FROM Sales.Invoices i
JOIN Sales.Customers c 
ON i.CustomerID = c.CustomerID
JOIN Sales.OrderLines ol 
ON i.OrderID = ol.OrderID
WHERE i.InvoiceDate >= '2015-01-01'
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), i.InvoiceDate, c.CustomerName;

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

set statistics time, io on
SELECT
i.InvoiceID AS 'Код продажи',
c.CustomerName AS 'Имя клиента',
i.InvoiceDate AS 'Дата продажи',
ol.Quantity*ol.UnitPrice AS 'Сумма продажи',
SUM(ol.Quantity*ol.UnitPrice)
OVER(PARTITION BY YEAR(i.InvoiceDate)*100+MONTH(i.InvoiceDate)) AS 'Нарастающая сумма'
FROM Sales.Invoices i
JOIN Sales.Customers c 
ON i.CustomerID=c.CustomerID
JOIN Sales.OrderLines ol 
ON i.OrderID=ol.OrderID
WHERE i.InvoiceDate >= '2015-01-01'
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), i.InvoiceDate, c.CustomerName

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

;WITH MonthlyProductSales AS (
SELECT 
si.StockItemName AS ProductName,
YEAR(i.InvoiceDate) AS Year,
MONTH(i.InvoiceDate) AS Month,
SUM(il.Quantity) AS TotalSold,
ROW_NUMBER() OVER (
PARTITION BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate) 
ORDER BY SUM(il.Quantity) DESC) AS Rank
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il 
ON i.InvoiceID = il.InvoiceID
JOIN Warehouse.StockItems si 
ON il.StockItemID = si.StockItemID
WHERE YEAR(i.InvoiceDate) = 2016
GROUP BY si.StockItemName, YEAR(i.InvoiceDate), MONTH(i.InvoiceDate))
SELECT 
ProductName AS 'Название продукта',
Year AS 'Год',
Month AS 'Месяц',
TotalSold AS 'Количество проданных'
FROM MonthlyProductSales
WHERE Rank <= 2
ORDER BY Year, Month, TotalSold DESC

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT
si.StockItemID AS 'Код товара',
si.StockItemName AS 'Название товара',
si.Brand AS 'Бренд',
si.UnitPrice AS 'Цена',
ROW_NUMBER() OVER (
PARTITION BY LEFT(si.StockItemName, 1) 
ORDER BY si.StockItemName) AS 'Номер по алфавиту',
COUNT(*) OVER () AS 'Общее количество товаров',
COUNT(*) OVER (
PARTITION BY LEFT(si.StockItemName, 1)) AS 'Количество товаров по первой букве',
LEAD(si.StockItemID) OVER (
ORDER BY si.StockItemName) AS 'Следующий ID товара',
LAG(si.StockItemID) OVER (
ORDER BY si.StockItemName) AS 'Предыдущий ID товара',
COALESCE(
LAG(si.StockItemName, 2) OVER (ORDER BY si.StockItemName),
'No items') AS 'Название товара 2 строки назад',
NTILE(30) OVER (
ORDER BY si.TypicalWeightPerUnit) AS 'Группа по весу'
FROM Warehouse.StockItems si
ORDER BY si.StockItemName

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

;WITH LastClient AS (
SELECT
p.PersonID AS PersID,
p.FullName AS SalesName,
c.CustomerID AS CustID,
c.CustomerName AS CustName,
i.InvoiceDate AS DateSale,
SUM(il.Quantity * il.UnitPrice) AS SumDeal,
ROW_NUMBER() OVER (
PARTITION BY p.PersonID 
ORDER BY i.InvoiceDate DESC) AS RowNum
FROM Sales.Invoices i
JOIN Sales.Customers c 
ON i.CustomerID = c.CustomerID
JOIN Sales.InvoiceLines il 
ON i.InvoiceID = il.InvoiceID
JOIN Application.People p 
ON i.SalespersonPersonID = p.PersonID
GROUP BY 
p.PersonID, p.FullName, 
c.CustomerID, c.CustomerName, 
i.InvoiceDate)
SELECT 
PersID AS 'Код сотрудника',
SalesName AS 'Имя сотрудника',
CustID AS 'Код клиента',
CustName AS 'Имя клиента',
DateSale AS 'Дата продажи',
SumDeal AS 'Сумма сделки'
FROM LastClient
WHERE RowNum = 1
ORDER BY SalesName, DateSale DESC

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;WITH ExpensiveProducts AS (
SELECT
c.CustomerID AS CustomerId,
c.CustomerName AS CustomerName,
si.StockItemID AS ItemId,
si.StockItemName AS ProductName,
il.Quantity * il.UnitPrice AS Cost,
i.InvoiceDate AS DateSale,
ROW_NUMBER() OVER (
PARTITION BY c.CustomerID
ORDER BY il.UnitPrice DESC) AS Rank
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il 
ON i.InvoiceID = il.InvoiceID
JOIN Sales.Customers c 
ON i.CustomerID = c.CustomerID
JOIN Warehouse.StockItems si 
ON il.StockItemID = si.StockItemID)
SELECT 
CustomerId AS 'Код клиента',
CustomerName AS 'Имя клиента',
ItemId AS 'Код продукта',
ProductName AS 'Название продукта',
Cost AS 'Стоимость',
DateSale AS 'Дата покупки'
FROM ExpensiveProducts
WHERE Rank <= 2
ORDER BY CustomerId, Cost DESC, DateSale DESC;