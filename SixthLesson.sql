SELECT ContactType, Count(ALL ContactType) FROM Contacts GROUP BY ContactType;
SELECT CategoryId, AVG(UnitPrice) AS AvgUnitPrice FROM Products GROUP BY CategoryId ORDER BY AvgUnitPrice;
