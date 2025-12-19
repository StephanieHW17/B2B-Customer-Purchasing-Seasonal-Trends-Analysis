/*1. What are the overall purchasing patterns for customers in terms of total sales, order frequency, and average order value?*/


SELECT 
    c.CustomerID,
    c.CustomerName,
    COUNT(DISTINCT inv.InvoiceID) AS OrderFrequency,
    ROUND(SUM(il.Quantity * il.UnitPrice) / COUNT(DISTINCT inv.InvoiceID), 2) AS AvgOrderValue,
	SUM(il.Quantity * il.UnitPrice) AS TotalSales
FROM 
    Sales.InvoiceLines il
JOIN 
    Sales.Invoices inv ON il.InvoiceID = inv.InvoiceID
JOIN 
    Sales.Customers c ON inv.CustomerID = c.CustomerID
GROUP BY 
    c.CustomerID, c.CustomerName
ORDER BY 
    TotalSales DESC;

/*2. How do purchasing patterns vary across different customer categories (e.g., toy shops, supermarkets)
regarding total sales, order frequency, and average order value?*/

SELECT 
    cc.CustomerCategoryName,
    SUM(il.Quantity * il.UnitPrice) AS TotalSales,
    COUNT(DISTINCT inv.InvoiceID) AS OrderFrequency,
    ROUND(SUM(il.Quantity * il.UnitPrice) / COUNT(DISTINCT inv.InvoiceID), 2) AS AvgOrderValue
FROM 
    Sales.InvoiceLines il
JOIN 
    Sales.Invoices inv ON il.InvoiceID = inv.InvoiceID
 JOIN 
    Sales.Customers c ON inv.CustomerID = c.CustomerID
full outer JOIN 
    Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
GROUP BY 
    cc.CustomerCategoryName
ORDER By
    TotalSales DESC;

select *
from [Sales].[SpecialDeals] 

--Want to understand what category is the two buying group belong to because they are the only group which has special deal during June 2016


select BG.BuyingGroupID, BuyingGroupName, COUNT(DISTINCT BuyingGroupName) as [buying group count] , CC.CustomerCategoryID, CustomerCategoryName
from [Sales].[BuyingGroups] BG
join  sales.Customers SC
on BG.BuyingGroupID = sc.BuyingGroupID
join [Sales].[CustomerCategories] CC
on SC.CustomerCategoryID=CC.CustomerCategoryID
Group by BG.BuyingGroupID, BuyingGroupName, CC.CustomerCategoryID,CustomerCategoryName

--Join the table to check when is the special deal happend and which buying group is that

select BG.BuyingGroupID, BuyingGroupName, COUNT(DISTINCT BuyingGroupName) as [buying group count] , CC.CustomerCategoryID, CustomerCategoryName, 
StartDate, EndDate, DiscountPercentage
from [Sales].[SpecialDeals] SD
full outer join [Sales].[BuyingGroups] BG on SD.BuyingGroupID=BG.BuyingGroupID
join  sales.Customers SC
on BG.BuyingGroupID = sc.BuyingGroupID
join [Sales].[CustomerCategories] CC
on SC.CustomerCategoryID=CC.CustomerCategoryID
Group by BG.BuyingGroupID, BuyingGroupName, CC.CustomerCategoryID,CustomerCategoryName,StartDate, EndDate, DiscountPercentage



/*3. How do seasonal purchasing patterns compare across different customer categories, 
specifically looking at total sales and order frequency during special seasons (October to January) versus regular periods (February to September)*/

SELECT 
    SubQuery.CustomerCategoryName,
    SubQuery.Period,
    SUM(SubQuery.TotalSales) / COUNT(DISTINCT SubQuery.Date) AS AverageMonthlySales,
    SUM(SubQuery.OrderFrequency) / COUNT(DISTINCT SubQuery.Date) AS AverageMonthlyOrders
