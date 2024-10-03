10.4.1.
SELECT Products.ProductName, [Order Details].UnitPrice FROM Products JOIN [Order Details] ON Products.ProductID = [Order Details].ProductID WHERE [Order Details].UnitPrice < 20;
10.4.2. За счет Customers без Orders. Встречаются только один раз.
10.4.3. Примерно так(Пример с 10.4.1.):
SELECT Products.ProductName, [Order Details].UnitPrice FROM Products CROSS JOIN [Order Details] WHERE [Order Details].UnitPrice < 20 AND Products.ProductID = [Order Details].ProductID;
10.4.4.
SELECT Products.ProductName, [Order Details].UnitPrice
FROM Products JOIN [Order Details] ON 
Products.ProductID = [Order Details].ProductID
