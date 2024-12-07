/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

INSERT INTO Sales.Customers(
[CustomerName]
,[BillToCustomerID]
,[CustomerCategoryID]
,[BuyingGroupID]
,[PrimaryContactPersonID]
,[AlternateContactPersonID]
,[DeliveryMethodID]
,[DeliveryCityID]
,[PostalCityID]
,[CreditLimit]
,[AccountOpenedDate]
,[StandardDiscountPercentage]
,[IsStatementSent]
,[IsOnCreditHold]
,[PaymentDays]
,[PhoneNumber]
,[FaxNumber]
,[DeliveryRun]
,[RunPosition]
,[WebsiteURL]
,[DeliveryAddressLine1]
,[DeliveryAddressLine2]
,[DeliveryPostalCode]
,[PostalAddressLine1]
,[PostalAddressLine2]
,[PostalPostalCode]
,[LastEditedBy]
)
VALUES(
'Aneri Rei', 888, 5, 2, 3139, NULL, 3,	19881,	19881,	1700.00, '2024-12-07', 0.000,	0,	0, 7, '(217) 555-0100', '(217) 555-0101',
NULL, NULL, 'http://www.microsoft.com/', 'Shop 15', '652 Victoria Lane', 90243,	'PO Box 8115',	'Milicaville',	90005,	1),
('Todoroki Touya', 888, 7, 2, 3140, NULL,	3,	19374,	19374,	2400.00, '2024-12-07', 0.000,	0,	0, 7, '(118) 555-0100', '(118) 555-0101',
NULL, NULL, 'http://www.microsoft.com/', 'Shop 16', '653 Victoria Lane', 90243,	'PO Box 911',	'Flames',	93018,	1),
('Memoire Vanitas', 888, 3, 2, 3141, NULL,	3,	29391,	29391,	3400.00, '2024-12-07', 0.000,	0,	0, 7, '(181) 555-0100', '(181) 555-0101',
NULL, NULL, 'http://www.microsoft.com/', 'Suite 5', '1527 Milada Lane', 90243,	'PO Box 1854',	'Graveyard',	91127,	1),
('Zlobin Michael', 888, 5, 1, 3142, NULL,	3,	26010,	26010,	400.00, '2024-12-07', 0.000,	0,	0, 7, '(232) 555-0100', '(232) 555-0101',
NULL, NULL, 'http://www.microsoft.com/', 'Shop 29', '105 Jitka Street', 90243,	'PO Box 777',	'Fior',	90976,	1),
('Kot Elly', 888, 4, 1, 3143, NULL,	3,	35684,	35684,	1800.00, '2024-12-07', 0.000,	0,	0, 7, '(333) 555-0100', '(333) 555-0101',
NULL, NULL, 'http://www.microsoft.com/', 'Shop 35', '1999 Ethan Road', 90243,	'PO Box 787',	'Lilly',	98750,	1)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Sales.Customers
WHERE [CustomerName] = 'Kot Elly'

/*
3. Изменить одну запись из добавленных через UPDATE
*/

UPDATE Sales.Customers
SET [PostalAddressLine2] = 'Fruktovaya'
WHERE [CustomerName] = 'Zlobin Michael'