FROM (
    SELECT 
        cc.CustomerCategoryName,
        i.InvoiceDate AS Date,
        CASE 
            WHEN MONTH(i.InvoiceDate) BETWEEN 10 AND 12 OR MONTH(i.InvoiceDate) = 1 THEN 'Special Season'
            ELSE 'Regular Period'
        END AS Period,
        SUM(il.Quantity * il.UnitPrice) AS TotalSales,
        COUNT(DISTINCT i.InvoiceID) AS OrderFrequency
    FROM 
        Sales.Invoices i
    JOIN 
        Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
    JOIN 
        Sales.Customers c ON i.CustomerID = c.CustomerID
    JOIN 
        Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
    GROUP BY 
        cc.CustomerCategoryName, 
        i.InvoiceDate,
        CASE 
            WHEN MONTH(i.InvoiceDate) BETWEEN 10 AND 12  THEN 'Special Season'
            ELSE 'Regular Period'
        END
) AS SubQuery
GROUP BY 
    SubQuery.CustomerCategoryName, 
    SubQuery.Period
ORDER BY 
    SubQuery.CustomerCategoryName, 
    SubQuery.Period, AverageMonthlySales;

---Understand the pattern of each month to  find noticeable information

SELECT 
    SubQuery.CustomerCategoryName,
    SubQuery.Period,
    YEAR(SubQuery.Date) AS Year,
    MONTH(SubQuery.Date) AS Month,
    SUM(SubQuery.TotalSales) / COUNT(DISTINCT SubQuery.Date) AS AverageMonthlySales,
    SUM(SubQuery.OrderFrequency) / COUNT(DISTINCT SubQuery.Date) AS AverageMonthlyOrders
FROM (
    SELECT 
        cc.CustomerCategoryName,
        i.InvoiceDate AS Date,
        CASE 
            WHEN MONTH(i.InvoiceDate) BETWEEN 10 AND 12 OR MONTH(i.InvoiceDate) = 1 THEN 'Special Season'
            ELSE 'Regular Period'
        END AS Period,
        SUM(il.Quantity * il.UnitPrice) AS TotalSales,
        COUNT(DISTINCT i.InvoiceID) AS OrderFrequency
    FROM 
        Sales.Invoices i
    JOIN 
        Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
    JOIN 
        Sales.Customers c ON i.CustomerID = c.CustomerID
    JOIN 
        Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
    GROUP BY 
        cc.CustomerCategoryName, 
        i.InvoiceDate,
        CASE 
            WHEN MONTH(i.InvoiceDate) BETWEEN 10 AND 12 OR MONTH(i.InvoiceDate) = 1 THEN 'Special Season'
            ELSE 'Regular Period'
        END
) AS SubQuery
GROUP BY 
    SubQuery.CustomerCategoryName, 
    SubQuery.Period,
    YEAR(SubQuery.Date),
    MONTH(SubQuery.Date)
ORDER BY 
    SubQuery.CustomerCategoryName, 
    Year, 
    Month;

--Understand which period has the highest monthly sales and orders. 
/*The best selling period is from April to September which is regular peiod. However the sales between regular and special period is not that obvious. 
The notvely shops with high monthly orders do not generate to high monthly sales. Which can be aware of and make sure the customers order to appropriate amount stock
for generating better sales result. */


SELECT 
    SubQuery.CustomerCategoryName,
    SubQuery.Period,
    YEAR(SubQuery.Date) AS Year,
    MONTH(SubQuery.Date) AS Month,
    SUM(SubQuery.TotalSales) / COUNT(DISTINCT SubQuery.Date) AS AverageMonthlySales,
    SUM(SubQuery.OrderFrequency) / COUNT(DISTINCT SubQuery.Date) AS AverageMonthlyOrders
