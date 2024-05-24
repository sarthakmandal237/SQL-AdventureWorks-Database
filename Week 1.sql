AdventureWorks Database:

  Level A Task Answers:
  
-- 1. List of all customers.
  SELECT * FROM Sales.Customer;

-- 2.List of all customers where company name ending in N.

SELECT * FROM Sales.Customer
WHERE CompanyName LIKE '%N';

-- 3.List of all customers who live in Berlin or London.

SELECT * FROM Sales.Customer
JOIN Person.Address ON Sales.Customer.AddressID = Person.Address.AddressID
WHERE City IN ('Berlin', 'London');

-- 4.List of all customers who live in UK or USA.

SELECT * FROM Sales.Customer
JOIN Person.Address ON Sales.Customer.AddressID = Person.Address.AddressID
JOIN Person.CountryRegion ON Person.Address.CountryRegionCode = Person.CountryRegion.CountryRegionCode
WHERE CountryRegion.Name IN ('United Kingdom', 'United States');

-- 5.List of all products sorted by product name.

SELECT * FROM Production.Product
ORDER BY Name;

-- 6.List of all products where product name starts with an A.

SELECT * FROM Production.Product
WHERE Name LIKE 'A%';

-- 7.List of customers who ever placed an order.

SELECT DISTINCT Sales.Customer.*
FROM Sales.Customer
JOIN Sales.SalesOrderHeader ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID;

-- 8.List of Customers who live in London and have bought chai.

SELECT DISTINCT Sales.Customer.*
FROM Sales.Customer
JOIN Person.Address ON Sales.Customer.AddressID = Person.Address.AddressID
JOIN Sales.SalesOrderHeader ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
WHERE Person.Address.City = 'London'
AND Production.Product.Name = 'Chai';

-- 9.List of customers who never place an order.

SELECT * FROM Sales.Customer
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Sales.SalesOrderHeader);

-- 10.List of customers who ordered Tofu.

SELECT DISTINCT Sales.Customer.*
FROM Sales.Customer
JOIN Sales.SalesOrderHeader ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
WHERE Production.Product.Name = 'Tofu';

-- 11.Details of first order of the system.

SELECT TOP 1 * FROM Sales.SalesOrderHeader
ORDER BY OrderDate ASC;

-- 12.Find the details of most expensive order date.

SELECT TOP 1 OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

-- 13.For each order get the OrderID and Average quantity of items in that order.

SELECT SalesOrderID, AVG(OrderQty) AS AvgQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

-- 14.For each order get the orderID, minimum quantity and maximum quantity for that order.

SELECT SalesOrderID, MIN(OrderQty) AS MinQuantity, MAX(OrderQty) AS MaxQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

-- 15.List of all managers and total number of employees who report to them.

SELECT Manager.EmployeeID AS ManagerID, COUNT(Employee.EmployeeID) AS ReportCount
FROM HumanResources.Employee AS Employee
JOIN HumanResources.Employee AS Manager ON Employee.ManagerID = Manager.EmployeeID
GROUP BY Manager.EmployeeID;

-- 16.Get the OrderID and the total quantity for each order that has a total quantity of greater than 300.

