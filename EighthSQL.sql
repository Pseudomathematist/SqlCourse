SELECT Products.ProductID, Products.ProductName, Categories.CategoryName FROM Products, Categories WHERE Products.CategoryID = Categories.CategoryID;
SELECT Products.ProductName, [Order Details].UnitPrice FROM Products, [Order Details] WHERE Products.ProductID = [Order Details].ProductID AND [Order Details].UnitPrice < 20;
SELECT Products.ProductName, [Order Details].UnitPrice, Categories.CategoryName FROM Products, [Order Details], Categories WHERE Products.ProductID = [Order Details].ProductID AND [Order Details].UnitPrice < 20 
AND Products.CategoryID = Categories.CategoryID;