FROM (
    SELECT 
        distinct(cc.CustomerCategoryName),
        i.InvoiceDate AS Date,
        CASE 
            WHEN MONTH(i.InvoiceDate) BETWEEN 10 AND 12 OR MONTH(i.InvoiceDate) = 1 THEN 'Special Season'
            ELSE 'Regular Period'
        END AS Period,
        SUM(il.Quantity * il.UnitPrice) AS TotalSales,
        COUNT(DISTINCT i.InvoiceID) AS OrderFrequency
    FROM 
        Sales.Invoices i
    JOIN 
        Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
    JOIN 
        Sales.Customers c ON i.CustomerID = c.CustomerID
    JOIN 
        Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
    GROUP BY 
        cc.CustomerCategoryName, 
        i.InvoiceDate,
        CASE 
            WHEN MONTH(i.InvoiceDate) BETWEEN 10 AND 12 OR MONTH(i.InvoiceDate) = 1 THEN 'Special Season'
            ELSE 'Regular Period'
        END
) AS SubQuery
GROUP BY 
    SubQuery.CustomerCategoryName, 
    SubQuery.Period,
    YEAR(SubQuery.Date),
    MONTH(SubQuery.Date)
ORDER BY
  AverageMonthlyOrders desc, 
    AverageMonthlySales desc ;

--Monthly sale of novelty shop

	SELECT 
    SubQuery.CustomerCategoryName,
    SubQuery.Period,
    YEAR(SubQuery.Date) AS Year,
    MONTH(SubQuery.Date) AS Month,
    SUM(SubQuery.TotalSales) / COUNT(DISTINCT SubQuery.Date) AS AverageMonthlySales,
    SUM(SubQuery.OrderFrequency) / COUNT(DISTINCT SubQuery.Date) AS AverageMonthlyOrders
FROM (
    SELECT 
        distinct(cc.CustomerCategoryName),
        i.InvoiceDate AS Date,
        CASE 
            WHEN MONTH(i.InvoiceDate) BETWEEN 10 AND 12¡@THEN 'Special Season'
            ELSE 'Regular Period'
        END AS Period,
        SUM(il.Quantity * il.UnitPrice) AS TotalSales,
        COUNT(DISTINCT i.InvoiceID) AS OrderFrequency
    FROM 
        Sales.Invoices i
    JOIN 
        Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
    JOIN 
        Sales.Customers c ON i.CustomerID = c.CustomerID
    JOIN 
        Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
	Where Year(i.InvoiceDate)=2015
    GROUP BY 
        cc.CustomerCategoryName, 
        i.InvoiceDate,
        CASE 
            WHEN MONTH(i.InvoiceDate) BETWEEN 10 AND 12 OR MONTH(i.InvoiceDate) = 1 THEN 'Special Season'
            ELSE 'Regular Period'
        END
) AS SubQuery
GROUP BY 
    SubQuery.CustomerCategoryName, 
    SubQuery.Period,
    YEAR(SubQuery.Date),
    MONTH(SubQuery.Date)
Having SubQuery.CustomerCategoryName='Novelty Shop'
ORDER BY
  AverageMonthlyOrders desc, 
    AverageMonthlySales desc ;
	 

--Monthly sale of supermarket
	SELECT 
    SubQuery.CustomerCategoryName,
    SubQuery.Period,
    YEAR(SubQuery.Date) AS Year,
    MONTH(SubQuery.Date) AS Month,
    SUM(SubQuery.TotalSales) / COUNT(DISTINCT SubQuery.Date) AS AverageMonthlySales,
    SUM(SubQuery.OrderFrequency) / COUNT(DISTINCT SubQuery.Date) AS AverageMonthlyOrders
FROM (
    SELECT 
        distinct(cc.CustomerCategoryName),
        i.InvoiceDate AS Date,
        CASE 
            WHEN MONTH(i.InvoiceDate) BETWEEN 10 AND 12¡@THEN 'Special Season'
            ELSE 'Regular Period'
        END AS Period,
        SUM(il.Quantity * il.UnitPrice) AS TotalSales,
        COUNT(DISTINCT i.InvoiceID) AS OrderFrequency
    FROM 
        Sales.Invoices i
    JOIN 
        Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
    JOIN 
        Sales.Customers c ON i.CustomerID = c.CustomerID
    JOIN 
        Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
	Where Year(i.InvoiceDate)=2015
    GROUP BY 
        cc.CustomerCategoryName, 
        i.InvoiceDate,
        CASE 
            WHEN MONTH(i.InvoiceDate) BETWEEN 10 AND 12 OR MONTH(i.InvoiceDate) = 1 THEN 'Special Season'
            ELSE 'Regular Period'
        END
) AS SubQuery
GROUP BY 
    SubQuery.CustomerCategoryName, 
    SubQuery.Period,
    YEAR(SubQuery.Date),
    MONTH(SubQuery.Date)
