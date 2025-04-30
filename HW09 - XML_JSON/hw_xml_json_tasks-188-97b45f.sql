/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

--с помощью OPENXML

DECLARE @xmlDocument XML;

SELECT @xmlDocument = BulkColumn
FROM OPENROWSET(BULK 'C:\SQL2022\otus-mssql-pushkareva\HW09 - XML_JSON\StockItems-188-1fb5df.xml', SINGLE_CLOB) AS data;

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

MERGE INTO Warehouse.StockItems AS target
USING (
SELECT 
StockItemName,
SupplierID,
UnitPackageID,
OuterPackageID,
QuantityPerOuter,
TypicalWeightPerUnit,
LeadTimeDays,
IsChillerStock,
TaxRate,
UnitPrice
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
StockItemName NVARCHAR(100) '@Name',
SupplierID INT 'SupplierID',
UnitPackageID INT 'Package/UnitPackageID',
OuterPackageID INT 'Package/OuterPackageID',
QuantityPerOuter INT 'Package/QuantityPerOuter',
TypicalWeightPerUnit DECIMAL(18,3) 'Package/TypicalWeightPerUnit',
LeadTimeDays INT 'LeadTimeDays',
IsChillerStock BIT 'IsChillerStock',
TaxRate DECIMAL(18,3) 'TaxRate',
UnitPrice DECIMAL(18,2) 'UnitPrice')) AS source
ON target.StockItemName = source.StockItemName

WHEN MATCHED THEN
UPDATE SET
target.SupplierID = source.SupplierID,
target.UnitPackageID = source.UnitPackageID,
target.OuterPackageID = source.OuterPackageID,
target.QuantityPerOuter = source.QuantityPerOuter,
target.TypicalWeightPerUnit = source.TypicalWeightPerUnit,
target.LeadTimeDays = source.LeadTimeDays,
target.IsChillerStock = source.IsChillerStock,
target.TaxRate = source.TaxRate,
target.UnitPrice = source.UnitPrice,
target.LastEditedBy = 1

WHEN NOT MATCHED THEN
INSERT (StockItemName, SupplierID, UnitPackageID, OuterPackageID, 
QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, 
TaxRate, UnitPrice, LastEditedBy)
VALUES (source.StockItemName, source.SupplierID, source.UnitPackageID, 
source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit, 
source.LeadTimeDays, source.IsChillerStock, source.TaxRate, source.UnitPrice, 1);

EXEC sp_xml_removedocument @docHandle;

--через XQuery

DECLARE @xmlDocument1 XML;

SELECT @xmlDocument1 = BulkColumn
FROM OPENROWSET(BULK 'C:\SQL2022\otus-mssql-pushkareva\HW09 - XML_JSON\StockItems-188-1fb5df.xml', SINGLE_CLOB) AS data;

MERGE INTO Warehouse.StockItems AS target
USING (
SELECT 
Item.value('@Name', 'NVARCHAR(100)') AS StockItemName, 
Item.value('(SupplierID)[1]', 'INT') AS SupplierID,
Item.value('(Package/UnitPackageID)[1]', 'INT') AS UnitPackageID,
Item.value('(Package/OuterPackageID)[1]', 'INT') AS OuterPackageID,
Item.value('(Package/QuantityPerOuter)[1]', 'INT') AS QuantityPerOuter,
Item.value('(Package/TypicalWeightPerUnit)[1]', 'DECIMAL(18,3)') AS TypicalWeightPerUnit,
Item.value('(LeadTimeDays)[1]', 'INT') AS LeadTimeDays,
Item.value('(IsChillerStock)[1]', 'BIT') AS IsChillerStock,
Item.value('(TaxRate)[1]', 'DECIMAL(18,3)') AS TaxRate,
Item.value('(UnitPrice)[1]', 'DECIMAL(18,2)') AS UnitPrice
FROM @xmlDocument1.nodes('/StockItems/Item') AS X(Item)) AS source
ON target.StockItemName = source.StockItemName

WHEN MATCHED THEN
UPDATE SET
target.SupplierID = source.SupplierID,
target.UnitPackageID = source.UnitPackageID,
target.OuterPackageID = source.OuterPackageID,
target.QuantityPerOuter = source.QuantityPerOuter,
target.TypicalWeightPerUnit = source.TypicalWeightPerUnit,
target.LeadTimeDays = source.LeadTimeDays,
target.IsChillerStock = source.IsChillerStock,
target.TaxRate = source.TaxRate,
target.UnitPrice = source.UnitPrice,
target.LastEditedBy = 1

WHEN NOT MATCHED THEN
INSERT (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, 
LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, LastEditedBy)
VALUES (source.StockItemName, source.SupplierID, source.UnitPackageID, source.OuterPackageID, source.QuantityPerOuter, 
source.TypicalWeightPerUnit, source.LeadTimeDays, source.IsChillerStock, source.TaxRate, source.UnitPrice, 1);


/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

CREATE VIEW StockItemsView AS
SELECT 
StockItemName,
SupplierID,
UnitPackageID,
OuterPackageID,
QuantityPerOuter,
TypicalWeightPerUnit,
LeadTimeDays,
IsChillerStock,
TaxRate,
UnitPrice,
LastEditedBy
FROM Warehouse.StockItems

/* bcp "dbo.StockItemsView" out "C:\SQL2022\otus-mssql-pushkareva\HW09 - XML_JSON\StockItemsNotXMLFormatData.xml" -c -T -S "server_name" -d "WideWorldImporters" */

SELECT 
StockItemName AS [@Name],
SupplierID AS [SupplierID],
UnitPackageID AS [Package/UnitPackageID],
OuterPackageID AS [Package/OuterPackageID],
QuantityPerOuter AS [Package/QuantityPerOuter],
TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit],
LeadTimeDays AS [LeadTimeDays],
IsChillerStock AS [IsChillerStock],
TaxRate AS [TaxRate],
UnitPrice AS [UnitPrice],
LastEditedBy AS [LastEditedBy]
FROM Warehouse.StockItems
FOR XML PATH('Item'), ROOT('StockItems');

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT 
StockItemID AS [StockItemID],
StockItemName AS [StockItemName],
JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS [CountryOfManufacture],
JSON_VALUE(CustomFields, '$.Tags[0]') AS [Tags/FirstTag]
FROM Warehouse.StockItems
FOR XML PATH('Item'), ROOT('StockItems');

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT 
StockItemID, 
StockItemName, 
STRING_AGG(tag.value, ', ') AS Tags
FROM Warehouse.StockItems
CROSS APPLY 
OPENJSON(CustomFields, '$.Tags') AS tag 
WHERE 
EXISTS (
SELECT 1 
FROM OPENJSON(CustomFields, '$.Tags') AS check_tag
WHERE check_tag.value = 'Vintage')
GROUP BY StockItemID, StockItemName
FOR XML PATH('Item'), ROOT('StockItems');
