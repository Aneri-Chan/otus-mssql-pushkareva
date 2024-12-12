/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
YEAR(i.InvoiceDate) AS 'Год продажи',
MONTH(i.InvoiceDate) AS 'Месяц продажи',
AVG(il.UnitPrice) AS 'Средняя цена за месяц по всем товарам',
SUM(il.Quantity * il.UnitPrice) AS 'Общая сумма продаж за месяц'
FROM Sales.InvoiceLines il WITH (NOLOCK)
LEFT JOIN Sales.Invoices i WITH (NOLOCK)
ON il.InvoiceID = i.InvoiceID
WHERE YEAR(i.InvoiceDate) = 2015
AND MONTH(i.InvoiceDate) = 4
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate);

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
YEAR(i.InvoiceDate) AS 'Год продажи',
MONTH(i.InvoiceDate) AS 'Месяц продажи',
SUM(il.Quantity * il.UnitPrice) AS 'Общая сумма продаж за месяц'
FROM Sales.InvoiceLines il WITH (NOLOCK)
LEFT JOIN Sales.Invoices i WITH (NOLOCK)
ON il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
HAVING SUM(il.Quantity * il.UnitPrice) > 4600000

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
YEAR(i.InvoiceDate) AS 'Год продажи',
MONTH(i.InvoiceDate) AS 'Месяц продажи',
si.StockItemName AS 'Наименование товара',
SUM(il.Quantity * il.UnitPrice) AS 'Сумма продаж',
MIN(i.InvoiceDate) AS 'Дата первой продажи',
SUM(il.Quantity) AS 'Количество проданного'
FROM Sales.InvoiceLines il WITH (NOLOCK)
LEFT JOIN Sales.Invoices i WITH (NOLOCK) ON il.InvoiceID = i.InvoiceID
LEFT JOIN Warehouse.StockItems si WITH (NOLOCK) ON il.StockItemID = si.StockItemID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), si.StockItemName
HAVING SUM(il.Quantity) < 50
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), si.StockItemName;

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

-- 2. 

WITH DateRange AS (
SELECT DISTINCT
years.Year AS [Год продажи],
months.month AS [Месяц продажи]
FROM Sales.Invoices i WITH (NOLOCK)
CROSS JOIN (SELECT DISTINCT YEAR(InvoiceDate) AS Year FROM Sales.Invoices) years
CROSS JOIN (SELECT 1 AS month UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 
UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12) months)
SELECT
dr.[Год продажи],
dr.[Месяц продажи],
COALESCE(SUM(il.Quantity * il.UnitPrice), 0) AS [Общая сумма продаж за месяц]
FROM DateRange dr
LEFT JOIN Sales.Invoices i WITH (NOLOCK) 
ON YEAR(i.InvoiceDate) = dr.[Год продажи]
AND MONTH(i.InvoiceDate) = dr.[Месяц продажи]
LEFT JOIN Sales.InvoiceLines il WITH (NOLOCK)
ON il.InvoiceID = i.InvoiceID
GROUP BY dr.[Год продажи], dr.[Месяц продажи]
ORDER BY dr.[Год продажи], dr.[Месяц продажи];

-- 3.

WITH DateRange AS (
SELECT DISTINCT
years.Year AS [Год продажи],
months.month AS [Месяц продажи]
FROM Sales.Invoices i WITH (NOLOCK)
CROSS JOIN (SELECT DISTINCT YEAR(InvoiceDate) AS Year FROM Sales.Invoices) years
CROSS JOIN (SELECT 1 AS month UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 
UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12) months)
SELECT
dr.[Год продажи],
dr.[Месяц продажи],
si.StockItemName AS [Наименование товара],
COALESCE(SUM(il.Quantity * il.UnitPrice), 0) AS [Сумма продаж],
MIN(i.InvoiceDate) AS [Дата первой продажи],
COALESCE(SUM(il.Quantity), 0) AS [Количество проданного]
FROM DateRange dr
LEFT JOIN Sales.Invoices i WITH (NOLOCK)
ON YEAR(i.InvoiceDate) = dr.[Год продажи]
AND MONTH(i.InvoiceDate) = dr.[Месяц продажи]
LEFT JOIN Sales.InvoiceLines il WITH (NOLOCK)
ON il.InvoiceID = i.InvoiceID
LEFT JOIN Warehouse.StockItems si WITH (NOLOCK)
ON il.StockItemID = si.StockItemID
GROUP BY dr.[Год продажи], dr.[Месяц продажи], si.StockItemName
HAVING COALESCE(SUM(il.Quantity), 0) < 50
ORDER BY dr.[Год продажи], dr.[Месяц продажи], si.StockItemName;