Having SubQuery.CustomerCategoryName='Supermarket'
ORDER BY
  AverageMonthlyOrders desc, 
    AverageMonthlySales desc ;




--Not much difference between seasons, therefore understanding which product is the best seller, 
--the result shows that packaging materials has the highest sales among all of the 10 groups. 
SELECT Top 10 

    s.StockItemName AS ProductName,
    SUM(il.Quantity * il.UnitPrice) AS TotalSales
FROM 
    Sales.InvoiceLines il
JOIN 
   [Warehouse].[StockItems] s ON il.StockItemID = s.StockItemID
GROUP BY 
    s.StockItemName, s.StockItemID
ORDER BY 
    TotalSales DESC

--Understand how many stock groups. 

select *
from [Warehouse].[StockGroups]

--Air Cushion machine in the packaging material group is the best seller

SELECT 
sg.StockGroupName,
    s.StockItemName AS ProductName,
    SUM(il.Quantity * il.UnitPrice) AS TotalSales
FROM 
    Sales.InvoiceLines il
JOIN 
   [Warehouse].[StockItems] s ON il.StockItemID = s.StockItemID
Join [Warehouse].[StockItemStockGroups] as ssg
   on s.StockItemID=ssg.StockItemID
Join [Warehouse].[StockGroups] sg
   on ssg.StockGroupID=sg.StockGroupID
GROUP BY 
    sg.StockGroupName,StockItemName, s.StockItemID
ORDER BY 
    TotalSales DESC




/*4. How do purchasing behaviors during special seasons vary by states, 
and which key cities experience the highest sales and order frequency increases? 
Additionally, what are the best-selling products and customer categories (e.g., toy shops, supermarkets) in these cities during these periods?*/


--count how many countries and cities
select count(countryName)
from [Application].[Countries]--190 Countries
select *
from [Application].[Countries]

select count(Distinct [CityName])
from [Application].[Cities]--23272 cities

select count(distinct cityname)
from [Website].[Customers]-- 665 city name on website

select count(StateProvinceID)
from [Application].[StateProvinces]--53 states

--Sales and Order frequency by regions and cities
--The only country to deliver now is United States among all 53 states, Texas has the highest total sales 


--Sales Trends over the past three years
SELECT Top 10
    SP.StateProvinceName AS State,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE 
    YEAR(O.OrderDate) BETWEEN 2013 AND 2016
GROUP BY 
    SP.StateProvinceName
ORDER BY 
    TotalSales DESC;




--Sales Trends During Special period(Oct-Dec)

SELECT TOP 10
    C.CountryName,
    SP.StateProvinceName,
    CT.CityName,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN [Sales].[Invoices] I
ON O.OrderID=I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
JOIN 
    [Application].[Countries] C ON SP.CountryID = C.CountryID
WHERE 
    MONTH(O.OrderDate) IN (10, 11, 12) 
    AND YEAR(O.OrderDate) BETWEEN 2013 AND 2016
GROUP BY 
    C.CountryName, SP.StateProvinceName, CT.CityName
ORDER BY 
    TotalSales DESC, OrderFrequency DESC;

--Sales Trends During regular periods(Jan-Sept)
SELECT TOP 10
    C.CountryName,
    SP.StateProvinceName,
    CT.CityName,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN [Sales].[Invoices] I
ON O.OrderID=I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
JOIN 
    [Application].[Countries] C ON SP.CountryID = C.CountryID
