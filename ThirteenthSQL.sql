UPDATE [Order Details] SET UnitPrice = 0.2 WHERE Quantity > 50;
UPDATE Contacts SET Country = 'Russia', City = 'Piter' WHERE Country = 'Germany' AND City = 'Berlin';
INSERT INTO Shippers (CompanyName) VALUES ('Yandex');
INSERT INTO Shippers (CompanyName) VALUES ('Yandex1');
DELETE FROM Shippers WHERE ShipperID > 3;
