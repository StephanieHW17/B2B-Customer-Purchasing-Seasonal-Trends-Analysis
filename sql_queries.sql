--Task A Write SQL statements for the following to perform this descriptive analysis.


/*--1. [4 marks] What is the average order value for each customer who made purchases in 2016? Include the 
customer's ID, full name, and average order value (rounded to two decimal places) in the results. Order 
the results appropriately to quickly identify the customers with the highest average spending per order. 
*/

--First try 
/*
select C.CustomerID, CustomerName, avg(OL.Quantity*OL.UnitPrice) as [Average Spending], OrderDate
from [Sales].[Customers] C
Join [Sales].[Orders] O
on c.CustomerID=o.CustomerID
join [Sales].[OrderLines] OL
on O.OrderID=OL.OrderID
Where O.OrderDate between '2016-01-01' and '2016-12-31'
Group by C.CustomerID, CustomerName, OrderDate
Order by [Average Spending] DESC
*/


--Missing rounding two decimal and grouping the wrong column


/*
select C.CustomerID, CustomerName, Round(avg(OL.Quantity*OL.UnitPrice),2) as [Average Spending]
from [Sales].[Customers] C
Join (
        SELECT 
            O.OrderID, 
            O.CustomerID 
        FROM 
            [Sales].[Orders] O 
        WHERE 
            O.OrderDate BETWEEN '2016-01-01' AND '2016-12-31'
    ) AS FilteredOrders 
	ON C.CustomerID = FilteredOrders.CustomerID

join [Sales].[OrderLines] OL
on FilteredOrders.OrderID = OL.OrderID
Group by C.CustomerID, CustomerName
Order by [Average Spending] DESC
*/

/* 
I started by identifying the relevant tables for CustomerID, customer names, and order values. After consulting the metadata,
I determined that the Customers, Orders, and OrderLines tables were necessary. 
I calculated the total order value by multiplying Quantity by UnitPrice and used the AVG function to find the average spending per customer. 
Initially, I grouped by CustomerID, CustomerName, and OrderDate, but the results were incorrect because of the grouping by OrderDate.
To resolve this issue, I consult ChatGPT for clarification and was advised to remove OrderDate from the GROUP BY clause and use a subquery to filter orders from 2016.
After implementing these changes, the results were more accurate and aligned with the question requirements.
*/



-----------------------------------------------------------------------------------------------------------------------------------



/*2. [4 marks] Which stock groups have generated the highest total sales between January 1, 2014, and 
December 31, 2016? Include the stock group ID, stock group name, and total sales amount in your 
results. Order the results suitably to identify the top-performing stock groups. */



--First try

/*

select SG.StockGroupID, SG.StockGroupName, SUM(SI.unitprice*ST.Quantity) as [total sales amont]
from [Warehouse].[StockGroups]  SG
JOIN [Warehouse].[StockItemStockGroups] SSG
ON SG.StockGroupID=SSG.StockGroupID 
JOIN [Warehouse].[StockItems] SI
ON SSG.StockItemID=SI.StockItemID
JOIN [Warehouse].[StockItemTransactions] ST
ON SI.StockItemID=ST.StockItemID
WHERE SG.ValidFrom BETWEEN '2014-01-01' AND '2016-12-31'
GROUP BY SG.StockGroupID,SG.StockGroupName
Order by [total sales amont] desc

*/


/*missing details such as checking if the quanitity is negative or positive and adding absolute to change it to positive value*/


-- Check for negative UnitPrice
SELECT DISTINCT SI.UnitPrice
FROM [Warehouse].[StockItems] SI
WHERE SI.UnitPrice < 0;

-- Check for negative Quantities
SELECT DISTINCT ST.Quantity
FROM [Warehouse].[StockItemTransactions] ST
WHERE ST.Quantity < 0


Select 
	sg.StockGroupID [Stock Group ID], 
	sg.StockGroupName [Stock Group Name], 
	SUM(il.quantity * il.UnitPrice) AS [Total Sales]
From sales.InvoiceLines il
Join sales.Invoices i
	on il.InvoiceID = i.InvoiceID
Join sales.Customers c
	on c.CustomerID = i.CustomerID
Join Warehouse.StockItems si
	on il.StockItemID = si.StockItemID
Join Warehouse.StockItemStockGroups sisg
	on sisg.StockItemID = si.StockItemID
Join Warehouse.StockGroups sg
	on sg.StockGroupID = sisg.StockGroupID
Where i.InvoiceDate between '2014-01-01' and '2016-12-31'
Group by sg.StockGroupID, sg.StockGroupName
Order by [Total Sales] DESC;