WHERE 
    MONTH(O.OrderDate) Between 1 and 9
    AND YEAR(O.OrderDate) BETWEEN 2013 AND 2016
GROUP BY 
    C.CountryName, SP.StateProvinceName, CT.CityName
ORDER BY 
    TotalSales DESC, OrderFrequency DESC;


-- Rockwall in Texas has the highest total sales during special period
--surprisingly Alsaska is in the top 3


-- Best-Selling Products and Customer Categories in Key Cities

SELECT 
    CC.CustomerCategoryID,
	CC.CustomerCategoryName,
    CT_Postal.CityName AS PostalCity,
    SI.StockItemName AS ProductName,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    SUP.SupplierName AS SupplierName
FROM [Sales].[CustomerCategories] CC
join  
    [Sales].[Customers] CU  ON CC.customercategoryID= CU.CustomerCategoryID
JOIN 
    [Sales].[Orders] O ON CU.CustomerID = O.CustomerID
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Purchasing].[Suppliers] SUP ON SI.SupplierID = SUP.SupplierID
JOIN 
    [Application].[Cities] CT_Delivery ON CU.DeliveryCityID = CT_Delivery.CityID
JOIN 
    [Application].[Cities] CT_Postal ON CU.PostalCityID = CT_Postal.CityID
WHERE 
    MONTH(I.InvoiceDate) IN (10, 11, 12) 
GROUP BY 
    CC.CustomerCategoryID,
	CC.CustomerCategoryName,
    CT_Postal.CityName, 
    SI.StockItemName,
    SUP.SupplierName
ORDER BY 
    TotalSales DESC;

--The best seller among cities are so far the air cushion machine and the customer category is gift store
--it's assuming that gift stores require lots of packaging materials to wrap the products. 
--with a total sale of $58869 on air cusion machine and the psotal city is wanaque, New Jersey and the supplier is Litware, Inc



/*Best-Selling Products and Customer Categories During Special Seasons*/

SELECT 
    CC.CustomerCategoryID,
    CC.CustomerCategoryName,
    CT_Postal.CityName AS PostalCity,
    SI.StockItemName AS ProductName,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    SUP.SupplierName AS SupplierName
FROM 
    [Sales].[CustomerCategories] CC
JOIN  
    [Sales].[Customers] CU ON CC.CustomerCategoryID = CU.CustomerCategoryID
JOIN 
    [Sales].[Orders] O ON CU.CustomerID = O.CustomerID
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Purchasing].[Suppliers] SUP ON SI.SupplierID = SUP.SupplierID
JOIN 
    [Application].[Cities] CT_Delivery ON CU.DeliveryCityID = CT_Delivery.CityID
JOIN 
    [Application].[Cities] CT_Postal ON CU.PostalCityID = CT_Postal.CityID
WHERE 
    MONTH(O.OrderDate) IN (10, 11, 12)  -- Special seasons: October to December
    AND YEAR(O.OrderDate) BETWEEN 2013 AND 2016
GROUP BY 
    CC.CustomerCategoryID,
    CC.CustomerCategoryName,
    CT_Postal.CityName, 
    SI.StockItemName,
    SUP.SupplierName
ORDER BY 
    TotalSales DESC;

/*--During speical season, Wanaque in New Jersey has the highest total sales, the top 10 valuable customers during special period
are all supplied by Litware Inc*/


/*There is no significant difference between regular period and special period, which can indicate that novelty goods's sale won't be affected by special season
however it can seen as an opportunity to have some seasonal packaging where can sell to the customers to further use, and since gift store is where the highest
sales was generated, they might have the need to use different style of wrapping. */


/*I wonder what are the cities are require the most packaging materials, is that happened in all regions? or some regions use less packaging materials?*/

--Sales Trends by State During Special Seasons


SELECT 
    SP.StateProvinceName AS State,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE 
    MONTH(O.OrderDate) IN (10, 11, 12)  -- Special seasons: October to December
    AND YEAR(O.OrderDate) BETWEEN 2013 AND 2016
GROUP BY 
    SP.StateProvinceName
