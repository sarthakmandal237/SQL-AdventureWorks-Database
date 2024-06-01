--STORED PROCEDURES

-- InsertOrderDetails
CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(10, 2) = NULL,
    @Quantity INT,
    @Discount DECIMAL(5, 2) = 0
AS
BEGIN
    DECLARE @rowcount INT;

    -- Set UnitPrice if not provided
    IF @UnitPrice IS NULL
    BEGIN
        SELECT @UnitPrice = UnitPrice FROM Products WHERE ProductID = @ProductID;
    END


    -- Insert Order Detail
    INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

    SET @rowcount = @@ROWCOUNT;

    IF @rowcount = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    -- Adjust UnitsInStock
    DECLARE @UnitsInStock INT, @ReorderLevel INT;
    SELECT @UnitsInStock = UnitsInStock, @ReorderLevel = ReorderLevel
    FROM Products WHERE ProductID = @ProductID;

    IF @UnitsInStock < @Quantity
    BEGIN
        PRINT 'Not enough stock available.';
        RETURN;
    END

    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;

    SELECT @UnitsInStock = UnitsInStock FROM Products WHERE ProductID = @ProductID;
    IF @UnitsInStock < @ReorderLevel
    BEGIN
        PRINT 'Warning: Stock below reorder level.';
    END
END
GO

-- UpdateOrderDetails
CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(10, 2) = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(5, 2) = NULL
AS
BEGIN
    -- Update Order Details
    UPDATE OrderDetails
    SET 
        UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        Quantity = ISNULL(@Quantity, Quantity),
        Discount = ISNULL(@Discount, Discount)
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    -- Adjust UnitsInStock if Quantity is updated
    IF @Quantity IS NOT NULL
    BEGIN
        DECLARE @OriginalQuantity INT;
        SELECT @OriginalQuantity = Quantity FROM OrderDetails WHERE OrderID = @OrderID AND ProductID = @ProductID;

        UPDATE Products
        SET UnitsInStock = UnitsInStock + @OriginalQuantity - @Quantity
        WHERE ProductID = @ProductID;
    END
END
GO

      

-- GetOrderDetails
CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM OrderDetails WHERE OrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist.';
        RETURN 1;
    END

    SELECT * FROM OrderDetails WHERE OrderID = @OrderID;
END
GO



-- DeleteOrderDetails
CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
    BEGIN
        PRINT 'Invalid OrderID.';
        RETURN -1;
    END

    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
    BEGIN
        PRINT 'Invalid ProductID.';
        RETURN -1;
    END

    DELETE FROM OrderDetails WHERE OrderID = @OrderID AND ProductID = @ProductID;
END
GO


--====================================================================================================================

--FUNCTIONS

-- Convert datetime to MM/DD/YYYY
CREATE FUNCTION ConvertToMMDDYYYY (@date datetime)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN (SELECT CONVERT(VARCHAR(10), @date, 101));
END
GO

-- Convert datetime to YYYYMMDD
CREATE FUNCTION ConvertToYYYYMMDD (@date datetime)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN (SELECT CONVERT(VARCHAR(8), @date, 112));
END
GO


--======================================================================================================================
--VIEWS

-- vwCustomerOrders
CREATE VIEW vwCustomerOrders AS
SELECT 
    c.CompanyName,
    od.OrderID,
    o.OrderDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Quantity * od.UnitPrice AS TotalPrice
FROM 
    Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    JOIN Customers c ON o.CustomerID = c.CustomerID;
GO

-- vwCustomerOrders for yesterday
CREATE VIEW vwCustomerOrders_Yesterday AS
SELECT 
    c.CompanyName,
    od.OrderID,
    o.OrderDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Quantity * od.UnitPrice AS TotalPrice
FROM 
    Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE
    o.OrderDate = CONVERT(date, GETDATE()-1);
GO

-- MyProducts
CREATE VIEW MyProducts AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.QuantityPerUnit,
    p.UnitPrice,
    s.CompanyName,
    c.CategoryName
FROM 
    Products p
    JOIN Suppliers s ON p.SupplierID = s.SupplierID
    JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE
    p.Discontinued = 0;
GO


--============================================================================================================

--TRIGGERS

-- Instead of Delete Trigger on Orders
CREATE TRIGGER trgInsteadOfDeleteOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @OrderID INT;

    SELECT @OrderID = OrderID FROM deleted;

    DELETE FROM OrderDetails WHERE OrderID = @OrderID;
    DELETE FROM Orders WHERE OrderID = @OrderID;
END
GO

-- Order Placement Trigger
CREATE TRIGGER trgOrderPlacement
ON OrderDetails
AFTER INSERT
AS
BEGIN
    DECLARE @ProductID INT, @Quantity INT, @UnitsInStock INT;

    SELECT @ProductID = ProductID, @Quantity = Quantity FROM inserted;

    SELECT @UnitsInStock = UnitsInStock FROM Products WHERE ProductID = @ProductID;

    IF @UnitsInStock < @Quantity
    BEGIN
        PRINT 'Insufficient stock to place the order.';
        ROLLBACK;
    END
    ELSE
    BEGIN
        UPDATE Products
        SET UnitsInStock = UnitsInStock
