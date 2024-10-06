SELECT Customers.CustomerID FROM Customers LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID WHERE Orders.OrderID IS NULL;
SELECT ContactName, City, Country, 'Customer' As Type FROM Customers UNION SELECT ContactName, City, Country, 'Suppliers' As Type FROM Suppliers;