/*
4. Написать MERGE, который вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE INTO Sales.Customers AS target
USING (
SELECT
1069 AS CustomerID,
'Kot Elly' AS CustomerName,
888 AS BillToCustomerID,
4 AS CustomerCategoryID,
1 AS BuyingGroupID,
3143 AS PrimaryContactPersonID,
NULL AS AlternateContactPersonID,
3 AS DeliveryMethodID,
35684 AS DeliveryCityID,
35684 AS PostalCityID,
1800.00 AS CreditLimit,
'2024-12-07' AS AccountOpenedDate,
0.000 AS StandardDiscountPercentage,
0 AS IsStatementSent,
0 AS IsOnCreditHold,
7 AS PaymentDays,
'(333) 555-0100' AS PhoneNumber,
'(333) 555-0101' AS FaxNumber,
NULL AS DeliveryRun,
NULL AS RunPosition,
'http://www.microsoft.com/' AS WebsiteURL,
'Shop 35' AS DeliveryAddressLine1,
'1999 Ethan Road' AS DeliveryAddressLine2,
90243 AS DeliveryPostalCode,
'PO Box 787' AS PostalAddressLine1,
'Lilly' AS PostalAddressLine2,
98750 AS PostalPostalCode,
1 AS LastEditedBy
UNION ALL
SELECT
1068 AS CustomerID,
'Dragneel Natsu' AS CustomerName,
888 AS BillToCustomerID,
5 AS CustomerCategoryID,
1 AS BuyingGroupID,
3142 AS PrimaryContactPersonID,
NULL AS AlternateContactPersonID,
3 AS DeliveryMethodID,
26010 AS DeliveryCityID,
26010 AS PostalCityID,
400.00 AS CreditLimit,
'2024-12-07' AS AccountOpenedDate,
0.000 AS StandardDiscountPercentage,
0 AS IsStatementSent,
0 AS IsOnCreditHold,
7 AS PaymentDays,
'(232) 555-0100' AS PhoneNumber,
'(232) 555-0101' AS FaxNumber,
NULL AS DeliveryRun,
NULL AS RunPosition,
'http://www.microsoft.com/' AS WebsiteURL,
'Shop 29' AS DeliveryAddressLine1,
'105 Jitka Street' AS DeliveryAddressLine2,
90243 AS DeliveryPostalCode,
'PO Box 777' AS PostalAddressLine1,
'Fior' AS PostalAddressLine2,
90976 AS PostalPostalCode,
1 AS LastEditedBy) AS source
ON target.CustomerID = source.CustomerID
WHEN MATCHED THEN
UPDATE SET
target.CustomerName = source.CustomerName,
target.BillToCustomerID = source.BillToCustomerID,
target.CustomerCategoryID = source.CustomerCategoryID,
target.BuyingGroupID = source.BuyingGroupID,
target.PrimaryContactPersonID = source.PrimaryContactPersonID,
target.AlternateContactPersonID = source.AlternateContactPersonID,
target.DeliveryMethodID = source.DeliveryMethodID,
target.DeliveryCityID = source.DeliveryCityID,
target.PostalCityID = source.PostalCityID,
target.CreditLimit = source.CreditLimit,
target.AccountOpenedDate = source.AccountOpenedDate,
target.StandardDiscountPercentage = source.StandardDiscountPercentage,
target.IsStatementSent = source.IsStatementSent,
target.IsOnCreditHold = source.IsOnCreditHold,
target.PaymentDays = source.PaymentDays,
target.PhoneNumber = source.PhoneNumber,
target.FaxNumber = source.FaxNumber,
target.DeliveryRun = source.DeliveryRun,
target.RunPosition = source.RunPosition,
target.WebsiteURL = source.WebsiteURL,
target.DeliveryAddressLine1 = source.DeliveryAddressLine1,
target.DeliveryAddressLine2 = source.DeliveryAddressLine2,
target.DeliveryPostalCode = source.DeliveryPostalCode,
target.PostalAddressLine1 = source.PostalAddressLine1,
target.PostalAddressLine2 = source.PostalAddressLine2,
target.PostalPostalCode = source.PostalPostalCode,
target.LastEditedBy = source.LastEditedBy
WHEN NOT MATCHED THEN
INSERT (
CustomerID,
CustomerName,
BillToCustomerID,
CustomerCategoryID,
BuyingGroupID,
PrimaryContactPersonID,
AlternateContactPersonID,
DeliveryMethodID,
DeliveryCityID,
PostalCityID,
CreditLimit,
AccountOpenedDate,
StandardDiscountPercentage,
IsStatementSent,
IsOnCreditHold,
PaymentDays,
PhoneNumber,
FaxNumber,
DeliveryRun,
RunPosition,
WebsiteURL,
DeliveryAddressLine1,
DeliveryAddressLine2,
DeliveryPostalCode,
PostalAddressLine1,
PostalAddressLine2,
PostalPostalCode,
LastEditedBy)
VALUES (
source.CustomerID,
source.CustomerName,
source.BillToCustomerID,
source.CustomerCategoryID,
source.BuyingGroupID,
source.PrimaryContactPersonID,
source.AlternateContactPersonID,
source.DeliveryMethodID,
source.DeliveryCityID,
source.PostalCityID,
source.CreditLimit,
source.AccountOpenedDate,
source.StandardDiscountPercentage,
source.IsStatementSent,
source.IsOnCreditHold,
source.PaymentDays,
source.PhoneNumber,
source.FaxNumber,
source.DeliveryRun,
source.RunPosition,
source.WebsiteURL,
source.DeliveryAddressLine1,
source.DeliveryAddressLine2,
source.DeliveryPostalCode,
source.PostalAddressLine1,
source.PostalAddressLine2,
source.PostalPostalCode,
source.LastEditedBy);

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

/* Запрос для командной строки:
bcp "Sales.Customers" out "C:\SQL2022\otus-mssql-pushkareva\HW08 - Operators\customers.dat" -c -T -S "имя сервера" -d "WideWorldImporters" */

SELECT * INTO Sales.Customers_Copy
FROM Sales.Customers
WHERE 1=0;

BULK INSERT Sales.Customers_Copy
FROM 'C:\SQL2022\otus-mssql-pushkareva\HW08 - Operators\customers.dat'
WITH (
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1
);