/*
When working on this question, I identified key terms like "stock," "stock group," and "sales amount," and referred to the schema diagram to locate the relevant columns. 
After identifying the necessary tables, I examined their relationships through foreign keys. Initially, when I ran the query, the total sales amount appeared negative. 
To clarify this, I consulted ChatGPT, which pointed out that I should filter the data using the transaction date instead of the valid date.
Additionally, I referred to the table details for this question and discovered that the Quantity field contained negative values, representing outgoing stock. 
ChatGPT suggested using the ABS function to convert these negative values to positive, accurately reflecting sales amounts. 
After adjusting the WHERE clause and applying the ABS function, I was able to generate the correct results as expected.
 */

 ---------------------------------------------------------------------------------------------------------------------------

/*3.List all suppliers, displaying the total sales amount for their items (if any), and order the 
suppliers by the total sales amount in descending order, ensuring that suppliers with no sales are shown 
with a total sales amount of zero. */

/*
I began by carefully reading the question to identify key terms and refer to diagram to 
understand table relationships, particularly the foreign keys. 
Initially, I explored the necessary tables by selecting all columns to verify the relevant data. 
I faced challenges in filtering and displaying a SUM result as zero for suppliers with no sales. 
*/

--First attempt

/*
SELECT 
	S.SupplierID, 
	S.SupplierName [Supplier Name], 
	SUM( IL.quantity * IL.unitprice) as [Total Sales amount]
FROM Purchasing.Suppliers S
LEFT JOIN Warehouse.StockItems WS  ON s.SupplierID = WS.SupplierID
LEFT JOIN Sales.InvoiceLines IL    ON WS.StockItemID = IL.StockItemID
GROUP BY S.SupplierID, S.SupplierName
ORDER BY [Total Sales amount] DESC;

*/



--After adding Coalesce to change the nulls to 0


SELECT 
	S.SupplierID, 
	S.SupplierName [Supplier Name], 
	COALESCE(SUM( IL.quantity * IL.unitprice),0) as [Total Sales amount]
FROM Purchasing.Suppliers S
LEFT JOIN Warehouse.StockItems WS  ON s.SupplierID = WS.SupplierID
LEFT JOIN Sales.InvoiceLines IL    ON WS.StockItemID = IL.StockItemID
GROUP BY S.SupplierID, S.SupplierName
ORDER BY [Total Sales amount] DESC;

/*
After considering different approaches like subqueries or CASE statements, 
I consulted with ChatGPT. The suggestion to use COALESCE to handle NULL values and ensure all suppliers
were displayed using a LEFT JOIN resolved my issues efficiently. 
*/


-----------------------------------------------------------------------------------------------------------------------------------


/*4.List all delivery methods and usage counts in sales invoices and purchase orders. Return the 
delivery method ID, delivery method name, and the counts of their usage in both sales and purchasing. */

/*
Before writing the query, I review the diagram and draft the query in a text editor 
to visualize table relationships and relevant columns. 
I begin by selecting all data from the tables involved to identify useful fields.
I then attempt to join the relevant tables to test if the join operations work correctly.
*/

--First try

/*
Select DM.DeliveryMethodID,
       DM.DeliveryMethodName, 
       COUNT(PO.DeliveryMethodId) as [usage counts in sales invoices] ,
       Count(I.DeliveryMethodID) as [usage counts in purchasing orders]
From [Application].[DeliveryMethods] DM
Join [Purchasing].[PurchaseOrders] PO on DM.DeliveryMethodID=PO.DeliveryMethodID
Join [Sales].[Invoices] I on PO.DeliveryMethodID=I.DeliveryMethodID
Group by DM.DeliveryMethodID,
DM.DeliveryMethodName

*/

/*
In my initial query, the results there was no result come out. 
Hence, I rechecked the table connections. 
However, I still faced issues, prompting me to seek help from ChatGPT. 
The advice was to use COUNT([PrimaryKey]) rather than COUNT([DeliveryMethodID]) 
because counting only the delivery method ID would not accurately reflect usage and it will only show 0 and 1. 
Applying this advice,I adjusted the query to count primary keys, 
which resolved the issue and provided accurate results.
*/

--Chatgpt suggestion

Select DM.DeliveryMethodID,
       DM.DeliveryMethodName, 
       COUNT(I.InvoiceID) as [usage counts in sales invoices] ,
       Count(Po.PurchaseOrderID) as [usage counts in purchasing orders]
 From [Purchasing].[PurchaseOrders] PO