ORDER BY 
    TotalSales DESC, OrderFrequency DESC;

--Texas has the highest total sales, and highest orderfrequency. so I BREAK DOWN to see more details of each month and cities





--Top States by Total Sales DURING SPECIAL PERIOD
SELECT 
    SP.StateProvinceName AS State,
    YEAR(O.OrderDate) AS Year,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE 
    MONTH(O.OrderDate) IN (10, 11, 12) 
    AND YEAR(O.OrderDate) BETWEEN 2013 AND 2016
GROUP BY 
    SP.StateProvinceName, YEAR(O.OrderDate)
ORDER BY 
    TotalSales DESC;

--Which city in which state perform the best and order by which month has the highest sales

SELECT 
    SP.StateProvinceName AS State,
	CT.CityName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE 
    YEAR(O.OrderDate) BETWEEN 2013 AND 2016
    AND (MONTH(O.OrderDate) IN (10, 11, 12) OR MONTH(O.OrderDate) IN (1, 2))
GROUP BY 
    CT.CityName,StateProvinceName, YEAR(O.OrderDate), MONTH(O.OrderDate)
ORDER BY 
    TotalSales DESC, State, Year, Month;

--Monthly Sales Breakdown for Texas
SELECT 
    SP.StateProvinceName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE 
    SP.StateProvinceName = 'Texas'
    AND YEAR(O.OrderDate) BETWEEN 2013 AND 2016
GROUP BY 
     SP.StateProvinceName, YEAR(O.OrderDate), MONTH(O.OrderDate)
ORDER BY 
    Year, Month;

/*Key Insights:
Overall Sales Performance:

2014: Highest total sales at $1,310,411.30
2013: Second highest at $1,145,045.30
2015: Lowest of the three years but still significant at $1,104,931.05
Yearly Sales Trends:

Texas experienced its highest sales in 2014, with a decrease in sales in the following years (2013 and 2015). 
This could suggest a peak in 2014 possibly due to specific market conditions, seasonal effects, or other factors that are worth investigating further.*/


--Seasonal Sales Analysis for Texas
SELECT 
    YEAR(O.OrderDate) AS Year,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE 
    SP.StateProvinceName = 'Texas'
    AND YEAR(O.OrderDate) BETWEEN 2013 AND 2016
GROUP BY 
    YEAR(O.OrderDate)
ORDER BY 
    TotalSales DESC;

/*The data is only collected until May 2016, so the total sale of 2016 is not complete,
As the number shows the sales in 2014 is the best overall, and follow by 2015 and 2013*/


SELECT top 10
    SP.StateProvinceName AS State,
	CT.CityName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE SP.StateProvinceName = 'Texas' 
    AND YEAR(O.OrderDate) = 2013
    AND (MONTH(O.OrderDate) IN (10, 11, 12) )
GROUP BY 
    CT.CityName,StateProvinceName, YEAR(O.OrderDate), MONTH(O.OrderDate)
ORDER BY 
    TotalSales DESC, State, Year, Month;



SELECT top 10
    SP.StateProvinceName AS State,
	CT.CityName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE SP.StateProvinceName = 'Texas' 
    AND YEAR(O.OrderDate) = 2014
    AND (MONTH(O.OrderDate) IN (10, 11, 12))
GROUP BY 
    CT.CityName,StateProvinceName, YEAR(O.OrderDate), MONTH(O.OrderDate)
ORDER BY 
    TotalSales DESC, State, Year, Month;


SELECT top 10
    SP.StateProvinceName AS State,
	CT.CityName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE SP.StateProvinceName = 'Texas' 
    AND YEAR(O.OrderDate) = 2015
    AND (MONTH(O.OrderDate) IN (10, 11, 12))
GROUP BY 
    CT.CityName,StateProvinceName, YEAR(O.OrderDate), MONTH(O.OrderDate)
