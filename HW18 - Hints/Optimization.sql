SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Исходный запрос
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

-- Оптимизация запроса

-- Выберем конкретного поставщика в отдельную временную таблицу
SELECT StockItemID
INTO #StockItemsFiltered
FROM Warehouse.StockItems
WHERE SupplierID = 12;

-- Создадим временную таблицу для клиентов с общей суммой заказов >250000
SELECT
ord.CustomerID,
SUM(det.UnitPrice * det.Quantity) AS TotalOrderAmount
INTO #CustomerTotalOrders
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
ON ord.OrderID = det.OrderID
GROUP BY ord.CustomerID
HAVING SUM(det.UnitPrice * det.Quantity) > 250000;

-- В основном запросе подтянем данные из временных таблиц #StockItemsFiltered и #CustomerTotalOrders
SELECT
ord.CustomerID,
det.StockItemID,
SUM(det.UnitPrice) AS TotalUnitPrice,
SUM(det.Quantity) AS TotalQuantity,
COUNT(ord.OrderID) AS OrderCount
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv
ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans
ON ItemTrans.StockItemID = det.StockItemID
JOIN #StockItemsFiltered AS It
ON It.StockItemID = det.StockItemID
JOIN #CustomerTotalOrders AS CTO
ON CTO.CustomerID = Inv.CustomerID
WHERE Inv.BillToCustomerID != ord.CustomerID
AND Inv.InvoiceDate = ord.OrderDate
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID;

-- Удаляем временные таблицы
DROP TABLE #StockItemsFiltered;
DROP TABLE #CustomerTotalOrders;

/*
Исходный запрос содержит коррелированные подзапросы в условии WHERE каждой результирующей строки, которые явно необходимо оптимизировать.
План выполнения для исходного запроса включает вложенные циклы, фильтры, сканирование больших таблиц.
Есть ещё сомнительный момент для COUNT(ord.OrderID) в исходном запросе, поскольку количество заказов считается довольно странно,
но я решила придерживаться того же результата, поэтому не стала вносить изменения в соединения таблиц,
которые не особо участвуют в выборке данных(CustomerTransactions, StockItemTransactions).

В качестве оптимизации хочу предложить использовать временные таблицы для подзапросов, а также прямое сравнение дат,
поскольку тип данных у полей Inv.InvoiceDate, ord.OrderDate совпадает - date.
При оптимизации я постаралась минимизировать количество операций чтения 
(Таблица "Invoices". Сканирований 1, логических операций чтения 71474 - 1 запрос; Таблица "Invoices". Сканирований 1, логических операций чтения 11400 - 2 запрос), 
исключить повторное выполнение подзапросов, используя предрасчёты в отдельных временных таблицах (#StockItemsFiltered и #CustomerTotalOrders).

Пробовала работать с hint'ами, однако результаты были максимально неудовлетворительными,
планы запросов сходили с ума, выдавая много мест с nested loops, либо возникали места с параллелизмом,
да и в самой статистике время выполнения и ресурсозатратность тоже увеличилась, поэтому отказалась от них.

Текущие запросы показали следующую статистику:

1 запрос:

 Время работы SQL Server:
   Время ЦП = 484 мс, затраченное время = 720 мс.

2 запрос:

 Время работы SQL Server:
   Время ЦП = 266 мс, затраченное время = 413 мс.

   Полную статистику приложила в файле Statistics.txt
*/