Right Join [Application].[DeliveryMethods] DM on PO.DeliveryMethodID=DM.DeliveryMethodID-- Ensure the value of Delivery Method can all be listed out
Left Join [Sales].[Invoices] I on DM.DeliveryMethodID=I.DeliveryMethodID
Group by DM.DeliveryMethodID,
         DM.DeliveryMethodName



/*5. Identify which customers purchased the most diverse range of products in 2016, and the total 
amount they spent.  Include the number of unique products each customer has bought, and the total 
amount spent in the results to demonstrate the diversity of products. Order and filter the result set in a 
suitable manner to find the top 10 high-value customers.  */

/*
To identify which customers purchased the most diverse range of products in 2016 and their total spending, 
I began by reviewing the database diagram to locate the StockItems table for product details. 
I linked this with the Sales.Invoices table to calculate the total spending and count of unique products. 
My initial query did not produce the expected results as it counted entries without properly addressing unique products
and lacked a filter for the year 2016.
*/

/*First try
SELECT TOP 10 
    c.CustomerID,
    c.CustomerName,
	StockitemName,
   SUM(IL. Quantity * IL.UnitPrice) AS [Total Spending]
FROM 
    [Warehouse].[StockItems] SI
JOIN Sales.InvoiceLines IL ON SI.stockitemID=IL.StockitemID
JOIN Sales.Invoices inv ON il.InvoiceID = inv.InvoiceID
JOIN Sales.Customers c ON inv.CustomerID = c.CustomerID
GROUP BY 
    c.CustomerID, c.CustomerName,StockitemName
ORDER BY 
    [Total Spending] DESC;
*/

/*
However, my first try did not give me the proper result of different kinds of products there is only one
so I read the question again and found I need to count stockitemID to know the number of product and also
make every count unique
*/

/*
SELECT TOP 10 
    c.CustomerID,
    c.CustomerName,
    count(distinct il. StockItemID ) as [Product Number] ,
	stockitemname,
   SUM(IL. Quantity * IL.UnitPrice) AS [Total Spending]
FROM 
    [Warehouse].[StockItems] SI
JOIN Sales.InvoiceLines IL ON SI.stockitemID=IL.StockitemID
JOIN Sales.Invoices inv ON il.InvoiceID = inv.InvoiceID
JOIN Sales.Customers c ON inv.CustomerID = c.CustomerID
GROUP BY 
    c.CustomerID, c.CustomerName, StockItemName
ORDER BY 
    [Total Spending] DESC;
*/

/*
I realized that counting distinct StockItemID values was necessary to measure product diversity correctly.
I also needed to include a WHERE clause to filter for 2016. In my second attempt,
I included the StockItemName column, which was unnecessary and complicated the grouping.
I found that excluding this column will simplify the query and improved accuracy. 
*/

SELECT TOP 10 
    c.CustomerID,
    c.CustomerName,
    count(distinct il. StockItemID ) as [Product Number] ,
   SUM(IL. Quantity * IL.UnitPrice) AS [Total Spending]
FROM 
    [Warehouse].[StockItems] SI
JOIN Sales.InvoiceLines IL ON SI.stockitemID=IL.StockitemID
JOIN Sales.Invoices inv ON il.InvoiceID = inv.InvoiceID
JOIN Sales.Customers c ON inv.CustomerID = c.CustomerID
Where year(Inv.InvoiceDate) = 2016
GROUP BY 
    c.CustomerID, c.CustomerName
ORDER BY 
    [Total Spending] DESC;	




/*After adding the where clause and exclude the stockitem name column 
I can finally get the result that I want, since this question is similiar to one of my EDA questions,
initially I just use that query and made changes on it. However, after the final result, they don't look
at similiar so i've also learn to read the table and quesiton more deeply. */





/*6. [7 marks] Modify your query from question 5) above to display the details of these purchases for the 
top 5 high-value customers.  Include in your results the customer's ID and full name, the product IDs 
and names, the number of orders for each product, the total quantity ordered, and the total amount spent 
on each product. */

--First try

/*SELECT TOP 5 
    c.CustomerID,
    c.CustomerName,
    count(distinct il. StockItemID ) as [Product Number] ,
	SI.StockItemName as [Product Name],
	Sum(IL.Quantity) as [Total Quantity],
   SUM(IL. Quantity * IL.UnitPrice) AS [Total Spending]
FROM sales.Customers AS C
JOIN sales.Invoices AS I
    ON C.CustomerID = I.CustomerID
JOIN sales.InvoiceLines AS IL
    ON I.InvoiceID = IL.InvoiceID
JOIN Warehouse.StockItems SI
    ON IL.StockItemID = SI.StockItemID
WHERE YEAR(I.InvoiceDate) = 2016
GROUP BY 
    c.CustomerID, c.CustomerName
ORDER BY 
    [Total Spending] DESC;	
*/

