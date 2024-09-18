SELECT * FROM Employees ORDER BY BirthDate DESC, Country;
SELECT * FROM Employees WHERE Region IS NOT NULL ORDER BY BirthDate DESC, Country;
SELECT AVG(UnitPrice), MIN(UnitPrice), MAX(UnitPrice) FROM [Order Details];
SELECT COUNT(DISTINCT City) FROM Customers;
