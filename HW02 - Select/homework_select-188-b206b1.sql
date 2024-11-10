/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT StockItemID AS 'Код товара', StockItemName AS 'Наименование товара'
FROM Warehouse.StockItems with (nolock)
WHERE StockItemName LIKE '%urgent%'
OR StockItemName LIKE 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT s.SupplierID AS 'Код поставщика', s.SupplierName AS 'Наименование поставщика'
FROM Purchasing.Suppliers s with (nolock)
LEFT JOIN Purchasing.PurchaseOrders po with (nolock)
ON s.SupplierID = po.SupplierID
WHERE po.OrderDate IS NULL

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT TOP 1000 o.OrderID AS 'Код заказа', 
FORMAT(o.OrderDate, 'dd.MM.yyyy') AS 'Дата заказа',
DATENAME(MONTH, o.OrderDate) AS 'Месяц',
DATEPART(QUARTER, o.OrderDate) AS 'Квартал',
((MONTH(o.OrderDate)-1)/4)+1 AS 'Треть года',
c.CustomerName AS 'Имя заказчика'
FROM Sales.Orders o with (nolock)
LEFT JOIN Sales.OrderLines ol with (nolock)
ON o.OrderID = ol.OrderID
LEFT JOIN Sales.Customers c with (nolock)
ON o.CustomerID=c.CustomerID
WHERE (ol.UnitPrice  >100 OR ol.Quantity > 20)
AND o.PickingCompletedWhen IS NOT NULL
ORDER BY DATEPART(QUARTER, o.OrderDate),
((MONTH(o.OrderDate)-1)/4)+1, o.OrderDate

/* следующие 100 строк */

SELECT o.OrderID AS 'Код заказа', 
FORMAT(o.OrderDate, 'dd.MM.yyyy') AS 'Дата заказа',
DATENAME(MONTH, o.OrderDate) AS 'Месяц',
DATEPART(QUARTER, o.OrderDate) AS 'Квартал',
((MONTH(o.OrderDate)-1)/4)+1 AS 'Треть года',
c.CustomerName AS 'Имя заказчика'
FROM Sales.Orders o with (nolock)
LEFT JOIN Sales.OrderLines ol with (nolock)
ON o.OrderID = ol.OrderID
LEFT JOIN Sales.Customers c with (nolock)
ON o.CustomerID=c.CustomerID
WHERE (ol.UnitPrice  >100 OR ol.Quantity > 20)
AND o.PickingCompletedWhen IS NOT NULL
ORDER BY DATEPART(QUARTER, o.OrderDate),
((MONTH(o.OrderDate)-1)/4)+1, o.OrderDate
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY;

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT 
dm.DeliveryMethodName AS 'Способ доставки',
po.ExpectedDeliveryDate AS 'Дата доставки',
s.SupplierName AS 'Имя поставщика',
p.FullName AS 'Контактное лицо'
FROM Purchasing.Suppliers s with (nolock)
LEFT JOIN Purchasing.PurchaseOrders po with (nolock)
ON s.SupplierID = po.SupplierID
LEFT JOIN Application.DeliveryMethods dm with (nolock)
ON po.DeliveryMethodID=dm.DeliveryMethodID
LEFT JOIN Application.People p with (nolock)
ON po.ContactPersonID=p.PersonID
WHERE (MONTH(po.ExpectedDeliveryDate) = 1 AND YEAR(po.ExpectedDeliveryDate) = 2013)
AND (dm.DeliveryMethodName = 'Air Freight' OR dm.DeliveryMethodName = 'Refrigerated Air Freight')
AND po.IsOrderFinalized = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP 10
o.OrderDate AS 'Дата продажи',
c.CustomerName AS 'Имя клиента',
p.FullName AS 'Имя сотрудника'
FROM Sales.Orders o with (nolock)
JOIN Sales.Customers c with (nolock)
ON o.CustomerID = c.CustomerID
JOIN Application.People p with (nolock)
ON o.SalespersonPersonID = p.PersonID
ORDER BY o.OrderDate DESC

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT
c.CustomerID AS 'Код клиента',
c.CustomerName AS 'Имя клиента',
c.PhoneNumber AS 'Контактный телефон'
FROM Sales.Customers c with (nolock)
JOIN Sales.Orders o with (nolock)
ON o.CustomerID = c.CustomerID
JOIN Sales.OrderLines ol with (nolock)
ON ol.OrderID = o.OrderID
JOIN Warehouse.StockItems si with (nolock)
ON si.StockItemID = ol.StockItemID
WHERE si.StockItemName = 'Chocolate frogs 250g'

