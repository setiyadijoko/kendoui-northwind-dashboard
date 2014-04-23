USE [Northwind]
GO
/****** Object:  StoredProcedure [dbo].[TopSellingProducts]    Script Date: 4/23/2014 16:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TopSellingProducts]  
AS
BEGIN 
	SET NOCOUNT ON; 
	SELECT Products.ProductName, Sales.Date, SUM(Sales.EmployeeSales) AS Quantity FROM
		(
			SELECT  [Order Details].ProductID, 
					SUM(Quantity)  AS EmployeeSales,  
					DATEFROMPARTS(DATEPART(YEAR, Orders.OrderDate), DATEPART(MONTH, Orders.OrderDate), 1) AS Date
			FROM [Order Details]
				INNER JOIN Orders ON Orders.OrderID = [Order Details].OrderID
			GROUP BY [Order Details].ProductID, DATEFROMPARTS(DATEPART(YEAR, Orders.OrderDate), DATEPART(MONTH, Orders.OrderDate), 1) 
		) AS Sales 
		INNER JOIN Products ON Products.ProductID = Sales.ProductID
	WHERE Sales.ProductID IN (
		SELECT TOP 5 Sales.ProductID  FROM
			(
				SELECT  [Order Details].ProductID, 
						SUM(Quantity)  AS EmployeeSales
				FROM [Order Details]
					INNER JOIN Orders ON Orders.OrderID = [Order Details].OrderID
				GROUP BY [Order Details].ProductID
			) AS Sales 
		GROUP BY Sales.ProductID
		ORDER BY SUM(Sales.EmployeeSales) DESC
	)
	GROUP BY Sales.Date, Products.ProductName
	ORDER BY SUM(Sales.EmployeeSales) DESC
END