SELECT SalesOrderID, SUM(OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;

-- 17.List of all orders placed on or after 1996/12/31.

SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';

-- 18.List of all orders shipped to Canada.

SELECT * FROM Sales.SalesOrderHeader
WHERE ShipToAddressID IN (SELECT AddressID FROM Person.Address WHERE CountryRegionCode = 'CA');

-- 19.List of all orders with order total > 200.

SELECT * FROM Sales.SalesOrderHeader
WHERE TotalDue > 200;

-- 20.List of countries and sales made in each country.

SELECT CountryRegion.Name, SUM(SalesOrderHeader.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
JOIN Person.Address ON Sales.SalesOrderHeader.ShipToAddressID = Person.Address.AddressID
JOIN Person.CountryRegion ON Person.Address.CountryRegionCode = Person.CountryRegion.CountryRegionCode
GROUP BY CountryRegion.Name;

-- 21.List of Customer ContactName and number of orders they placed.

SELECT ContactName, COUNT(SalesOrderHeader.SalesOrderID) AS OrderCount
FROM Sales.Customer
JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
JOIN Sales.SalesOrderHeader ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
GROUP BY ContactName;

-- 22.List of customer contactnames who have placed more than 3 orders.

SELECT ContactName
FROM Sales.Customer
JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
JOIN Sales.SalesOrderHeader ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
GROUP BY ContactName
HAVING COUNT(SalesOrderHeader.SalesOrderID) > 3;

-- 23.List of discontinued products which were ordered between 1/1/1997 and 1/1/1998

SELECT DISTINCT Product.Name
FROM Production.Product
JOIN Sales.SalesOrderDetail ON Production.Product.ProductID = Sales.SalesOrderDetail.ProductID
JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
WHERE Product.DiscontinuedDate IS NOT NULL
AND Sales.SalesOrderHeader.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

-- 24.List of employee firstname, lastname, supervisor FirstName, LastName.

SELECT Employee.FirstName AS EmployeeFirstName, Employee.LastName AS EmployeeLastName,
       Supervisor.FirstName AS SupervisorFirstName, Supervisor.LastName AS SupervisorLastName
FROM HumanResources.Employee AS Employee
JOIN HumanResources.Employee AS Supervisor ON Employee.ManagerID = Supervisor.EmployeeID;

-- 25.List of Employees id and total sale conducted by employee.

SELECT SalesPersonID, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY SalesPersonID;

-- 26.List of employees whose FirstName contains character a.

SELECT * FROM HumanResources.Employee
WHERE FirstName LIKE '%a%';

-- 27.List of managers who have more than four people reporting to them.

SELECT ManagerID
FROM HumanResources.Employee
GROUP BY ManagerID
HAVING COUNT(EmployeeID) > 4;

-- 28.List of Orders and ProductNames.

SELECT SalesOrderHeader.SalesOrderID, Product.Name AS ProductName
FROM Sales.SalesOrderHeader
JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID;

-- 29.List of orders placed by the best customer.

SELECT SalesOrderID
FROM Sales.SalesOrderHeader
WHERE CustomerID = (
    SELECT TOP 1 CustomerID
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
    ORDER BY SUM(TotalDue) DESC
);

-- 30.List of orders placed by customers who do not have a Fax number.

SELECT SalesOrderHeader.*
FROM Sales.SalesOrderHeader
JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
WHERE Sales.Customer.Fax IS NULL;

-- 31.List of Postal codes where the product Tofu was shipped.

SELECT DISTINCT Person.Address.PostalCode
FROM Sales.SalesOrderHeader
JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
JOIN Person.Address ON Sales.SalesOrderHeader.ShipToAddressID = Person.Address.AddressID
WHERE Production.Product.Name = 'Tofu';

-- 32.List of product Names that were shipped to France.

SELECT DISTINCT Production.Product.Name
FROM Sales.SalesOrderHeader
JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
JOIN Person.Address ON Sales.SalesOrderHeader.ShipToAddressID = Person.Address.AddressID
WHERE Person.Address.CountryRegionCode = 'FR';

-- 33.List of ProductNames and Categories for the supplier 'Specialty Biscuits, Ltd.'

SELECT Production.Product.Name AS ProductName, Production.ProductCategory.Name AS CategoryName
FROM Production.Product
JOIN Production.ProductVendor ON Production.Product.ProductID = Production.ProductVendor.ProductID
JOIN Purchasing.Vendor ON Production.ProductVendor.BusinessEntityID = Purchasing.Vendor.BusinessEntityID
JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
JOIN Production.ProductCategory ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID
WHERE Purchasing.Vendor.Name = 'Specialty Biscuits, Ltd.';

-- 34.List of products that were never ordered.

SELECT * FROM Production.Product
WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM Sales.SalesOrderDetail);

-- 35.List of products where units in stock is less than 10 and units on order are 0.

SELECT * FROM Production.ProductInventory
WHERE Quantity < 10 AND SafetyStockLevel = 0;

-- 36.List of top 10 countries by sales.

SELECT TOP 10 CountryRegion.Name, SUM(SalesOrderHeader.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
JOIN Person.Address ON Sales.SalesOrderHeader.ShipToAddressID = Person.Address.AddressID
JOIN Person.CountryRegion ON Person.Address.CountryRegionCode = Person.CountryRegion.CountryRegionCode
GROUP BY CountryRegion.Name
ORDER BY TotalSales DESC;

-- 37.Number of orders each employee has taken for customers with CustomerIDs between A and AO.

SELECT SalesPersonID, COUNT(SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader
WHERE CustomerID BETWEEN 'A' AND 'AO'
GROUP BY SalesPersonID;

-- 38.Orderdate of most expensive order.

SELECT TOP 1 OrderDate
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

-- 39.Product name and total revenue from that product.

SELECT Product.Name, SUM(SalesOrderDetail.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail
JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
GROUP BY Product.Name;

-- 40.SupplierID and number of products offered.

SELECT VendorID, COUNT(ProductID) AS NumberOfProducts
FROM Production.ProductVendor
GROUP BY VendorID;

-- 41.Top ten customers based on their business.

SELECT TOP 10 Sales.Customer.CustomerID, SUM(SalesOrderHeader.TotalDue) AS TotalBusiness
FROM Sales.Customer
JOIN Sales.SalesOrderHeader ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
GROUP BY Sales.Customer.CustomerID
ORDER BY TotalBusiness DESC;

-- 42.What is the total revenue of the company.

SELECT SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader;
