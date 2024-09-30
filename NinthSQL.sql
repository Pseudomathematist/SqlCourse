SELECT t1.CustomerID, t2.CustomerID FROM Customers t1, Customers t2 WHERE (t1.Region IS NULL) AND (t2.Region IS NULL);
SELECT * FROM Orders WHERE CustomerID = ANY(SELECT CustomerID FROM Customers WHERE Region IS NOT NULL);
SELECT * FROM Orders WHERE Freight > ALL(SELECT UnitPrice FROM Products); 