ORDER BY 
    TotalSales DESC, State, Year, Month;


	--2013 and 2015 have pretty simliar monthly sales, whiel 2014 has the highest compare to the other two yeas, there might be something happen that year to boost the sales.
	--Check the best selling product in 2014
SELECT top 10
    SP.StateProvinceName AS State,
	CT.CityName,
	SI.StockItemID,
	StockItemName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE SP.StateProvinceName = 'Texas' 
    AND YEAR(O.OrderDate) = 2014
    AND (MONTH(O.OrderDate) IN (10, 11, 12))
GROUP BY 
    CT.CityName,StateProvinceName, YEAR(O.OrderDate), MONTH(O.OrderDate),
	SI.StockItemID,
	StockItemName
ORDER BY 
    TotalSales DESC, State, Year, Month;



SELECT top 10
    SP.StateProvinceName AS State,
	CT.CityName,
	SI.StockItemID,
	StockItemName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE SP.StateProvinceName = 'Texas' 
    AND YEAR(O.OrderDate) = 2014
    AND (MONTH(O.OrderDate) not IN (10, 11, 12))
GROUP BY 
    CT.CityName,StateProvinceName, YEAR(O.OrderDate), MONTH(O.OrderDate),
	SI.StockItemID,
	StockItemName
ORDER BY 
    TotalSales DESC, State, Year, Month;



--Special Period in 2014
SELECT top 10
    SP.StateProvinceName AS State,
	CT.CityName,
	SI.StockItemID,
	StockItemName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE 
   YEAR(O.OrderDate) = 2014
    AND (MONTH(O.OrderDate) IN (10, 11, 12))
GROUP BY 
    CT.CityName,StateProvinceName, YEAR(O.OrderDate), MONTH(O.OrderDate),
	SI.StockItemID,
	StockItemName
ORDER BY 
    TotalSales DESC, State, Year, Month;

--Regular period in 2014

SELECT top 10
    SP.StateProvinceName AS State,
	CT.CityName,
	SI.StockItemID,
	StockItemName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE 
   YEAR(O.OrderDate) = 2014
    AND (MONTH(O.OrderDate) not IN (10, 11, 12))
GROUP BY 
    CT.CityName,StateProvinceName, YEAR(O.OrderDate), MONTH(O.OrderDate),
	SI.StockItemID,
	StockItemName
ORDER BY 
    TotalSales DESC, State, Year, Month;


--Additional understanding of May since it has a high sale figure

--Comparison between 2013-2015 May
SELECT top 10
    SP.StateProvinceName AS State,
	CT.CityName,
	SI.StockItemID,
	StockItemName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE SP.StateProvinceName = 'Texas' 
    AND YEAR(O.OrderDate) Between 2013 and 2015
    AND (MONTH(O.OrderDate) =5)
GROUP BY 
    CT.CityName,StateProvinceName, YEAR(O.OrderDate), MONTH(O.OrderDate),
	SI.StockItemID,
	StockItemName
ORDER BY 
    TotalSales DESC, State, Year, Month;


SELECT top 10
    SP.StateProvinceName AS State,
	CT.CityName,
	SI.StockItemID,
	StockItemName,
    YEAR(O.OrderDate) AS Year,
    MONTH(O.OrderDate) AS Month,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    COUNT(DISTINCT O.OrderID) AS OrderFrequency
FROM 
    [Sales].[Orders] O
JOIN 
    [Sales].[Invoices] I ON O.OrderID = I.OrderID
JOIN 
    [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
JOIN 
    [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID
JOIN 
    [Sales].[Customers] CU ON O.CustomerID = CU.CustomerID
JOIN 
    [Application].[Cities] CT ON CU.PostalCityID = CT.CityID
JOIN 
    [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID
WHERE YEAR(O.OrderDate) Between 2013 and 2015
    AND (MONTH(O.OrderDate) =5)
GROUP BY 
    CT.CityName,StateProvinceName, YEAR(O.OrderDate), MONTH(O.OrderDate),
	SI.StockItemID,
	StockItemName
ORDER BY 
    TotalSales DESC, State, Year, Month;