/*
When I began modifying the query, I initially changed the top 10 to top 5 and added additional columns but overlooked adding StockItemName to the GROUP BY clause, 
which resulted in an error. The initial result only provided details for individual columns without aggregating data for each customer. Realizing this, 
I decided to consult ChatGPT for guidance. I asked whether a subquery was necessary and where it should be placed.
Although I knew a subquery could help, I wasn¡¦t fully sure how it worked.
*/

--Second Attempt after Chatgpt

/*SELECT  
    c.CustomerID,
    c.CustomerName,
    count(distinct il. StockItemID ) as [Product Number] ,
	SI.StockItemID as [Product ID]
	SI.StockItemName as [Product Name],
	Sum(IL.Quantity) as [Total Quantity],
   SUM(IL. Quantity * IL.UnitPrice) AS [Total Spending]
FROM sales.Customers AS C
JOIN sales.Invoices AS I
    ON C.CustomerID = I.CustomerID
JOIN sales.InvoiceLines AS IL
    ON I.InvoiceID = IL.InvoiceID
JOIN Warehouse.StockItems SI
    ON IL.StockItemID = SI.StockItemID
WHERE YEAR(I.InvoiceDate) = 2016
and c.CustomerID in 
    (SELECT TOP 5 
    c.CustomerID,
    c.CustomerName,
    count(distinct il. StockItemID ) as [Product Number] ,
   SUM(IL. Quantity * IL.UnitPrice) AS [Total Spending]
FROM 
    [Warehouse].[StockItems] SI
JOIN Sales.InvoiceLines IL ON SI.stockitemID=IL.StockitemID
JOIN Sales.Invoices inv ON il.InvoiceID = inv.InvoiceID
JOIN Sales.Customers c ON inv.CustomerID = c.CustomerID
Where year(Inv.InvoiceDate) = 2016
GROUP BY 
    c.CustomerID, c.CustomerName,SI.StockItemID, SI.StockItemName
ORDER BY 
    [Total Spending] DESC
	) 
GROUP BY 
    c.CustomerID, c.CustomerName,SI.StockItemID,StockItemName
ORDER BY 
    [Total Spending] DESC;	
*/


/*This question was particularly challenging, as I encountered repeated errors, 
including one that said, "Only one expression can be specified in the select list when the subquery is not introduced with EXISTS.
" I didn¡¦t understand what this meant or how to fix it, so I sought further help. 
ChatGPT advised me to keep only CustomerID in the subquery after IN since only one column is allowed there. 
I followed this guidance, but I still faced another issue with a "StockItemName not exists" error. 
ChatGPT pointed out a typo in my code, and after fixing it, I finally obtained the correct result.
*/

SELECT 
    C.CustomerID,
    C.CustomerName AS [Full Name],
    IL.StockItemID AS [Product ID],
    SI.StockItemName AS [Product Name],
    COUNT(DISTINCT IL.InvoiceID) AS [Number of Orders],
    SUM(IL.Quantity) AS [Total Quantity Ordered],
    SUM(IL.Quantity * IL.UnitPrice) AS [Total Spending]
FROM sales.Customers AS C
JOIN sales.Invoices AS I
    ON C.CustomerID = I.CustomerID
JOIN sales.InvoiceLines AS IL
    ON I.InvoiceID = IL.InvoiceID
JOIN Warehouse.StockItems SI
    ON IL.StockItemID = SI.StockItemID
WHERE YEAR(I.InvoiceDate) = 2016
    AND C.CustomerID IN 
    (
        SELECT TOP (5) C.CustomerID
        FROM sales.Customers C
        JOIN sales.Invoices I
            ON C.CustomerID = I.CustomerID
        JOIN sales.InvoiceLines IL
            ON I.InvoiceID = IL.InvoiceID
        WHERE YEAR(I.InvoiceDate) = 2016
        GROUP BY C.CustomerID, C.CustomerName
        ORDER BY SUM(IL.UnitPrice * IL.Quantity) DESC
    )
GROUP BY C.CustomerID, C.CustomerName, IL.StockItemID, SI.StockItemName
ORDER BY C.CustomerID, [Total Spending] DESC;





-----Task C EDA QUESTIONS


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



